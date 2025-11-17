import 'package:flutter_app/src/features/company_profile/domain/entities/company_profile.dart';
import 'package:flutter_app/src/features/company_profile/domain/repositories/company_profile_repository.dart';

class SaveCompanyProfile {
  final CompanyProfileRepository repository;

  SaveCompanyProfile(this.repository);

  Future<void> call(String userId, CompanyProfile companyProfile) {
    return repository.saveCompanyProfile(userId, companyProfile);
  }
}
