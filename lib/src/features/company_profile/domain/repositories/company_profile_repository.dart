import 'package:flutter_app/src/features/company_profile/domain/entities/company_profile.dart';

abstract class CompanyProfileRepository {
  Future<void> saveCompanyProfile(String userId, CompanyProfile companyProfile);
  Future<CompanyProfile?> getCompanyProfile(String userId);
}
