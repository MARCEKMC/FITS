import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/secure_note.dart';

class SecureNotesRepository {
  static const String _secureNotesKey = 'secure_notes';
  static const String _pinHashKey = 'secure_notes_pin_hash';

  Future<List<SecureNote>> getAllSecureNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString(_secureNotesKey);
    
    if (notesJson == null) return [];
    
    final List<dynamic> notesList = json.decode(notesJson);
    return notesList.map((json) => SecureNote.fromMap(json)).toList();
  }

  Future<SecureNote?> getSecureNoteById(String id) async {
    final notes = await getAllSecureNotes();
    try {
      return notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveSecureNote(SecureNote note) async {
    final notes = await getAllSecureNotes();
    final existingIndex = notes.indexWhere((n) => n.id == note.id);
    
    if (existingIndex != -1) {
      notes[existingIndex] = note;
    } else {
      notes.add(note);
    }
    
    await _saveSecureNotes(notes);
  }

  Future<void> deleteSecureNote(String id) async {
    final notes = await getAllSecureNotes();
    notes.removeWhere((note) => note.id == id);
    await _saveSecureNotes(notes);
  }

  Future<bool> isPinSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinHashKey);
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    // Hash the pin for storage
    final hashedPin = _hashPin(pin);
    await prefs.setString(_pinHashKey, hashedPin);
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_pinHashKey);
    if (storedHash == null) return false;
    
    final hashedPin = _hashPin(pin);
    return hashedPin == storedHash;
  }

  Future<void> changePin(String oldPin, String newPin) async {
    if (!await verifyPin(oldPin)) {
      throw Exception('PIN actual incorrecto');
    }
    await setPin(newPin);
  }

  String _hashPin(String pin) {
    // Simple hash function - in production, use a more robust solution
    return pin.split('').map((char) => char.codeUnitAt(0)).join();
  }

  Future<void> _saveSecureNotes(List<SecureNote> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = json.encode(notes.map((note) => note.toMap()).toList());
    await prefs.setString(_secureNotesKey, notesJson);
  }
}
