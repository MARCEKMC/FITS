import 'package:flutter/material.dart';
import 'package:fits/data/models/note_entry.dart';

class NoteCard extends StatelessWidget {
  final NoteEntry note;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onTap;

  const NoteCard({
    Key? key,
    required this.note,
    this.onToggleComplete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTask = note.type == NoteType.tarea;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isTask
              ? (note.completed ? Colors.green[100] : Colors.yellow[50])
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: ListTile(
          leading: isTask
              ? IconButton(
                  icon: Icon(
                    note.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: note.completed ? Colors.green : Colors.grey,
                    size: 28,
                  ),
                  onPressed: onToggleComplete,
                  tooltip: note.completed ? 'Completada' : 'Marcar como completada',
                )
              : const Icon(Icons.note, color: Colors.black54),
          title: Text(
            note.content,
            style: TextStyle(
              decoration: isTask && note.completed ? TextDecoration.lineThrough : null,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            isTask ? "Tarea" : "Nota",
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
            ),
          ),
          trailing: isTask
              ? null
              : const Icon(Icons.chevron_right, color: Colors.black26),
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        ),
      ),
    );
  }
}