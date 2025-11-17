import 'package:flutter_app/src/features/company_profile/domain/entities/company_profile.dart';
import 'package:flutter_app/src/features/company_profile/domain/repositories/company_profile_repository.dart';

class GetCompanyProfile {
  final CompanyProfileRepository repository;

  GetCompanyProfile(this.repository);

  Future<CompanyProfile?> call(String userId) {
    return repository.getCompanyProfile(userId);
  }
}
