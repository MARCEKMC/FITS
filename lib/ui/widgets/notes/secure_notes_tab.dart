import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/secure_notes_viewmodel.dart';
import 'secure_note_card.dart';
import 'secure_note_editor_screen.dart';
import 'pin_setup_screen.dart';
import 'pin_auth_screen.dart';

class SecureNotesTab extends StatefulWidget {
  const SecureNotesTab({super.key});

  @override
  State<SecureNotesTab> createState() => _SecureNotesTabState();
}

class _SecureNotesTabState extends State<SecureNotesTab> {

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  void _checkPinStatus() async {
    final viewModel = context.read<SecureNotesViewModel>();
    final isPinSet = await viewModel.isPinSet();
    
    if (!isPinSet) {
      _showPinSetup();
    } else if (!viewModel.isAuthenticated) {
      _showPinAuth();
    }
  }

  void _showPinSetup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PinSetupScreen(),
      ),
    );
  }

  void _showPinAuth() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PinAuthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SecureNotesViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.isAuthenticated) {
          return _buildUnauthenticatedState();
        }

        return Column(
          children: [
            // Header with logout button
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    size: 20,
                    color: Colors.green[600],
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Bóveda Segura',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.grey[600]),
                    onPressed: () {
                      viewModel.logout();
                    },
                    tooltip: 'Cerrar bóveda',
                  ),
                ],
              ),
            ),
            
            // Notes list
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.black87))
                  : viewModel.secureNotes.isEmpty
                      ? _buildEmptyState()
                      : _buildSecureNotesList(viewModel.secureNotes),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUnauthenticatedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Bóveda Cerrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa tu PIN para acceder a tus notas seguras',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showPinAuth,
            icon: const Icon(Icons.lock_open, size: 20),
            label: const Text('Abrir Bóveda'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay notas seguras',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón + para crear tu primera nota segura',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecureNotesList(List<dynamic> notes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SecureNoteCard(
            note: note,
            onTap: () => _editSecureNote(note),
            onDelete: () => _deleteSecureNote(note),
          ),
        );
      },
    );
  }

  void _editSecureNote(dynamic note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecureNoteEditorScreen(note: note),
      ),
    );
  }

  void _deleteSecureNote(dynamic note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar nota segura'),
        content: Text('¿Estás seguro de que quieres eliminar "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<SecureNotesViewModel>().deleteSecureNote(note.id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
