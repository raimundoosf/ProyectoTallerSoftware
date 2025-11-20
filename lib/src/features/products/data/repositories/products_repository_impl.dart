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
}
