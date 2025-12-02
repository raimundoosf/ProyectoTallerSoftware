import 'package:flutter/material.dart';
import 'package:flutter_app/src/core/config/certifications.dart';
import 'package:flutter_app/src/core/config/product_categories.dart';
import 'package:flutter_app/src/features/products/domain/entities/product_filter.dart';

class ProductFilterSheet extends StatefulWidget {
  final ProductFilter initialFilter;
  final List<String> availableCategories;

  const ProductFilterSheet({
    super.key,
    required this.initialFilter,
    required this.availableCategories,
  });

  @override
  State<ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<ProductFilterSheet> {
  late ProductFilter _filter;
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    if (_filter.minPrice != null) {
      _minPriceController.text = _filter.minPrice!.toInt().toString();
    }
    if (_filter.maxPrice != null) {
      _maxPriceController.text = _filter.maxPrice!.toInt().toString();
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _updateTypeFilter(ProductTypeFilter type) {
    setState(() {
      _filter = _filter.copyWith(
        typeFilter: type,
        clearCategory: true,
        clearCondition: true,
        clearServiceModality: true,
      );
    });
  }

  List<String> _getCategoriesForCurrentType() {
    if (_filter.typeFilter == ProductTypeFilter.products) {
      return productCategories;
    } else if (_filter.typeFilter == ProductTypeFilter.services) {
      return serviceCategories;
    }
    // Para "todos", mostrar categorías que existen en los productos cargados
    return widget.availableCategories;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtros',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    if (_filter.hasActiveFilters)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _filter = _filter.clearFilters();
                            _minPriceController.clear();
                            _maxPriceController.clear();
                          });
                        },
                        child: const Text('Limpiar'),
                      ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tipo de publicación
                  _buildSectionTitle(theme, 'Tipo'),
                  const SizedBox(height: 12),
                  _buildTypeFilter(theme),
                  const SizedBox(height: 24),

                  // Categoría
                  _buildSectionTitle(theme, 'Categoría'),
                  const SizedBox(height: 12),
                  _buildCategoryFilter(theme),
                  const SizedBox(height: 24),

                  // Rango de precio
                  _buildSectionTitle(theme, 'Rango de precio'),
                  const SizedBox(height: 12),
                  _buildPriceRangeFilter(theme),
                  const SizedBox(height: 24),

                  // Condición (solo para productos)
                  if (_filter.typeFilter != ProductTypeFilter.services) ...[
                    _buildSectionTitle(theme, 'Condición del producto'),
                    const SizedBox(height: 12),
                    _buildConditionFilter(theme),
                    const SizedBox(height: 24),
                  ],

                  // Modalidad (solo para servicios)
                  if (_filter.typeFilter != ProductTypeFilter.products) ...[
                    _buildSectionTitle(theme, 'Modalidad del servicio'),
                    const SizedBox(height: 12),
                    _buildModalityFilter(theme),
                    const SizedBox(height: 24),
                  ],

                  // Certificaciones
                  _buildSectionTitle(theme, 'Certificaciones'),
                  const SizedBox(height: 12),
                  _buildCertificationFilter(theme),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Footer con botón aplicar
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPadding),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    // Actualizar precios antes de aplicar
                    final minPrice = double.tryParse(_minPriceController.text);
                    final maxPrice = double.tryParse(_maxPriceController.text);
                    final finalFilter = _filter.copyWith(
                      minPrice: minPrice,
                      maxPrice: maxPrice,
                      clearPriceRange: minPrice == null && maxPrice == null,
                    );
                    Navigator.pop(context, finalFilter);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _filter.hasActiveFilters
                        ? 'Aplicar filtros (${_filter.activeFilterCount})'
                        : 'Aplicar filtros',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildTypeFilter(ThemeData theme) {
    return SegmentedButton<ProductTypeFilter>(
      segments: ProductTypeFilter.values.map((type) {
        return ButtonSegment(value: type, label: Text(type.label));
      }).toList(),
      selected: {_filter.typeFilter},
      onSelectionChanged: (selected) {
        _updateTypeFilter(selected.first);
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildCategoryFilter(ThemeData theme) {
    final categories = _getCategoriesForCurrentType();

    if (categories.isEmpty) {
      return Text(
        'No hay categorías disponibles',
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = _filter.category == category;
        return FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _filter = _filter.copyWith(
                category: selected ? category : null,
                clearCategory: !selected,
              );
            });
          },
          showCheckmark: false,
          labelStyle: TextStyle(
            fontSize: 13,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          selectedColor: theme.colorScheme.primaryContainer,
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceRangeFilter(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Mínimo',
              prefixText: '\$ ',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '—',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: TextField(
            controller: _maxPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Máximo',
              prefixText: '\$ ',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionFilter(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: productConditions.map((condition) {
        final isSelected = _filter.condition == condition;
        return FilterChip(
          label: Text(condition),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _filter = _filter.copyWith(
                condition: selected ? condition : null,
                clearCondition: !selected,
              );
            });
          },
          showCheckmark: false,
          labelStyle: TextStyle(
            fontSize: 13,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          selectedColor: theme.colorScheme.primaryContainer,
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModalityFilter(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: serviceModalities.map((modality) {
        final isSelected = _filter.serviceModality == modality;
        return FilterChip(
          label: Text(modality),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _filter = _filter.copyWith(
                serviceModality: selected ? modality : null,
                clearServiceModality: !selected,
              );
            });
          },
          showCheckmark: false,
          labelStyle: TextStyle(
            fontSize: 13,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          selectedColor: theme.colorScheme.primaryContainer,
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCertificationFilter(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableCertifications.map((certification) {
        final isSelected = _filter.certification == certification;
        return FilterChip(
          label: Text(certification),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _filter = _filter.copyWith(
                certification: selected ? certification : null,
                clearCertification: !selected,
              );
            });
          },
          showCheckmark: false,
          avatar: Icon(
            Icons.verified_rounded,
            size: 16,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          labelStyle: TextStyle(
            fontSize: 13,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          selectedColor: theme.colorScheme.primaryContainer,
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }).toList(),
    );
  }
}
