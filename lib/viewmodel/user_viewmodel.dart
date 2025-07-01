import 'package:flutter/material.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  UserProfile? _profile;
  final UserRepository _repo = UserRepository();

  UserProfile? get profile => _profile;

  Future<void> loadProfile(String uid) async {
    try {
      _profile = await _repo.getUserProfile(uid);
    } catch (e) {
      _profile = null;
    }
    notifyListeners();
  }

  Future<void> setProfile(UserProfile profile) async {
    _profile = profile;
    await _repo.saveUserProfile(profile);
    notifyListeners();
  }

  /// Verifica si el username está tomado
  Future<bool> isUsernameTaken(String username) async {
    return await _repo.isUsernameTaken(username);
  }

  /// Retorna true SOLO si el perfil está realmente completo
  bool get isProfileComplete => _profile != null && _profile!.isReallyComplete;

  /// Calcula la edad del usuario basada en su fecha de nacimiento
  int get userAge {
    if (_profile == null) return 0;
    final now = DateTime.now();
    final birthDate = _profile!.birthDate;
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}