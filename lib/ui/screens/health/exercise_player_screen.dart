import 'dart:async';
import 'package:flutter/material.dart';

class ExercisePlayerScreen extends StatefulWidget {
  final List<String> exerciseFolders; // Ej: ['Push-Ups_With_Feet_Elevated', ...]
  final String groupName;

  const ExercisePlayerScreen({
    Key? key,
    required this.exerciseFolders,
    required this.groupName,
  }) : super(key: key);

  @override
  State<ExercisePlayerScreen> createState() => _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends State<ExercisePlayerScreen> {
  int current = 0;
  int imageIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => imageIndex = (imageIndex + 1) % 2);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void nextExercise() {
    if (current < widget.exerciseFolders.length - 1) {
      setState(() {
        current++;
        imageIndex = 0;
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('¡Completaste los ejercicios de ${widget.groupName}!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('OK'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final folder = widget.exerciseFolders[current];
    final title = folder.replaceAll("_", " ");
    final imgPath = 'assets/exercise/$folder/$imageIndex.jpg';

    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imgPath,
            height: 300,
            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 120),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: nextExercise,
                child: const Text('Siguiente'),
              ),
              ElevatedButton(
                onPressed: nextExercise,
                child: const Text('Omitir'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}