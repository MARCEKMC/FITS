import 'package:flutter/material.dart';

class IntensitySelector extends StatelessWidget {
  final void Function(String intensity) onSelect;

  const IntensitySelector({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'label': '¡Desafío Total!',
        'desc': 'Rutina exigente, máximo rendimiento',
        'value': 'intense',
        'icon': Icons.whatshot,
      },
      {
        'label': 'Potencia y Progreso',
        'desc': 'Rutina balanceada y efectiva',
        'value': 'medium',
        'icon': Icons.flash_on,
      },
      {
        'label': 'Actívate Ligero',
        'desc': 'Rutina suave para comenzar o recuperar',
        'value': 'easy',
        'icon': Icons.self_improvement,
      },
      {
        'label': 'Rutina Personalizada',
        'desc': 'Elige tus propios ejercicios',
        'value': 'custom',
        'icon': Icons.settings,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 18),
          child: Text(
            "Elige el tipo de entrenamiento",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            textAlign: TextAlign.center,
          ),
        ),
        ...options.map((opt) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            child: ListTile(
              leading: Icon(opt['icon'] as IconData, color: Colors.blue),
              title: Text(opt['label'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(opt['desc'] as String),
              onTap: () => onSelect(opt['value'] as String),
            ),
          );
        }).toList(),
      ],
    );
  }
}
