import 'package:flutter/material.dart';

class WaterTracker extends StatelessWidget {
  final int cups;
  final int goal;
  final void Function(int) onTap;

  const WaterTracker({super.key, required this.cups, required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(goal, (i) {
        return GestureDetector(
          onTap: () => onTap(i + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(
              Icons.local_drink,
              color: i < cups ? Colors.blue : Colors.grey[300],
              size: 32,
            ),
          ),
        );
      }),
    );
  }
}