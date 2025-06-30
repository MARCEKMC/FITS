import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NotesRepository {
  static const String _notesKey = 'notes';

  Future<List<Note>> getAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString(_notesKey);
    
    if (notesJson == null) return [];
    
    final List<dynamic> notesList = json.decode(notesJson);
    return notesList.map((json) => Note.fromMap(json)).toList();
  }

  Future<Note?> getNoteById(String id) async {
    final notes = await getAllNotes();
    try {
      return notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveNote(Note note) async {
    final notes = await getAllNotes();
    final existingIndex = notes.indexWhere((n) => n.id == note.id);
    
    if (existingIndex != -1) {
      notes[existingIndex] = note;
    } else {
      notes.add(note);
    }
    
    await _saveNotes(notes);
  }

  Future<void> deleteNote(String id) async {
    final notes = await getAllNotes();
    notes.removeWhere((note) => note.id == id);
    await _saveNotes(notes);
  }

  Future<List<Note>> searchNotes(String query) async {
    final notes = await getAllNotes();
    if (query.isEmpty) return notes;
    
    final lowerQuery = query.toLowerCase();
    return notes.where((note) =>
        note.title.toLowerCase().contains(lowerQuery) ||
        note.content.toLowerCase().contains(lowerQuery) ||
        note.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))
    ).toList();
  }

  Future<List<Note>> getNotesByTag(String tag) async {
    final notes = await getAllNotes();
    return notes.where((note) => note.tags.contains(tag)).toList();
  }

  Future<List<String>> getAllTags() async {
    final notes = await getAllNotes();
    final allTags = <String>{};
    
    for (final note in notes) {
      allTags.addAll(note.tags);
    }
    
    return allTags.toList()..sort();
  }

  Future<void> _saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = json.encode(notes.map((note) => note.toMap()).toList());
    await prefs.setString(_notesKey, notesJson);
  }
}
