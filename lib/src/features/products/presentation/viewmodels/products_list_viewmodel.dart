import 'package:flutter/foundation.dart';
import 'package:flutter_app/src/features/products/domain/entities/product.dart';
import 'package:flutter_app/src/features/products/domain/entities/product_filter.dart';
import 'package:flutter_app/src/features/products/domain/repositories/products_repository.dart';

class ProductsListViewModel extends ChangeNotifier {
  final ProductsRepository _repository;

  ProductsListViewModel(this._repository);

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  ProductFilter _filter = const ProductFilter();

  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _allProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ProductFilter get filter => _filter;

  /// Carga todos los productos/servicios
  Future<void> loadAllProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allProducts = await _repository.getAllProducts();
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar publicaciones: $e';
      _allProducts = [];
      _filteredProducts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Aplica los filtros a la lista de productos
  void _applyFilters() {
    _filteredProducts = _allProducts.where((product) {
      // Filtro por texto de búsqueda
      if (_filter.searchQuery.isNotEmpty) {
        final query = _filter.searchQuery.toLowerCase();
        final matchesName = product.name.toLowerCase().contains(query);
        final matchesDescription = product.description.toLowerCase().contains(
          query,
        );
        final matchesTags = product.tags.any(
          (tag) => tag.toLowerCase().contains(query),
        );
        final matchesCategory = product.isService
            ? product.serviceCategory.toLowerCase().contains(query)
            : product.productCategory.toLowerCase().contains(query);

        if (!matchesName &&
            !matchesDescription &&
            !matchesTags &&
            !matchesCategory) {
          return false;
        }
      }

      // Filtro por tipo (producto/servicio)
      if (_filter.typeFilter == ProductTypeFilter.products &&
          product.isService) {
        return false;
      }
      if (_filter.typeFilter == ProductTypeFilter.services &&
          !product.isService) {
        return false;
      }

      // Filtro por categoría
      if (_filter.category != null) {
        final productCategory = product.isService
            ? product.serviceCategory
            : product.productCategory;
        if (productCategory != _filter.category) {
          return false;
        }
      }

      // Filtro por rango de precio
      if (!product.priceOnRequest) {
        if (_filter.minPrice != null && product.price < _filter.minPrice!) {
          return false;
        }
        if (_filter.maxPrice != null && product.price > _filter.maxPrice!) {
          return false;
        }
      }

      // Filtro por precio a convenir
      if (_filter.priceOnRequest != null) {
        if (_filter.priceOnRequest! && !product.priceOnRequest) {
          return false;
        }
        if (!_filter.priceOnRequest! && product.priceOnRequest) {
          return false;
        }
      }

      // Filtro por condición (solo productos)
      if (_filter.condition != null) {
        // Si el filtro es por condición, excluir servicios y productos que no coincidan
        if (product.isService) {
          return false;
        }
        if (product.condition != _filter.condition) {
          return false;
        }
      }

      // Filtro por modalidad (solo servicios)
      if (_filter.serviceModality != null) {
        // Si el filtro es por modalidad, excluir productos y servicios que no coincidan
        if (!product.isService) {
          return false;
        }
        if (product.serviceModality != _filter.serviceModality) {
          return false;
        }
      }

      // Filtro por certificación
      if (_filter.certification != null) {
        if (!product.certifications.contains(_filter.certification)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Actualiza el texto de búsqueda
  void updateSearchQuery(String query) {
    _filter = _filter.copyWith(searchQuery: query);
    _applyFilters();
    notifyListeners();
  }

  /// Actualiza el filtro completo
  void updateFilter(ProductFilter newFilter) {
    _filter = newFilter;
    _applyFilters();
    notifyListeners();
  }

  /// Limpia todos los filtros
  void clearFilters() {
    _filter = _filter.clearFilters();
    _applyFilters();
    notifyListeners();
  }

  /// Limpia todo (búsqueda y filtros)
  void clearAll() {
    _filter = const ProductFilter();
    _applyFilters();
    notifyListeners();
  }

  /// Obtiene las categorías disponibles según el tipo seleccionado
  List<String> getAvailableCategories() {
    final Set<String> categories = {};
    for (final product in _allProducts) {
      if (_filter.typeFilter == ProductTypeFilter.products &&
          product.isService) {
        continue;
      }
      if (_filter.typeFilter == ProductTypeFilter.services &&
          !product.isService) {
        continue;
      }
      final category = product.isService
          ? product.serviceCategory
          : product.productCategory;
      if (category.isNotEmpty) {
        categories.add(category);
      }
    }
    return categories.toList()..sort();
  }

  /// Carga productos/servicios de una empresa específica
  Future<void> loadProductsByCompany(String companyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allProducts = await _repository.getProductsByCompany(companyId);
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar publicaciones: $e';
      _allProducts = [];
      _filteredProducts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresca la lista de productos
  Future<void> refresh() async {
    await loadAllProducts();
  }

  /// Elimina un producto
  Future<void> deleteProduct(String productId) async {
    try {
      await _repository.deleteProduct(productId);
      // Actualizar la lista local
      _allProducts.removeWhere((p) => p.id == productId);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar publicación: $e';
      notifyListeners();
      rethrow;
    }
  }
}
