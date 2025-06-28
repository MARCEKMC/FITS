import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_entry.dart';

class FoodRepository {
  final _db = FirebaseFirestore.instance;

  Future<List<FoodEntry>> getFoodEntries(String userId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final snapshot = await _db
        .collection('food_entries')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThan: end.toIso8601String())
        .get();

    return snapshot.docs.map((doc) => FoodEntry.fromMap(doc.data())).toList();
  }

  Future<void> addFoodEntry(FoodEntry entry) async {
    await _db.collection('food_entries').doc(entry.id).set(entry.toMap());
  }

  Future<void> deleteFoodEntry(String id) async {
    await _db.collection('food_entries').doc(id).delete();
  }
}