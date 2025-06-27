import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Activity {
  final String id;
  final String title;
  final TimeOfDay start;
  final TimeOfDay end;
  final DateTime date;
  final String category;
  final String priority;
  final bool important;

  Activity({
    String? id,
    required this.title,
    required this.start,
    required this.end,
    required this.date,
    required this.category,
    required this.priority,
    required this.important,
  }) : id = id ?? const Uuid().v4();

  Activity copyWith({
    String? id,
    String? title,
    TimeOfDay? start,
    TimeOfDay? end,
    DateTime? date,
    String? category,
    String? priority,
    bool? important,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      start: start ?? this.start,
      end: end ?? this.end,
      date: date ?? this.date,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      important: important ?? this.important,
    );
  }
}