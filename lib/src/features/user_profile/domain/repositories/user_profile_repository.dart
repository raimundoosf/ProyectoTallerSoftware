import 'package:flutter_app/src/features/auth/domain/entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<void> saveUserProfile(String userId, UserProfile userProfile);
  Future<UserProfile?> getUserProfile(String userId);
}
