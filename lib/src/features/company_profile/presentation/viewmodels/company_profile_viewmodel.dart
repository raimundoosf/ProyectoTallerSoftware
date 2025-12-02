import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
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
  String? get currentUserId => _currentUserId;

  // Form state moved here
  String companyName = '';
  String companyDescription = '';
  String website = '';
  String logoUrl = '';
  String? industry;
  String coverageLevel = 'Nacional';
  List<String> coverageRegions = [];
  List<String> coverageCommunes = [];
  List<Map<String, String>> certifications = []; // {name, documentUrl}

  // Estado para subida de documentos de certificación
  bool _isUploadingCertification = false;
  bool get isUploadingCertification => _isUploadingCertification;
  double _certificationUploadProgress = 0.0;
  double get certificationUploadProgress => _certificationUploadProgress;

  // Nuevos campos
  String email = '';
  String phone = '';
  String address = '';
  String rut = '';
  int foundedYear = 0;
  int employeeCount = 0;
  List<String> specialties = [];
  String missionStatement = '';
  String visionStatement = '';
  List<Map<String, String>> socialMedia = [];

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
    coverageLevel = 'Nacional';
    coverageRegions = [];
    coverageCommunes = [];
    certifications = [];
    email = '';
    phone = '';
    address = '';
    rut = '';
    foundedYear = 0;
    employeeCount = 0;
    specialties = [];
    missionStatement = '';
    visionStatement = '';
    socialMedia = [];
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
    coverageLevel = profile.coverageLevel;
    coverageRegions = List<String>.from(profile.coverageRegions);
    coverageCommunes = List<String>.from(profile.coverageCommunes);
    certifications = List<Map<String, String>>.from(
      profile.certifications.map((e) => Map<String, String>.from(e)),
    );
    email = profile.email;
    phone = profile.phone;
    address = profile.address;
    rut = profile.rut;
    foundedYear = profile.foundedYear;
    employeeCount = profile.employeeCount;
    specialties = List<String>.from(profile.specialties);
    missionStatement = profile.missionStatement;
    visionStatement = profile.visionStatement;
    socialMedia = List<Map<String, String>>.from(
      profile.socialMedia.map((e) => Map<String, String>.from(e)),
    );
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

  void setCoverageLevel(String v) {
    coverageLevel = v;
    // Limpiar selecciones cuando cambia el nivel de cobertura
    if (v == 'Nacional') {
      coverageRegions = [];
      coverageCommunes = [];
    } else if (v == 'Regional') {
      coverageCommunes = [];
    }
    _fieldErrors.remove('coverageLevel');
    notifyListeners();
  }

  void setCoverageRegions(List<String> v) {
    coverageRegions = List.from(v);
    _fieldErrors.remove('coverageRegions');
    notifyListeners();
  }

  void addCoverageRegion(String region) {
    if (!coverageRegions.contains(region)) {
      coverageRegions.add(region);
      notifyListeners();
    }
  }

  void removeCoverageRegion(String region) {
    coverageRegions.remove(region);
    notifyListeners();
  }

  void setCoverageCommunes(List<String> v) {
    coverageCommunes = List.from(v);
    _fieldErrors.remove('coverageCommunes');
    notifyListeners();
  }

  void addCoverageCommune(String commune) {
    if (!coverageCommunes.contains(commune)) {
      coverageCommunes.add(commune);
      notifyListeners();
    }
  }

  void removeCoverageCommune(String commune) {
    coverageCommunes.remove(commune);
    notifyListeners();
  }

  void setCertifications(List<Map<String, String>> v) {
    certifications = List<Map<String, String>>.from(
      v.map((e) => Map<String, String>.from(e)),
    );
    notifyListeners();
  }

  /// Añadir una certificación con nombre y URL de documento
  void addCertification(String name, String documentUrl) {
    certifications.add({'name': name, 'documentUrl': documentUrl});
    notifyListeners();
  }

  /// Eliminar una certificación por índice
  void removeCertificationAt(int index) {
    if (index >= 0 && index < certifications.length) {
      certifications.removeAt(index);
      notifyListeners();
    }
  }

  /// Actualizar la URL de documento de una certificación existente
  void updateCertificationDocument(int index, String documentUrl) {
    if (index >= 0 && index < certifications.length) {
      final cert = certifications[index];
      certifications[index] = {
        'name': cert['name'] ?? '',
        'documentUrl': documentUrl,
      };
      notifyListeners();
    }
  }

  /// Seleccionar y subir un documento de certificación a Firebase Storage
  /// Usa image_picker para seleccionar imágenes (JPG, PNG, etc.)
  Future<String?> pickAndUploadCertificationDocument(String userId) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      final file = File(pickedFile.path);

      // Validar tamaño (máximo 10 MB para documentos)
      const maxDocBytes = 10 * 1024 * 1024;
      final fileSize = await file.length();
      if (fileSize > maxDocBytes) {
        _error = 'Documento demasiado grande (máx 10 MB)';
        notifyListeners();
        return null;
      }

      _isUploadingCertification = true;
      _certificationUploadProgress = 0.0;
      _error = null;
      notifyListeners();

      final fileName = pickedFile.path.split('/').last;
      final storageRef = FirebaseStorage.instance.ref().child(
        'certifications/$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName',
      );

      final uploadTask = storageRef.putFile(file);

      uploadTask.snapshotEvents.listen(
        (snapshot) {
          _certificationUploadProgress =
              snapshot.bytesTransferred / snapshot.totalBytes;
          notifyListeners();
        },
        onError: (e) {
          // Ignorar errores del stream, se manejan abajo
        },
      );

      // Timeout de 60 segundos para la subida
      await uploadTask.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );

      final downloadUrl = await storageRef.getDownloadURL();

      _isUploadingCertification = false;
      _certificationUploadProgress = 0.0;
      notifyListeners();

      return downloadUrl;
    } on FirebaseException catch (e) {
      String message = 'Error al subir documento';
      if (e.code == 'unauthorized' || e.code == 'permission-denied') {
        message = 'Sin permisos para subir. Contacta al administrador.';
      } else if (e.code == 'canceled') {
        message = 'Subida cancelada';
      }
      _error = message;
      _isUploadingCertification = false;
      _certificationUploadProgress = 0.0;
      notifyListeners();
      return null;
    } catch (e) {
      _error =
          'Error al subir documento: ${e.toString().split(':').last.trim()}';
      _isUploadingCertification = false;
      _certificationUploadProgress = 0.0;
      notifyListeners();
      return null;
    }
  }

  // Setters para nuevos campos
  void setEmail(String v) {
    email = v;
    _fieldErrors.remove('email');
    notifyListeners();
  }

  void setPhone(String v) {
    phone = v;
    _fieldErrors.remove('phone');
    notifyListeners();
  }

  void setAddress(String v) {
    address = v;
    _fieldErrors.remove('address');
    notifyListeners();
  }

  void setRut(String v) {
    rut = v;
    _fieldErrors.remove('rut');
    notifyListeners();
  }

  void setFoundedYear(int v) {
    foundedYear = v;
    _fieldErrors.remove('foundedYear');
    notifyListeners();
  }

  void setEmployeeCount(int v) {
    employeeCount = v;
    _fieldErrors.remove('employeeCount');
    notifyListeners();
  }

  void setSpecialties(List<String> v) {
    specialties = List.from(v);
    notifyListeners();
  }

  void setMissionStatement(String v) {
    missionStatement = v;
    _fieldErrors.remove('missionStatement');
    notifyListeners();
  }

  void setVisionStatement(String v) {
    visionStatement = v;
    _fieldErrors.remove('visionStatement');
    notifyListeners();
  }

  void setSocialMedia(List<Map<String, String>> v) {
    socialMedia = List<Map<String, String>>.from(
      v.map((e) => Map<String, String>.from(e)),
    );
    notifyListeners();
  }

  void addSocialMedia(String platform, String url) {
    socialMedia.add({'platform': platform, 'url': url});
    notifyListeners();
  }

  void removeSocialMediaAt(int index) {
    if (index >= 0 && index < socialMedia.length) {
      socialMedia.removeAt(index);
      notifyListeners();
    }
  }

  bool validateForm() {
    _fieldErrors.clear();
    if (companyName.isEmpty) {
      _fieldErrors['companyName'] = 'Nombre de la empresa requerido';
    }
    if (industry == null || industry!.isEmpty) {
      _fieldErrors['industry'] = 'Seleccione una industria';
    }
    if (email.isNotEmpty && !_isValidEmail(email)) {
      _fieldErrors['email'] = 'Email inválido';
    }
    if (rut.isNotEmpty && !_isValidRut(rut)) {
      _fieldErrors['rut'] = 'RUT inválido';
    }
    notifyListeners();
    return _fieldErrors.isEmpty;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidRut(String rut) {
    // Validación básica de formato RUT chileno (ej: 12.345.678-9)
    return RegExp(r'^\d{1,2}\.\d{3}\.\d{3}-[\dkK]$').hasMatch(rut);
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
      companyDescription: companyDescription,
      website: website,
      logoUrl: logoUrl,
      certifications: certifications,
      coverageLevel: coverageLevel,
      coverageRegions: coverageRegions,
      coverageCommunes: coverageCommunes,
      email: email,
      phone: phone,
      address: address,
      rut: rut,
      foundedYear: foundedYear,
      employeeCount: employeeCount,
      specialties: specialties,
      missionStatement: missionStatement,
      visionStatement: visionStatement,
      socialMedia: socialMedia,
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
