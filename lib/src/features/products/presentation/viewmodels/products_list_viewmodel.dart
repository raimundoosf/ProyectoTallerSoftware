import 'package:flutter/foundation.dart';
import 'package:flutter_app/src/features/products/domain/entities/product.dart';
import 'package:flutter_app/src/features/products/domain/repositories/products_repository.dart';

class ProductsListViewModel extends ChangeNotifier {
  final ProductsRepository _repository;

  ProductsListViewModel(this._repository);

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga todos los productos/servicios
  Future<void> loadAllProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _repository.getAllProducts();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar publicaciones: $e';
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga productos/servicios de una empresa específica
  Future<void> loadProductsByCompany(String companyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _repository.getProductsByCompany(companyId);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar publicaciones: $e';
      _products = [];
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
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar publicación: $e';
      notifyListeners();
      rethrow;
    }
  }
}
