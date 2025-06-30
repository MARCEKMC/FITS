import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/schedule_activity.dart';

class ScheduleActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';
  
  CollectionReference get _activitiesCollection => 
      _firestore.collection('schedule_activities');

  // Crear una nueva actividad
  Future<void> createActivity(ScheduleActivity activity) async {
    if (_userId.isEmpty) throw Exception('Usuario no autenticado');
    
    final activityData = activity.toMap();
    activityData['userId'] = _userId;
    activityData['createdAt'] = Timestamp.now();
    // Convertir fechas a Timestamp para Firebase
    activityData['startTime'] = Timestamp.fromDate(activity.startTime);
    activityData['endTime'] = Timestamp.fromDate(activity.endTime);
    activityData['startDate'] = Timestamp.fromDate(activity.startDate);
    if (activity.endDate != null) {
      activityData['endDate'] = Timestamp.fromDate(activity.endDate!);
    }
    
    await _activitiesCollection.doc(activity.id).set(activityData);
  }

  // Obtener actividades del usuario
  Stream<List<ScheduleActivity>> getActivities() {
    if (_userId.isEmpty) return Stream.value([]);
    
    return _activitiesCollection
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ScheduleActivity.fromFirestore(data, doc.id);
        }).toList();
      } catch (e) {
        print('Error parsing activities: $e');
        return <ScheduleActivity>[];
      }
    });
  }

  // Actualizar una actividad
  Future<void> updateActivity(ScheduleActivity activity) async {
    if (_userId.isEmpty) throw Exception('Usuario no autenticado');
    
    final activityData = activity.toMap();
    activityData['userId'] = _userId;
    activityData['updatedAt'] = Timestamp.now();
    // Convertir fechas a Timestamp para Firebase
    activityData['startTime'] = Timestamp.fromDate(activity.startTime);
    activityData['endTime'] = Timestamp.fromDate(activity.endTime);
    activityData['startDate'] = Timestamp.fromDate(activity.startDate);
    if (activity.endDate != null) {
      activityData['endDate'] = Timestamp.fromDate(activity.endDate!);
    }
    
    await _activitiesCollection.doc(activity.id).update(activityData);
  }

  // Eliminar una actividad
  Future<void> deleteActivity(String activityId) async {
    if (_userId.isEmpty) throw Exception('Usuario no autenticado');
    
    await _activitiesCollection.doc(activityId).delete();
  }

  // Obtener actividades por fecha
  Future<List<ScheduleActivity>> getActivitiesByDate(DateTime date) async {
    if (_userId.isEmpty) return [];
    
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final snapshot = await _activitiesCollection
        .where('userId', isEqualTo: _userId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ScheduleActivity.fromFirestore(data, doc.id);
    }).toList();
  }
}
