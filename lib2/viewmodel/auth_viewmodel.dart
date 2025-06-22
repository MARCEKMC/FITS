import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  User? get user => _repo.currentUser;

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final user = await _repo.signInWithEmail(email, password);
      notifyListeners();
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final user = await _repo.registerWithEmail(email, password);
      notifyListeners();
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final user = await _repo.signInWithGoogle();
      notifyListeners();
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signInWithFacebook() async {
    try {
      final user = await _repo.signInWithFacebook();
      notifyListeners();
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    notifyListeners();
  }

  Future<bool> isEmailVerified() => _repo.isEmailVerified();
}