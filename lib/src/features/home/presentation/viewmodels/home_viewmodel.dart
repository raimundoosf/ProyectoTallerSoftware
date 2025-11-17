import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/src/features/auth/domain/usecases/get_user_role.dart';
import 'package:flutter_app/src/features/auth/domain/usecases/sign_out.dart';

class HomeViewModel extends ChangeNotifier {
  final SignOut _signOut;
  final GetUserRole _getUserRole;

  HomeViewModel(this._signOut, this._getUserRole);

  User? get currentUser => FirebaseAuth.instance.currentUser;

  String? _currentRole;
  bool _isRoleLoading = false;

  String? get currentRole => _currentRole;
  bool get isRoleLoading => _isRoleLoading;

  Future<void> fetchUserRole() async {
    final uid = currentUser?.uid;
    if (uid == null) {
      _currentRole = null;
      return;
    }
    _isRoleLoading = true;
    notifyListeners();
    try {
      _currentRole = await _getUserRole(uid);
    } finally {
      _isRoleLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _signOut();
    _currentRole = null;
    notifyListeners();
  }
}
