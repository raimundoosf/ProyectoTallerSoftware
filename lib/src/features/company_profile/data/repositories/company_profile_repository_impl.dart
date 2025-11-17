import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/src/features/company_profile/domain/entities/company_profile.dart';
import 'package:flutter_app/src/features/company_profile/domain/repositories/company_profile_repository.dart';

class CompanyProfileRepositoryImpl implements CompanyProfileRepository {
  final FirebaseFirestore _firestore;
  final Map<String, CompanyProfile?> _cache = {};

  CompanyProfileRepositoryImpl(this._firestore);

  @override
  Future<void> saveCompanyProfile(
    String userId,
    CompanyProfile companyProfile,
  ) {
    _cache[userId] = companyProfile;
    return _firestore
        .collection('businesses')
        .doc(userId)
        .set(companyProfile.toJson());
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
}
