import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> saveUserProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null && doc.data()!.isNotEmpty) {
      return UserProfile.fromMap(doc.data()!);
    }
    return null;
  }

  /// Chequea si el username ya está en uso (case-insensitive)
  Future<bool> isUsernameTaken(String username) async {
    final query = await _db
        .collection('users')
        .where('username', isEqualTo: username.trim().toLowerCase())
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }
}