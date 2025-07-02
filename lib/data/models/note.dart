import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final String color;
  final bool isPinned;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.color = '#FFFFFF',
    this.isPinned = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'color': color,
      'isPinned': isPinned,
    };
  }

  static Note fromMap(Map<String, dynamic> map) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      
      // Si es un Timestamp de Firestore
      if (value.runtimeType.toString() == 'Timestamp') {
        try {
          return (value as dynamic).toDate();
        } catch (e) {
          print('Error parsing Timestamp: $e');
          return DateTime.now();
        }
      }
      
      // Si es un string ISO
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          print('Error parsing DateTime string: $e');
          return DateTime.now();
        }
      }
      
      // Si es un DateTime
      if (value is DateTime) {
        return value;
      }
      
      print('Unknown date type: ${value.runtimeType}, value: $value');
      return DateTime.now();
    }
    
    return Note(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseDateTime(map['updatedAt']),
      tags: List<String>.from(map['tags'] ?? []),
      color: map['color'] ?? '#FFFFFF',
      isPinned: map['isPinned'] ?? false,
    );
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? color,
    bool? isPinned,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
