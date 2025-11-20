import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/src/features/company_profile/domain/entities/company_profile.dart';
import 'package:flutter_app/src/features/company_profile/domain/usecases/get_company_profile.dart';
import 'package:flutter_app/src/features/company_profile/domain/usecases/save_company_profile.dart';
import 'package:image_picker/image_picker.dart';

class CompanyProfileViewModel extends ChangeNotifier {
  final GetCompanyProfile _getCompanyProfile;
  final SaveCompanyProfile _saveCompanyProfile;

  CompanyProfileViewModel(this._getCompanyProfile, this._saveCompanyProfile);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  String? _error;
  String? get error => _error;

  CompanyProfile? _companyProfile;
  CompanyProfile? get companyProfile => _companyProfile;

  String? _currentUserId;

  // Form state moved here
  String companyName = '';
  String companyDescription = '';
  String website = '';
  String logoUrl = '';
  String? industry;
  String? companyLocation;
  List<String> certifications = [];

  static const int maxLogoBytes = 5 * 1024 * 1024; // 5 MB
  static const allowedLogoExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];

  final Map<String, String?> _fieldErrors = {};
  Map<String, String?> get fieldErrors => _fieldErrors;

  void resetForm() {
    companyName = '';
    companyDescription = '';
    website = '';
    logoUrl = '';
    industry = null;
    companyLocation = null;
    certifications = [];
    _fieldErrors.clear();
    _error = null;
    notifyListeners();
  }

  void prefillFrom(CompanyProfile profile) {
    companyName = profile.companyName;
    companyDescription = profile.companyDescription;
    website = profile.website;
    logoUrl = profile.logoUrl;
    industry = profile.industry;
    companyLocation = profile.companyLocation;
    certifications = List<String>.from(profile.certifications);
    _fieldErrors.clear();
    notifyListeners();
  }

  void setCompanyName(String v) {
    companyName = v;
    _fieldErrors.remove('companyName');
    notifyListeners();
  }

  void setCompanyDescription(String v) {
    companyDescription = v;
    _fieldErrors.remove('companyDescription');
    notifyListeners();
  }

  void setWebsite(String v) {
    website = v;
    _fieldErrors.remove('website');
    notifyListeners();
  }

  void setLogoUrl(String v) {
    logoUrl = v;
    _fieldErrors.remove('logoUrl');
    notifyListeners();
  }

  void setIndustry(String? v) {
    industry = v;
    _fieldErrors.remove('industry');
    notifyListeners();
  }

  void setCompanyLocation(String? v) {
    companyLocation = v;
    _fieldErrors.remove('companyLocation');
    notifyListeners();
  }

  void setCertifications(List<String> v) {
    certifications = List.from(v);
    notifyListeners();
  }

  bool validateForm() {
    _fieldErrors.clear();
    if (companyName.isEmpty) {
      _fieldErrors['companyName'] = 'Nombre de la empresa requerido';
    }
    if (industry == null || industry!.isEmpty) {
      _fieldErrors['industry'] = 'Seleccione una industria';
    }
    // additional validations can be added here
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

    final profile = CompanyProfile(
      companyName: companyName,
      industry: industry ?? '',
      companyLocation: companyLocation ?? '',
      companyDescription: companyDescription,
      website: website,
      logoUrl: logoUrl,
      certifications: certifications,
    );

    _isLoading = true;
    _uploadProgress = 0.0;
    _error = null;
    notifyListeners();

    try {
      await _saveCompanyProfile(
        _currentUserId!,
        profile,
        onUploadProgress: (p) {
          _uploadProgress = p;
          notifyListeners();
        },
      );
      // reload saved profile to ensure we get any transformed fields
      final updated = await _getCompanyProfile(_currentUserId!);
      if (updated != null) {
        _companyProfile = updated;
        prefillFrom(updated);
      } else {
        _companyProfile = profile;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }

  Future<void> loadCompanyProfile(String userId) async {
    final switchedUser = _currentUserId != userId;
    if (switchedUser) {
      _currentUserId = userId;
      _companyProfile = null;
      _error = null;
      resetForm();
    }
    _isLoading = true;
    notifyListeners();

    try {
      _companyProfile = await _getCompanyProfile(userId);
      if (_companyProfile != null) {
        prefillFrom(_companyProfile!);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveCompanyProfile(
    String userId,
    CompanyProfile companyProfile,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _saveCompanyProfile(
        userId,
        companyProfile,
        onUploadProgress: (p) {
          _uploadProgress = p;
          notifyListeners();
        },
      );
      final updated = await _getCompanyProfile(userId);
      if (updated != null) {
        _companyProfile = updated;
        prefillFrom(updated);
      } else {
        _companyProfile = companyProfile;
      }
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
      final file = File(pickedFile.path);
      try {
        final size = await file.length();
        final ext = pickedFile.path.split('.').last.toLowerCase();
        if (!allowedLogoExtensions.contains(ext)) {
          _fieldErrors['logoUrl'] =
              'Formato no soportado. Use JPG/PNG/WebP/GIF';
          notifyListeners();
          return;
        }
        if (size > maxLogoBytes) {
          _fieldErrors['logoUrl'] = 'Archivo demasiado grande (máx 5 MB)';
          notifyListeners();
          return;
        }
      } catch (e) {
        _fieldErrors['logoUrl'] = 'No se pudo leer el archivo';
        notifyListeners();
        return;
      }

      // update both the view model form state and the underlying profile
      logoUrl = pickedFile.path;
      final updatedProfile = _companyProfile?.copyWith(
        logoUrl: pickedFile.path,
      );
      if (updatedProfile != null) {
        _companyProfile = updatedProfile;
      }
      _fieldErrors.remove('logoUrl');
      notifyListeners();
    }
  }
}
