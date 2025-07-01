import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseLog {
  final String id;
  final String userId;
  final DateTime date;
  final String exerciseName;
  final int durationMinutes;
  final String? bodyPart;
  final int? sets;
  final int? reps;
  final double? weight;

  ExerciseLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.exerciseName,
    required this.durationMinutes,
    this.bodyPart,
    this.sets,
    this.reps,
    this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'exerciseName': exerciseName,
      'durationMinutes': durationMinutes,
      'bodyPart': bodyPart,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }

  static ExerciseLog fromMap(Map<String, dynamic> map) {
    DateTime date = DateTime.now();
    
    if (map['date'] is Timestamp) {
      date = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is String) {
      date = DateTime.tryParse(map['date']) ?? DateTime.now();
    }
    
    return ExerciseLog(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      date: date,
      exerciseName: map['exerciseName'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 0,
      bodyPart: map['bodyPart'],
      sets: map['sets'],
      reps: map['reps'],
      weight: map['weight']?.toDouble(),
    );
  }
}
