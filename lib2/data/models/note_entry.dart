import 'package:uuid/uuid.dart';

enum NoteType { nota, tarea }

class NoteEntry {
  final String id;
  final NoteType type;
  final String content;
  final DateTime date;
  final bool completed;
  final DateTime addedAt; // Nuevo: fecha y hora de añadido

  NoteEntry({
    String? id,
    required this.type,
    required this.content,
    required this.date,
    this.completed = false,
    DateTime? addedAt,
  })  : id = id ?? const Uuid().v4(),
        addedAt = addedAt ?? DateTime.now();

  NoteEntry copyWith({
    String? id,
    NoteType? type,
    String? content,
    DateTime? date,
    bool? completed,
    DateTime? addedAt,
  }) {
    return NoteEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}