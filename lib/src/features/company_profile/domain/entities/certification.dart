import 'package:freezed_annotation/freezed_annotation.dart';

part 'certification.freezed.dart';
part 'certification.g.dart';

enum CertificationType {
  environmental,
  social,
  governance,
  quality,
  safety,
  sustainability,
  other,
}

enum VerificationStatus { pending, verified, rejected }

@freezed
class Certification with _$Certification {
  const factory Certification({
    required String id,
    required String name,
    @Default('') String issuer,
    DateTime? issueDate,
    DateTime? expiryDate,
    @Default([]) List<String> documentUrls,
    @Default([]) List<String> documentNames,
    @Default(CertificationType.other) CertificationType type,
    @Default(VerificationStatus.pending) VerificationStatus status,
    @Default('') String verificationNotes,
    @Default('') String verifiedBy,
    DateTime? verifiedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Certification;

  factory Certification.fromJson(Map<String, dynamic> json) =>
      _$CertificationFromJson(json);
}
