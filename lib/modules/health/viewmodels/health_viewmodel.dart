import 'package:flutter/material.dart';
import '../../../data/models/health_profile.dart';
import '../../../data/repositories/health_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HealthViewModel extends ChangeNotifier {
  HealthProfile? _profile;
  final HealthRepository _repo = HealthRepository();

  HealthProfile? get profile => _profile;

  Future<bool> hasHealthProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    _profile = await _repo.getHealthProfile(user.uid);
    notifyListeners();
    return _profile != null;
  }

  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _profile = await _repo.getHealthProfile(user.uid);
    notifyListeners();
  }

  Future<void> saveProfile(HealthProfile profile) async {
    await _repo.saveHealthProfile(profile);
    _profile = profile;
    notifyListeners();
  }

  Future<void> markExerciseSurveyCompleted() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    if (_profile != null) {
      // Si ya tenemos un perfil cargado, actualizar solo el campo específico
      await _repo.updateExerciseSurveyCompleted(user.uid, true);
      
      // Actualizar el perfil local
      _profile = HealthProfile(
        uid: _profile!.uid,
        objetivo: _profile!.objetivo,
        pesoActual: _profile!.pesoActual,
        alturaActual: _profile!.alturaActual,
        metaPeso: _profile!.metaPeso,
        enfermedades: _profile!.enfermedades,
        edad: _profile!.edad,
        genero: _profile!.genero,
        kcalObjetivo: _profile!.kcalObjetivo,
        hasCompletedExerciseSurvey: true,
      );
    } else {
      // Si no hay perfil, solo actualizar el campo específico en Firebase
      await _repo.updateExerciseSurveyCompleted(user.uid, true);
    }
    
    notifyListeners();
  }

  bool get hasCompletedExerciseSurvey => _profile?.hasCompletedExerciseSurvey ?? false;
}
