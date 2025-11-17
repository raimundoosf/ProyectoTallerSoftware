// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompanyProfileImpl _$$CompanyProfileImplFromJson(Map<String, dynamic> json) =>
    _$CompanyProfileImpl(
      companyName: json['companyName'] as String,
      industry: json['industry'] as String,
      companyLocation: json['companyLocation'] as String,
      companyDescription: json['companyDescription'] as String,
      website: json['website'] as String,
      logoUrl: json['logoUrl'] as String? ?? '',
      certifications:
          (json['certifications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CompanyProfileImplToJson(
  _$CompanyProfileImpl instance,
) => <String, dynamic>{
  'companyName': instance.companyName,
  'industry': instance.industry,
  'companyLocation': instance.companyLocation,
  'companyDescription': instance.companyDescription,
  'website': instance.website,
  'logoUrl': instance.logoUrl,
  'certifications': instance.certifications,
};
