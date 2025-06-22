import 'package:flutter/material.dart';
import '../data/models/health_profile.dart';
import '../data/models/meal_entry.dart';
import '../data/models/food_entry.dart';

class HealthViewModel extends ChangeNotifier {
  HealthProfile? _profile;
  final Map<DateTime, Map<MealType, MealEntry>> _mealsByDay = {};
  final Map<DateTime, int> _waterByDay = {};

  // --- Perfil ---
  HealthProfile? get profile => _profile;
  set profile(HealthProfile? val) {
    _profile = val;
    notifyListeners();
  }

  // --- Comidas ---
  Map<MealType, MealEntry> mealsForDay(DateTime day) =>
      _mealsByDay[DateTime(day.year, day.month, day.day)] ??
      {
        MealType.breakfast: MealEntry(type: MealType.breakfast),
        MealType.snackMorning: MealEntry(type: MealType.snackMorning),
        MealType.lunch: MealEntry(type: MealType.lunch),
        MealType.snackEvening: MealEntry(type: MealType.snackEvening),
        MealType.dinner: MealEntry(type: MealType.dinner),
      };

  void addFood(DateTime day, MealType type, FoodEntry food) {
    final d = DateTime(day.year, day.month, day.day);
    final meals = mealsForDay(d);
    final meal = meals[type] ?? MealEntry(type: type);
    meals[type] = meal.copyWith(foods: [...meal.foods, food]);
    _mealsByDay[d] = meals;
    notifyListeners();
  }

  void removeFood(DateTime day, MealType type, int foodIndex) {
    final d = DateTime(day.year, day.month, day.day);
    final meals = mealsForDay(d);
    final meal = meals[type] ?? MealEntry(type: type);
    final foods = List<FoodEntry>.from(meal.foods);
    if (foodIndex >= 0 && foodIndex < foods.length) {
      foods.removeAt(foodIndex);
      meals[type] = meal.copyWith(foods: foods);
      _mealsByDay[d] = meals;
      notifyListeners();
    }
  }

  // --- Agua ---
  int waterForDay(DateTime day) =>
      _waterByDay[DateTime(day.year, day.month, day.day)] ?? 0;

  void setWater(DateTime day, int cups) {
    final d = DateTime(day.year, day.month, day.day);
    _waterByDay[d] = cups;
    notifyListeners();
  }

  // --- Totales del día ---
  int caloriesForDay(DateTime day) {
    final meals = mealsForDay(day);
    return meals.values.fold(0, (sum, m) => sum + m.totalCalories.round());
  }

  double proteinForDay(DateTime day) {
    final meals = mealsForDay(day);
    return meals.values.fold(0.0, (sum, m) => sum + m.totalProtein);
  }

  double carbsForDay(DateTime day) {
    final meals = mealsForDay(day);
    return meals.values.fold(0.0, (sum, m) => sum + m.totalCarbs);
  }

  double fatForDay(DateTime day) {
    final meals = mealsForDay(day);
    return meals.values.fold(0.0, (sum, m) => sum + m.totalFat);
  }
}