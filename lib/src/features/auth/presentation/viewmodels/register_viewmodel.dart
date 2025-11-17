import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/features/auth/domain/usecases/save_user_role.dart';
import 'package:flutter_app/src/features/auth/domain/usecases/sign_up.dart';

class RegisterViewModel extends ChangeNotifier {
  final SignUp _signUp;
  final SaveUserRole _saveUserRole;

  RegisterViewModel(this._signUp, this._saveUserRole);

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

  String _confirmPassword = '';
  String get confirmPassword => _confirmPassword;
  set confirmPassword(String value) {
    if (_confirmPassword == value) return;
    _confirmPassword = value;
    _fieldErrors.remove('confirmPassword');
    notifyListeners();
  }

  String _role = 'Consumidor';
  String get role => _role;
  set role(String value) {
    if (_role == value) return;
    _role = value;
    notifyListeners();
  }

  final Map<String, String?> _fieldErrors = {};
  Map<String, String?> get fieldErrors => _fieldErrors;

  void resetForm() {
    _email = '';
    _password = '';
    _confirmPassword = '';
    _role = 'Consumidor';
    _fieldErrors.clear();
    _error = null;
    notifyListeners();
  }

  bool validate() {
    _fieldErrors.clear();

    if (_email.isEmpty) {
      _fieldErrors['email'] = 'Por favor ingrese su correo electrónico';
    } else {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(_email)) {
        _fieldErrors['email'] =
            'Por favor ingrese un correo electrónico válido';
      }
    }

    if (_password.isEmpty) {
      _fieldErrors['password'] = 'Por favor ingrese su contraseña';
    } else {
      if (_password.length < 6) {
        _fieldErrors['password'] =
            'La contraseña debe tener al menos 6 caracteres';
      } else if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(_password)) {
        _fieldErrors['password'] =
            'La contraseña debe contener letras y números';
      }
    }

    if (_confirmPassword.isEmpty) {
      _fieldErrors['confirmPassword'] = 'Por favor confirme su contraseña';
    } else if (_confirmPassword != _password) {
      _fieldErrors['confirmPassword'] = 'Las contraseñas no coinciden';
    }

    notifyListeners();
    return _fieldErrors.isEmpty;
  }

  Future<bool> register() async {
    if (!validate()) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _signUp(_email, _password);
      if (user == null) {
        _error = 'No se pudo crear la cuenta.';
        return false;
      }
      await _saveUserRole(user.uid, _role);
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _error = 'El correo ya está registrado.';
          break;
        case 'invalid-email':
          _error = 'Correo electrónico inválido.';
          break;
        case 'weak-password':
          _error = 'La contraseña es demasiado débil.';
          break;
        default:
          _error = e.message ?? 'Error de autenticación.';
      }
      return false;
    } catch (e) {
      _error = 'Ocurrió un error inesperado.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
