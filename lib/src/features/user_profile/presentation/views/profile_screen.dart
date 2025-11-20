import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
// entity import not required here; ViewModel exposes data and form state
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
  TextEditingController? _photoUrlController;
  String? _selectedLocation;

  static const _regions = [
    'Arica y Parinacota',
    'Tarapacá',
    'Antofagasta',
    'Atacama',
    'Coquimbo',
    'Valparaíso',
    'Metropolitana de Santiago',
    'O\'Higgins',
    'Maule',
    'Ñuble',
    'Biobío',
    'La Araucanía',
    'Los Ríos',
    'Los Lagos',
    'Aysén',
    'Magallanes y de la Antártica Chilena',
  ];

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProfileViewModel>().loadUserProfile(userId);
      });
    }
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _photoUrlController?.dispose();
    super.dispose();
  }

  void _initControllersFromViewModel(ProfileViewModel viewModel) {
    _nameController ??= TextEditingController(text: viewModel.name);
    _photoUrlController ??= TextEditingController(text: viewModel.photoUrl);
    _selectedLocation = viewModel.location;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Editar Perfil' : 'Mi Perfil'),
            leading: _isEditing
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _isEditing = false),
                  )
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
            child: !_isEditing
                ? FloatingActionButton(
                    key: const ValueKey('edit-fab'),
                    onPressed: () {
                      _initControllersFromViewModel(viewModel);
                      setState(() => _isEditing = true);
                    },
                    tooltip: 'Editar perfil',
                    child: const Icon(Icons.edit),
                  )
                : const SizedBox.shrink(key: ValueKey('fab-empty')),
          ),
        );
      },
    );
  }

  Widget _buildProfileView(BuildContext context, ProfileViewModel viewModel) {
    if (viewModel.userProfile == null) {
      return const Center(child: Text('Aún no has creado tu perfil.'));
    }
    final userProfile = viewModel.userProfile!;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                child: CircleAvatar(
                  key: ValueKey(userProfile.photoUrl ?? ''),
                  radius: 60,
                  backgroundImage:
                      userProfile.photoUrl != null &&
                          userProfile.photoUrl!.isNotEmpty
                      ? NetworkImage(userProfile.photoUrl!)
                      : null,
                  child:
                      (userProfile.photoUrl == null ||
                          userProfile.photoUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Nombre'),
                    subtitle: Text(userProfile.name),
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('Ubicación'),
                    subtitle: Text(userProfile.location ?? 'No especificada'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.interests_outlined),
                    title: const Text('Intereses'),
                    subtitle: Text(
                      userProfile.interests.isNotEmpty
                          ? userProfile.interests.join(', ')
                          : 'No especificados',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm(BuildContext context, ProfileViewModel viewModel) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  child: CircleAvatar(
                    key: ValueKey(
                      viewModel.photoUrl.isNotEmpty
                          ? viewModel.photoUrl
                          : (viewModel.userProfile?.photoUrl ?? ''),
                    ),
                    radius: 60,
                    backgroundImage: _buildProfileImageProvider(
                      viewModel.userProfile?.photoUrl,
                    ),
                    child:
                        (viewModel.userProfile?.photoUrl == null ||
                            viewModel.userProfile!.photoUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () => viewModel.pickImage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _photoUrlController,
            decoration: const InputDecoration(
              labelText: 'O ingresa la URL de la imagen',
            ),
            onChanged: (v) => viewModel.setPhotoUrl(v),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nombre',
              prefixIcon: const Icon(Icons.person_outline),
              errorText: viewModel.fieldErrors['name'],
            ),
            validator: (value) => value == null || value.isEmpty
                ? 'Por favor, ingresa tu nombre'
                : null,
            onChanged: (v) => viewModel.setName(v),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: viewModel.location ?? _selectedLocation,
            onChanged: (newValue) {
              viewModel.setLocation(newValue);
              setState(() => _selectedLocation = newValue);
            },
            items: _regions
                .map(
                  (region) => DropdownMenuItem<String>(
                    value: region,
                    child: Text(region),
                  ),
                )
                .toList(),
            decoration: const InputDecoration(
              labelText: 'Ubicación',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _showInterestsDialog(context, viewModel.interests, (
              newInterests,
            ) {
              viewModel.setInterests(newInterests);
            }),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Categorías de Interés',
                prefixIcon: Icon(Icons.interests_outlined),
              ),
              child: Text(
                viewModel.interests.isNotEmpty
                    ? viewModel.interests.join(', ')
                    : 'Seleccionar intereses',
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              final vm = context.read<ProfileViewModel>();
              // capture messenger and theme before the async gap
              final messenger = ScaffoldMessenger.of(context);
              final colorScheme = Theme.of(context).colorScheme;

              // ensure latest controller text is in the VM
              if (_nameController != null) vm.setName(_nameController!.text);
              if (_photoUrlController != null) {
                vm.setPhotoUrl(_photoUrlController!.text);
              }
              final success = await vm.saveFromForm();
              if (!mounted) return;
              if (success) {
                setState(() => _isEditing = false);
                // dispose controllers so they will be re-created next edit
                _nameController?.dispose();
                _photoUrlController?.dispose();
                _nameController = null;
                _photoUrlController = null;
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
            child: const Text('Guardar Cambios'),
          ),
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
    final allInterests = [
      'Tecnología',
      'Hogar',
      'Moda',
      'Deportes',
      'Salud y Belleza',
      'Vehículos',
      'Inmuebles',
      'Servicios Profesionales',
      'Comida y Bebidas',
      'Viajes y Turismo',
      'Educación',
      'Entretenimiento',
    ];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecciona tus intereses'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: allInterests.map((interest) {
                    return CheckboxListTile(
                      title: Text(interest),
                      value: tempInterests.contains(interest),
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
                  }).toList(),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                onSave(tempInterests);
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  ImageProvider? _buildProfileImageProvider(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    final uri = Uri.tryParse(photoUrl);
    if (uri != null && uri.hasScheme && uri.isAbsolute) {
      return NetworkImage(photoUrl);
    }
    final file = File(photoUrl);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return null;
  }
}
