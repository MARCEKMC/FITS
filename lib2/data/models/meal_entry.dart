import 'food_entry.dart';

enum MealType { breakfast, snackMorning, lunch, snackEvening, dinner }

class MealEntry {
  final MealType type;
  final List<FoodEntry> foods;

  MealEntry({required this.type, List<FoodEntry>? foods})
      : foods = foods ?? [];

  double get totalCalories =>
      foods.fold(0, (sum, f) => sum + f.calories);

  double get totalProtein =>
      foods.fold(0, (sum, f) => sum + f.protein);

  double get totalCarbs =>
      foods.fold(0, (sum, f) => sum + f.carbs);

  double get totalFat =>
      foods.fold(0, (sum, f) => sum + f.fat);

  MealEntry copyWith({List<FoodEntry>? foods}) =>
      MealEntry(type: type, foods: foods ?? this.foods);
}