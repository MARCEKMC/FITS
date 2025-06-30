import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityCategory {
  actividades,
  habitos,
  asuntosImportantes,
}

extension ActivityCategoryExtension on ActivityCategory {
  String get displayName {
    switch (this) {
      case ActivityCategory.actividades:
        return 'Actividades';
      case ActivityCategory.habitos:
        return 'Hábitos';
      case ActivityCategory.asuntosImportantes:
        return 'Asuntos Importantes';
    }
  }
  
  String get value {
    switch (this) {
      case ActivityCategory.actividades:
        return 'actividades';
      case ActivityCategory.habitos:
        return 'habitos';
      case ActivityCategory.asuntosImportantes:
        return 'asuntos_importantes';
    }
  }
}

class ScheduleActivity {
  final String id;
  final String title;
  final ActivityCategory category;
  final DateTime startTime;
  final DateTime endTime;
  final List<int> repeatDays; // 1=Monday, 7=Sunday
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;

  ScheduleActivity({
    required this.id,
    required this.title,
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.repeatDays,
    required this.startDate,
    this.endDate,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category.value,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'repeatDays': repeatDays,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'description': description,
    };
  }

  static ScheduleActivity fromFirestore(Map<String, dynamic> data, String id) {
    return ScheduleActivity(
      id: id,
      title: data['title'] ?? '',
      category: ActivityCategory.values.firstWhere(
        (e) => e.value == data['category'],
        orElse: () => ActivityCategory.actividades,
      ),
      startTime: data['startTime'] is Timestamp 
          ? (data['startTime'] as Timestamp).toDate()
          : DateTime.parse(data['startTime']),
      endTime: data['endTime'] is Timestamp 
          ? (data['endTime'] as Timestamp).toDate()
          : DateTime.parse(data['endTime']),
      repeatDays: List<int>.from(data['repeatDays'] ?? []),
      startDate: data['startDate'] is Timestamp 
          ? (data['startDate'] as Timestamp).toDate()
          : DateTime.parse(data['startDate']),
      endDate: data['endDate'] != null 
          ? (data['endDate'] is Timestamp 
              ? (data['endDate'] as Timestamp).toDate()
              : DateTime.parse(data['endDate']))
          : null,
      description: data['description'],
    );
  }

  static ScheduleActivity fromMap(Map<String, dynamic> map, String id) {
    return ScheduleActivity(
      id: id,
      title: map['title'],
      category: ActivityCategory.values.firstWhere(
        (e) => e.value == map['category'],
        orElse: () => ActivityCategory.actividades,
      ),
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      repeatDays: List<int>.from(map['repeatDays']),
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      description: map['description'],
    );
  }

  static ScheduleActivity fromMapWithId(Map<String, dynamic> map) {
    return ScheduleActivity(
      id: map['id'],
      title: map['title'],
      category: ActivityCategory.values.firstWhere(
        (e) => e.value == map['category'],
        orElse: () => ActivityCategory.actividades,
      ),
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      repeatDays: List<int>.from(map['repeatDays']),
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      description: map['description'],
    );
  }
}
