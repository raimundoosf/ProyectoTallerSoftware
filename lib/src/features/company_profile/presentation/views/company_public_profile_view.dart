import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/features/company_profile/presentation/viewmodels/company_profile_viewmodel.dart';
import 'package:flutter_app/src/features/products/presentation/views/company_products_list_view.dart';

/// Vista pública del perfil de una empresa (solo lectura)
/// Muestra el perfil de cualquier empresa y sus publicaciones
class CompanyPublicProfileView extends StatefulWidget {
  final String companyId;

  const CompanyPublicProfileView({super.key, required this.companyId});

  @override
  State<CompanyPublicProfileView> createState() =>
      _CompanyPublicProfileViewState();
}

class _CompanyPublicProfileViewState extends State<CompanyPublicProfileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanyProfileViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Perfil de Empresa')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.companyProfile == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Perfil de Empresa')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Empresa no encontrada',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          );
        }

        final profile = viewModel.companyProfile!;

        return Scaffold(
          appBar: AppBar(title: Text(profile.companyName), elevation: 0),
          body: Column(
            children: [
              // Header con logo y nombre
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      backgroundImage: profile.logoUrl.isNotEmpty
                          ? NetworkImage(profile.logoUrl)
                          : null,
                      child: profile.logoUrl.isEmpty
                          ? Icon(
                              Icons.business,
                              size: 40,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.companyName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (profile.industry.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              profile.industry,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab bar
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Perfil'),
                  Tab(text: 'Publicaciones'),
                ],
              ),

              // Contenido
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTab(context, profile),
                    CompanyProductsListView(companyId: widget.companyId),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileTab(BuildContext context, dynamic profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profile.companyDescription.isNotEmpty) ...[
            Text(
              'Descripción',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(profile.companyDescription),
            const SizedBox(height: 24),
          ],

          if (profile.specialties.isNotEmpty) ...[
            Text(
              'Especialidades',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.specialties
                  .map<Widget>(
                    (specialty) => Chip(
                      label: Text(specialty),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          if (profile.coverageLevel.isNotEmpty) ...[
            Text(
              'Cobertura',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Nivel: ${profile.coverageLevel}'),
            const SizedBox(height: 24),
          ],

          if (profile.website.isNotEmpty ||
              profile.email.isNotEmpty ||
              profile.phone.isNotEmpty) ...[
            Text(
              'Contacto',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (profile.website.isNotEmpty)
              ListTile(
                leading: Icon(Icons.language),
                title: Text(profile.website),
                contentPadding: EdgeInsets.zero,
              ),
            if (profile.email.isNotEmpty)
              ListTile(
                leading: Icon(Icons.email),
                title: Text(profile.email),
                contentPadding: EdgeInsets.zero,
              ),
            if (profile.phone.isNotEmpty)
              ListTile(
                leading: Icon(Icons.phone),
                title: Text(profile.phone),
                contentPadding: EdgeInsets.zero,
              ),
          ],
        ],
      ),
    );
  }
}
