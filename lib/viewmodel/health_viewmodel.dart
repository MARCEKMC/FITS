import 'package:flutter/material.dart';
import '../data/models/health_profile.dart';
import '../data/repositories/health_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HealthViewModel extends ChangeNotifier {
  HealthProfile? _profile;
  final HealthRepository _repo = HealthRepository();

  HealthProfile? get profile => _profile;

  Future<bool> hasHealthProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    _profile = await _repo.getHealthProfile(user.uid);
    notifyListeners();
    return _profile != null;
  }

  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _profile = await _repo.getHealthProfile(user.uid);
    notifyListeners();
  }

  Future<void> saveProfile(HealthProfile profile) async {
    await _repo.saveHealthProfile(profile);
    _profile = profile;
    notifyListeners();
  }
}