import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/src/features/auth/domain/repositories/auth_repository.dart';

class SignUp {
  final AuthRepository repository;

  SignUp(this.repository);

  Future<User?> call(String email, String password) {
    return repository.createUserWithEmailAndPassword(email, password);
  }
}
