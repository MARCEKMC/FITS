class HealthProfile {
  final String uid;
  final String objetivo; // 'ganar', 'mantener', 'perder'
  final double pesoActual;
  final double alturaActual;
  final double metaPeso;
  final List<String> enfermedades;
  final int edad;
  final String genero;
  final double kcalObjetivo;
  final bool hasCompletedExerciseSurvey; // Nuevo campo para la encuesta de ejercicios

  HealthProfile({
    required this.uid,
    required this.objetivo,
    required this.pesoActual,
    required this.alturaActual,
    required this.metaPeso,
    required this.enfermedades,
    required this.edad,
    required this.genero,
    required this.kcalObjetivo,
    this.hasCompletedExerciseSurvey = false, // Por defecto false
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'objetivo': objetivo,
        'pesoActual': pesoActual,
        'alturaActual': alturaActual,
        'metaPeso': metaPeso,
        'enfermedades': enfermedades,
        'edad': edad,
        'genero': genero,
        'kcalObjetivo': kcalObjetivo,
        'hasCompletedExerciseSurvey': hasCompletedExerciseSurvey,
      };

  static HealthProfile fromMap(Map<String, dynamic> map) => HealthProfile(
        uid: map['uid'],
        objetivo: map['objetivo'],
        pesoActual: (map['pesoActual'] as num).toDouble(),
        alturaActual: (map['alturaActual'] as num).toDouble(),
        metaPeso: (map['metaPeso'] as num).toDouble(),
        enfermedades: List<String>.from(map['enfermedades'] ?? []),
        edad: map['edad'],
        genero: map['genero'],
        kcalObjetivo: (map['kcalObjetivo'] as num).toDouble(),
        hasCompletedExerciseSurvey: map['hasCompletedExerciseSurvey'] ?? false,
      );
}