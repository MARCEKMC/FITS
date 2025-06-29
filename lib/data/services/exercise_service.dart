import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/exercise.dart';

class ExerciseService {
  // Usa el path correcto registrado en pubspec.yaml
  static const String jsonPath = 'lib/data/utils/exercises.json';

  Future<List<Exercise>> fetchAllExercises() async {
    final String jsonStr = await rootBundle.loadString(jsonPath);
    final List<dynamic> jsonList = json.decode(jsonStr) as List<dynamic>;
    return jsonList.map((e) => Exercise.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Exercise>> fetchExercisesByMuscle(String muscle) async {
    final all = await fetchAllExercises();
    return all
        .where((e) =>
            e.primaryMuscles.map((m) => m.toLowerCase()).contains(muscle.toLowerCase()))
        .toList();
  }

  Future<List<Exercise>> fetchExercisesByCategory(String category) async {
    final all = await fetchAllExercises();
    return all
        .where((e) => (e.category ?? '').toLowerCase() == category.toLowerCase())
        .toList();
  }
}