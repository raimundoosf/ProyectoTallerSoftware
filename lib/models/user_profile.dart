class UserProfile {
  final String name;
  final List<String> interests;
  final String? location;
  final String? photoUrl;

  UserProfile({
    required this.name,
    required this.interests,
    this.location,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'interests': interests,
      'location': location,
      'photoUrl': photoUrl,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      interests: List<String>.from(map['interests'] ?? []),
      location: map['location'],
      photoUrl: map['photoUrl'],
    );
  }
}
