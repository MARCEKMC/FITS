import 'package:flutter/material.dart';

class CalorieProgressBar extends StatelessWidget {
  final int consumed;
  final int target;

  const CalorieProgressBar({super.key, required this.consumed, required this.target});

  @override
  Widget build(BuildContext context) {
    final percent = (consumed / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Calorías: $consumed / $target kcal", style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey[200],
            color: percent < 0.9
                ? Colors.green
                : (percent < 1.1 ? Colors.orange : Colors.red),
            minHeight: 12,
          ),
        ),
      ],
    );
  }
}