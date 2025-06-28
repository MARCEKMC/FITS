import 'package:flutter/material.dart';

class CaloriesProgressBar extends StatelessWidget {
  final int total;
  final int consumed;

  const CaloriesProgressBar({super.key, required this.total, required this.consumed});

  @override
  Widget build(BuildContext context) {
    final percent = (consumed / total).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: percent,
          minHeight: 18,
          backgroundColor: Colors.grey[300],
          color: Colors.green,
        ),
        const SizedBox(height: 8),
        Text("$consumed / $total kcal", style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}