import 'package:flutter_app/src/features/auth/domain/entities/user_profile.dart';
import 'package:flutter_app/src/features/user_profile/domain/repositories/user_profile_repository.dart';

class GetUserProfile {
  final UserProfileRepository repository;

  GetUserProfile(this.repository);

  Future<UserProfile?> call(String userId) {
    return repository.getUserProfile(userId);
  }
}
