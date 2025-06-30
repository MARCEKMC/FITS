import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/secure_note.dart';

class FirestoreSecureNotesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  Future<String?> _ensureUserAuthenticated() async {
    if (_auth.currentUser != null) {
      return _auth.currentUser!.uid;
    }
    
    // Sign in anonymously if no user is authenticated
    try {
      final userCredential = await _auth.signInAnonymously();
      print('Signed in anonymously with user ID: ${userCredential.user?.uid}');
      return userCredential.user?.uid;
    } catch (e) {
      print('Error signing in anonymously: $e');
      return null;
    }
  }

  Future<List<SecureNote>> getAllSecureNotes() async {
    final userId = await _ensureUserAuthenticated();
    if (userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('secure_notes')
          .where('userId', isEqualTo: userId)
          .get();

      final notes = snapshot.docs
          .map((doc) => SecureNote.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Sort in memory instead of using Firestore orderBy
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      return notes;
    } catch (e) {
      print('Error loading secure notes from Firestore: $e');
      return [];
    }
  }

  Future<SecureNote?> getSecureNoteById(String id) async {
    final userId = await _ensureUserAuthenticated();
    if (userId == null) return null;

    try {
      final doc = await _firestore.collection('secure_notes').doc(id).get();
      if (doc.exists && doc.data()?['userId'] == userId) {
        return SecureNote.fromMap({...doc.data()!, 'id': doc.id});
      }
    } catch (e) {
      print('Error getting secure note by id: $e');
    }
    return null;
  }

  Future<void> saveSecureNote(SecureNote note) async {
    final userId = await _ensureUserAuthenticated();
    if (userId == null) return;

    try {
      final noteData = {
        ...note.toMap(),
        'userId': userId,
      };
      noteData.remove('id'); // Remove id from data

      if (note.id.isEmpty) {
        // Create new secure note - let Firestore generate the ID
        await _firestore.collection('secure_notes').add(noteData);
      } else {
        // Update existing secure note
        await _firestore.collection('secure_notes').doc(note.id).set(noteData);
      }
    } catch (e) {
      print('Error saving secure note: $e');
      rethrow;
    }
  }

  Future<void> deleteSecureNote(String id) async {
    final userId = await _ensureUserAuthenticated();
    if (userId == null) return;

    try {
      // Verify ownership before deleting
      final doc = await _firestore.collection('secure_notes').doc(id).get();
      if (doc.exists && doc.data()?['userId'] == userId) {
        await _firestore.collection('secure_notes').doc(id).delete();
      }
    } catch (e) {
      print('Error deleting secure note: $e');
      rethrow;
    }
  }

  Future<bool> isPinSet() async {
    final userId = await _ensureUserAuthenticated();
    if (userId == null) return false;

    try {
      final doc = await _firestore.collection('user_settings').doc(userId).get();
      return doc.exists && doc.data()?['pinHash'] != null;
    } catch (e) {
      print('Error checking if pin is set: $e');
      return false;
    }
  }

  Future<void> setPin(String pinHash) async {
    final userId = await _ensureUserAuthenticated();
    if (userId == null) return;

    try {
      await _firestore.collection('user_settings').doc(userId).set({
        'pinHash': pinHash,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error setting pin: $e');
      rethrow;
    }
  }

  Future<bool> verifyPin(String pinHash) async {
    final userId = await _ensureUserAuthenticated();
    if (userId == null) return false;

    try {
      final doc = await _firestore.collection('user_settings').doc(userId).get();
      if (doc.exists) {
        final storedHash = doc.data()?['pinHash'];
        return storedHash == pinHash;
      }
      return false;
    } catch (e) {
      print('Error verifying pin: $e');
      return false;
    }
  }
}
