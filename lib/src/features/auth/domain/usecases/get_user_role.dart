import 'package:flutter_app/src/features/auth/domain/repositories/auth_repository.dart';

class GetUserRole {
  final AuthRepository repository;

  GetUserRole(this.repository);

  Future<String?> call(String userId) {
    return repository.getUserRole(userId);
  }
}
