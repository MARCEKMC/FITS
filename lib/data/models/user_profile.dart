class UserProfile {
  final String uid;
  final String username;
  final String realName;
  final String gender;
  final DateTime birthDate;
  final String profileType;
  final String region;
  final String language;

  UserProfile({
    required this.uid,
    required this.username,
    required this.realName,
    required this.gender,
    required this.birthDate,
    required this.profileType,
    required this.region,
    required this.language,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'realName': realName,
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
      realName: map['realName'] ?? '',
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
        realName.trim().isNotEmpty &&
        gender.trim().isNotEmpty &&
        profileType.trim().isNotEmpty &&
        region.trim().isNotEmpty &&
        language.trim().isNotEmpty;
  }
}