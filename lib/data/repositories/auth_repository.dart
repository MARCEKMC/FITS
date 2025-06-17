import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login con email y contraseña
  Future<User?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  // Registro con email y contraseña + envío de verificación
  Future<User?> registerWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user?.sendEmailVerification();
    return cred.user;
  }

  // Login con Google
  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null; // Usuario canceló
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    return cred.user;
  }

  // Login con Facebook
  Future<User?> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status != LoginStatus.success) return null;
    final OAuthCredential facebookAuthCredential =
      FacebookAuthProvider.credential(result.accessToken!.token);
    final cred = await _auth.signInWithCredential(facebookAuthCredential);
    return cred.user;
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