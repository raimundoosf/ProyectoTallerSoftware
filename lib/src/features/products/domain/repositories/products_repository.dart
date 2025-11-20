import 'package:flutter_app/src/features/products/domain/entities/product.dart';

abstract class ProductsRepository {
  Future<String> createProduct(Product product, List<String> localImagePaths);
}
