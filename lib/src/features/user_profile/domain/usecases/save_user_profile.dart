import 'package:flutter_app/src/features/auth/domain/entities/user_profile.dart';
import 'package:flutter_app/src/features/user_profile/domain/repositories/user_profile_repository.dart';

class SaveUserProfile {
  final UserProfileRepository repository;

  SaveUserProfile(this.repository);

  Future<void> call(String userId, UserProfile userProfile) {
    return repository.saveUserProfile(userId, userProfile);
  }
}
