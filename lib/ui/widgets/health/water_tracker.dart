import 'package:flutter/material.dart';

class WaterTracker extends StatelessWidget {
  final int glasses;
  final int maxGlasses;
  final Function(int) onTapGlass;

  const WaterTracker({
    super.key,
    required this.glasses,
    this.maxGlasses = 10,
    required this.onTapGlass,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(maxGlasses, (i) {
        final filled = i < glasses;
        return IconButton(
          icon: Icon(
            filled ? Icons.local_drink : Icons.local_drink_outlined,
            color: filled ? Colors.blue : Colors.grey,
            size: 32,
          ),
          onPressed: () => onTapGlass(i + 1),
        );
      }),
    );
  }
}