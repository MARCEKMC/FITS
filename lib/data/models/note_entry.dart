import 'package:flutter/material.dart';

enum NoteType { nota, tarea }

class NoteEntry {
  final String? id;
  final NoteType type;
  final String content;
  final DateTime date;
  final bool completed;
  final DateTime addedAt;

  NoteEntry({
    this.id,
    required this.type,
    required this.content,
    required this.date,
    this.completed = false,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

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