import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/water_entry.dart';
import '../data/repositories/water_repository.dart';

class WaterViewModel extends ChangeNotifier {
  final WaterRepository _repo = WaterRepository();
  WaterEntry? _entry;

  WaterEntry? get entry => _entry;
  int get glasses => _entry?.glasses ?? 0;

  void clearEntry() {
    _entry = null;
    notifyListeners();
  }

  Future<void> loadEntryForDate(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    _entry = null;
    notifyListeners();
    print('[WaterViewModel] Cargando entrada para fecha: $normalizedDate');
    _entry = await _repo.getWaterEntry(user.uid, normalizedDate);
    notifyListeners();
  }

  Future<void> setGlasses(int count, DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final id = '${user.uid}_${normalizedDate.year}_${normalizedDate.month}_${normalizedDate.day}';
    print('[WaterViewModel] Guardando $count vasos para $normalizedDate (id=$id)');
    final entry = WaterEntry(
      id: id,
      userId: user.uid,
      date: normalizedDate,
      glasses: count,
    );
    await _repo.setWaterEntry(entry);
    _entry = entry;
    notifyListeners();
  }
}