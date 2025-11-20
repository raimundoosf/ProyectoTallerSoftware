// This file intentionally suppresses the `use_build_context_synchronously` lint
// in a few dialog helper functions where we pass dialog-owned BuildContexts
// across awaits in a controlled way (the dialog's builder context `ctx` is
// used, not the State's `context`). See individual ignores around the calls.
// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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

class NewProductView extends StatefulWidget {
  const NewProductView({super.key, this.onCancel, this.onPublishSuccess});

  final VoidCallback? onCancel;
  final VoidCallback? onPublishSuccess;

  @override
  State<NewProductView> createState() => _NewProductViewState();
}

class _NewProductViewState extends State<NewProductView> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // If company id is available, set brand link in the VM
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vm = context.read<NewProductViewModel>();
        vm.setBrandLink('/businesses/$userId');
        // load the company profile so we can display the company name
        try {
          context.read<CompanyProfileViewModel>().loadCompanyProfile(userId);
        } catch (_) {}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewProductViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              vm.isEditing ? 'Editar Publicación' : 'Nueva Publicación',
            ),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                // Mostrar diálogo de confirmación si hay datos en el formulario
                final hasData =
                    vm.name.isNotEmpty ||
                    vm.description.isNotEmpty ||
                    vm.localImagePaths.isNotEmpty;

                if (hasData) {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('¿Cancelar publicación?'),
                      content: const Text(
                        'Se perderán todos los datos ingresados.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Continuar editando'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;
                }

                // Limpiar el formulario antes de cancelar
                vm.resetForm();
                // Si hay un callback onCancel, usarlo (desde MainScaffold)
                if (widget.onCancel != null) {
                  widget.onCancel!();
                } else {
                  // Fallback: intentar navegar con GoRouter
                  if (context.mounted) context.go('/');
                }
              },
              tooltip: 'Cancelar',
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Información Básica',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Tipo: Producto / Servicio (switch mejorado)
                          Row(
                            children: [
                              Expanded(
                                child: SegmentedButton<bool>(
                                  segments: const [
                                    ButtonSegment(
                                      value: false,
                                      label: Text('Producto'),
                                      icon: Icon(Icons.inventory_2_outlined),
                                    ),
                                    ButtonSegment(
                                      value: true,
                                      label: Text('Servicio'),
                                      icon: Icon(Icons.work_outline),
                                    ),
                                  ],
                                  selected: {vm.isService},
                                  onSelectionChanged: (Set<bool> newSelection) {
                                    vm.setIsService(newSelection.first);
                                  },
                                ),
                              ),
                            ],
                          ),

                          if (vm.isService) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: vm.serviceCategory,
                              decoration: InputDecoration(
                                labelText: 'Categoría del servicio',
                                hintText: 'ej: Reparación, Instalación',
                                prefixIcon: const Icon(Icons.category_outlined),
                                errorText: vm.fieldErrors['serviceCategory'],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (v) => vm.serviceCategory = v,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: vm.serviceDuration,
                              decoration: InputDecoration(
                                labelText: 'Duración estimada (opcional)',
                                hintText: 'ej: 30 min, 2 horas',
                                prefixIcon: const Icon(Icons.schedule_outlined),
                                errorText: vm.fieldErrors['serviceDuration'],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (v) => vm.serviceDuration = v,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Información principal
                  TextFormField(
                    initialValue: vm.name,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      hintText: vm.isService
                          ? 'ej: Reparación de electrodomésticos'
                          : 'ej: Lavadora eco-friendly',
                      prefixIcon: const Icon(Icons.title),
                      errorText: vm.fieldErrors['name'],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (v) => vm.name = v,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: vm.description,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Describe los detalles y beneficios',
                      prefixIcon: const Icon(Icons.description_outlined),
                      alignLabelWithHint: true,
                      errorText: vm.fieldErrors['description'],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 4,
                    onChanged: (v) => vm.description = v,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: vm.price > 0 ? vm.price.toString() : '',
                    decoration: InputDecoration(
                      labelText: 'Precio',
                      hintText: '0',
                      prefixIcon: const Icon(Icons.attach_money),
                      prefixText: '\$ ',
                      suffixText: 'CLP',
                      errorText: vm.fieldErrors['price'],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (v) => vm.price = double.tryParse(v) ?? 0.0,
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 16),
                  Text(
                    'Marca (no editable)',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Builder(
                    builder: (bctx) {
                      final cpvm = bctx.read<CompanyProfileViewModel>();
                      final name = cpvm.companyProfile?.companyName;
                      return Text(
                        name ?? vm.brandLink,
                        style: const TextStyle(color: Colors.blueGrey),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Certificaciones disponibles',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (bctx) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: availableCertifications.map((cert) {
                          final selected = bctx
                              .read<NewProductViewModel>()
                              .hasCertification(cert);
                          return ChoiceChip(
                            label: Text(cert),
                            selected: selected,
                            onSelected: (_) => bctx
                                .read<NewProductViewModel>()
                                .toggleCertification(cert),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Imágenes (mínimo 1, máximo 3)'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              // Show existing images (when editing)
                              ...vm.existingImageUrls.mapIndexed((i, url) {
                                return Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        showDialog<void>(
                                          context: context,
                                          builder: (dctx) => AlertDialog(
                                            title: const Text('Vista previa'),
                                            content: Image.network(url),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(dctx).pop(),
                                                child: const Text('Cerrar'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: Image.network(
                                        url,
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.all(4),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.cloud,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              // Show newly picked images
                              ...vm.localImagePaths.mapIndexed((i, path) {
                                return Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final shouldDelete =
                                            await showDialog<bool>(
                                              context: context,
                                              builder: (dctx) => AlertDialog(
                                                title: const Text(
                                                  'Vista previa',
                                                ),
                                                content: Image.file(File(path)),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          dctx,
                                                        ).pop(false),
                                                    child: const Text('Cerrar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          dctx,
                                                        ).pop(true),
                                                    child: const Text(
                                                      'Eliminar',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                        if (shouldDelete == true) {
                                          vm.removeLocalImageAt(i);
                                        }
                                      },
                                      child: Image.file(
                                        File(path),
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        onPressed: () =>
                                            vm.removeLocalImageAt(i),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              if ((vm.localImagePaths.length +
                                      vm.existingImageUrls.length) <
                                  vm.maxImageCount)
                                TextButton.icon(
                                  onPressed: vm.isPicking ? null : vm.pickImage,
                                  icon: vm.isPicking
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.add_a_photo),
                                  label: const Text('Agregar'),
                                ),
                            ],
                          ),
                          if (vm.fieldErrors['images'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                vm.fieldErrors['images'] ?? '',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.map_outlined),
                      title: const Text('Trazabilidad (marcar orígenes)'),
                      subtitle: Text(
                        '${vm.traceability.length} puntos añadidos',
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          _showAddTracePointDialog(context, vm);
                        },
                        child: const Text('Agregar punto'),
                      ),
                    ),
                  ),
                  if (vm.traceability.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: vm.traceability.mapIndexed((i, t) {
                          final mp = t['mediaPath'] as String?;
                          final description =
                              (t['description'] as String?) ?? '';
                          final lat =
                              (t['lat'] as double?) ??
                              (t['lat'] as num?)?.toDouble() ??
                              0.0;
                          final lon =
                              (t['lon'] as double?) ??
                              (t['lon'] as num?)?.toDouble() ??
                              0.0;
                          return Dismissible(
                            key: ValueKey(t.hashCode),
                            direction: DismissDirection.endToStart,
                            // background must be non-null when secondaryBackground is
                            // provided (Dismissible assertion). Provide a transparent
                            // background for the non-used direction.
                            background: Container(color: Colors.transparent),
                            secondaryBackground: Container(
                              color: Colors.red.shade600,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) {
                              vm.removeTracePointAt(i);
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: mp != null && mp.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.file(
                                          File(mp),
                                          width: 72,
                                          height: 56,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(Icons.map_outlined),
                                title: Text(
                                  description.isNotEmpty
                                      ? description
                                      : 'Sin descripción',
                                ),
                                subtitle: Text(
                                  'Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}',
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.build_circle_outlined),
                      title: const Text('Reparación (locales)'),
                      subtitle: Text(
                        '${vm.repairLocations.length} locales añadidos',
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          _showAddRepairDialog(context, vm);
                        },
                        child: const Text('Agregar'),
                      ),
                    ),
                  ),
                  if (vm.repairLocations.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: vm.repairLocations.mapIndexed((i, r) {
                          final address = (r['address'] as String?) ?? '';
                          final lat =
                              (r['lat'] as double?) ??
                              (r['lat'] as num?)?.toDouble() ??
                              0.0;
                          final lon =
                              (r['lon'] as double?) ??
                              (r['lon'] as num?)?.toDouble() ??
                              0.0;
                          return Dismissible(
                            key: ValueKey(r.hashCode),
                            direction: DismissDirection.endToStart,
                            background: Container(color: Colors.transparent),
                            secondaryBackground: Container(
                              color: Colors.red.shade600,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) {
                              vm.removeRepairLocationAt(i);
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(
                                  address.isNotEmpty ? address : 'Sin nombre',
                                ),
                                subtitle: Text(
                                  'Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}',
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 16),
                  vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () async {
                            final userId =
                                FirebaseAuth.instance.currentUser?.uid;
                            if (userId == null) {
                              context.showAppSnackBar(
                                'Usuario no autenticado',
                                success: false,
                              );
                              return;
                            }
                            final router = GoRouter.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            final successSnack = makeAppSnackBar(
                              context,
                              'Publicado con éxito',
                              success: true,
                            );
                            final errorMessage =
                                vm.error ?? 'Fallo al publicar';
                            final errorSnack = makeAppSnackBar(
                              context,
                              errorMessage,
                              success: false,
                            );

                            final success = await vm.publish(userId);
                            if (!mounted) return;
                            if (success) {
                              messenger.showSnackBar(successSnack);
                              // Si hay callback onPublishSuccess, usarlo (desde MainScaffold)
                              if (widget.onPublishSuccess != null) {
                                widget.onPublishSuccess!();
                              } else {
                                // Fallback: navegar con GoRouter
                                router.go('/company-profile');
                              }
                            } else {
                              messenger.showSnackBar(errorSnack);
                            }
                          },
                          child: Text(
                            vm.isEditing ? 'Guardar Cambios' : 'Publicar',
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddTracePointDialog(
    BuildContext context,
    NewProductViewModel vm,
  ) async {
    String name = '';
    XFile? media;
    LatLng? pickedLoc;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Añadir punto de trazabilidad'),
        content: StatefulBuilder(
          builder: (ctx, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  onChanged: (v) => name = v,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
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
                const SizedBox(height: 8),
                // Wrap the attach button in a Consumer so it reacts to vm.isPicking
                Consumer<NewProductViewModel>(
                  builder: (cctx, model, child) {
                    return TextButton.icon(
                      onPressed: model.isPicking
                          ? null
                          : () async {
                              final picked = await model.pickImageFile();
                              if (picked != null) {
                                setState(() => media = picked);
                              }
                            },
                      icon: model.isPicking
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.attachment),
                      label: const Text('Adjuntar imagen/video (opc.)'),
                    );
                  },
                ),
                if (media != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 120,
                    height: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(File(media!.path), fit: BoxFit.cover),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final point = {
                'description': name,
                'lat': pickedLoc?.latitude ?? 0.0,
                'lon': pickedLoc?.longitude ?? 0.0,
                'mediaPath': media?.path,
              };
              vm.addTracePoint(point);
              Navigator.of(ctx).pop();
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddRepairDialog(
    BuildContext context,
    NewProductViewModel vm,
  ) async {
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
                const SizedBox(height: 8),
                TextButton.icon(
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
          TextButton(
            onPressed: () {
              vm.addRepairLocation({
                'address': address,
                'lat': pickedLoc?.latitude ?? 0.0,
                'lon': pickedLoc?.longitude ?? 0.0,
              });
              Navigator.of(ctx).pop();
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

// small helper extension to map with index
extension _IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E e) f) sync* {
    var i = 0;
    for (final e in this) {
      yield f(i++, e);
    }
  }
}
