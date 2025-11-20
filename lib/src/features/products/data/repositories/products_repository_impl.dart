import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_app/src/features/products/domain/entities/product.dart';
import 'package:flutter_app/src/features/products/domain/repositories/products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProductsRepositoryImpl(this._firestore, this._storage);

  @override
  Future<String> createProduct(
    Product product,
    List<String> localImagePaths,
  ) async {
    // upload images first
    final now = DateTime.now().millisecondsSinceEpoch;
    final uploadedUrls = <String>[];
    for (var p in localImagePaths) {
      final file = File(p);
      final filename = p.split(Platform.pathSeparator).last;
      final ref = _storage.ref().child(
        'products/${product.companyId}/$now/$filename',
      );
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();
      uploadedUrls.add(url);
    }

    final docRef = _firestore.collection('products').doc();
    final data = product.toMap()..['imageUrls'] = uploadedUrls;
    await docRef.set(data);
    return docRef.id;
  }

  @override
  Future<List<Product>> getAllProducts() async {
    final snapshot = await _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<Product>> getProductsByCompany(String companyId) async {
    final snapshot = await _firestore
        .collection('products')
        .where('companyId', isEqualTo: companyId)
        // Temporalmente sin orderBy hasta que el índice esté listo
        // .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> updateProduct(
    String productId,
    Product product,
    List<String> localImagePaths,
  ) async {
    // Subir nuevas imágenes si existen
    final uploadedUrls = <String>[];
    if (localImagePaths.isNotEmpty) {
      final now = DateTime.now().millisecondsSinceEpoch;
      for (var p in localImagePaths) {
        // Si es una URL existente, mantenerla
        if (p.startsWith('http://') || p.startsWith('https://')) {
          uploadedUrls.add(p);
          continue;
        }
        // Si es un path local, subir la imagen
        final file = File(p);
        if (!file.existsSync()) {
          uploadedUrls.add(p);
          continue;
        }
        final filename = p.split(Platform.pathSeparator).last;
        final ref = _storage.ref().child(
          'products/${product.companyId}/$now/$filename',
        );
        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask;
        final url = await snapshot.ref.getDownloadURL();
        uploadedUrls.add(url);
      }
    }

    final data = product.toMap()
      ..['imageUrls'] = uploadedUrls.isNotEmpty
          ? uploadedUrls
          : product.imageUrls;

    await _firestore.collection('products').doc(productId).update(data);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    // Obtener el producto para eliminar sus imágenes de Storage
    final doc = await _firestore.collection('products').doc(productId).get();

    if (doc.exists) {
      final product = Product.fromMap(doc.id, doc.data()!);

      // Eliminar imágenes de Storage
      for (final imageUrl in product.imageUrls) {
        try {
          final ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          // Ignorar errores si la imagen ya no existe
        }
      }

      // Eliminar medios de trazabilidad
      for (final trace in product.traceability) {
        final mediaPath = trace['mediaPath'] as String?;
        if (mediaPath != null && mediaPath.isNotEmpty) {
          try {
            final ref = _storage.refFromURL(mediaPath);
            await ref.delete();
          } catch (e) {
            // Ignorar errores
          }
        }
      }
    }

    // Eliminar el documento
    await _firestore.collection('products').doc(productId).delete();
  }
}
