// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_app/src/features/company_profile/domain/constants/business_constants.dart';
import 'package:flutter_app/src/features/company_profile/presentation/viewmodels/company_profile_viewmodel.dart';
import 'package:flutter_app/src/features/products/presentation/views/company_products_list_view.dart';
import 'package:flutter_app/src/features/contact/presentation/views/contact_form_view.dart';
import 'package:flutter_app/src/features/home/presentation/viewmodels/home_viewmodel.dart';

/// Vista unificada del perfil de empresa
/// Muestra el perfil de cualquier empresa con opciones de edición cuando es el perfil propio
class CompanyProfileView extends StatefulWidget {
  final String companyId;

  const CompanyProfileView({super.key, required this.companyId});

  @override
  State<CompanyProfileView> createState() => _CompanyProfileViewState();
}

class _CompanyProfileViewState extends State<CompanyProfileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers for edit mode
  TextEditingController? _companyNameController;
  TextEditingController? _companyDescriptionController;
  TextEditingController? _websiteController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyProfileViewModel>().loadCompanyProfile(
        widget.companyId,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _companyNameController?.dispose();
    _companyDescriptionController?.dispose();
    _websiteController?.dispose();
    super.dispose();
  }

  bool get _isOwner {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return currentUserId != null && currentUserId == widget.companyId;
  }

  Future<void> _launchUrl(String url) async {
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<CompanyProfileViewModel>(
      builder: (context, viewModel, child) {
        // If editing mode, show edit form
        if (_isEditing && _isOwner) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Editar Perfil de Empresa'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _isEditing = false),
              ),
            ),
            body: _buildEditForm(context, viewModel),
          );
        }

        if (viewModel.isLoading) {
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                _buildAppBar(theme, null),
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          );
        }

        if (viewModel.companyProfile == null) {
          return Scaffold(
            appBar: AppBar(),
            body: _isOwner
                ? _buildNoProfileView(context)
                : _buildCompanyNotFound(context, theme),
          );
        }

        final profile = viewModel.companyProfile!;

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildAppBar(theme, profile),
              _buildTabBar(theme),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(context, profile),
                CompanyProductsListView(companyId: widget.companyId),
              ],
            ),
          ),
          floatingActionButton:
              _isOwner && !_isEditing && _tabController.index == 0
              ? FloatingActionButton.extended(
                  onPressed: () {
                    _initControllersFromViewModel(viewModel);
                    setState(() => _isEditing = true);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Perfil'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildAppBar(ThemeData theme, dynamic profile) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, size: 20),
        ),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go('/');
          }
        },
      ),
      actions: _isOwner && profile != null
          ? [
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_vert, size: 20),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    final viewModel = context.read<CompanyProfileViewModel>();
                    _initControllersFromViewModel(viewModel);
                    setState(() => _isEditing = true);
                  } else if (value == 'new_product') {
                    context.go('/products/new');
                  } else if (value == 'logout') {
                    _showLogoutDialog(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 12),
                        Text('Editar perfil'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'new_product',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline),
                        SizedBox(width: 12),
                        Text('Nueva publicación'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded),
                        SizedBox(width: 12),
                        Text('Cerrar sesión'),
                      ],
                    ),
                  ),
                ],
              ),
            ]
          : !_isOwner && profile != null && profile.email.isNotEmpty
          ? [
              // Solo mostrar botón de contacto para usuarios Consumidor
              Consumer<HomeViewModel>(
                builder: (context, homeVm, child) {
                  if (homeVm.currentRole != 'Consumidor') {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.email_outlined, size: 20),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ContactFormView(
                            companyId: widget.companyId,
                            companyName: profile.companyName,
                          ),
                        ),
                      );
                    },
                    tooltip: 'Contactar empresa',
                  );
                },
              ),
            ]
          : null,
      flexibleSpace: profile != null
          ? FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -30,
                    bottom: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 47,
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                backgroundImage: profile.logoUrl.isNotEmpty
                                    ? NetworkImage(profile.logoUrl)
                                    : null,
                                child: profile.logoUrl.isEmpty
                                    ? Icon(
                                        Icons.business_rounded,
                                        size: 48,
                                        color: theme.colorScheme.primary,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.companyName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (profile.industry.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      profile.industry,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                                if (profile.foundedYear > 0) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Desde ${profile.foundedYear}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.info_outline_rounded), text: 'Información'),
            Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Publicaciones'),
          ],
        ),
        theme.colorScheme.surface,
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

  Widget _buildCompanyNotFound(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.business_outlined,
              size: 64,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Empresa no encontrada',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esta empresa no existe o fue eliminada',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context, dynamic profile) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profile.companyDescription.isNotEmpty) ...[
            _buildSectionCard(
              theme,
              icon: Icons.description_outlined,
              title: 'Sobre nosotros',
              child: Text(
                profile.companyDescription,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  height: 1.6,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (profile.specialties.isNotEmpty) ...[
            _buildSectionCard(
              theme,
              icon: Icons.star_outline_rounded,
              title: 'Especialidades',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.specialties
                    .map<Widget>(
                      (specialty) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primaryContainer,
                              theme.colorScheme.primaryContainer.withValues(
                                alpha: 0.7,
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          specialty,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (profile.coverageLevel.isNotEmpty) ...[
            _buildSectionCard(
              theme,
              icon: Icons.location_on_outlined,
              title: 'Cobertura',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              profile.coverageLevel == 'Nacional'
                                  ? Icons.public
                                  : profile.coverageLevel == 'Regional'
                                  ? Icons.map_outlined
                                  : Icons.location_city,
                              size: 18,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              profile.coverageLevel,
                              style: TextStyle(
                                color: theme.colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (profile.coverageLevel == 'Regional' &&
                      profile.coverageRegions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: profile.coverageRegions
                          .map<Widget>(
                            (region) => Chip(
                              label: Text(region),
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (profile.coverageLevel == 'Comunal' &&
                      profile.coverageCommunes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: profile.coverageCommunes
                          .map<Widget>(
                            (commune) => Chip(
                              label: Text(commune),
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (profile.certifications.isNotEmpty) ...[
            _buildSectionCard(
              theme,
              icon: Icons.verified_outlined,
              title: 'Certificaciones',
              child: Column(
                children: profile.certifications
                    .map<Widget>(
                      (cert) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified,
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                cert['name'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if ((cert['documentUrl'] ?? '').isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.open_in_new, size: 18),
                                onPressed: () =>
                                    _launchUrl(cert['documentUrl'] ?? ''),
                                tooltip: 'Ver documento',
                              ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (profile.website.isNotEmpty ||
              profile.email.isNotEmpty ||
              profile.phone.isNotEmpty) ...[
            _buildSectionCard(
              theme,
              icon: Icons.contact_mail_outlined,
              title: 'Contacto',
              child: Column(
                children: [
                  if (profile.website.isNotEmpty)
                    _buildContactTile(
                      theme,
                      icon: Icons.language_rounded,
                      label: 'Sitio web',
                      value: profile.website,
                      onTap: () => _launchUrl(profile.website),
                    ),
                  if (profile.email.isNotEmpty)
                    _buildContactTile(
                      theme,
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: profile.email,
                      onTap: () => _launchEmail(profile.email),
                    ),
                  if (profile.phone.isNotEmpty)
                    _buildContactTile(
                      theme,
                      icon: Icons.phone_outlined,
                      label: 'Teléfono',
                      value: profile.phone,
                      onTap: () => _launchPhone(profile.phone),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (profile.employeeCount > 0) ...[
            _buildSectionCard(
              theme,
              icon: Icons.people_outline_rounded,
              title: 'Información adicional',
              child: Row(
                children: [
                  _buildInfoChip(
                    theme,
                    Icons.groups_outlined,
                    _getEmployeeCountRange(profile.employeeCount),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_isOwner) ...[
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
            const SizedBox(height: 90),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildContactTile(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

  // Edit form (extracted from CompanyProfileScreen)
  Widget _buildEditForm(
    BuildContext context,
    CompanyProfileViewModel viewModel,
  ) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Logo
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
          const SizedBox(height: 24),

          // Sección: Información Básica
          Text(
            'Información Básica',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _companyNameController,
            decoration: InputDecoration(
              labelText: 'Nombre de la Empresa *',
              prefixIcon: const Icon(Icons.business_outlined),
              errorText: viewModel.fieldErrors['companyName'],
            ),
            onChanged: (v) => viewModel.companyName = v,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            key: ValueKey('industry-${viewModel.industry}'),
            initialValue: viewModel.industry,
            decoration: InputDecoration(
              labelText: 'Industria / Rubro *',
              prefixIcon: const Icon(Icons.business_center_outlined),
              helperText: 'Selecciona la industria principal de tu empresa',
              errorText: viewModel.fieldErrors['industry'],
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
              viewModel.setIndustry(newValue);
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _companyDescriptionController,
            decoration: InputDecoration(
              labelText: 'Descripción *',
              prefixIcon: const Icon(Icons.description_outlined),
              errorText: viewModel.fieldErrors['companyDescription'],
              helperText: 'Describe tu empresa y sus servicios',
            ),
            maxLines: 3,
            onChanged: (v) => viewModel.companyDescription = v,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _websiteController,
            decoration: const InputDecoration(
              labelText: 'Sitio Web',
              prefixIcon: Icon(Icons.language_outlined),
              helperText: 'URL de tu sitio web (opcional)',
            ),
            onChanged: (v) => viewModel.website = v,
            keyboardType: TextInputType.url,
          ),

          const SizedBox(height: 32),

          // Sección: Información de Contacto
          Text(
            'Información de Contacto',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.email,
            decoration: InputDecoration(
              labelText: 'Correo Electrónico',
              prefixIcon: const Icon(Icons.email_outlined),
              helperText: 'Email de contacto para clientes',
              errorText: viewModel.fieldErrors['email'],
            ),
            onChanged: (v) => viewModel.email = v,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.phone,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
              prefixIcon: Icon(Icons.phone_outlined),
              helperText: 'Número de contacto',
            ),
            onChanged: (v) => viewModel.phone = v,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.address,
            decoration: const InputDecoration(
              labelText: 'Dirección',
              prefixIcon: Icon(Icons.location_on_outlined),
              helperText: 'Dirección física de la empresa',
            ),
            onChanged: (v) => viewModel.address = v,
            maxLines: 2,
          ),

          const SizedBox(height: 32),

          // Sección: Detalles Adicionales
          Text(
            'Detalles Adicionales',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.rut,
            decoration: InputDecoration(
              labelText: 'RUT',
              prefixIcon: const Icon(Icons.badge_outlined),
              helperText: 'RUT de la empresa (formato: 12.345.678-9)',
              errorText: viewModel.fieldErrors['rut'],
            ),
            onChanged: (v) => viewModel.rut = v,
          ),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.foundedYear > 0
                ? viewModel.foundedYear.toString()
                : '',
            decoration: const InputDecoration(
              labelText: 'Año de Fundación',
              prefixIcon: Icon(Icons.calendar_today_outlined),
              helperText: 'Año en que se fundó la empresa',
            ),
            onChanged: (v) {
              final year = int.tryParse(v);
              if (year != null) viewModel.foundedYear = year;
            },
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.employeeCount > 0
                ? viewModel.employeeCount.toString()
                : '',
            decoration: const InputDecoration(
              labelText: 'Número de Empleados',
              prefixIcon: Icon(Icons.people_outlined),
              helperText: 'Cantidad aproximada de empleados',
            ),
            onChanged: (v) {
              final count = int.tryParse(v);
              if (count != null) viewModel.employeeCount = count;
            },
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 32),

          // Sección: Cobertura Geográfica
          Text(
            'Cobertura Geográfica',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            key: ValueKey('coverage-${viewModel.coverageLevel}'),
            initialValue: viewModel.coverageLevel,
            decoration: const InputDecoration(
              labelText: 'Nivel de Cobertura',
              prefixIcon: Icon(Icons.map_outlined),
              helperText: 'Alcance geográfico de tus servicios',
            ),
            items: const [
              DropdownMenuItem(value: 'Nacional', child: Text('Nacional')),
              DropdownMenuItem(value: 'Regional', child: Text('Regional')),
              DropdownMenuItem(value: 'Comunal', child: Text('Comunal')),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                viewModel.setCoverageLevel(newValue);
              }
            },
          ),

          const SizedBox(height: 32),

          // Sección: Misión y Visión
          Text(
            'Misión y Visión',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.missionStatement,
            decoration: const InputDecoration(
              labelText: 'Misión',
              prefixIcon: Icon(Icons.flag_outlined),
              helperText: '¿Cuál es el propósito de tu empresa?',
            ),
            maxLines: 3,
            onChanged: (v) => viewModel.missionStatement = v,
          ),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: viewModel.visionStatement,
            decoration: const InputDecoration(
              labelText: 'Visión',
              prefixIcon: Icon(Icons.visibility_outlined),
              helperText: '¿Hacia dónde va tu empresa?',
            ),
            maxLines: 3,
            onChanged: (v) => viewModel.visionStatement = v,
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () async {
                      final vm = context.read<CompanyProfileViewModel>();
                      final messenger = ScaffoldMessenger.of(context);
                      final colorScheme = Theme.of(context).colorScheme;

                      final success = await vm.saveFromForm();
                      if (!mounted) return;
                      if (success) {
                        setState(() => _isEditing = false);
                        messenger.showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            backgroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            content: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: colorScheme.onPrimary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Perfil de empresa actualizado con éxito',
                                    style: TextStyle(
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        final error =
                            vm.error ?? 'Error al guardar los cambios';
                        messenger.showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            backgroundColor: colorScheme.error,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            content: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: colorScheme.onError,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    error,
                                    style: TextStyle(
                                      color: colorScheme.onError,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: viewModel.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Guardar Cambios'),
            ),
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
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
