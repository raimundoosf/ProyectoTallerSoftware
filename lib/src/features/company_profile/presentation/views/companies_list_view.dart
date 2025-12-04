import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/src/features/company_profile/domain/entities/company_filter.dart';
import 'package:flutter_app/src/features/company_profile/presentation/viewmodels/companies_list_viewmodel.dart';
import 'package:flutter_app/src/features/company_profile/presentation/widgets/company_search_bar.dart';
import 'package:flutter_app/src/features/company_profile/presentation/widgets/company_filter_sheet.dart';
import 'package:flutter_app/src/features/company_profile/presentation/widgets/company_card.dart';

class CompaniesListView extends StatefulWidget {
  const CompaniesListView({super.key});

  @override
  State<CompaniesListView> createState() => _CompaniesListViewState();
}

class _CompaniesListViewState extends State<CompaniesListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompaniesListViewModel>().loadAllCompanies();
    });
  }

  void _showFilterSheet(
    BuildContext context,
    CompaniesListViewModel viewModel,
  ) {
    showModalBottomSheet<CompanyFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CompanyFilterSheet(
        initialFilter: viewModel.filter,
        availableIndustries: viewModel.getAvailableIndustries(),
      ),
    ).then((result) {
      if (result != null) {
        viewModel.updateFilter(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<CompaniesListViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            // Barra de búsqueda
            CompanySearchBar(
              filter: viewModel.filter,
              onSearchChanged: viewModel.updateSearchQuery,
              onFilterTap: () => _showFilterSheet(context, viewModel),
              onClearFilters: viewModel.filter.hasActiveFilters
                  ? viewModel.clearFilters
                  : null,
            ),

            // Chips de filtros activos
            if (viewModel.filter.hasActiveFilters)
              _buildActiveFiltersBar(theme, viewModel),

            // Contenido principal
            Expanded(child: _buildContent(theme, viewModel)),
          ],
        );
      },
    );
  }

  Widget _buildActiveFiltersBar(
    ThemeData theme,
    CompaniesListViewModel viewModel,
  ) {
    final filter = viewModel.filter;
    final chips = <Widget>[];

    if (filter.industry != null) {
      chips.add(
        _buildFilterChip(
          theme,
          filter.industry!,
          () => viewModel.updateFilter(filter.copyWith(clearIndustry: true)),
        ),
      );
    }

    if (filter.coverageLevel != null) {
      chips.add(
        _buildFilterChip(
          theme,
          filter.coverageLevel!,
          () =>
              viewModel.updateFilter(filter.copyWith(clearCoverageLevel: true)),
        ),
      );
    }

    if (filter.coverageRegions.isNotEmpty) {
      for (final region in filter.coverageRegions) {
        chips.add(
          _buildFilterChip(theme, region, () {
            final newRegions = List<String>.from(filter.coverageRegions)
              ..remove(region);
            viewModel.updateFilter(
              filter.copyWith(coverageRegions: newRegions),
            );
          }),
        );
      }
    }

    if (filter.certifications.isNotEmpty) {
      for (final cert in filter.certifications) {
        chips.add(
          _buildFilterChip(theme, cert, () {
            final newCerts = List<String>.from(filter.certifications)
              ..remove(cert);
            viewModel.updateFilter(filter.copyWith(certifications: newCerts));
          }),
        );
      }
    }

    if (filter.minEmployees != null || filter.maxEmployees != null) {
      String label;
      if (filter.minEmployees != null && filter.maxEmployees != null) {
        label = '${filter.minEmployees}-${filter.maxEmployees} empleados';
      } else if (filter.minEmployees != null) {
        label = 'Desde ${filter.minEmployees} empleados';
      } else {
        label = 'Hasta ${filter.maxEmployees} empleados';
      }
      chips.add(
        _buildFilterChip(
          theme,
          label,
          () =>
              viewModel.updateFilter(filter.copyWith(clearEmployeeRange: true)),
        ),
      );
    }

    if (filter.minFoundedYear != null || filter.maxFoundedYear != null) {
      String label;
      if (filter.minFoundedYear != null && filter.maxFoundedYear != null) {
        label = '${filter.minFoundedYear}-${filter.maxFoundedYear}';
      } else if (filter.minFoundedYear != null) {
        label = 'Desde ${filter.minFoundedYear}';
      } else {
        label = 'Hasta ${filter.maxFoundedYear}';
      }
      chips.add(
        _buildFilterChip(
          theme,
          label,
          () => viewModel.updateFilter(
            filter.copyWith(clearFoundedYearRange: true),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      color: theme.colorScheme.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...chips,
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: viewModel.clearFilters,
              icon: const Icon(Icons.clear_all_rounded, size: 18),
              label: const Text('Limpiar'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    ThemeData theme,
    String label,
    VoidCallback onRemove,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close_rounded, size: 16),
        onDeleted: onRemove,
        backgroundColor: theme.colorScheme.primaryContainer,
        labelStyle: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontSize: 12,
        ),
        deleteIconColor: theme.colorScheme.onPrimaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildContent(ThemeData theme, CompaniesListViewModel viewModel) {
    if (viewModel.isLoading && viewModel.companies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando empresas...',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.error != null && viewModel.allCompanies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.3,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Error al cargar',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                viewModel.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: viewModel.loadAllCompanies,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Sin empresas registradas
    if (viewModel.allCompanies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.business_rounded,
                  size: 56,
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No hay empresas',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aún no hay empresas registradas.\nSé el primero en registrarte.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Lista vacía después de aplicar filtros
    if (viewModel.companies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 56,
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Sin resultados',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No se encontraron empresas\nque coincidan con tu búsqueda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              if (viewModel.filter.hasActiveFilters) ...[
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: viewModel.clearAll,
                  icon: const Icon(Icons.clear_all_rounded, size: 18),
                  label: const Text('Limpiar filtros'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      color: theme.colorScheme.primary,
      child: Column(
        children: [
          // Contador de resultados
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${viewModel.companies.length} empresa${viewModel.companies.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                if (viewModel.filter.searchQuery.isNotEmpty ||
                    viewModel.filter.hasActiveFilters) ...[
                  Text(
                    ' de ${viewModel.allCompanies.length}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Lista de empresas
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: viewModel.companies.length,
              itemBuilder: (context, index) {
                final companyWithId = viewModel.companies[index];
                return CompanyCard(
                  company: companyWithId.profile,
                  onTap: () {
                    context.go('/company/${companyWithId.id}');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
