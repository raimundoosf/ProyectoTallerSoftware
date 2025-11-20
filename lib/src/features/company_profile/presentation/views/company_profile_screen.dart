import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/src/features/company_profile/presentation/viewmodels/company_profile_viewmodel.dart';
import 'package:flutter_app/src/features/products/presentation/views/company_products_list_view.dart';
import 'package:go_router/go_router.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Use controllers while editing to avoid rebuild-resetting the cursor.
  // Controllers are created when entering edit mode and disposed afterwards.
  TextEditingController? _companyNameController;
  TextEditingController? _companyDescriptionController;
  TextEditingController? _websiteController;
  // logo url controller removed: logo is selected via image picker

  static const _industries = [
    'Tecnología',
    'Salud',
    'Educación',
    'Finanzas',
    'Retail',
    'Otra',
  ];

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
    _tabController = TabController(length: 2, vsync: this);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CompanyProfileViewModel>().loadCompanyProfile(userId);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _companyNameController?.dispose();
    _companyDescriptionController?.dispose();
    _websiteController?.dispose();
    // no logoUrl controller to dispose
    super.dispose();
  }

  // No local cached profile required; UI rebuilds from the ViewModel.

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanyProfileViewModel>(
      builder: (context, viewModel, child) {
        // If editing, show full-screen edit form without tabs
        if (_isEditing) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Editar Perfil de Empresa'),
              leading: viewModel.companyProfile != null
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _isEditing = false),
                    )
                  : null,
            ),
            body: _buildEditForm(context, viewModel),
          );
        }

        // Otherwise, show tabs
        return Scaffold(
          appBar: AppBar(
            title: const Text('Perfil de Empresa'),
            bottom: viewModel.companyProfile != null
                ? TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.business),
                        text: 'Perfil',
                      ),
                      Tab(
                        icon: Icon(Icons.inventory_2),
                        text: 'Mis Publicaciones',
                      ),
                    ],
                  )
                : null,
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.companyProfile == null
                  ? _buildNoProfileView(context)
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildProfileView(context, viewModel),
                        CompanyProductsListView(
                          companyId: FirebaseAuth.instance.currentUser!.uid,
                        ),
                      ],
                    ),
          floatingActionButton: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: !_isEditing &&
                    viewModel.companyProfile != null &&
                    _tabController.index == 0
                ? FloatingActionButton(
                    key: const ValueKey('company-edit-fab'),
                    onPressed: () {
                      // initialize controllers from the view model when entering edit mode
                      _initControllersFromViewModel(viewModel);
                      setState(() => _isEditing = true);
                    },
                    child: const Icon(Icons.edit),
                  )
                : const SizedBox.shrink(key: ValueKey('company-fab-empty')),
          ),
        );
      },
    );
  }

  void _initControllersFromViewModel(CompanyProfileViewModel viewModel) {
    _companyNameController ??= TextEditingController(
      text: viewModel.companyName,
    );
    _companyDescriptionController ??= TextEditingController(
      text: viewModel.companyDescription,
    );
    _websiteController ??= TextEditingController(text: viewModel.website);
  }

  Widget _buildNoProfileView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Aún no has creado tu perfil de empresa.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Text('Crear Perfil de Empresa'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView(
    BuildContext context,
    CompanyProfileViewModel viewModel,
  ) {
    final companyProfile = viewModel.companyProfile!;
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
                child: Builder(
                  builder: (context) {
                    final imageProvider = _buildProfileImageProvider(
                      companyProfile.logoUrl,
                    );
                    return CircleAvatar(
                      key: ValueKey(companyProfile.logoUrl),
                      radius: 60,
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? const Icon(Icons.business, size: 60)
                          : null,
                    );
                  },
                ),
              ),
            ),
            // Upload progress indicator (shows while an upload is in progress)
            if (viewModel.uploadProgress > 0 && viewModel.uploadProgress < 1)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: LinearProgressIndicator(value: viewModel.uploadProgress),
              ),

            const SizedBox(height: 16),
            Text(
              companyProfile.companyName,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  _buildInfoTile(
                    Icons.business_center_outlined,
                    'Industria',
                    companyProfile.industry,
                  ),
                  _buildInfoTile(
                    Icons.location_on_outlined,
                    'Ubicación',
                    companyProfile.companyLocation,
                  ),
                  _buildInfoTile(
                    Icons.link_outlined,
                    'Sitio Web',
                    companyProfile.website,
                  ),
                  _buildInfoTile(
                    Icons.description_outlined,
                    'Descripción',
                    companyProfile.companyDescription,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (companyProfile.certifications.isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.verified_outlined),
                  title: const Text('Certificaciones'),
                  subtitle: Text(companyProfile.certifications.join('\n')),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/products/new');
              },
              icon: const Icon(Icons.post_add_outlined),
              label: const Text('Nueva Publicación'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String? subtitle) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        subtitle != null && subtitle.isNotEmpty ? subtitle : 'No especificado',
      ),
    );
  }

  Widget _buildEditForm(
    BuildContext context,
    CompanyProfileViewModel viewModel,
  ) {
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
                      viewModel.logoUrl.isNotEmpty
                          ? viewModel.logoUrl
                          : (viewModel.companyProfile?.logoUrl ?? ''),
                    ),
                    radius: 60,
                    backgroundImage: _buildProfileImageProvider(
                      viewModel.logoUrl.isNotEmpty
                          ? viewModel.logoUrl
                          : viewModel.companyProfile?.logoUrl,
                    ),
                    child:
                        (viewModel.logoUrl.isEmpty &&
                            (viewModel.companyProfile?.logoUrl == null ||
                                viewModel.companyProfile!.logoUrl.isEmpty))
                        ? const Icon(Icons.business, size: 60)
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
          if (viewModel.uploadProgress > 0 && viewModel.uploadProgress < 1)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: LinearProgressIndicator(value: viewModel.uploadProgress),
            ),
          const SizedBox(height: 16),
          // logo is selected via image picker; URL input removed
          const SizedBox(height: 8),
          TextFormField(
            controller: _companyNameController,
            decoration: InputDecoration(
              labelText: 'Nombre de la Empresa',
              prefixIcon: const Icon(Icons.business_outlined),
              errorText: viewModel.fieldErrors['companyName'],
            ),
            onChanged: (v) {
              // update form state in VM but avoid rebuilding controller
              viewModel.companyName = v;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: ValueKey(
              'industry-${context.watch<CompanyProfileViewModel>().industry}',
            ),
            initialValue: context.watch<CompanyProfileViewModel>().industry,
            decoration: const InputDecoration(
              labelText: 'Industria',
              prefixIcon: Icon(Icons.business_center_outlined),
            ),
            items: _industries
                .map(
                  (String industry) => DropdownMenuItem<String>(
                    value: industry,
                    child: Text(industry),
                  ),
                )
                .toList(),
            onChanged: (String? newValue) {
              context.read<CompanyProfileViewModel>().setIndustry(newValue);
            },
            validator: (value) => value == null ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: ValueKey(
              'location-${context.watch<CompanyProfileViewModel>().companyLocation}',
            ),
            initialValue: context
                .watch<CompanyProfileViewModel>()
                .companyLocation,
            decoration: const InputDecoration(
              labelText: 'Ubicación',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            items: _regions
                .map(
                  (String region) => DropdownMenuItem<String>(
                    value: region,
                    child: Text(region),
                  ),
                )
                .toList(),
            onChanged: (String? newValue) {
              context.read<CompanyProfileViewModel>().setCompanyLocation(
                newValue,
              );
            },
            validator: (value) => value == null ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _companyDescriptionController,
            decoration: InputDecoration(
              labelText: 'Descripción',
              prefixIcon: const Icon(Icons.description_outlined),
              errorText: viewModel.fieldErrors['companyDescription'],
            ),
            maxLines: 3,
            onChanged: (v) {
              viewModel.companyDescription = v;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _websiteController,
            decoration: InputDecoration(
              labelText: 'Sitio Web',
              prefixIcon: const Icon(Icons.link_outlined),
              errorText: viewModel.fieldErrors['website'],
            ),
            keyboardType: TextInputType.url,
            onChanged: (v) {
              viewModel.website = v;
            },
          ),
          const SizedBox(height: 24),
          _buildCertificationsManager(context, viewModel.certifications, (
            newCerts,
          ) {
            viewModel.setCertifications(newCerts);
          }),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              final vm = context.read<CompanyProfileViewModel>();
              // capture messenger and theme before async gap
              final messenger = ScaffoldMessenger.of(context);
              final colorScheme = Theme.of(context).colorScheme;

              final success = await vm.saveFromForm();
              if (!mounted) return;
              if (success) {
                setState(() => _isEditing = false);
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
                          'Perfil de empresa actualizado con éxito',
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

  ImageProvider? _buildProfileImageProvider(String? logoUrl) {
    if (logoUrl == null || logoUrl.isEmpty) return null;
    final uri = Uri.tryParse(logoUrl);
    if (uri != null && uri.hasScheme && uri.isAbsolute) {
      return NetworkImage(logoUrl);
    }
    final file = File(logoUrl);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return null;
  }

  Widget _buildCertificationsManager(
    BuildContext context,
    List<String> certs,
    Function(List<String>) onUpdate,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              leading: Icon(Icons.verified_outlined),
              title: Text('Certificaciones'),
            ),
            ...certs.map(
              (cert) => ListTile(
                title: Text(cert),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    final newCerts = List<String>.from(certs)..remove(cert);
                    onUpdate(newCerts);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        String newCert = '';
                        final result = await showDialog<String>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Añadir certificación'),
                            content: StatefulBuilder(
                              builder: (context, setState) {
                                return TextFormField(
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Nombre de la certificación',
                                  ),
                                  onChanged: (v) {
                                    newCert = v;
                                    // no setState required for the dialog UI here
                                  },
                                  onFieldSubmitted: (v) {
                                    Navigator.of(ctx).pop(v);
                                  },
                                );
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(newCert),
                                child: const Text('Añadir'),
                              ),
                            ],
                          ),
                        );
                        if (result != null && result.isNotEmpty) {
                          final newCerts = List<String>.from(certs)
                            ..add(result);
                          onUpdate(newCerts);
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Añadir certificación'),
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
}
