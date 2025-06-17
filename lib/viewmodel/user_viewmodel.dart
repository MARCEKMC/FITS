import 'package:flutter/material.dart';
import '../data/models/user_profile.dart';

class UserViewModel extends ChangeNotifier {
  UserProfile? _profile;
  UserProfile? get profile => _profile;

  void setProfile(UserProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  bool get isProfileComplete => _profile != null;
}