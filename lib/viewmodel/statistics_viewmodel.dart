import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/food_entry.dart';
import '../data/models/exercise_log.dart';

class StatisticsViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Obtiene las estadísticas de calorías para un período específico
  Future<List<double>> getCaloriesData(String userId, String period) async {
    _isLoading = true;
    notifyListeners();

    try {
      final dates = _getDateRange(period);
      final calories = <double>[];

      for (DateTime date in dates) {
        final dayCalories = await _getCaloriesForDate(userId, date);
        calories.add(dayCalories);
      }

      _isLoading = false;
      notifyListeners();
      return calories;
    } catch (e) {
      print('Error getting calories data: $e');
      _isLoading = false;
      notifyListeners();
      return List.filled(_getDateRange(period).length, 0.0);
    }
  }

  /// Obtiene las estadísticas de ejercicios para un período específico
  Future<List<double>> getExercisesData(String userId, String period) async {
    _isLoading = true;
    notifyListeners();

    try {
      final dates = _getDateRange(period);
      final exercises = <double>[];

      for (DateTime date in dates) {
        final hasExercise = await _getExerciseForDate(userId, date);
        exercises.add(hasExercise ? 1.0 : 0.0);
      }

      _isLoading = false;
      notifyListeners();
      return exercises;
    } catch (e) {
      print('Error getting exercises data: $e');
      _isLoading = false;
      notifyListeners();
      return List.filled(_getDateRange(period).length, 0.0);
    }
  }

  /// Obtiene las calorías consumidas en una fecha específica
  Future<double> _getCaloriesForDate(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('food_entries')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThan: endOfDay.toIso8601String())
          .get();

      double totalCalories = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final calories = data['kcal'] ?? data['calories'] ?? 0;
        totalCalories += (calories as num).toDouble();
      }

      return totalCalories;
    } catch (e) {
      print('Error getting calories for date: $e');
      return 0.0;
    }
  }

  /// Verifica si se hizo ejercicio en una fecha específica
  Future<bool> _getExerciseForDate(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      print('🏋️ Buscando ejercicios para: ${startOfDay.toString().substring(0, 10)}');

      final querySnapshot = await _firestore
          .collection('exercise_logs')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      print('🏋️ Ejercicios encontrados: ${querySnapshot.docs.length}');
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('🏋️ Ejercicio: ${data['exerciseName']} - ${(data['date'] as Timestamp).toDate()}');
      }

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error getting exercise for date: $e');
      return false;
    }
  }

  /// Genera el rango de fechas según el período seleccionado
  List<DateTime> _getDateRange(String period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (period) {
      case 'week':
        return List.generate(7, (index) => today.subtract(Duration(days: 6 - index)));
      case 'month':
        return List.generate(30, (index) => today.subtract(Duration(days: 29 - index)));
      case 'year':
        return List.generate(12, (index) {
          final month = now.month - 11 + index;
          final year = month <= 0 ? now.year - 1 : now.year;
          final adjustedMonth = month <= 0 ? month + 12 : month;
          return DateTime(year, adjustedMonth, 1);
        });
      default:
        return List.generate(7, (index) => today.subtract(Duration(days: 6 - index)));
    }
  }

  /// Obtiene estadísticas resumidas para un período
  Future<Map<String, dynamic>> getSummaryStats(String userId, String metric, String period) async {
    List<double> data;
    
    switch (metric) {
      case 'calories':
        data = await getCaloriesData(userId, period);
        break;
      case 'exercises':
        data = await getExercisesData(userId, period);
        break;
      default:
        data = [];
    }

    if (data.isEmpty) {
      return {
        'total': '0',
        'average': '0.0',
        'best': '0',
      };
    }

    final total = data.reduce((a, b) => a + b);
    final average = total / data.length;
    final best = data.reduce((a, b) => a > b ? a : b);

    return {
      'total': metric == 'calories' ? '${total.toInt()}' : '${total.toInt()}',
      'average': average.toStringAsFixed(1),
      'best': best.toInt().toString(),
    };
  }
}
