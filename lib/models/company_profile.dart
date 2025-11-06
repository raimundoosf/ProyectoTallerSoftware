class CompanyProfile {
  final String companyName;
  final String industry;
  final String companyLocation;
  final String companyDescription;
  final String website;
  final String logoUrl;
  final List<String> certifications;

  CompanyProfile({
    required this.companyName,
    required this.industry,
    required this.companyLocation,
    required this.companyDescription,
    required this.website,
    this.logoUrl = '',
    this.certifications = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'industry': industry,
      'companyLocation': companyLocation,
      'companyDescription': companyDescription,
      'website': website,
      'logoUrl': logoUrl,
      'certifications': certifications,
    };
  }

  factory CompanyProfile.fromMap(Map<String, dynamic> map) {
    return CompanyProfile(
      companyName: map['companyName'] ?? '',
      industry: map['industry'] ?? '',
      companyLocation: map['companyLocation'] ?? '',
      companyDescription: map['companyDescription'] ?? '',
      website: map['website'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      certifications: List<String>.from(map['certifications'] ?? []),
    );
  }
}
