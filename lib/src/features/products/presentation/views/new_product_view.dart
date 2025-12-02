// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/src/features/products/presentation/viewmodels/new_product_viewmodel.dart';
import 'package:flutter_app/src/features/company_profile/presentation/viewmodels/company_profile_viewmodel.dart';
import 'package:flutter_app/src/core/ui/app_snackbar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_app/src/core/config/certifications.dart';
import 'package:flutter_app/src/core/config/product_categories.dart';

class NewProductView extends StatefulWidget {
  const NewProductView({super.key, this.onCancel, this.onPublishSuccess});

  final VoidCallback? onCancel;
  final VoidCallback? onPublishSuccess;

  @override
  State<NewProductView> createState() => _NewProductViewState();
}

class _NewProductViewState extends State<NewProductView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<NewProductViewModel>();
      if (!vm.isEditing) {
        vm.resetForm();
      }
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        vm.setBrandLink('/businesses/$userId');
        try {
          context.read<CompanyProfileViewModel>().loadCompanyProfile(userId);
        } catch (_) {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewProductViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          appBar: _buildAppBar(context, vm),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: ValueKey('product_form_${vm.formVersion}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTypeSelector(vm),
                  const SizedBox(height: 20),
                  _buildBasicInfo(vm),
                  const SizedBox(height: 20),
                  if (vm.isService)
                    _buildServiceFields(vm)
                  else
                    _buildProductFields(vm),
                  const SizedBox(height: 20),
                  _buildImages(vm),
                  const SizedBox(height: 20),
                  _buildCertifications(vm),
                  const SizedBox(height: 20),
                  _buildTags(vm),
                  const SizedBox(height: 20),
                  if (!vm.isService) _buildRepairLocations(vm),
                  if (!vm.isService) const SizedBox(height: 20),
                  _buildTerms(vm),
                  const SizedBox(height: 24),
                  _buildPublishButton(context, vm),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, NewProductViewModel vm) {
    return AppBar(
      title: Text(
        vm.isEditing ? 'Editar Publicación' : 'Nueva Publicación',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, size: 20),
        ),
        onPressed: () => _handleCancel(context, vm),
        tooltip: 'Cancelar',
      ),
      actions: [
        if (!vm.isEditing)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: vm.isLoading
                  ? null
                  : () => _handlePublish(context, vm),
              icon: const Icon(Icons.publish, size: 18),
              label: const Text('Publicar'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
      elevation: 0,
      scrolledUnderElevation: 2,
    );
  }

  Future<void> _handleCancel(
    BuildContext context,
    NewProductViewModel vm,
  ) async {
    final hasData =
        vm.name.isNotEmpty ||
        vm.description.isNotEmpty ||
        vm.localImagePaths.isNotEmpty;

    if (hasData) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¿Cancelar publicación?'),
          content: const Text('Se perderán todos los datos ingresados.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Continuar editando'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    vm.resetForm();
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      if (context.mounted) context.go('/');
    }
  }

  Widget _buildTypeSelector(NewProductViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '¿Qué deseas publicar?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildTypeCard(
                icon: Icons.inventory_2_outlined,
                label: 'Producto',
                subtitle: 'Artículos físicos',
                isSelected: !vm.isService,
                onTap: () => vm.setIsService(false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeCard(
                icon: Icons.build_outlined,
                label: 'Servicio',
                subtitle: 'Actividades y trabajos',
                isSelected: vm.isService,
                onTap: () => vm.setIsService(true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withOpacity(0.5)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo(NewProductViewModel vm) {
    return _buildSection(
      icon: Icons.edit_note_outlined,
      title: 'Información Básica',
      children: [
        _buildTextField(
          initialValue: vm.name,
          label: 'Nombre',
          hint: vm.isService
              ? 'ej: Reparación de electrodomésticos'
              : 'ej: Lavadora eco-friendly',
          icon: Icons.badge_outlined,
          error: vm.fieldErrors['name'],
          onChanged: (v) => vm.name = v,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          initialValue: vm.description,
          label: 'Descripción',
          hint: 'Describe los detalles y beneficios sostenibles',
          icon: Icons.notes_rounded,
          error: vm.fieldErrors['description'],
          onChanged: (v) => vm.description = v,
          maxLines: 4,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: vm.isService ? 3 : 1,
              child: _buildTextField(
                initialValue: vm.price > 0 ? vm.price.toStringAsFixed(0) : '',
                label: 'Precio',
                hint: '0',
                icon: Icons.payments_outlined,
                error: vm.fieldErrors['price'],
                onChanged: (v) => vm.price = double.tryParse(v) ?? 0.0,
                keyboardType: TextInputType.number,
                prefix: '\$ ',
                suffix: 'CLP',
                enabled: !vm.priceOnRequest,
                isRequired: !vm.priceOnRequest,
              ),
            ),
            if (vm.isService) ...[
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    vm.priceOnRequest = !vm.priceOnRequest;
                    (context as Element).markNeedsBuild();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: vm.priceOnRequest
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: vm.priceOnRequest
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          vm.priceOnRequest
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 20,
                          color: vm.priceOnRequest
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'A convenir',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: vm.priceOnRequest
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: vm.priceOnRequest
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String? initialValue,
    required String label,
    required String hint,
    required IconData icon,
    required String? error,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? prefix,
    String? suffix,
    bool enabled = true,
    bool isRequired = false,
  }) {
    return TextFormField(
      initialValue: initialValue,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 22),
        prefixText: prefix,
        suffixText: suffix,
        errorText: error,
        alignLabelWithHint: maxLines > 1,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: enabled
            ? Theme.of(context).colorScheme.surfaceContainerLowest
            : Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildProductFields(NewProductViewModel vm) {
    return _buildSection(
      icon: Icons.inventory_2_rounded,
      title: 'Detalles del Producto',
      children: [
        _buildDropdown<String>(
          value: vm.productCategory.isEmpty ? null : vm.productCategory,
          label: 'Categoría',
          hint: 'Selecciona una categoría',
          icon: Icons.category_rounded,
          error: vm.fieldErrors['productCategory'],
          items: productCategories
              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
              .toList(),
          onChanged: (v) {
            vm.productCategory = v ?? '';
            (context as Element).markNeedsBuild();
          },
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildDropdown<String>(
          value: vm.condition.isEmpty ? null : vm.condition,
          label: 'Estado',
          hint: 'Selecciona el estado',
          icon: Icons.grade_rounded,
          error: vm.fieldErrors['condition'],
          items: productConditions
              .map(
                (cond) => DropdownMenuItem(
                  value: cond,
                  child: Row(
                    children: [
                      Icon(
                        _getConditionIcon(cond),
                        size: 18,
                        color: _getConditionColor(cond),
                      ),
                      const SizedBox(width: 8),
                      Text(cond),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            vm.condition = v ?? '';
            (context as Element).markNeedsBuild();
          },
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildDropdown<int>(
          value: vm.warrantyMonths == 0 ? null : vm.warrantyMonths,
          label: 'Garantía',
          hint: 'Sin garantía',
          icon: Icons.verified_user_rounded,
          items: [
            const DropdownMenuItem(value: null, child: Text('Sin garantía')),
            ...warrantyMonths.map(
              (months) => DropdownMenuItem(
                value: months,
                child: Text(
                  months >= 12
                      ? '${months ~/ 12} ${(months ~/ 12) == 1 ? 'año' : 'años'}'
                      : '$months ${months == 1 ? 'mes' : 'meses'}',
                ),
              ),
            ),
          ],
          onChanged: (v) {
            vm.warrantyMonths = v ?? 0;
            (context as Element).markNeedsBuild();
          },
        ),
      ],
    );
  }

  IconData _getConditionIcon(String condition) {
    switch (condition) {
      case 'Nuevo':
        return Icons.fiber_new_rounded;
      case 'Como nuevo':
        return Icons.star_rounded;
      case 'Buen estado':
        return Icons.thumb_up_rounded;
      case 'Usado':
        return Icons.history_rounded;
      case 'Para reparar':
        return Icons.build_rounded;
      default:
        return Icons.help_outline;
    }
  }

  Color _getConditionColor(String condition) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final tertiary = Theme.of(context).colorScheme.tertiary;
    final outline = Theme.of(context).colorScheme.outline;
    switch (condition) {
      case 'Nuevo':
        return primary;
      case 'Como nuevo':
        return primary.withOpacity(0.8);
      case 'Buen estado':
        return secondary;
      case 'Usado':
        return tertiary;
      case 'Para reparar':
        return outline;
      default:
        return outline;
    }
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String label,
    required String hint,
    required IconData icon,
    String? error,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    bool isRequired = false,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 22),
        errorText: error,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      items: items,
      onChanged: onChanged,
      dropdownColor: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
    );
  }

  Widget _buildServiceFields(NewProductViewModel vm) {
    return _buildSection(
      icon: Icons.handyman_rounded,
      title: 'Detalles del Servicio',
      children: [
        _buildDropdown<String>(
          value: vm.serviceCategory.isEmpty ? null : vm.serviceCategory,
          label: 'Categoría',
          hint: 'Selecciona el tipo de servicio',
          icon: Icons.category_rounded,
          error: vm.fieldErrors['serviceCategory'],
          items: serviceCategories
              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
              .toList(),
          onChanged: (v) {
            vm.serviceCategory = v ?? '';
            (context as Element).markNeedsBuild();
          },
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildDropdown<String>(
          value: vm.serviceModality.isEmpty ? null : vm.serviceModality,
          label: 'Modalidad',
          hint: 'Presencial, remoto, etc.',
          icon: Icons.place_rounded,
          error: vm.fieldErrors['serviceModality'],
          items: serviceModalities
              .map(
                (mod) => DropdownMenuItem(
                  value: mod,
                  child: Row(
                    children: [
                      Icon(
                        _getModalityIcon(mod),
                        size: 18,
                        color: _getModalityColor(mod),
                      ),
                      const SizedBox(width: 8),
                      Text(mod),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            vm.serviceModality = v ?? '';
            (context as Element).markNeedsBuild();
          },
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildDurationPicker(vm),
        const SizedBox(height: 16),
        _buildCoveragePicker(vm),
        const SizedBox(height: 16),
        _buildTextField(
          initialValue: vm.serviceSchedule,
          label: 'Horarios disponibles',
          hint: 'ej: Lun-Vie 9:00-18:00, Sáb 9:00-13:00',
          icon: Icons.schedule_rounded,
          error: null,
          onChanged: (v) => vm.serviceSchedule = v,
          maxLines: 2,
        ),
      ],
    );
  }

  IconData _getModalityIcon(String modality) {
    switch (modality) {
      case 'Presencial':
        return Icons.storefront_rounded;
      case 'A domicilio':
        return Icons.home_rounded;
      case 'Remoto':
        return Icons.computer_rounded;
      case 'Híbrido':
        return Icons.sync_alt_rounded;
      default:
        return Icons.help_outline;
    }
  }

  Color _getModalityColor(String modality) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final tertiary = Theme.of(context).colorScheme.tertiary;
    final outline = Theme.of(context).colorScheme.outline;
    switch (modality) {
      case 'Presencial':
        return primary;
      case 'A domicilio':
        return secondary;
      case 'Remoto':
        return tertiary;
      case 'Híbrido':
        return outline;
      default:
        return outline;
    }
  }

  Widget _buildDurationPicker(NewProductViewModel vm) {
    final hours = vm.serviceDurationMinutes ~/ 60;
    final minutes = vm.serviceDurationMinutes % 60;

    return InkWell(
      onTap: () async {
        final result = await showDialog<Map<String, int>>(
          context: context,
          builder: (ctx) => _DurationPickerDialog(
            initialHours: hours,
            initialMinutes: minutes,
          ),
        );
        if (result != null) {
          vm.serviceDurationMinutes =
              (result['hours']! * 60) + result['minutes']!;
          setState(() {});
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Duración estimada',
          prefixIcon: const Icon(Icons.timer_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        child: Text(
          vm.serviceDurationMinutes == 0
              ? 'Sin especificar'
              : _formatDuration(vm.serviceDurationMinutes),
          style: vm.serviceDurationMinutes == 0
              ? TextStyle(color: Theme.of(context).hintColor)
              : null,
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return '$hours ${hours == 1 ? 'hora' : 'horas'}';
      } else {
        return '$hours h $mins min';
      }
    }
  }

  Widget _buildCoveragePicker(NewProductViewModel vm) {
    return InkWell(
      onTap: () async {
        final selected = await showDialog<List<String>>(
          context: context,
          builder: (ctx) => _RegionPickerDialog(
            selectedRegions: List.from(vm.serviceCoverage),
          ),
        );
        if (selected != null) {
          vm.serviceCoverage = selected;
          setState(() {});
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Cobertura (regiones)',
          prefixIcon: const Icon(Icons.map_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        child: vm.serviceCoverage.isEmpty
            ? Text(
                'Seleccionar regiones',
                style: TextStyle(color: Theme.of(context).hintColor),
              )
            : Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...vm.serviceCoverage.take(3).map((region) {
                    return Chip(
                      label: Text(region, style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                    );
                  }),
                  if (vm.serviceCoverage.length > 3)
                    Chip(
                      label: Text(
                        '+${vm.serviceCoverage.length - 3}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildImages(NewProductViewModel vm) {
    final imageCount = vm.localImagePaths.length + vm.existingImageUrls.length;
    final theme = Theme.of(context);
    return _buildSection(
      icon: Icons.photo_library_rounded,
      title: 'Imágenes',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: imageCount > 0
              ? theme.colorScheme.primary.withOpacity(0.15)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$imageCount/${vm.maxImageCount}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: imageCount > 0
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount:
              vm.existingImageUrls.length +
              vm.localImagePaths.length +
              ((vm.localImagePaths.length + vm.existingImageUrls.length) <
                      vm.maxImageCount
                  ? 1
                  : 0),
          itemBuilder: (context, index) {
            if (index < vm.existingImageUrls.length) {
              return _buildExistingImage(vm.existingImageUrls[index]);
            }
            index -= vm.existingImageUrls.length;
            if (index < vm.localImagePaths.length) {
              return _buildNewImage(vm, index);
            }
            return _buildAddImageButton(vm);
          },
        ),
        if (vm.fieldErrors['images'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  vm.fieldErrors['images']!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildExistingImage(String url) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(url, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_done,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewImage(NewProductViewModel vm, int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(File(vm.localImagePaths[index]), fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            onPressed: () => vm.removeLocalImageAt(index),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton(NewProductViewModel vm) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: vm.isPicking ? null : vm.pickImage,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: vm.isPicking
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                  strokeWidth: 3,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 26,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Agregar',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCertifications(NewProductViewModel vm) {
    return _buildSection(
      icon: Icons.workspace_premium_rounded,
      title: 'Certificaciones',
      children: [
        Text(
          'Selecciona las certificaciones que apliquen:',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: availableCertifications.map((cert) {
            final isSelected = vm.hasCertification(cert);
            final theme = Theme.of(context);
            return FilterChip(
              label: Text(
                cert,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => vm.toggleCertification(cert),
              avatar: isSelected
                  ? Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    )
                  : Icon(
                      Icons.add_circle_outline,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
              selectedColor: theme.colorScheme.primary.withOpacity(0.15),
              checkmarkColor: theme.colorScheme.primary,
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTags(NewProductViewModel vm) {
    return _buildSection(
      icon: Icons.sell_rounded,
      title: 'Etiquetas',
      children: [
        if (vm.tags.isNotEmpty) ...[
          Text(
            'Etiquetas seleccionadas:',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vm.tags.map((tag) {
              final theme = Theme.of(context);
              return Chip(
                label: Text(
                  tag,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                deleteIcon: const Icon(Icons.close_rounded, size: 18),
                deleteIconColor: theme.colorScheme.primary,
                onDeleted: () => vm.removeTag(tag),
                side: BorderSide(color: theme.colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(),
        ],
        const SizedBox(height: 12),
        Text(
          'Sugerencias:',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: commonTags.where((tag) => !vm.tags.contains(tag)).map((
            tag,
          ) {
            return ActionChip(
              label: Text(
                tag,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onPressed: () => vm.addTag(tag),
              avatar: Icon(
                Icons.add_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _showAddCustomTagDialog(vm),
          icon: const Icon(Icons.new_label_rounded, size: 20),
          label: const Text('Crear etiqueta personalizada'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddCustomTagDialog(NewProductViewModel vm) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar etiqueta'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Etiqueta',
            hintText: 'Ej: Sin plástico',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final tag = controller.text.trim();
              if (tag.isNotEmpty) {
                vm.addTag(tag);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairLocations(NewProductViewModel vm) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.build_circle_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Locales de Reparación',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddRepairDialog(vm),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            if (vm.repairLocations.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...vm.repairLocations.asMap().entries.map((entry) {
                final index = entry.key;
                final location = entry.value;
                final address = location['address'] as String? ?? 'Sin nombre';
                final lat = (location['lat'] as num?)?.toDouble() ?? 0.0;
                final lon = (location['lon'] as num?)?.toDouble() ?? 0.0;

                return Dismissible(
                  key: ValueKey(location.hashCode),
                  direction: DismissDirection.endToStart,
                  background: Container(color: Colors.transparent),
                  secondaryBackground: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  onDismissed: (_) => vm.removeRepairLocationAt(index),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.store_outlined),
                      title: Text(address),
                      subtitle: Text(
                        'Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTerms(NewProductViewModel vm) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.gavel_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Términos y Condiciones',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: vm.terms,
              decoration: InputDecoration(
                labelText: 'Política de devolución, garantía, etc.',
                hintText: vm.isService
                    ? 'ej: Cancelación gratuita 24h antes'
                    : 'ej: Devolución dentro de 30 días',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              onChanged: (v) => vm.terms = v,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishButton(BuildContext context, NewProductViewModel vm) {
    if (vm.isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            SizedBox(width: 16),
            Text(
              'Publicando...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handlePublish(context, vm),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  vm.isEditing ? Icons.save_rounded : Icons.publish_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  vm.isEditing ? 'Guardar Cambios' : 'Publicar',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePublish(
    BuildContext context,
    NewProductViewModel vm,
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          makeAppSnackBar(context, 'Usuario no autenticado', success: false),
        );
      }
      return;
    }

    final success = await vm.publish(userId);
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        makeAppSnackBar(context, 'Publicado con éxito', success: true),
      );
      if (widget.onPublishSuccess != null) {
        widget.onPublishSuccess!();
      } else {
        context.go('/company-profile');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        makeAppSnackBar(
          context,
          vm.error ?? 'Error al publicar',
          success: false,
        ),
      );
    }
  }

  Future<void> _showAddRepairDialog(NewProductViewModel vm) async {
    String address = '';
    LatLng? pickedLoc;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Añadir local de reparación'),
        content: StatefulBuilder(
          builder: (ctx, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nombre/Descripción',
                  ),
                  onChanged: (v) => address = v,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    final loc = await _showMapPicker(ctx, initial: pickedLoc);
                    if (loc != null) setState(() => pickedLoc = loc);
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: Text(
                    pickedLoc == null
                        ? 'Seleccionar ubicación'
                        : 'Ubicación seleccionada',
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (address.isNotEmpty && pickedLoc != null) {
                vm.addRepairLocation({
                  'address': address,
                  'lat': pickedLoc!.latitude,
                  'lon': pickedLoc!.longitude,
                });
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  Future<LatLng?> _showMapPicker(BuildContext ctx, {LatLng? initial}) async {
    // Ask for location permission
    var status = await Permission.locationWhenInUse.status;
    bool hasLocation = status.isGranted;
    if (!hasLocation) {
      final req = await Permission.locationWhenInUse.request();
      hasLocation = req.isGranted;
      if (req.isPermanentlyDenied) {
        final open = await showDialog<bool>(
          context: ctx,
          builder: (d) => AlertDialog(
            title: const Text('Permiso denegado'),
            content: const Text(
              'El permiso de ubicación fue denegado permanentemente. Puedes usar la búsqueda por dirección o abrir la configuración.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(d).pop(false),
                child: const Text('Continuar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(d).pop(true),
                child: const Text('Abrir configuración'),
              ),
            ],
          ),
        );
        if (open == true) {
          await openAppSettings();
          return null;
        }
        hasLocation = false;
      }
    }

    // Default location (Santiago, Chile)
    LatLng selected = initial ?? const LatLng(-33.4489, -70.6693);

    // Try to get current location if permission granted
    if (hasLocation) {
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        selected = LatLng(pos.latitude, pos.longitude);
      } catch (e) {
        // Continue with default location
        debugPrint('Error getting location: $e');
      }
    }

    // Show enhanced map picker dialog
    return await showDialog<LatLng>(
      context: ctx,
      builder: (dctx) {
        return _MapPickerDialog(
          initialPosition: selected,
          hasLocation: hasLocation,
        );
      },
    );
  }
}

// Widget separado para el selector de mapa
class _MapPickerDialog extends StatefulWidget {
  final LatLng initialPosition;
  final bool hasLocation;

  const _MapPickerDialog({
    required this.initialPosition,
    required this.hasLocation,
  });

  @override
  State<_MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<_MapPickerDialog> {
  late LatLng selected;
  GoogleMapController? mapController;
  final addressController = TextEditingController();
  bool isSearching = false;
  String? searchError;

  @override
  void initState() {
    super.initState();
    selected = widget.initialPosition;
  }

  @override
  void dispose() {
    addressController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  List<String> _getCommonPlaces() {
    return [
      // Región Metropolitana
      'Santiago Centro, Santiago',
      'Providencia, Santiago',
      'Las Condes, Santiago',
      'Vitacura, Santiago',
      'La Reina, Santiago',
      'Ñuñoa, Santiago',
      'Maipú, Santiago',
      'Puente Alto, Santiago',
      'La Florida, Santiago',
      'San Miguel, Santiago',
      'Estación Central, Santiago',
      'Recoleta, Santiago',
      'Independencia, Santiago',
      'Quilicura, Santiago',
      'Pudahuel, Santiago',
      'Peñalolén, Santiago',
      'Macul, Santiago',
      'Lo Barnechea, Santiago',
      'Huechuraba, Santiago',
      'Cerrillos, Santiago',
      // Valparaíso
      'Valparaíso, Valparaíso',
      'Viña del Mar, Valparaíso',
      'Concón, Valparaíso',
      'Quilpué, Valparaíso',
      'Villa Alemana, Valparaíso',
      'Quillota, Valparaíso',
      'San Antonio, Valparaíso',
      // Concepción
      'Concepción, Biobío',
      'Talcahuano, Biobío',
      'Chiguayante, Biobío',
      'San Pedro de la Paz, Biobío',
      'Coronel, Biobío',
      'Los Ángeles, Biobío',
      'Chillán, Ñuble',
      // La Serena - Coquimbo
      'La Serena, Coquimbo',
      'Coquimbo, Coquimbo',
      'Ovalle, Coquimbo',
      // Norte
      'Antofagasta, Antofagasta',
      'Calama, Antofagasta',
      'Iquique, Tarapacá',
      'Arica, Arica y Parinacota',
      'Copiapó, Atacama',
      // Sur
      'Temuco, La Araucanía',
      'Valdivia, Los Ríos',
      'Puerto Montt, Los Lagos',
      'Osorno, Los Lagos',
      'Punta Arenas, Magallanes',
      'Puerto Varas, Los Lagos',
      'Coyhaique, Aysén',
      // Rancagua - O'Higgins
      'Rancagua, O\'Higgins',
      'Talca, Maule',
      'Curicó, Maule',
    ];
  }

  Future<void> _searchAddress(String address) async {
    if (address.trim().isEmpty) return;

    setState(() {
      isSearching = true;
      searchError = null;
    });

    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty && mounted) {
        final location = locations.first;
        final newPosition = LatLng(location.latitude, location.longitude);

        setState(() => selected = newPosition);

        await mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newPosition, 16),
        );

        if (mounted) {
          setState(() {
            isSearching = false;
            searchError = null;
          });
        }
      } else if (mounted) {
        setState(() {
          isSearching = false;
          searchError = 'No se encontró la dirección';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isSearching = false;
          searchError = 'Error al buscar la dirección';
        });
      }
      debugPrint('Geocoding error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecciona ubicación'),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      content: SizedBox(
        width: double.maxFinite,
        height: 480,
        child: Column(
          children: [
            // Search bar for address with autocomplete
            TypeAheadField<String>(
              controller: addressController,
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: 'Buscar dirección (ej: Providencia, Santiago)',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : addressController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              addressController.clear();
                              setState(() => searchError = null);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText: searchError,
                  ),
                );
              },
              suggestionsCallback: (pattern) async {
                if (pattern.isEmpty) {
                  return _getCommonPlaces();
                }

                final filtered = _getCommonPlaces()
                    .where(
                      (place) =>
                          place.toLowerCase().contains(pattern.toLowerCase()),
                    )
                    .toList();

                return filtered.isNotEmpty ? filtered : _getCommonPlaces();
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(suggestion),
                  dense: true,
                );
              },
              onSelected: (suggestion) {
                addressController.text = suggestion;
                _searchAddress(suggestion);
              },
              emptyBuilder: (context) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No se encontraron sugerencias',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Info chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Toca el mapa para seleccionar',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Map
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: selected,
                    zoom: 14,
                  ),
                  myLocationEnabled: widget.hasLocation,
                  myLocationButtonEnabled: widget.hasLocation,
                  onMapCreated: (controller) {
                    mapController = controller;
                    controller.animateCamera(
                      CameraUpdate.newLatLngZoom(selected, 14),
                    );
                  },
                  onTap: (latlng) {
                    setState(() => selected = latlng);
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('picked'),
                      position: selected,
                      draggable: true,
                      onDragEnd: (newPosition) {
                        setState(() => selected = newPosition);
                      },
                    ),
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Coordinates display
            Text(
              'Lat: ${selected.latitude.toStringAsFixed(6)}, '
              'Lng: ${selected.longitude.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(selected),
          icon: const Icon(Icons.check),
          label: const Text('Seleccionar'),
        ),
      ],
    );
  }
}

// Helper dialogs
class _DurationPickerDialog extends StatefulWidget {
  final int initialHours;
  final int initialMinutes;

  const _DurationPickerDialog({
    required this.initialHours,
    required this.initialMinutes,
  });

  @override
  State<_DurationPickerDialog> createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<_DurationPickerDialog> {
  late int hours;
  late int minutes;

  @override
  void initState() {
    super.initState();
    hours = widget.initialHours;
    minutes = widget.initialMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Duración del servicio'),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: hours,
              decoration: const InputDecoration(labelText: 'Horas'),
              items: List.generate(24, (i) => i).map((h) {
                return DropdownMenuItem(value: h, child: Text('$h'));
              }).toList(),
              onChanged: (v) => setState(() => hours = v ?? 0),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: minutes,
              decoration: const InputDecoration(labelText: 'Minutos'),
              items: [0, 15, 30, 45].map((m) {
                return DropdownMenuItem(value: m, child: Text('$m'));
              }).toList(),
              onChanged: (v) => setState(() => minutes = v ?? 0),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop({'hours': hours, 'minutes': minutes});
          },
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}

class _RegionPickerDialog extends StatefulWidget {
  final List<String> selectedRegions;

  const _RegionPickerDialog({required this.selectedRegions});

  @override
  State<_RegionPickerDialog> createState() => _RegionPickerDialogState();
}

class _RegionPickerDialogState extends State<_RegionPickerDialog> {
  late List<String> selected;

  @override
  void initState() {
    super.initState();
    selected = List.from(widget.selectedRegions);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar regiones'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: chileanRegions.map((region) {
            final isSelected = selected.contains(region);
            return CheckboxListTile(
              title: Text(region),
              value: isSelected,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    selected.add(region);
                  } else {
                    selected.remove(region);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(selected),
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}
