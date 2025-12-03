import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_app/src/features/company_profile/domain/entities/company_profile.dart';
import 'package:flutter_app/src/features/company_profile/domain/entities/company_with_id.dart';
import 'package:flutter_app/src/features/company_profile/domain/repositories/company_profile_repository.dart';

class CompanyProfileRepositoryImpl implements CompanyProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Map<String, CompanyProfile?> _cache = {};

  CompanyProfileRepositoryImpl(this._firestore, this._storage);

  @override
  Future<void> saveCompanyProfile(
    String userId,
    CompanyProfile companyProfile, {
    UploadProgressCallback? onUploadProgress,
  }) async {
    _cache[userId] = companyProfile;

    final data = companyProfile.toJson();

    // If logoUrl points to a local file path, upload it to Firebase Storage
    final logo = companyProfile.logoUrl;
    if (logo.isNotEmpty) {
      final uri = Uri.tryParse(logo);
      final isNetwork =
          uri != null &&
          uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https');
      if (!isNetwork) {
        final file = File(logo);
        if (file.existsSync()) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final filename =
              'logo_$timestamp${file.path.contains('.') ? '.${file.path.split('.').last}' : ''}';
          // Upload into the folder expected by the Storage rules
          final ref = _storage.ref().child('company_logos/$userId/$filename');

          // Upload with progress reporting
          final uploadTask = ref.putFile(file);
          final sub = uploadTask.snapshotEvents.listen((snapshot) {
            final total = snapshot.totalBytes == 0 ? 1 : snapshot.totalBytes;
            final progress = snapshot.bytesTransferred / total;
            if (onUploadProgress != null) {
              onUploadProgress(progress.clamp(0.0, 1.0));
            }
          });
          try {
            // Await the upload and capture Firebase-specific errors to provide
            // more context when debugging permission issues.
            final snapshot = await uploadTask;
            final downloadUrl = await snapshot.ref.getDownloadURL();
            data['logoUrl'] = downloadUrl;

            // Delete previous logo in storage if it exists and it's a storage URL
            try {
              final prevDoc = await _firestore
                  .collection('businesses')
                  .doc(userId)
                  .get();
              if (prevDoc.exists) {
                final prevUrl = prevDoc.data()?['logoUrl'] as String? ?? '';
                if (prevUrl.isNotEmpty && prevUrl != data['logoUrl']) {
                  try {
                    final prevRef = _storage.refFromURL(prevUrl);
                    await prevRef.delete();
                  } catch (_) {
                    // ignore delete failures (file might not exist or not a storage URL)
                  }
                }
              }
            } catch (_) {
              // ignore failures when fetching previous doc
            }
          } on FirebaseException catch (e) {
            // Add contextual info and rethrow so the caller can display/log it.
            // This helps identify if the failure is due to auth/permission rules
            // or other storage configuration issues.
            // ignore: avoid_print
            print(
              'FirebaseStorage upload failed for userId=$userId '
              'path=${ref.fullPath} code=${e.code} message=${e.message}',
            );
            rethrow;
          } catch (e) {
            // Generic fallback logging
            // ignore: avoid_print
            print(
              'Storage upload unexpected error for userId=$userId '
              'path=${ref.fullPath} error=$e',
            );
            rethrow;
          } finally {
            await sub.cancel();
            if (onUploadProgress != null) onUploadProgress(1.0);
          }
        }
      }
    }

    await _firestore.collection('businesses').doc(userId).set(data);

    // Update local cache with the stored representation so subsequent reads
    // return the Firestore-backed object (with the storage download URL)
    try {
      _cache[userId] = CompanyProfile.fromJson(data);
    } catch (_) {
      // If parsing fails, leave the cache as-is (best-effort).
    }
  }

  @override
  Future<CompanyProfile?> getCompanyProfile(String userId) async {
    if (_cache.containsKey(userId)) {
      return _cache[userId];
    }
    final doc = await _firestore.collection('businesses').doc(userId).get();
    if (doc.exists) {
      final profile = CompanyProfile.fromJson(doc.data()!);
      _cache[userId] = profile;
      return profile;
    }
    _cache[userId] = null;
    return null;
  }

  @override
  Future<List<CompanyWithId>> getAllCompanies() async {
    try {
      final snapshot = await _firestore
          .collection('businesses')
          .orderBy('companyName')
          .get();

      return snapshot.docs
          .map((doc) {
            try {
              final profile = CompanyProfile.fromJson(doc.data());
              return CompanyWithId(id: doc.id, profile: profile);
            } catch (e) {
              // Skip malformed documents
              return null;
            }
          })
          .whereType<CompanyWithId>()
          .toList();
    } catch (e) {
      throw Exception('Error al cargar empresas: $e');
    }
  }
}
