/// Modelo para encapsular los filtros de búsqueda de productos/servicios
class ProductFilter {
  final String searchQuery;
  final ProductTypeFilter typeFilter;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final String? condition;
  final String? serviceModality;
  final bool? priceOnRequest;
  final String? certification;

  const ProductFilter({
    this.searchQuery = '',
    this.typeFilter = ProductTypeFilter.all,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.condition,
    this.serviceModality,
    this.priceOnRequest,
    this.certification,
  });

  /// Crea una copia con nuevos valores
  ProductFilter copyWith({
    String? searchQuery,
    ProductTypeFilter? typeFilter,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? serviceModality,
    bool? priceOnRequest,
    String? certification,
    bool clearCategory = false,
    bool clearCondition = false,
    bool clearServiceModality = false,
    bool clearPriceRange = false,
    bool clearPriceOnRequest = false,
    bool clearCertification = false,
  }) {
    return ProductFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter: typeFilter ?? this.typeFilter,
      category: clearCategory ? null : (category ?? this.category),
      minPrice: clearPriceRange ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPriceRange ? null : (maxPrice ?? this.maxPrice),
      condition: clearCondition ? null : (condition ?? this.condition),
      serviceModality: clearServiceModality
          ? null
          : (serviceModality ?? this.serviceModality),
      priceOnRequest: clearPriceOnRequest
          ? null
          : (priceOnRequest ?? this.priceOnRequest),
      certification: clearCertification
          ? null
          : (certification ?? this.certification),
    );
  }

  /// Verifica si hay algún filtro activo (excluyendo búsqueda)
  bool get hasActiveFilters =>
      typeFilter != ProductTypeFilter.all ||
      category != null ||
      minPrice != null ||
      maxPrice != null ||
      condition != null ||
      serviceModality != null ||
      priceOnRequest != null ||
      certification != null;

  /// Cuenta el número de filtros activos
  int get activeFilterCount {
    int count = 0;
    if (typeFilter != ProductTypeFilter.all) count++;
    if (category != null) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (condition != null) count++;
    if (serviceModality != null) count++;
    if (priceOnRequest != null) count++;
    if (certification != null) count++;
    return count;
  }

  /// Limpia todos los filtros
  ProductFilter clearAll() {
    return const ProductFilter();
  }

  /// Limpia solo los filtros (mantiene búsqueda)
  ProductFilter clearFilters() {
    return ProductFilter(searchQuery: searchQuery);
  }
}

/// Tipo de filtro para productos/servicios
enum ProductTypeFilter {
  all,
  products,
  services;

  String get label {
    switch (this) {
      case ProductTypeFilter.all:
        return 'Todos';
      case ProductTypeFilter.products:
        return 'Productos';
      case ProductTypeFilter.services:
        return 'Servicios';
    }
  }
}
