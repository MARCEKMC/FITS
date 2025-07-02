import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/notes_viewmodel.dart';
import '../viewmodels/secure_notes_viewmodel.dart';
import '../viewmodels/tasks_viewmodel.dart';
import 'note_editor_screen.dart';
import 'secure_note_editor_screen.dart';
import 'task_editor_screen.dart';

class NotesFloatingActionButton extends StatelessWidget {
  final int currentTabIndex;

  const NotesFloatingActionButton({
    super.key,
    required this.currentTabIndex,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _handleFabPress(context),
      backgroundColor: Colors.black87,
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.add, size: 28),
    );
  }

  void _handleFabPress(BuildContext context) {
    switch (currentTabIndex) {
      case 0: // Notes tab
        _createNewNote(context);
        break;
      case 1: // Secure notes tab
        _createNewSecureNote(context);
        break;
      case 2: // Tasks tab
        _createNewTask(context);
        break;
    }
  }

  void _createNewNote(BuildContext context) {
    final newNote = context.read<NotesViewModel>().createNewNote();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: newNote),
      ),
    );
  }

  void _createNewSecureNote(BuildContext context) {
    final secureNotesViewModel = context.read<SecureNotesViewModel>();
    
    if (!secureNotesViewModel.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes autenticarte primero para crear notas seguras'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SecureNoteEditorScreen(),
      ),
    );
  }

  void _createNewTask(BuildContext context) {
    final newTask = context.read<TasksViewModel>().createNewTask();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskEditorScreen(task: newTask),
      ),
    );
  }
}
