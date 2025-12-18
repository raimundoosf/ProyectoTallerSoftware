import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/src/features/company_profile/domain/constants/business_constants.dart';
import 'package:flutter_app/src/features/user_profile/presentation/viewmodels/profile_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  // Controllers will be created when entering edit mode to avoid rebuild-reset issues
  TextEditingController? _nameController;
  TextEditingController? _companyController;
  TextEditingController? _positionController;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final viewModel = context.read<ProfileViewModel>();
        await viewModel.loadUserProfile(userId);
        // Si no existe perfil, activar modo edición automáticamente
        if (mounted && viewModel.userProfile == null && !viewModel.isLoading) {
          _initControllersFromViewModel(viewModel);
          setState(() => _isEditing = true);
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _companyController?.dispose();
    _positionController?.dispose();
    super.dispose();
  }

  void _initControllersFromViewModel(ProfileViewModel viewModel) {
    _nameController ??= TextEditingController(text: viewModel.name);
    _companyController ??= TextEditingController(text: viewModel.company ?? '');
    _positionController ??= TextEditingController(
      text: viewModel.position ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _isEditing ? 'Editar Perfil' : 'Mi Perfil',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            centerTitle: false,
            elevation: 0,
            leading: _isEditing
                ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setState(() => _isEditing = false),
                    tooltip: 'Cancelar',
                  )
                : null,
            actions: !_isEditing
                ? [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded),
                      tooltip: 'Más opciones',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'logout') {
                          _showLogoutDialog(context);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: theme.colorScheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Cerrar sesión',
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ]
                : null,
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              // combine fade + slide slightly upward
              final offset = Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offset,
                  child: ScaleTransition(scale: animation, child: child),
                ),
              );
            },
            child: viewModel.isLoading
                ? const Center(
                    key: ValueKey('profile-loading'),
                    child: CircularProgressIndicator(),
                  )
                : _isEditing
                ? _buildEditForm(context, viewModel)
                : _buildProfileView(context, viewModel),
          ),
          floatingActionButton: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: !_isEditing && viewModel.userProfile != null
                ? FloatingActionButton.extended(
                    key: const ValueKey('edit-fab'),
                    onPressed: () {
                      _initControllersFromViewModel(viewModel);
                      setState(() => _isEditing = true);
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar Perfil'),
                    elevation: 3,
                  )
                : const SizedBox.shrink(key: ValueKey('fab-empty')),
          ),
        );
      },
    );
  }

  Widget _buildProfileView(BuildContext context, ProfileViewModel viewModel) {
    if (viewModel.userProfile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Completa tu perfil',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Agrega tu información para que otros usuarios puedan conocerte mejor.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }
    final userProfile = viewModel.userProfile!;
    final theme = Theme.of(context);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header con avatar y nombre
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userProfile.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (userProfile.company != null &&
                        userProfile.company!.isNotEmpty &&
                        userProfile.position != null &&
                        userProfile.position!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${userProfile.position} en ${userProfile.company}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else if (userProfile.company != null &&
                        userProfile.company!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          userProfile.company!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else if (userProfile.position != null &&
                        userProfile.position!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          userProfile.position!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Información laboral (solo si existe al menos un campo)
            if ((userProfile.company != null &&
                    userProfile.company!.isNotEmpty) ||
                (userProfile.position != null &&
                    userProfile.position!.isNotEmpty))
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Información Laboral',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (userProfile.company != null &&
                          userProfile.company!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.business_outlined,
                                  size: 20,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Empresa',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      userProfile.company!,
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (userProfile.position != null &&
                          userProfile.position!.isNotEmpty)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.badge_outlined,
                                size: 20,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cargo',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    userProfile.position!,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

            if ((userProfile.company != null &&
                    userProfile.company!.isNotEmpty) ||
                (userProfile.position != null &&
                    userProfile.position!.isNotEmpty))
              const SizedBox(height: 16),

            // Intereses
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.interests_outlined,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Categorías de Interés',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (userProfile.interests.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: userProfile.interests.map((interest) {
                          return Chip(
                            label: Text(interest),
                            backgroundColor: theme.colorScheme.primaryContainer,
                            labelStyle: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          );
                        }).toList(),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No has seleccionado intereses',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  Widget _buildEditForm(BuildContext context, ProfileViewModel viewModel) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Información Personal
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Información Personal',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre completo',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      errorText: viewModel.fieldErrors['name'],
                      border: const OutlineInputBorder(),
                      filled: true,
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Por favor, ingresa tu nombre'
                        : null,
                    onChanged: (v) => viewModel.setName(v),
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Información Laboral
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.work_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Información Laboral',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Opcional',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _companyController,
                    decoration: const InputDecoration(
                      labelText: 'Empresa',
                      prefixIcon: Icon(Icons.business_outlined),
                      hintText: 'Nombre de tu empresa',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    onChanged: (v) => viewModel.setCompany(v),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _positionController,
                    decoration: const InputDecoration(
                      labelText: 'Cargo',
                      prefixIcon: Icon(Icons.work_history_outlined),
                      hintText: 'Tu cargo o posición',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    onChanged: (v) => viewModel.setPosition(v),
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Intereses
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.interests_outlined,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Categorías de Interés',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _showInterestsDialog(
                      context,
                      viewModel.interests,
                      (newInterests) {
                        viewModel.setInterests(newInterests);
                      },
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: theme.colorScheme.surface,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              viewModel.interests.isNotEmpty
                                  ? '${viewModel.interests.length} categoría${viewModel.interests.length > 1 ? 's' : ''} seleccionada${viewModel.interests.length > 1 ? 's' : ''}'
                                  : 'Toca para seleccionar intereses',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: viewModel.interests.isNotEmpty
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (viewModel.interests.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: viewModel.interests.map((interest) {
                        return Chip(
                          label: Text(interest),
                          backgroundColor: theme.colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontSize: 12,
                          ),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 16,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          onDeleted: () {
                            final updated = List<String>.from(
                              viewModel.interests,
                            )..remove(interest);
                            viewModel.setInterests(updated);
                          },
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Botón de guardar mejorado
          FilledButton.icon(
            onPressed: () async {
              final vm = context.read<ProfileViewModel>();
              // capture messenger and theme before the async gap
              final messenger = ScaffoldMessenger.of(context);
              final colorScheme = Theme.of(context).colorScheme;

              // ensure latest controller text is in the VM
              if (_nameController != null) vm.setName(_nameController!.text);
              if (_companyController != null) {
                vm.setCompany(_companyController!.text);
              }
              if (_positionController != null) {
                vm.setPosition(_positionController!.text);
              }
              final success = await vm.saveFromForm();
              if (!mounted) return;
              if (success) {
                setState(() => _isEditing = false);
                // dispose controllers so they will be re-created next edit
                _nameController?.dispose();
                _companyController?.dispose();
                _positionController?.dispose();
                _nameController = null;
                _companyController = null;
                _positionController = null;
                final bg = colorScheme.primary;
                final fg = colorScheme.onPrimary;
                final snack = SnackBar(
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  backgroundColor: bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  content: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: fg),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Perfil actualizado con éxito',
                          style: TextStyle(color: fg),
                        ),
                      ),
                    ],
                  ),
                );
                messenger.showSnackBar(snack);
              } else {
                final error = vm.error;
                if (error != null) {
                  final bg = colorScheme.error;
                  final fg = colorScheme.onError;
                  final snack = SnackBar(
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    backgroundColor: bg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    content: Row(
                      children: [
                        Icon(Icons.error_outline, color: fg),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(error, style: TextStyle(color: fg)),
                        ),
                      ],
                    ),
                  );
                  messenger.showSnackBar(snack);
                }
              }
            },
            icon: viewModel.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              viewModel.isLoading ? 'Guardando...' : 'Guardar Cambios',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showInterestsDialog(
    BuildContext context,
    List<String> currentInterests,
    Function(List<String>) onSave,
  ) {
    final tempInterests = List<String>.from(currentInterests);
    final allInterests = BusinessConstants.industries;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.interests_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              const Text('Categorías de Interés'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${tempInterests.length} categoría${tempInterests.length != 1 ? 's' : ''} seleccionada${tempInterests.length != 1 ? 's' : ''}',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...allInterests.map((interest) {
                        final isSelected = tempInterests.contains(interest);
                        return CheckboxListTile(
                          title: Text(interest),
                          value: isSelected,
                          activeColor: theme.colorScheme.primary,
                          checkboxShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (isSelected) {
                            setState(() {
                              if (isSelected == true) {
                                tempInterests.add(interest);
                              } else {
                                tempInterests.remove(interest);
                              }
                            });
                          },
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () {
                onSave(tempInterests);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check),
              label: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
