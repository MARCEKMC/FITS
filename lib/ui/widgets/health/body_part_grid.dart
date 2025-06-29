import 'package:flutter/material.dart';

class BodyPartGrid extends StatelessWidget {
  final String gender;
  final void Function(String partName, int muscleId) onTap;

  const BodyPartGrid({
    super.key,
    required this.gender,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> parts = gender == 'Femenino'
        ? [
            {'name': 'Glúteos 🍑', 'id': 8},
            {'name': 'Piernas 🦵', 'id': 10},
            {'name': 'Abdomen', 'id': 6},
            {'name': 'Brazos', 'id': 1},
            {'name': 'Todo el cuerpo', 'id': -1},
          ]
        : [
            {'name': 'Pecho', 'id': 4},
            {'name': 'Espalda', 'id': 12},
            {'name': 'Brazos 💪', 'id': 1},
            {'name': 'Abdomen', 'id': 6},
            {'name': 'Piernas', 'id': 10},
            {'name': 'Todo el cuerpo', 'id': -1},
          ];

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: parts.map((p) {
        return GestureDetector(
          onTap: () => onTap(p['name'], p['id']),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blueGrey, width: 1.5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                p['name'],
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}