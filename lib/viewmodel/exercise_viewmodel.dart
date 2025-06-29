import 'package:flutter/material.dart';
import '../data/models/exercise.dart';
import '../data/services/exercise_service.dart';
import '../data/utils/muscle_groups.dart'; // <--- AGREGA ESTA LÍNEA


class ExerciseViewModel extends ChangeNotifier {
  final ExerciseService _service = ExerciseService();
  List<Exercise> _exercises = [];
  bool _loading = false;

  List<dynamic> _routine = [];
  List<dynamic> get routine => _routine;

  List<Exercise> get exercises => _exercises;
  bool get loading => _loading;

  Future<void> fetchExercises({String? muscle}) async {
    _loading = true;
    notifyListeners();
    try {
      if (muscle != null && muscle.isNotEmpty) {
        _exercises = await _service.fetchExercisesByMuscle(muscle);
      } else {
        _exercises = await _service.fetchAllExercises();
      }
    } catch (e) {
      _exercises = [];
    }
    _loading = false;
    notifyListeners();
  }

  /// Ejemplo de rutina por grupo muscular
  Future<void> fetchDefaultRoutineByGroup(String groupName, bool isFemale) async {
    _loading = true;
    notifyListeners();
    try {
      final muscleGroups = isFemale ? muscleGroupsFemale : muscleGroupsMale;
      final muscles = muscleGroups[groupName] ?? [];
      final List<Exercise> allExercises = await _service.fetchAllExercises();

      final selectedExercises = allExercises
          .where((e) => e.primaryMuscles.any((m) => muscles.contains(m)))
          .take(5)
          .toList();

      if (selectedExercises.isEmpty) {
        _routine = [
          {
            'type': 'error',
            'label': 'No hay ejercicios disponibles para este grupo muscular.'
          }
        ];
      } else {
        // Puedes alternar ejercicios y descansos aquí según tu lógica
        _routine = [];
        for (var i = 0; i < selectedExercises.length; i++) {
          _routine.add(selectedExercises[i]);
          if (i < selectedExercises.length - 1) {
            _routine.add({
              'type': 'rest',
              'label': 'Descanso breve'
            });
          }
        }
      }
    } catch (e) {
      _routine = [
        {
          'type': 'error',
          'label': 'Ocurrió un error cargando la rutina.'
        }
      ];
    }
    _loading = false;
    notifyListeners();
  }
}