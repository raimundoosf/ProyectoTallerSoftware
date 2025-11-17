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
    _error = null;
    notifyListeners();

    try {
      await _saveCompanyProfile(_currentUserId!, profile);
      _companyProfile = profile;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
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
      await _saveCompanyProfile(userId, companyProfile);
      _companyProfile = companyProfile;
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
      // update both the view model form state and the underlying profile
      logoUrl = pickedFile.path;
      final updatedProfile = _companyProfile?.copyWith(
        logoUrl: pickedFile.path,
      );
      if (updatedProfile != null) {
        _companyProfile = updatedProfile;
      }
      notifyListeners();
    }
  }
}
