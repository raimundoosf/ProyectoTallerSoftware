import 'package:freezed_annotation/freezed_annotation.dart';

part 'company_profile.freezed.dart';
part 'company_profile.g.dart';

@freezed
class CompanyProfile with _$CompanyProfile {
  const factory CompanyProfile({
    required String companyName,
    required String industry,
    required String companyLocation,
    required String companyDescription,
    required String website,
    @Default('') String logoUrl,
    @Default([]) List<String> certifications,
  }) = _CompanyProfile;

  factory CompanyProfile.fromJson(Map<String, dynamic> json) =>
      _$CompanyProfileFromJson(json);
}
