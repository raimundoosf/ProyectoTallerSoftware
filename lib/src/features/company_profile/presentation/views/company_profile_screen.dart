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
          appBar: AppBar(title: const Text('Mi Empresa'), elevation: 0),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.companyProfile == null
              ? _buildNoProfileView(context)
              : Column(
                  children: [
                    // Header fijo con logo, nombre e industria
                    _buildFixedHeader(context, viewModel),

                    // Tab bar
                    _buildTabBar(context),

                    // Contenido de los tabs
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildProfileView(context, viewModel),
                          CompanyProductsListView(
                            companyId: FirebaseAuth.instance.currentUser!.uid,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          floatingActionButton: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child:
                !_isEditing &&
                    viewModel.companyProfile != null &&
                    _tabController.index == 0
                ? FloatingActionButton.extended(
                    key: const ValueKey('company-edit-fab'),
                    onPressed: () {
                      _initControllersFromViewModel(viewModel);
                      setState(() => _isEditing = true);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
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

  Widget _buildFixedHeader(
    BuildContext context,
    CompanyProfileViewModel viewModel,
  ) {
    final companyProfile = viewModel.companyProfile!;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 32),
          child: Column(
            children: [
              // Logo de la empresa
              Hero(
                tag: 'company-logo',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
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
                          radius: 64,
                          backgroundColor: theme.colorScheme.surface,
                          backgroundImage: imageProvider,
                          child: imageProvider == null
                              ? Icon(
                                  Icons.business,
                                  size: 64,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Nombre de la empresa
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  companyProfile.companyName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 26,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              // Industria como chip mejorado
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.business_center,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      companyProfile.industry,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        dividerColor: Colors.transparent,
        labelColor: theme.colorScheme.onPrimaryContainer,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.6,
        ),
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        padding: const EdgeInsets.all(6),
        tabs: const [
          Tab(icon: Icon(Icons.business, size: 24), text: 'Perfil', height: 64),
          Tab(
            icon: Icon(Icons.inventory_2, size: 24),
            text: 'Publicaciones',
            height: 64,
          ),
        ],
      ),
    );
  }

  Widget _buildNoProfileView(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.business_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bienvenido a tu Perfil de Empresa',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Crea tu perfil para comenzar a publicar productos y servicios que tus clientes puedan descubrir.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.add_business),
              label: const Text('Crear Perfil de Empresa'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
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
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        // Descripción
        _buildSection(
          context,
          title: 'Acerca de',
          icon: Icons.info_outline,
          child: Text(
            companyProfile.companyDescription.isNotEmpty
                ? companyProfile.companyDescription
                : 'Sin descripción',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.6,
              fontSize: 16,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Información de contacto
        _buildSection(
          context,
          title: 'Información',
          icon: Icons.contact_page_outlined,
          child: Column(
            children: [
              _buildInfoRow(
                context,
                icon: Icons.location_on_outlined,
                label: 'Ubicación',
                value: companyProfile.companyLocation,
              ),
              const Divider(height: 32),
              _buildInfoRow(
                context,
                icon: Icons.language_outlined,
                label: 'Sitio Web',
                value: companyProfile.website,
                isLink: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Certificaciones
        if (companyProfile.certifications.isNotEmpty)
          _buildSection(
            context,
            title: 'Certificaciones',
            icon: Icons.verified_outlined,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: companyProfile.certifications
                  .map(
                    (cert) => Chip(
                      avatar: Icon(
                        Icons.verified,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(cert),
                      backgroundColor: theme.colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

        if (companyProfile.certifications.isNotEmpty)
          const SizedBox(height: 20),

        // Botón de nueva publicación
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer,
                theme.colorScheme.secondaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/products/new'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Crear Nueva Publicación',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 90), // Espacio para el FAB
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primaryContainer,
                        theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.7,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 22, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isLink = false,
  }) {
    final theme = Theme.of(context);
    final hasValue = value.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 22, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                hasValue ? value : 'No especificado',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isLink && hasValue
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  decoration: isLink && hasValue
                      ? TextDecoration.underline
                      : null,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
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
