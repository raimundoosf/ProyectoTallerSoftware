// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/src/features/company_profile/domain/constants/business_constants.dart';
import 'package:flutter_app/src/features/company_profile/presentation/viewmodels/company_profile_viewmodel.dart';
import 'package:flutter_app/src/features/products/presentation/views/company_products_list_view.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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
        // Descripción de la empresa
        _buildSection(
          context,
          title: 'Acerca de Nosotros',
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

        // Área de Cobertura
        _buildSection(
          context,
          title: 'Área de Cobertura',
          icon: Icons.map_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                context,
                icon: Icons.public_outlined,
                label: 'Nivel',
                value: companyProfile.coverageLevel,
              ),
              if (companyProfile.coverageLevel == 'Regional' &&
                  companyProfile.coverageRegions.isNotEmpty) ...[
                const Divider(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Regiones',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: companyProfile.coverageRegions
                                .map(
                                  (region) => Chip(
                                    label: Text(region),
                                    backgroundColor:
                                        theme.colorScheme.secondaryContainer,
                                    labelStyle: TextStyle(
                                      color: theme
                                          .colorScheme
                                          .onSecondaryContainer,
                                      fontSize: 12,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              if (companyProfile.coverageLevel == 'Comunal' &&
                  companyProfile.coverageCommunes.isNotEmpty) ...[
                const Divider(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_city_outlined,
                      size: 20,
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Comunas',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: companyProfile.coverageCommunes
                                .map(
                                  (commune) => Chip(
                                    label: Text(commune),
                                    backgroundColor:
                                        theme.colorScheme.secondaryContainer,
                                    labelStyle: TextStyle(
                                      color: theme
                                          .colorScheme
                                          .onSecondaryContainer,
                                      fontSize: 12,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Información clave de la empresa
        if (companyProfile.rut.isNotEmpty ||
            companyProfile.foundedYear > 0 ||
            companyProfile.employeeCount > 0)
          _buildSection(
            context,
            title: 'Información de la Empresa',
            icon: Icons.business_outlined,
            child: Column(
              children: [
                if (companyProfile.rut.isNotEmpty)
                  _buildInfoRow(
                    context,
                    icon: Icons.badge_outlined,
                    label: 'RUT',
                    value: companyProfile.rut,
                  ),
                if (companyProfile.rut.isNotEmpty &&
                    companyProfile.foundedYear > 0)
                  const Divider(height: 24),
                if (companyProfile.foundedYear > 0)
                  _buildInfoRow(
                    context,
                    icon: Icons.calendar_today_outlined,
                    label: 'Año de Fundación',
                    value: companyProfile.foundedYear.toString(),
                  ),
                if (companyProfile.foundedYear > 0 &&
                    companyProfile.employeeCount > 0)
                  const Divider(height: 24),
                if (companyProfile.employeeCount > 0)
                  _buildInfoRow(
                    context,
                    icon: Icons.people_outline,
                    label: 'Número de Empleados',
                    value: _getEmployeeCountRange(companyProfile.employeeCount),
                  ),
              ],
            ),
          ),

        if (companyProfile.rut.isNotEmpty ||
            companyProfile.foundedYear > 0 ||
            companyProfile.employeeCount > 0)
          const SizedBox(height: 20),

        // Información de contacto
        if (companyProfile.email.isNotEmpty ||
            companyProfile.phone.isNotEmpty ||
            companyProfile.address.isNotEmpty ||
            companyProfile.website.isNotEmpty)
          _buildSection(
            context,
            title: 'Contacto',
            icon: Icons.contact_page_outlined,
            child: Column(
              children: [
                if (companyProfile.email.isNotEmpty)
                  _buildContactRow(
                    context,
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: companyProfile.email,
                    onTap: () => _launchEmail(companyProfile.email),
                  ),
                if (companyProfile.email.isNotEmpty &&
                    companyProfile.phone.isNotEmpty)
                  const Divider(height: 24),
                if (companyProfile.phone.isNotEmpty)
                  _buildContactRow(
                    context,
                    icon: Icons.phone_outlined,
                    label: 'Teléfono',
                    value: companyProfile.phone,
                    onTap: () => _launchPhone(companyProfile.phone),
                  ),
                if (companyProfile.phone.isNotEmpty &&
                    companyProfile.address.isNotEmpty)
                  const Divider(height: 24),
                if (companyProfile.address.isNotEmpty)
                  _buildContactRow(
                    context,
                    icon: Icons.location_on_outlined,
                    label: 'Dirección',
                    value: companyProfile.address,
                    onTap: () => _launchMap(companyProfile.address),
                  ),
                if ((companyProfile.address.isNotEmpty ||
                        companyProfile.phone.isNotEmpty ||
                        companyProfile.email.isNotEmpty) &&
                    companyProfile.website.isNotEmpty)
                  const Divider(height: 24),
                if (companyProfile.website.isNotEmpty)
                  _buildContactRow(
                    context,
                    icon: Icons.language_outlined,
                    label: 'Sitio Web',
                    value: companyProfile.website,
                    isLink: true,
                    onTap: () => _launchURL(companyProfile.website),
                  ),
              ],
            ),
          ),

        if (companyProfile.email.isNotEmpty ||
            companyProfile.phone.isNotEmpty ||
            companyProfile.address.isNotEmpty ||
            companyProfile.website.isNotEmpty)
          const SizedBox(height: 20),

        // Especialidades
        if (companyProfile.specialties.isNotEmpty)
          _buildSection(
            context,
            title: 'Especialidades',
            icon: Icons.star_outline,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: companyProfile.specialties
                  .map(
                    (specialty) => Chip(
                      avatar: Icon(
                        Icons.check_circle,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(specialty),
                      backgroundColor: theme.colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

        if (companyProfile.specialties.isNotEmpty) const SizedBox(height: 20),

        // Misión
        if (companyProfile.missionStatement.isNotEmpty)
          _buildSection(
            context,
            title: 'Nuestra Misión',
            icon: Icons.flag_outlined,
            child: Text(
              companyProfile.missionStatement,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        if (companyProfile.missionStatement.isNotEmpty)
          const SizedBox(height: 20),

        // Visión
        if (companyProfile.visionStatement.isNotEmpty)
          _buildSection(
            context,
            title: 'Nuestra Visión',
            icon: Icons.visibility_outlined,
            child: Text(
              companyProfile.visionStatement,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        if (companyProfile.visionStatement.isNotEmpty)
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
                    (cert) => _buildCertificationChip(
                      context,
                      cert['name'] ?? '',
                      cert['documentUrl'] ?? '',
                      theme,
                    ),
                  )
                  .toList(),
            ),
          ),

        if (companyProfile.certifications.isNotEmpty)
          const SizedBox(height: 20),

        // Redes sociales
        if (companyProfile.socialMedia.isNotEmpty)
          _buildSection(
            context,
            title: 'Redes Sociales',
            icon: Icons.share_outlined,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: companyProfile.socialMedia.map((social) {
                final platform = social['platform'] ?? '';
                final url = social['url'] ?? '';
                return InkWell(
                  onTap: () => _launchURL(url),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSocialIcon(platform),
                          size: 20,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          platform,
                          style: TextStyle(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        if (companyProfile.socialMedia.isNotEmpty) const SizedBox(height: 20),

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

  Widget _buildContactRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
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
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isLink
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      decoration: isLink ? TextDecoration.underline : null,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
          ],
        ),
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
              labelText: 'Industria / Rubro',
              prefixIcon: Icon(Icons.business_center_outlined),
              helperText: 'Selecciona la industria principal de tu empresa',
            ),
            items: BusinessConstants.industries
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
          const SizedBox(height: 24),

          // Área de Cobertura
          Text(
            'Área de Cobertura',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Define el alcance geográfico de tu empresa',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            key: ValueKey(
              'coverage-${context.watch<CompanyProfileViewModel>().coverageLevel}',
            ),
            initialValue: context
                .watch<CompanyProfileViewModel>()
                .coverageLevel,
            decoration: const InputDecoration(
              labelText: 'Nivel de Cobertura',
              prefixIcon: Icon(Icons.public_outlined),
            ),
            items: BusinessConstants.coverageLevels
                .map(
                  (String level) => DropdownMenuItem<String>(
                    value: level,
                    child: Text(level),
                  ),
                )
                .toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                context.read<CompanyProfileViewModel>().setCoverageLevel(
                  newValue,
                );
              }
            },
          ),
          const SizedBox(height: 16),

          // Mostrar selector de regiones si el nivel es Regional
          if (context.watch<CompanyProfileViewModel>().coverageLevel ==
              'Regional')
            _buildRegionSelector(context, viewModel),

          // Mostrar selector de comunas si el nivel es Comunal
          if (context.watch<CompanyProfileViewModel>().coverageLevel ==
              'Comunal')
            _buildCommuneSelector(context, viewModel),

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
          const SizedBox(height: 32),

          // Información de la Empresa
          Text(
            'Información de la Empresa',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.rut,
            decoration: InputDecoration(
              labelText: 'RUT (ej: 12.345.678-9)',
              prefixIcon: const Icon(Icons.badge_outlined),
              errorText: viewModel.fieldErrors['rut'],
              hintText: '12.345.678-9',
            ),
            onChanged: (v) => viewModel.setRut(v),
          ),

          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.foundedYear > 0
                ? viewModel.foundedYear.toString()
                : '',
            decoration: const InputDecoration(
              labelText: 'Año de Fundación',
              prefixIcon: Icon(Icons.calendar_today_outlined),
              hintText: '2020',
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final year = int.tryParse(v) ?? 0;
              viewModel.setFoundedYear(year);
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.employeeCount > 0
                ? viewModel.employeeCount.toString()
                : '',
            decoration: const InputDecoration(
              labelText: 'Número de Empleados',
              prefixIcon: Icon(Icons.people_outline),
              hintText: '10',
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final count = int.tryParse(v) ?? 0;
              viewModel.setEmployeeCount(count);
            },
          ),

          const SizedBox(height: 32),

          // Información de Contacto
          Text(
            'Información de Contacto',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.email,
            decoration: InputDecoration(
              labelText: 'Email Corporativo',
              prefixIcon: const Icon(Icons.email_outlined),
              errorText: viewModel.fieldErrors['email'],
              hintText: '[email protected]',
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) => viewModel.setEmail(v),
          ),

          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.phone,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
              prefixIcon: Icon(Icons.phone_outlined),
              hintText: '+56 9 1234 5678',
            ),
            keyboardType: TextInputType.phone,
            onChanged: (v) => viewModel.setPhone(v),
          ),

          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.address,
            decoration: const InputDecoration(
              labelText: 'Dirección Completa',
              prefixIcon: Icon(Icons.location_on_outlined),
              hintText: 'Av. Principal 123, Santiago',
            ),
            maxLines: 2,
            onChanged: (v) => viewModel.setAddress(v),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _websiteController,
            decoration: InputDecoration(
              labelText: 'Sitio Web',
              prefixIcon: const Icon(Icons.link_outlined),
              errorText: viewModel.fieldErrors['website'],
              hintText: 'https://www.miempresa.cl',
            ),
            keyboardType: TextInputType.url,
            onChanged: (v) => viewModel.website = v,
          ),

          const SizedBox(height: 32),

          // Especialidades
          Text(
            'Especialidades',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Define las áreas principales en las que tu empresa se especializa',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),

          _buildSpecialtiesManager(
            context,
            viewModel.specialties,
            (newSpecialties) => viewModel.setSpecialties(newSpecialties),
          ),

          const SizedBox(height: 32),

          // Misión y Visión
          Text(
            'Misión y Visión',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.missionStatement,
            decoration: const InputDecoration(
              labelText: 'Misión',
              prefixIcon: Icon(Icons.flag_outlined),
              hintText: 'Nuestra misión es...',
            ),
            maxLines: 3,
            onChanged: (v) => viewModel.setMissionStatement(v),
          ),

          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.visionStatement,
            decoration: const InputDecoration(
              labelText: 'Visión',
              prefixIcon: Icon(Icons.visibility_outlined),
              hintText: 'Nuestra visión es...',
            ),
            maxLines: 3,
            onChanged: (v) => viewModel.setVisionStatement(v),
          ),

          const SizedBox(height: 32),

          // Certificaciones
          Text(
            'Certificaciones',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),

          _buildCertificationsManager(
            context,
            viewModel.certifications,
            (newCerts) => viewModel.setCertifications(newCerts),
          ),

          const SizedBox(height: 32),

          // Redes Sociales
          Text(
            'Redes Sociales',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),

          _buildSocialMediaManager(
            context,
            viewModel.socialMedia,
            (newSocial) => viewModel.setSocialMedia(newSocial),
          ),

          const SizedBox(height: 32),

          // Botón Guardar
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
    List<Map<String, String>> certs,
    Function(List<Map<String, String>>) onUpdate,
  ) {
    final viewModel = context.watch<CompanyProfileViewModel>();
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              leading: Icon(Icons.verified_outlined),
              title: Text('Certificaciones'),
              subtitle: Text('Añade certificaciones con documentos de respaldo'),
            ),
            if (viewModel.isUploadingCertification)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: viewModel.certificationUploadProgress,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Subiendo documento... ${(viewModel.certificationUploadProgress * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ...certs.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final cert = entry.value;
                final name = cert['name'] ?? '';
                final documentUrl = cert['documentUrl'] ?? '';
                final hasDocument = documentUrl.isNotEmpty;

                return ListTile(
                  leading: Icon(
                    hasDocument ? Icons.verified : Icons.verified_outlined,
                    color: hasDocument ? theme.colorScheme.primary : null,
                  ),
                  title: Text(name),
                  subtitle: hasDocument
                      ? InkWell(
                          onTap: () => _launchURL(documentUrl),
                          child: Text(
                            'Ver documento',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      : const Text(
                          'Sin documento adjunto',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón para subir/cambiar documento
                      IconButton(
                        icon: Icon(
                          hasDocument ? Icons.upload_file : Icons.attach_file,
                          color: hasDocument ? theme.colorScheme.primary : null,
                        ),
                        tooltip: hasDocument ? 'Cambiar documento' : 'Adjuntar documento',
                        onPressed: viewModel.isUploadingCertification
                            ? null
                            : () async {
                                final userId = context
                                    .read<CompanyProfileViewModel>()
                                    .currentUserId;
                                if (userId == null) return;

                                final url = await viewModel
                                    .pickAndUploadCertificationDocument(userId);
                                if (url != null) {
                                  viewModel.updateCertificationDocument(index, url);
                                }
                              },
                      ),
                      // Botón para eliminar certificación
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          viewModel.removeCertificationAt(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: viewModel.isUploadingCertification
                          ? null
                          : () async {
                              final result =
                                  await _showAddCertificationDialog(context);
                              if (result != null) {
                                viewModel.addCertification(
                                  result['name']!,
                                  result['documentUrl'] ?? '',
                                );
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

  Future<Map<String, String>?> _showAddCertificationDialog(
    BuildContext context,
  ) async {
    String certName = '';
    final documentUrlNotifier = ValueNotifier<String?>(null);
    final viewModel = context.read<CompanyProfileViewModel>();
    final theme = Theme.of(context);

    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false, // Evitar cerrar mientras sube
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return ValueListenableBuilder<String?>(
            valueListenable: documentUrlNotifier,
            builder: (context, documentUrl, _) {
              return AlertDialog(
                title: const Text('Añadir certificación'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la certificación *',
                          hintText: 'Ej: ISO 9001, Empresa B, etc.',
                        ),
                        onChanged: (v) {
                          certName = v;
                          setDialogState(() {}); // Rebuild para actualizar botón
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Documento de respaldo (opcional)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (viewModel.isUploadingCertification)
                        Column(
                          children: [
                            LinearProgressIndicator(
                              value: viewModel.certificationUploadProgress,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Subiendo... ${(viewModel.certificationUploadProgress * 100).toStringAsFixed(0)}%',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        )
                      else if (documentUrl != null)
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Documento adjuntado',
                                style: TextStyle(color: theme.colorScheme.primary),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => documentUrlNotifier.value = null,
                            ),
                          ],
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: () async {
                            final userId = viewModel.currentUserId;
                            if (userId == null) return;

                            final url = await viewModel
                                .pickAndUploadCertificationDocument(userId);
                            if (url != null) {
                              documentUrlNotifier.value = url;
                            }
                            // Forzar rebuild del diálogo para mostrar estado actualizado
                            setDialogState(() {});
                          },
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Seleccionar archivo'),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Formatos: JPG, PNG (máx 10 MB)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: viewModel.isUploadingCertification
                        ? null
                        : () => Navigator.of(ctx).pop(),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: certName.trim().isEmpty || viewModel.isUploadingCertification
                        ? null
                        : () => Navigator.of(ctx).pop({
                              'name': certName.trim(),
                              'documentUrl': documentUrlNotifier.value ?? '',
                            }),
                    child: const Text('Añadir'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );

    documentUrlNotifier.dispose();
    return result;
  }

  Widget _buildSpecialtiesManager(
    BuildContext context,
    List<String> specialties,
    Function(List<String>) onUpdate,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              leading: Icon(Icons.star_outline),
              title: Text('Especialidades'),
            ),
            if (specialties.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'No hay especialidades definidas',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ...specialties.map(
                (specialty) => ListTile(
                  leading: const Icon(Icons.check_circle_outline, size: 20),
                  title: Text(specialty),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      final newSpecialties = List<String>.from(specialties)
                        ..remove(specialty);
                      onUpdate(newSpecialties);
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
                        String newSpecialty = '';
                        final result = await showDialog<String>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Añadir especialidad'),
                            content: StatefulBuilder(
                              builder: (context, setState) {
                                return TextFormField(
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Especialidad',
                                    hintText: 'ej: Desarrollo de Apps Móviles',
                                  ),
                                  onChanged: (v) {
                                    newSpecialty = v;
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
                                onPressed: () =>
                                    Navigator.of(ctx).pop(newSpecialty),
                                child: const Text('Añadir'),
                              ),
                            ],
                          ),
                        );
                        if (result != null && result.isNotEmpty) {
                          final newSpecialties = List<String>.from(specialties)
                            ..add(result);
                          onUpdate(newSpecialties);
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Añadir especialidad'),
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

  Widget _buildSocialMediaManager(
    BuildContext context,
    List<Map<String, String>> socialMedia,
    Function(List<Map<String, String>>) onUpdate,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              leading: Icon(Icons.share_outlined),
              title: Text('Redes Sociales'),
            ),
            if (socialMedia.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'No hay redes sociales definidas',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ...socialMedia.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                final platform = item['platform'] ?? '';
                final url = item['url'] ?? '';
                return ListTile(
                  leading: Icon(_getSocialIcon(platform), size: 20),
                  title: Text(platform),
                  subtitle: Text(
                    url.length > 40 ? '${url.substring(0, 40)}...' : url,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      final newSocial = List<Map<String, String>>.from(
                        socialMedia,
                      )..removeAt(idx);
                      onUpdate(newSocial);
                    },
                  ),
                );
              }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        String selectedPlatform = 'Facebook';
                        String socialUrl = '';
                        final result = await showDialog<Map<String, String>>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Añadir red social'),
                            content: StatefulBuilder(
                              builder: (context, setState) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    DropdownButtonFormField<String>(
                                      initialValue: selectedPlatform,
                                      decoration: const InputDecoration(
                                        labelText: 'Plataforma',
                                        prefixIcon: Icon(Icons.public),
                                      ),
                                      items:
                                          [
                                                'Facebook',
                                                'Instagram',
                                                'Twitter',
                                                'X',
                                                'LinkedIn',
                                                'YouTube',
                                                'TikTok',
                                              ]
                                              .map(
                                                (p) => DropdownMenuItem(
                                                  value: p,
                                                  child: Text(p),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (v) {
                                        setState(() {
                                          selectedPlatform = v!;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      autofocus: false,
                                      decoration: const InputDecoration(
                                        labelText: 'URL',
                                        hintText:
                                            'https://facebook.com/miempresa',
                                        prefixIcon: Icon(Icons.link),
                                      ),
                                      keyboardType: TextInputType.url,
                                      onChanged: (v) {
                                        socialUrl = v;
                                      },
                                      onFieldSubmitted: (v) {
                                        Navigator.of(ctx).pop({
                                          'platform': selectedPlatform,
                                          'url': v,
                                        });
                                      },
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
                                onPressed: () => Navigator.of(ctx).pop({
                                  'platform': selectedPlatform,
                                  'url': socialUrl,
                                }),
                                child: const Text('Añadir'),
                              ),
                            ],
                          ),
                        );
                        if (result != null &&
                            result['url']?.isNotEmpty == true) {
                          final newSocial = List<Map<String, String>>.from(
                            socialMedia,
                          )..add(result);
                          onUpdate(newSocial);
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Añadir red social'),
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

  // Selectores de cobertura geográfica
  Widget _buildRegionSelector(
    BuildContext context,
    CompanyProfileViewModel viewModel,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.map_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Regiones de Cobertura',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona las regiones donde opera tu empresa',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            if (viewModel.coverageRegions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No hay regiones seleccionadas',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: viewModel.coverageRegions
                    .map(
                      (region) => Chip(
                        label: Text(region),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          viewModel.removeCoverageRegion(region);
                        },
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () async {
                final selectedRegion = await showDialog<String>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Seleccionar Región'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: BusinessConstants.regions.length,
                        itemBuilder: (context, index) {
                          final region = BusinessConstants.regions[index];
                          final isSelected = viewModel.coverageRegions.contains(
                            region,
                          );
                          return ListTile(
                            title: Text(region),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : null,
                            onTap: () => Navigator.of(ctx).pop(region),
                          );
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                );
                if (selectedRegion != null) {
                  viewModel.addCoverageRegion(selectedRegion);
                }
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Añadir región'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommuneSelector(
    BuildContext context,
    CompanyProfileViewModel viewModel,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_city_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Comunas de Cobertura',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona las comunas específicas donde opera tu empresa',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            if (viewModel.coverageCommunes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No hay comunas seleccionadas',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: viewModel.coverageCommunes
                    .map(
                      (commune) => Chip(
                        label: Text(commune),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          viewModel.removeCoverageCommune(commune);
                        },
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () async {
                // Primero seleccionar región
                final region = await showDialog<String>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Seleccionar Región'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: BusinessConstants.regions.length,
                        itemBuilder: (context, index) {
                          final reg = BusinessConstants.regions[index];
                          final hasCommunes = BusinessConstants.hasCommunes(
                            reg,
                          );
                          return ListTile(
                            title: Text(reg),
                            enabled: hasCommunes,
                            trailing: !hasCommunes
                                ? const Tooltip(
                                    message: 'Sin comunas disponibles',
                                    child: Icon(
                                      Icons.info_outline,
                                      color: Colors.grey,
                                    ),
                                  )
                                : null,
                            onTap: hasCommunes
                                ? () => Navigator.of(ctx).pop(reg)
                                : null,
                          );
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                );

                if (region == null || !mounted) return;

                // Luego seleccionar comuna de esa región
                final communes = BusinessConstants.getCommunesForRegion(region);
                if (communes.isEmpty) return;

                // Guardar el context antes del await
                final dialogContext = context;
                final selectedCommune = await showDialog<String>(
                  context: dialogContext,
                  builder: (ctx) => AlertDialog(
                    title: Text('Comunas de $region'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: communes.length,
                        itemBuilder: (context, index) {
                          final commune = communes[index];
                          final isSelected = viewModel.coverageCommunes
                              .contains(commune);
                          return ListTile(
                            title: Text(commune),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : null,
                            onTap: () => Navigator.of(ctx).pop(commune),
                          );
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                );
                if (selectedCommune != null) {
                  viewModel.addCoverageCommune(selectedCommune);
                }
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Añadir comuna'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for URL launching
  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchMap(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildCertificationChip(
    BuildContext context,
    String name,
    String documentUrl,
    ThemeData theme,
  ) {
    final hasDocument = documentUrl.isNotEmpty;
    return InkWell(
      onTap: hasDocument ? () => _launchURL(documentUrl) : null,
      borderRadius: BorderRadius.circular(20),
      child: Chip(
        avatar: Icon(
          hasDocument ? Icons.verified : Icons.verified_outlined,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name),
            if (hasDocument) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.open_in_new,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
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
    );
  }

  String _getEmployeeCountRange(int count) {
    if (count == 0) return 'No especificado';
    if (count <= 10) return '1-10 empleados';
    if (count <= 50) return '11-50 empleados';
    if (count <= 200) return '51-200 empleados';
    if (count <= 500) return '201-500 empleados';
    return '500+ empleados';
  }

  IconData _getSocialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt;
      case 'twitter':
      case 'x':
        return Icons.tag;
      case 'linkedin':
        return Icons.business;
      case 'youtube':
        return Icons.play_circle_outline;
      case 'tiktok':
        return Icons.music_note;
      default:
        return Icons.public;
    }
  }
}
