import 'package:flutter/material.dart';
import '../../../data/models/secure_note.dart';
import '../../../data/repositories/firestore_secure_notes_repository.dart';
import '../../../data/services/encryption_service.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecureNotesViewModel extends ChangeNotifier {
  final FirestoreSecureNotesRepository _repository = FirestoreSecureNotesRepository();
  
  List<SecureNote> _secureNotes = [];
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _currentPin;

  List<SecureNote> get secureNotes => _secureNotes;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> isPinSet() async {
    return await _repository.isPinSet();
  }

  Future<bool> setInitialPin(String pin) async {
    try {
      final hashedPin = _hashPin(pin);
      await _repository.setPin(hashedPin);
      _currentPin = pin;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticate(String pin) async {
    try {
      final hashedPin = _hashPin(pin);
      final isValid = await _repository.verifyPin(hashedPin);
      if (isValid) {
        _currentPin = pin;
        _isAuthenticated = true;
        await loadSecureNotes();
        notifyListeners();
      }
      return isValid;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    _currentPin = null;
    _secureNotes.clear();
    notifyListeners();
  }

  Future<void> loadSecureNotes() async {
    if (!_isAuthenticated) return;

    _isLoading = true;
    notifyListeners();

    try {
      _secureNotes = await _repository.getAllSecureNotes();
      // Sort by updated date (newest first)
      _secureNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      print('Error loading secure notes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveSecureNote(String title, String content, {String? id, String? color}) async {
    if (!_isAuthenticated || _currentPin == null) return false;

    try {
      final encryptedContent = EncryptionService.encryptContent(content, _currentPin!);
      
      // Find existing note if id is provided and not empty
      SecureNote? existingNote;
      if (id != null && id.isNotEmpty) {
        try {
          existingNote = _secureNotes.firstWhere((n) => n.id == id);
        } catch (e) {
          // Note not found, treat as new
        }
      }
      
      final note = SecureNote(
        id: id ?? '', // Let Firestore generate ID if null or empty
        title: title,
        encryptedContent: encryptedContent,
        createdAt: existingNote?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        color: color ?? '#FFFFFF',
      );

      await _repository.saveSecureNote(note);
      await loadSecureNotes();
      return true;
    } catch (e) {
      print('Error saving secure note: $e');
      return false;
    }
  }

  String? decryptNoteContent(SecureNote note) {
    if (!_isAuthenticated || _currentPin == null) return null;
    return EncryptionService.decryptContent(note.encryptedContent, _currentPin!);
  }

  Future<void> deleteSecureNote(String id) async {
    if (!_isAuthenticated) return;

    try {
      await _repository.deleteSecureNote(id);
      await loadSecureNotes();
    } catch (e) {
      print('Error deleting secure note: $e');
    }
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    try {
      // Verify old pin
      final oldHashedPin = _hashPin(oldPin);
      if (!await _repository.verifyPin(oldHashedPin)) {
        return false;
      }

      // Get all notes and re-encrypt with new pin
      final notes = await _repository.getAllSecureNotes();
      final reencryptedNotes = <SecureNote>[];

      for (final note in notes) {
        final decryptedContent = EncryptionService.decryptContent(note.encryptedContent, oldPin);
        if (decryptedContent != null) {
          final newEncryptedContent = EncryptionService.encryptContent(decryptedContent, newPin);
          reencryptedNotes.add(note.copyWith(encryptedContent: newEncryptedContent));
        }
      }

      // Save new pin and re-encrypted notes
      final newHashedPin = _hashPin(newPin);
      await _repository.setPin(newHashedPin);
      for (final note in reencryptedNotes) {
        await _repository.saveSecureNote(note);
      }

      _currentPin = newPin;
      await loadSecureNotes();
      return true;
    } catch (e) {
      print('Error changing pin: $e');
      return false;
    }
  }

  String _hashPin(String pin) {
    var bytes = utf8.encode(pin);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  SecureNote createNewSecureNote() {
    return SecureNote(
      id: '', // Firestore will generate the ID
      title: '',
      encryptedContent: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
