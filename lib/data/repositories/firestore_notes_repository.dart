import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note.dart';

class FirestoreNotesRepository {
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

  Future<List<Note>> getAllNotes() async {
    final userId = await _ensureUserAuthenticated();
    if (userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .get();

      final notes = snapshot.docs
          .map((doc) => Note.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Sort in memory instead of using Firestore orderBy
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      return notes;
    } catch (e) {
      print('Error loading notes from Firestore: $e');
      return [];
    }
  }

  Future<Note?> getNoteById(String id) async {
    final userId = await _ensureUserAuthenticated();
    if (userId == null) return null;

    try {
      final doc = await _firestore.collection('notes').doc(id).get();
      if (doc.exists && doc.data()?['userId'] == userId) {
        return Note.fromMap({...doc.data()!, 'id': doc.id});
      }
    } catch (e) {
      print('Error getting note by id: $e');
    }
    return null;
  }

  Future<void> saveNote(Note note) async {
    final userId = await _ensureUserAuthenticated();
    if (userId == null) {
      print('Error: Could not authenticate user');
      return;
    }

    print('Saving note for user: $userId');
    print('Note data: ${note.toMap()}');

    try {
      final noteData = {
        ...note.toMap(),
        'userId': userId,
      };
      noteData.remove('id'); // Remove id from data

      if (note.id.isEmpty) {
        // Create new note - let Firestore generate the ID
        print('Creating new note...');
        final docRef = await _firestore.collection('notes').add(noteData);
        print('Note created with ID: ${docRef.id}');
      } else {
        // Update existing note
        print('Updating existing note with ID: ${note.id}');
        await _firestore.collection('notes').doc(note.id).set(noteData);
        print('Note updated successfully');
      }
    } catch (e) {
      print('Error saving note: $e');
      rethrow;
    }
  }

  Future<void> deleteNote(String id) async {
    final userId = await _ensureUserAuthenticated();
    if (userId == null) return;

    try {
      // Verify ownership before deleting
      final doc = await _firestore.collection('notes').doc(id).get();
      if (doc.exists && doc.data()?['userId'] == userId) {
        await _firestore.collection('notes').doc(id).delete();
      }
    } catch (e) {
      print('Error deleting note: $e');
      rethrow;
    }
  }

  Future<List<Note>> searchNotes(String query) async {
    final allNotes = await getAllNotes();
    if (query.isEmpty) return allNotes;

    final lowerQuery = query.toLowerCase();
    return allNotes.where((note) =>
        note.title.toLowerCase().contains(lowerQuery) ||
        note.content.toLowerCase().contains(lowerQuery) ||
        note.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))
    ).toList();
  }

  Future<List<String>> getAllTags() async {
    final notes = await getAllNotes();
    final allTags = <String>{};
    
    for (final note in notes) {
      allTags.addAll(note.tags);
    }
    
    return allTags.toList()..sort();
  }
}
