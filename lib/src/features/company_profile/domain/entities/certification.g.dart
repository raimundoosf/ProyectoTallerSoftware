// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CertificationImpl _$$CertificationImplFromJson(Map<String, dynamic> json) =>
    _$CertificationImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      issuer: json['issuer'] as String? ?? '',
      issueDate: json['issueDate'] == null
          ? null
          : DateTime.parse(json['issueDate'] as String),
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      documentUrls:
          (json['documentUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      documentNames:
          (json['documentNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      type:
          $enumDecodeNullable(_$CertificationTypeEnumMap, json['type']) ??
          CertificationType.other,
      status:
          $enumDecodeNullable(_$VerificationStatusEnumMap, json['status']) ??
          VerificationStatus.pending,
      verificationNotes: json['verificationNotes'] as String? ?? '',
      verifiedBy: json['verifiedBy'] as String? ?? '',
      verifiedDate: json['verifiedDate'] == null
          ? null
          : DateTime.parse(json['verifiedDate'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CertificationImplToJson(_$CertificationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'issuer': instance.issuer,
      'issueDate': instance.issueDate?.toIso8601String(),
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'documentUrls': instance.documentUrls,
      'documentNames': instance.documentNames,
      'type': _$CertificationTypeEnumMap[instance.type]!,
      'status': _$VerificationStatusEnumMap[instance.status]!,
      'verificationNotes': instance.verificationNotes,
      'verifiedBy': instance.verifiedBy,
      'verifiedDate': instance.verifiedDate?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$CertificationTypeEnumMap = {
  CertificationType.environmental: 'environmental',
  CertificationType.social: 'social',
  CertificationType.governance: 'governance',
  CertificationType.quality: 'quality',
  CertificationType.safety: 'safety',
  CertificationType.sustainability: 'sustainability',
  CertificationType.other: 'other',
};

const _$VerificationStatusEnumMap = {
  VerificationStatus.pending: 'pending',
  VerificationStatus.verified: 'verified',
  VerificationStatus.rejected: 'rejected',
};
