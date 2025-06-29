import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/water_entry.dart';

class WaterRepository {
  final _db = FirebaseFirestore.instance;

  // Obtiene el registro del usuario para el día normalizado
  Future<WaterEntry?> getWaterEntry(String userId, DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final id = '${userId}_${normalizedDate.year}_${normalizedDate.month}_${normalizedDate.day}';
    final doc = await _db.collection('water_entries').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return WaterEntry.fromMap(doc.data()!);
    }
    return null;
  }

  // Guarda el registro usando el ID único por usuario y día
  Future<void> setWaterEntry(WaterEntry entry) async {
    await _db.collection('water_entries').doc(entry.id).set(entry.toMap());
  }
}