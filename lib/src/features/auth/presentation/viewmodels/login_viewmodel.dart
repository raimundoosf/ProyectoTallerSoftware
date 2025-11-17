import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/features/auth/domain/usecases/sign_in.dart';

class LoginViewModel extends ChangeNotifier {
  final SignIn _signIn;

  LoginViewModel(this._signIn);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _email = '';
  String get email => _email;
  set email(String value) {
    if (_email == value) return;
    _email = value;
    _fieldErrors.remove('email');
    notifyListeners();
  }

  String _password = '';
  String get password => _password;
  set password(String value) {
    if (_password == value) return;
    _password = value;
    _fieldErrors.remove('password');
    notifyListeners();
  }

  final Map<String, String?> _fieldErrors = {};
  Map<String, String?> get fieldErrors => _fieldErrors;

  void resetForm() {
    _email = '';
    _password = '';
    _error = null;
    _fieldErrors.clear();
    notifyListeners();
  }

  bool validate() {
    _fieldErrors.clear();

    if (_email.isEmpty) {
      _fieldErrors['email'] = 'Por favor ingresa tu correo electrónico';
    } else {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(_email)) {
        _fieldErrors['email'] = 'El formato de correo no es válido';
      }
    }

    if (_password.isEmpty) {
      _fieldErrors['password'] = 'Por favor ingresa tu contraseña';
    }

    notifyListeners();
    return _fieldErrors.isEmpty;
  }

  Future<bool> login() async {
    if (!validate()) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _signIn(_email, _password);
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _error = 'No encontramos una cuenta con ese correo.';
          break;
        case 'wrong-password':
          _error = 'La contraseña es incorrecta.';
          break;
        case 'invalid-email':
          _error = 'El correo electrónico es inválido.';
          break;
        case 'user-disabled':
          _error = 'Esta cuenta ha sido deshabilitada.';
          break;
        default:
          _error = e.message ?? 'Error al iniciar sesión.';
      }
      return false;
    } catch (_) {
      _error = 'Ocurrió un error inesperado.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
