import 'package:freezed_annotation/freezed_annotation.dart';

part 'company_profile.freezed.dart';
part 'company_profile.g.dart';

@freezed
class CompanyProfile with _$CompanyProfile {
  const factory CompanyProfile({
    required String companyName,
    required String industry,
    required String companyDescription,
    required String website,
    @Default('') String logoUrl,
    // Certificaciones con documentos de respaldo: [{name, documentUrl, documentName}]
    @Default([]) List<Map<String, String>> certifications,
    // Sistema de cobertura geográfica
    @Default('Nacional')
    String coverageLevel, // 'Nacional', 'Regional', 'Comunal'
    @Default([])
    List<String> coverageRegions, // Regiones seleccionadas si es Regional
    @Default([])
    List<String> coverageCommunes, // Comunas seleccionadas si es Comunal
    // Campos para información profesional
    @Default('') String email,
    @Default('') String phone,
    @Default('') String address,
    @Default('') String rut,
    @Default(0) int foundedYear,
    @Default(0) int employeeCount,
    @Default([]) List<String> specialties,
    @Default('') String missionStatement,
    @Default('') String visionStatement,
    @Default([]) List<Map<String, String>> socialMedia,
  }) = _CompanyProfile;

  factory CompanyProfile.fromJson(Map<String, dynamic> json) =>
      _$CompanyProfileFromJson(json);
}
