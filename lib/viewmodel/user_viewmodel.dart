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

  /// Retorna true SOLO si el perfil está realmente completo
  bool get isProfileComplete => _profile != null && _profile!.isReallyComplete;
}