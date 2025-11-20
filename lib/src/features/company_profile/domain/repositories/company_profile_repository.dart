import 'package:flutter_app/src/features/company_profile/domain/entities/company_profile.dart';

typedef UploadProgressCallback = void Function(double progress);

abstract class CompanyProfileRepository {
  /// Save company profile. If [onUploadProgress] is provided it will be called
  /// with values in range 0..1 during any storage upload.
  Future<void> saveCompanyProfile(
    String userId,
    CompanyProfile companyProfile, {
    UploadProgressCallback? onUploadProgress,
  });

  Future<CompanyProfile?> getCompanyProfile(String userId);
}
