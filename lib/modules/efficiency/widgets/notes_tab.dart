import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/notes_viewmodel.dart';
import '../../../data/models/note.dart';
import 'note_card.dart';
import 'note_editor_screen.dart';
import '../../../shared/widgets/elegant_confirm_dialog.dart';

class NotesTab extends StatefulWidget {
  const NotesTab({super.key});

  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            // Search and filters section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar notas...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                viewModel.searchNotes('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: viewModel.searchNotes,
                  ),
                  
                  // Tags filter
                  if (viewModel.availableTags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: viewModel.availableTags.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: const Text('Todas'),
                                selected: viewModel.selectedTag.isEmpty,
                                onSelected: (_) => viewModel.clearFilters(),
                                backgroundColor: Colors.white,
                                selectedColor: Colors.black87,
                                labelStyle: TextStyle(
                                  color: viewModel.selectedTag.isEmpty 
                                      ? Colors.white 
                                      : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          
                          final tag = viewModel.availableTags[index - 1];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(tag),
                              selected: viewModel.selectedTag == tag,
                              onSelected: (_) => viewModel.filterByTag(tag),
                              backgroundColor: Colors.white,
                              selectedColor: Colors.black87,
                              labelStyle: TextStyle(
                                color: viewModel.selectedTag == tag 
                                    ? Colors.white 
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Notes list
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.black87))
                  : RefreshIndicator(
                      onRefresh: () async {
                        print('📝 NotesTab: Usuario solicitó refrescar notas');
                        await viewModel.refreshNotes();
                      },
                      color: Colors.black87,
                      child: viewModel.notes.isEmpty
                          ? _buildEmptyState()
                          : _buildNotesList(viewModel.notes),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Center(
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
                'No hay notas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toca el botón + para crear tu primera nota\no desliza hacia abajo para actualizar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesList(List<Note> notes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: NoteCard(
            note: note,
            onTap: () => _editNote(note),
            onDelete: () => _deleteNote(note),
          ),
        );
      },
    );
  }

  void _editNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: note),
      ),
    );
  }

  void _deleteNote(Note note) {
    ElegantConfirmDialog.show(
      context: context,
      title: 'Eliminar nota',
      content: '¿Estás seguro de que quieres eliminar "${note.title}"?',
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
      confirmColor: Colors.red[400],
      onConfirm: () {
        context.read<NotesViewModel>().deleteNote(note.id);
      },
    );
  }
}
