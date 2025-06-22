import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../models/user_profile.dart';
import 'user_repository.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login con email y contraseña, manejo de errores mejorado
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Usuario no encontrado.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Contraseña incorrecta.');
      } else if (e.code == 'user-disabled') {
        throw Exception('Usuario deshabilitado.');
      } else {
        throw Exception('Error de autenticación: ${e.message}');
      }
    }
  }

  // Registro con email y contraseña + envío de verificación + crea usuario en Firestore
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await cred.user?.sendEmailVerification();
      // No creamos el perfil aquí, porque el username debe ser único y se completa después
      return cred.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Este correo ya está registrado.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Correo inválido.');
      } else if (e.code == 'weak-password') {
        throw Exception('La contraseña es muy débil.');
      } else {
        throw Exception('Error de autenticación: ${e.message}');
      }
    }
  }

  // Login con Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // Usuario canceló
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Error de Google: ${e.message}');
    }
  }

  // Login con Facebook
  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) return null;
      final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(result.accessToken!.token);
      final cred = await _auth.signInWithCredential(facebookAuthCredential);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Error de Facebook: ${e.message}');
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
  }

  User? get currentUser => _auth.currentUser;

  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }
}