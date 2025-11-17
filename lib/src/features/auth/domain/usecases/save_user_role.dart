import 'package:flutter_app/src/features/auth/domain/repositories/auth_repository.dart';

class SaveUserRole {
  final AuthRepository repository;

  SaveUserRole(this.repository);

  Future<void> call(String userId, String role) {
    return repository.saveUserRole(userId, role);
  }
}
