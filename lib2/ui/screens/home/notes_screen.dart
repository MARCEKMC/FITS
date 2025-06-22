import 'package:flutter/material.dart';
import 'package:fits/data/models/note_entry.dart';
import 'package:fits/ui/widgets/notes/note_card.dart';
import 'package:fits/ui/widgets/notes/add_note_modal.dart';
import 'package:fits/ui/widgets/notes/filter_sort_bar.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

enum NotesSortMode { fecha, added, nota, tarea }

class _NotesScreenState extends State<NotesScreen> {
  List<NoteEntry> notes = [];
  NotesSortMode sortMode = NotesSortMode.fecha;
  DateTime? filterDate; // Si filtras por fecha

  void _openAddNoteModal() async {
    final note = await showModalBottomSheet<NoteEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddNoteModal(
        initialDate: DateTime.now(),
      ),
    );
    if (note != null) {
      setState(() => notes.add(note));
    }
  }

  void _toggleComplete(NoteEntry note) {
    setState(() {
      notes = notes.map((n) {
        if (n.id == note.id) {
          return n.copyWith(completed: !n.completed);
        }
        return n;
      }).toList();
    });
  }

  void _changeSortMode(NotesSortMode mode) {
    setState(() => sortMode = mode);
  }

  void _filterByDate(DateTime? date) {
    setState(() => filterDate = date);
  }

  void _showNoteOptions(NoteEntry note) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar'),
              onTap: () async {
                Navigator.pop(ctx);
                final edited = await showModalBottomSheet<NoteEntry>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx2) => AddNoteModal(
                    initialDate: note.date,
                    note: note,
                  ),
                );
                if (edited != null) {
                  setState(() {
                    notes = notes.map((n) => n.id == note.id ? edited.copyWith(addedAt: note.addedAt) : n).toList();
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  notes.removeWhere((n) => n.id == note.id);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  List<NoteEntry> get filteredNotes {
    List<NoteEntry> filtered = List.from(notes);

    // Filtra por tipo si corresponde
    if (sortMode == NotesSortMode.nota) {
      filtered = filtered.where((n) => n.type == NoteType.nota).toList();
    } else if (sortMode == NotesSortMode.tarea) {
      filtered = filtered.where((n) => n.type == NoteType.tarea).toList();
    }

    // Filtra por fecha si corresponde
    if (filterDate != null) {
      filtered = filtered.where((n) =>
        n.date.year == filterDate!.year &&
        n.date.month == filterDate!.month &&
        n.date.day == filterDate!.day
      ).toList();
    }

    // Aplica orden
    switch (sortMode) {
      case NotesSortMode.fecha:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case NotesSortMode.added:
        filtered.sort((a, b) => b.addedAt.compareTo(a.addedAt));
        break;
      case NotesSortMode.nota:
      case NotesSortMode.tarea:
        filtered.sort((a, b) => b.addedAt.compareTo(a.addedAt));
        break;
    }
    return filtered;
  }

  // Agrupa por fecha (día)
  Map<DateTime, List<NoteEntry>> get groupedNotes {
    final map = <DateTime, List<NoteEntry>>{};
    for (final n in filteredNotes) {
      final key = DateTime(n.date.year, n.date.month, n.date.day);
      map.putIfAbsent(key, () => []).add(n);
    }
    // Ordena por fecha descendente
    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in sortedKeys) k: map[k]!};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notas y Tareas", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          FilterSortBar(
            onSortChanged: _changeSortMode,
            currentMode: sortMode,
            onDateFilter: _filterByDate,
            currentDate: filterDate,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: notes.isEmpty
          ? const Center(
              child: Text(
                "Agrega tus primeras notas o tareas",
                style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.w400),
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
              children: [
                for (final entry in groupedNotes.entries) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                    child: Row(
                      children: [
                        Text(
                          "${entry.key.day.toString().padLeft(2, '0')}/${entry.key.month.toString().padLeft(2, '0')}/${entry.key.year}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  ...entry.value.map((note) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        child: NoteCard(
                          note: note,
                          onToggleComplete: note.type == NoteType.tarea ? () => _toggleComplete(note) : null,
                          onTap: () => _showNoteOptions(note),
                        ),
                      )),
                  const SizedBox(height: 8),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddNoteModal,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}