import 'package:flutter/foundation.dart';
import '../data/models/note.dart';
import '../data/repositories/simple_notes_repository.dart';

class NotesViewModel extends ChangeNotifier {
  final SimpleNotesRepository _repository = SimpleNotesRepository();
  
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedTag = '';
  List<String> _availableTags = [];

  List<Note> get notes => _filteredNotes;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedTag => _selectedTag;
  List<String> get availableTags => _availableTags;

  Future<void> loadNotes() async {
    print('NotesViewModel: Starting to load notes...');
    _isLoading = true;
    notifyListeners();

    try {
      print('NotesViewModel: Calling repository.getAllNotes()...');
      _notes = await _repository.getAllNotes();
      print('NotesViewModel: Loaded ${_notes.length} notes');
      for (var note in _notes) {
        print('NotesViewModel: Note - ID: ${note.id}, Title: ${note.title}');
      }
      _availableTags = await _repository.getAllTags();
      _applyFilters();
    } catch (e) {
      print('NotesViewModel: Error loading notes: $e');
    } finally {
      _isLoading = false;
      print('NotesViewModel: Finished loading notes, notifying listeners...');
      notifyListeners();
    }
  }

  Future<void> saveNote(Note note) async {
    print('NotesViewModel: Attempting to save note: ${note.title}');
    try {
      await _repository.saveNote(note);
      print('NotesViewModel: Note saved successfully, reloading notes...');
      await loadNotes(); // Reload to update the list
    } catch (e) {
      print('NotesViewModel: Error saving note: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _repository.deleteNote(id);
      await loadNotes(); // Reload to update the list
    } catch (e) {
      print('Error deleting note: $e');
    }
  }

  void searchNotes(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void filterByTag(String tag) {
    _selectedTag = tag;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedTag = '';
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredNotes = _notes.where((note) {
      final matchesSearch = _searchQuery.isEmpty ||
          note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesTag = _selectedTag.isEmpty || note.tags.contains(_selectedTag);

      return matchesSearch && matchesTag;
    }).toList();
  }

  Note createNewNote() {
    return Note(
      id: '',
      title: '',
      content: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: [],
      color: '#FFFFFF',
      isPinned: false,
    );
  }

  Future<void> addQuickNote(String noteText) async {
    try {
      final newNote = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: noteText.length > 50 ? '${noteText.substring(0, 50)}...' : noteText,
        content: noteText,
        tags: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _repository.saveNote(newNote);
      await loadNotes(); // Reload to update the list
    } catch (e) {
      print('Error adding quick note: $e');
      rethrow;
    }
  }
}
