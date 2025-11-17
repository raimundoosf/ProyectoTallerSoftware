import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/src/features/auth/domain/entities/user_profile.dart';
import 'package:flutter_app/src/features/user_profile/domain/repositories/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final FirebaseFirestore _firestore;
  final Map<String, UserProfile?> _cache = {};

  UserProfileRepositoryImpl(this._firestore);

  @override
  Future<void> saveUserProfile(String userId, UserProfile userProfile) {
    _cache[userId] = userProfile;
    return _firestore
        .collection('consumers')
        .doc(userId)
        .set(userProfile.toJson());
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    if (_cache.containsKey(userId)) {
      return _cache[userId];
    }
    final doc = await _firestore.collection('consumers').doc(userId).get();
    if (doc.exists) {
      final profile = UserProfile.fromJson(doc.data()!);
      _cache[userId] = profile;
      return profile;
    }
    _cache[userId] = null;
    return null;
  }
}
