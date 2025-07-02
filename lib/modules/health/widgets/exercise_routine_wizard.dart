import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/exercise.dart';

class ExerciseRoutineWizard extends StatefulWidget {
  final List<dynamic> routine;

  const ExerciseRoutineWizard({super.key, required this.routine});

  @override
  State<ExerciseRoutineWizard> createState() => _ExerciseRoutineWizardState();
}

class _ExerciseRoutineWizardState extends State<ExerciseRoutineWizard> {
  int _currentStep = 0;
  int _imageIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startImageTimer();
  }

  void _startImageTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _imageIndex = (_imageIndex + 1) % 2);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _next() {
    setState(() {
      _currentStep++;
      _imageIndex = 0;
      _startImageTimer();
    });
  }

  void _skip() {
    setState(() {
      _currentStep++;
      _imageIndex = 0;
      _startImageTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.routine.isEmpty) {
      return const Center(
        child: Text(
          "No hay ejercicios disponibles.",
          style: TextStyle(fontSize: 22, color: Colors.red, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_currentStep >= widget.routine.length) {
      // Felicitaciones
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              "¡Felicitaciones!\nHas completado tu rutina.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Volver"),
            ),
          ],
        ),
      );
    }

    final item = widget.routine[_currentStep];

    // Mensaje de error
    if (item is Map && item['type'] == 'error') {
      return Center(
        child: Text(
          item['label'] ?? "No hay ejercicios disponibles para este grupo muscular.",
          style: const TextStyle(fontSize: 22, color: Colors.red, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Descanso
    if (item is Map && item['type'] == 'rest') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.snooze, size: 60, color: Colors.blueGrey),
            const SizedBox(height: 20),
            Text(
              item['label'] ?? "Descanso",
              style: const TextStyle(fontSize: 26, color: Colors.blueGrey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _next,
              child: const Text("Siguiente"),
            ),
          ],
        ),
      );
    }

    // Ejercicio real usando el modelo de ejercicio local
    final exercise = item as Exercise;
    final String name = exercise.name;
    final String description = exercise.description ?? '';
    final List<String> images = exercise.images;
    final List<String> muscles = exercise.primaryMuscles;

    // Cambia la ruta del asset a assets/exercise/...
    final String? currentImage = (images.isNotEmpty && _imageIndex < images.length) ? images[_imageIndex] : null;
    final String? assetPath = currentImage != null
        ? 'assets/exercise/$currentImage'
        : null;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              muscles.isNotEmpty ? muscles.join(", ") : "Ejercicio",
              style: const TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (assetPath != null && assetPath.isNotEmpty) ...[
              const SizedBox(height: 18),
              Image.asset(
                assetPath,
                width: 180,
                height: 180,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 90, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                description,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _skip,
                  child: const Text("Omitir"),
                ),
                const SizedBox(width: 18),
                ElevatedButton(
                  onPressed: _next,
                  child: const Text("Siguiente"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
