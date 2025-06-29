import 'package:flutter/material.dart';

class ExerciseSurvey extends StatefulWidget {
  final String gender;
  final String? objetivoAlimentacion; // 'ganar', 'mantener', 'perder'
  final void Function({
    required String objetivoAlimentacion,
    required String objetivoEntrenamiento,
    required List<int> selectedMuscleIds,
    required bool experiencia,
    required String lugar,
  }) onFinish;

  const ExerciseSurvey({
    super.key,
    required this.gender,
    required this.objetivoAlimentacion,
    required this.onFinish,
  });

  @override
  State<ExerciseSurvey> createState() => _ExerciseSurveyState();
}

class _ExerciseSurveyState extends State<ExerciseSurvey> {
  String? objetivoEntrenamiento;
  Set<int> selectedMuscles = {};
  bool? experiencia;
  String? lugar;

  // Mapear grupos musculares a IDs de WGER
  static const femaleGroups = [
    {'id': 8, 'name': 'Glúteos 🍑'},
    {'id': 10, 'name': 'Piernas 🦵'},
    {'id': 6, 'name': 'Abdomen'},
    {'id': 1, 'name': 'Brazos'},
    {'id': -1, 'name': 'Todo el cuerpo'},
  ];
  static const maleGroups = [
    {'id': 4, 'name': 'Pecho'},
    {'id': 12, 'name': 'Espalda'},
    {'id': 1, 'name': 'Brazos 💪'},
    {'id': 6, 'name': 'Abdomen'},
    {'id': 10, 'name': 'Piernas'},
    {'id': -1, 'name': 'Todo el cuerpo'},
  ];

  List<Map<String, dynamic>> get muscleOptions =>
      widget.gender == 'Femenino' ? femaleGroups : maleGroups;

  String get objetivoAlimentacionTexto {
    switch (widget.objetivoAlimentacion) {
      case 'ganar':
        return 'Ganar peso';
      case 'mantener':
        return 'Mantener peso';
      case 'perder':
        return 'Bajar peso';
      default:
        return 'Elige objetivo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        // 1. Género (solo muestra, no seleccionable)
        Row(
          children: [
            Text(
              "Género: ",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Text(widget.gender,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 18),
        // 2. Objetivo principal (alimentación)
        const Text("¿Cuál es tu objetivo principal?",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: null, // deshabilitado
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[100],
                  foregroundColor: Colors.black87,
                  disabledBackgroundColor: Colors.blue[100],
                  disabledForegroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                child: Text(objetivoAlimentacionTexto),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 2b. Botones extra para objetivo de entrenamiento
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ObjChip(
              label: 'Ganar fuerza',
              selected: objetivoEntrenamiento == 'fuerza',
              onTap: () => setState(() => objetivoEntrenamiento = 'fuerza'),
            ),
            _ObjChip(
              label: 'Ganar resistencia',
              selected: objetivoEntrenamiento == 'resistencia',
              onTap: () => setState(() => objetivoEntrenamiento = 'resistencia'),
            ),
            _ObjChip(
              label: 'Tonificar',
              selected: objetivoEntrenamiento == 'tonificar',
              onTap: () => setState(() => objetivoEntrenamiento = 'tonificar'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 3. Grupo muscular: cada chip se comporta de manera independiente
        const Text("¿Qué parte del cuerpo te interesa más trabajar?",
            style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 6,
          children: muscleOptions.map((m) {
            return FilterChip(
              label: Text(m['name']),
              selected: selectedMuscles.contains(m['id']),
              onSelected: (v) {
                setState(() {
                  if (v) {
                    selectedMuscles.add(m['id']);
                  } else {
                    selectedMuscles.remove(m['id']);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // 4. Experiencia entrenando
        const Text("¿Tienes experiencia entrenando?",
            style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            ChoiceChip(
              label: const Text('Sí'),
              selected: experiencia == true,
              onSelected: (_) => setState(() => experiencia = true),
            ),
            const SizedBox(width: 12),
            ChoiceChip(
              label: const Text('No'),
              selected: experiencia == false,
              onSelected: (_) => setState(() => experiencia = false),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 5. Lugar: gimnasio o casa
        const Text(
          "¿Tienes acceso a gimnasio o entrenas en casa?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            ChoiceChip(
              label: const Text('Gimnasio'),
              selected: lugar == 'gimnasio',
              onSelected: (_) => setState(() => lugar = 'gimnasio'),
            ),
            const SizedBox(width: 12),
            ChoiceChip(
              label: const Text('Casa'),
              selected: lugar == 'casa',
              onSelected: (_) => setState(() => lugar = 'casa'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Botón continuar
        ElevatedButton(
          onPressed: widget.objetivoAlimentacion != null &&
                  objetivoEntrenamiento != null &&
                  selectedMuscles.isNotEmpty &&
                  experiencia != null &&
                  lugar != null
              ? () {
                  widget.onFinish(
                    objetivoAlimentacion: widget.objetivoAlimentacion!,
                    objetivoEntrenamiento: objetivoEntrenamiento!,
                    selectedMuscleIds: selectedMuscles.toList(),
                    experiencia: experiencia!,
                    lugar: lugar!,
                  );
                }
              : null,
          child: const Text("Ver ejercicios recomendados"),
        )
      ],
    );
  }
}

// Chip para objetivos de entrenamiento
class _ObjChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ObjChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}