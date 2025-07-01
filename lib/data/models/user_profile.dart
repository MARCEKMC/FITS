class UserProfile {
  final String uid;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final DateTime birthDate;
  final String profileType;
  final String region;
  final String language;

  UserProfile({
    required this.uid,
    required String username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.birthDate,
    required this.profileType,
    required this.region,
    required this.language,
  }) : username = username.trim().toLowerCase();

  // Getter para nombre completo
  String get fullName => '$firstName $lastName'.trim();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'profileType': profileType,
      'region': region,
      'language': language,
    };
  }

  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      firstName: map['firstName'] ?? map['realName'] ?? '', // Compatibilidad hacia atrás
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      gender: map['gender'] ?? '',
      birthDate: map['birthDate'] != null && map['birthDate'] != ''
          ? DateTime.tryParse(map['birthDate']) ?? DateTime.now()
          : DateTime.now(),
      profileType: map['profileType'] ?? '',
      region: map['region'] ?? '',
      language: map['language'] ?? '',
    );
  }

  bool get isReallyComplete {
    return username.trim().isNotEmpty &&
        firstName.trim().isNotEmpty &&
        lastName.trim().isNotEmpty &&
        email.trim().isNotEmpty &&
        gender.trim().isNotEmpty &&
        profileType.trim().isNotEmpty &&
        region.trim().isNotEmpty &&
        language.trim().isNotEmpty;
  }
}