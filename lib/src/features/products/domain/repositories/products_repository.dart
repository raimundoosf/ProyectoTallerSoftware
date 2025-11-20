import 'package:flutter_app/src/features/products/domain/entities/product.dart';

abstract class ProductsRepository {
  Future<String> createProduct(Product product, List<String> localImagePaths);

  /// Obtiene todos los productos/servicios publicados
  Future<List<Product>> getAllProducts();

  /// Obtiene productos/servicios de una empresa específica
  Future<List<Product>> getProductsByCompany(String companyId);
}
