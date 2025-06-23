import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/repositories/auth_repositories.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  User? get user => _repo.currentUser;

  Future<User?> signInWithEmail(String email, String password) async {
    final user = await _repo.signInWithEmail(email, password);
    notifyListeners();
    return user;
  }

  Future<User?> registerWithEmail(String email, String password) async {
    final user = await _repo.registerWithEmail(email, password);
    notifyListeners();
    return user;
  }

  Future<User?> signInWithGoogle() async {
    final user = await _repo.signInWithGoogle();
    notifyListeners();
    return user;
  }

  Future<User?> signInWithFacebook() async {
    final user = await _repo.signInWithFacebook();
    notifyListeners();
    return user;
  }

  Future<void> signOut() async {
    await _repo.signOut();
    notifyListeners();
  }

  Future<bool> isEmailVerified() => _repo.isEmailVerified();

  Future<void> reloadUser() async {
    await _repo.currentUser?.reload();
    notifyListeners();
  }

  Future<void> sendEmailVerification() async {
    if (_repo.currentUser != null && !_repo.currentUser!.emailVerified) {
      await _repo.currentUser!.sendEmailVerification();
    }
  }
}