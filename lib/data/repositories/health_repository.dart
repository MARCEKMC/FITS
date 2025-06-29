import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_profile.dart';

class HealthRepository {
  final _db = FirebaseFirestore.instance;

  Future<HealthProfile?> getHealthProfile(String uid) async {
    final doc = await _db.collection('health_profiles').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return HealthProfile.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> saveHealthProfile(HealthProfile profile) async {
    await _db.collection('health_profiles').doc(profile.uid).set(profile.toMap());
  }
}