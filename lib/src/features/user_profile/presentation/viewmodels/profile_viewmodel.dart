import 'package:flutter/material.dart';
import 'package:flutter_app/src/features/auth/domain/entities/user_profile.dart';
import 'package:flutter_app/src/features/user_profile/domain/usecases/get_user_profile.dart';
import 'package:flutter_app/src/features/user_profile/domain/usecases/save_user_profile.dart';
import 'package:image_picker/image_picker.dart';

class ProfileViewModel extends ChangeNotifier {
  final GetUserProfile _getUserProfile;
  final SaveUserProfile _saveUserProfile;

  ProfileViewModel(this._getUserProfile, this._saveUserProfile);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  String? _currentUserId;

  // Form state
  String name = '';
  String photoUrl = '';
  List<String> interests = [];
  String? location;

  final Map<String, String?> _fieldErrors = {};
  Map<String, String?> get fieldErrors => _fieldErrors;

  Future<void> loadUserProfile(String userId) async {
    final switchedUser = _currentUserId != userId;
    if (switchedUser) {
      _currentUserId = userId;
      _userProfile = null;
      _error = null;
      resetForm();
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userProfile = await _getUserProfile(userId);
      if (_userProfile != null) {
        prefillFrom(_userProfile!);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetForm() {
    name = '';
    photoUrl = '';
    interests = [];
    location = null;
    _fieldErrors.clear();
    _error = null;
    notifyListeners();
  }

  void prefillFrom(UserProfile profile) {
    name = profile.name;
    photoUrl = profile.photoUrl ?? '';
    interests = List<String>.from(profile.interests);
    location = profile.location;
    _fieldErrors.clear();
    notifyListeners();
  }

  void setName(String v) {
    name = v;
    _fieldErrors.remove('name');
    // don't notify every keystroke to avoid rebuild interruptions
  }

  void setPhotoUrl(String v) {
    photoUrl = v;
    _fieldErrors.remove('photoUrl');
  }

  void setInterests(List<String> v) {
    interests = List.from(v);
    notifyListeners();
  }

  void setLocation(String? v) {
    location = v;
    _fieldErrors.remove('location');
    notifyListeners();
  }

  bool validateForm() {
    _fieldErrors.clear();
    if (name.isEmpty) {
      _fieldErrors['name'] = 'Por favor, ingresa tu nombre';
    }
    // additional validations as needed
    notifyListeners();
    return _fieldErrors.isEmpty;
  }

  Future<bool> saveFromForm() async {
    if (!validateForm()) return false;
    if (_currentUserId == null) {
      _error = 'Usuario no autenticado';
      notifyListeners();
      return false;
    }

    final updatedProfile = UserProfile(
      name: name,
      interests: interests,
      location: location,
      photoUrl: photoUrl.isNotEmpty ? photoUrl : _userProfile?.photoUrl,
    );

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _saveUserProfile(_currentUserId!, updatedProfile);
      _userProfile = updatedProfile;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveUserProfile(String userId, UserProfile userProfile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _saveUserProfile(userId, userProfile);
      _userProfile = userProfile;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Here you would typically upload the image to a storage service
      // and get the URL. For now, we'll just use the local path.
      final updatedProfile = _userProfile?.copyWith(photoUrl: pickedFile.path);
      if (updatedProfile != null) {
        _userProfile = updatedProfile;
        notifyListeners();
      }
    }
  }
}
