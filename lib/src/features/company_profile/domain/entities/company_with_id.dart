import 'package:flutter_app/src/features/company_profile/domain/entities/company_profile.dart';

/// Wrapper class that includes both company profile data and its Firestore document ID
class CompanyWithId {
  final String id;
  final CompanyProfile profile;

  const CompanyWithId({required this.id, required this.profile});
}
