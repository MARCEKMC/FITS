import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note.dart';

class SimpleNotesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    if (userId == null) {
      print('❌ SimpleNotesRepository: No authenticated user');
      return [];
    }

    try {
      print('📝 SimpleNotesRepository: Loading notes for user: $userId');
      
      // Get user-specific notes only
      final snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .get();

      print('📝 SimpleNotesRepository: Found ${snapshot.docs.length} notes for user $userId');
      final notes = snapshot.docs
          .map((doc) {
            final data = doc.data();
            print('📝 SimpleNotesRepository: Processing note doc: ${doc.id}');
            print('📝 SimpleNotesRepository: Doc data: $data');
            final noteMap = {...data, 'id': doc.id};
            print('📝 SimpleNotesRepository: Note map for parsing: $noteMap');
            try {
              final note = Note.fromMap(noteMap);
              print('✅ SimpleNotesRepository: Successfully parsed note: ${note.title}');
              return note;
            } catch (e) {
              print('❌ SimpleNotesRepository: Error parsing note ${doc.id}: $e');
              rethrow;
            }
          })
          .toList();
      
      // Sort by updatedAt in memory
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      print('📝 SimpleNotesRepository: Returning ${notes.length} sorted notes');
      return notes;
    } catch (e) {
      print('❌ SimpleNotesRepository: Error loading notes from Firestore: $e');
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
      noteData.remove('id');

      if (note.id.isEmpty) {
        print('Creating new note...');
        final docRef = await _firestore.collection('notes').add(noteData);
        print('Note created with ID: ${docRef.id}');
      } else {
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
      final doc = await _firestore.collection('notes').doc(id).get();
      if (doc.exists && doc.data()?['userId'] == userId) {
        await _firestore.collection('notes').doc(id).delete();
        print('Note deleted successfully');
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
