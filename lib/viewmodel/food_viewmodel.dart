import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/food_entry.dart';
import '../data/repositories/food_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodViewModel extends ChangeNotifier {
  final FoodRepository _repo = FoodRepository();

  List<FoodEntry> _foodEntries = [];

  List<FoodEntry> get foodEntries => _foodEntries;

  Future<void> loadEntriesForDate(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    _foodEntries = await _repo.getFoodEntries(user.uid, normalizedDate);
    notifyListeners();
  }

  Future<void> addFoodEntry(String mealType, String name, int kcal, DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final entry = FoodEntry(
      id: const Uuid().v4(),
      userId: user.uid,
      date: normalizedDate,
      mealType: mealType,
      name: name,
      kcal: kcal,
    );
    await _repo.addFoodEntry(entry);
    await loadEntriesForDate(normalizedDate);
  }

  Future<void> deleteFoodEntry(String id, DateTime date) async {
    await _repo.deleteFoodEntry(id);
    await loadEntriesForDate(date);
  }

  int totalKcalForMeal(String meal) =>
      _foodEntries.where((e) => e.mealType == meal).fold(0, (sum, e) => sum + e.kcal);

  int totalKcalDay() => _foodEntries.fold(0, (sum, e) => sum + e.kcal);
}