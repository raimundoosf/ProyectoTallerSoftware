// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompanyProfileImpl _$$CompanyProfileImplFromJson(Map<String, dynamic> json) =>
    _$CompanyProfileImpl(
      companyName: json['companyName'] as String,
      industry: json['industry'] as String,
      companyDescription: json['companyDescription'] as String,
      website: json['website'] as String,
      logoUrl: json['logoUrl'] as String? ?? '',
      certifications:
          (json['certifications'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          const [],
      coverageLevel: json['coverageLevel'] as String? ?? 'Nacional',
      coverageRegions:
          (json['coverageRegions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      coverageCommunes:
          (json['coverageCommunes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      rut: json['rut'] as String? ?? '',
      foundedYear: (json['foundedYear'] as num?)?.toInt() ?? 0,
      employeeCount: (json['employeeCount'] as num?)?.toInt() ?? 0,
      specialties:
          (json['specialties'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      missionStatement: json['missionStatement'] as String? ?? '',
      visionStatement: json['visionStatement'] as String? ?? '',
      socialMedia:
          (json['socialMedia'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CompanyProfileImplToJson(
  _$CompanyProfileImpl instance,
) => <String, dynamic>{
  'companyName': instance.companyName,
  'industry': instance.industry,
  'companyDescription': instance.companyDescription,
  'website': instance.website,
  'logoUrl': instance.logoUrl,
  'certifications': instance.certifications,
  'coverageLevel': instance.coverageLevel,
  'coverageRegions': instance.coverageRegions,
  'coverageCommunes': instance.coverageCommunes,
  'email': instance.email,
  'phone': instance.phone,
  'address': instance.address,
  'rut': instance.rut,
  'foundedYear': instance.foundedYear,
  'employeeCount': instance.employeeCount,
  'specialties': instance.specialties,
  'missionStatement': instance.missionStatement,
  'visionStatement': instance.visionStatement,
  'socialMedia': instance.socialMedia,
};
