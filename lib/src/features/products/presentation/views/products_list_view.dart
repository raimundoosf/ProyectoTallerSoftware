import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/features/products/domain/entities/product_filter.dart';
import 'package:flutter_app/src/features/products/presentation/viewmodels/products_list_viewmodel.dart';
import 'package:flutter_app/src/features/products/presentation/widgets/product_card.dart';
import 'package:flutter_app/src/features/products/presentation/widgets/product_search_bar.dart';
import 'package:flutter_app/src/features/products/presentation/widgets/product_filter_sheet.dart';

class ProductsListView extends StatefulWidget {
  const ProductsListView({super.key});

  @override
  State<ProductsListView> createState() => _ProductsListViewState();
}

class _ProductsListViewState extends State<ProductsListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsListViewModel>().loadAllProducts();
    });
  }

  void _showFilterSheet(BuildContext context, ProductsListViewModel viewModel) {
    showModalBottomSheet<ProductFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductFilterSheet(
        initialFilter: viewModel.filter,
        availableCategories: viewModel.getAvailableCategories(),
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

    return Consumer<ProductsListViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            // Barra de búsqueda
            ProductSearchBar(
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
    ProductsListViewModel viewModel,
  ) {
    final filter = viewModel.filter;
    final chips = <Widget>[];

    if (filter.typeFilter != ProductTypeFilter.all) {
      chips.add(
        _buildFilterChip(
          theme,
          filter.typeFilter.label,
          () => viewModel.updateFilter(
            filter.copyWith(typeFilter: ProductTypeFilter.all),
          ),
        ),
      );
    }

    if (filter.category != null) {
      chips.add(
        _buildFilterChip(
          theme,
          filter.category!,
          () => viewModel.updateFilter(filter.copyWith(clearCategory: true)),
        ),
      );
    }

    if (filter.minPrice != null || filter.maxPrice != null) {
      String priceLabel;
      if (filter.minPrice != null && filter.maxPrice != null) {
        priceLabel =
            '\$${filter.minPrice!.toInt()} - \$${filter.maxPrice!.toInt()}';
      } else if (filter.minPrice != null) {
        priceLabel = 'Desde \$${filter.minPrice!.toInt()}';
      } else {
        priceLabel = 'Hasta \$${filter.maxPrice!.toInt()}';
      }
      chips.add(
        _buildFilterChip(
          theme,
          priceLabel,
          () => viewModel.updateFilter(filter.copyWith(clearPriceRange: true)),
        ),
      );
    }

    if (filter.condition != null) {
      chips.add(
        _buildFilterChip(
          theme,
          filter.condition!,
          () => viewModel.updateFilter(filter.copyWith(clearCondition: true)),
        ),
      );
    }

    if (filter.serviceModality != null) {
      chips.add(
        _buildFilterChip(
          theme,
          filter.serviceModality!,
          () => viewModel.updateFilter(
            filter.copyWith(clearServiceModality: true),
          ),
        ),
      );
    }

    if (filter.certification != null) {
      chips.add(
        _buildFilterChip(
          theme,
          filter.certification!,
          () =>
              viewModel.updateFilter(filter.copyWith(clearCertification: true)),
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

  Widget _buildContent(ThemeData theme, ProductsListViewModel viewModel) {
    if (viewModel.isLoading && viewModel.products.isEmpty) {
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
              'Cargando publicaciones...',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.error != null && viewModel.allProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.3,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No se pudieron cargar las publicaciones',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
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
                onPressed: () => viewModel.loadAllProducts(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.allProducts.isEmpty) {
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
                  Icons.storefront_rounded,
                  size: 56,
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No hay publicaciones',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aún no hay productos o servicios publicados.\nSé el primero en publicar.',
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
    if (viewModel.products.isEmpty) {
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
                'No se encontraron productos o servicios\nque coincidan con tu búsqueda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: viewModel.clearAll,
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('Limpiar filtros'),
              ),
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
                  '${viewModel.products.length} resultado${viewModel.products.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                if (viewModel.filter.searchQuery.isNotEmpty ||
                    viewModel.filter.hasActiveFilters) ...[
                  Text(
                    ' de ${viewModel.allProducts.length}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Lista de productos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: viewModel.products.length,
              itemBuilder: (context, index) {
                final product = viewModel.products[index];
                return ProductCard(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }
}
