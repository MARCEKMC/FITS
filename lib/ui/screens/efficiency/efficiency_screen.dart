import 'package:flutter/material.dart';

class EfficiencyScreen extends StatelessWidget {
  const EfficiencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Image.asset(
          'assets/exercise/Pushups/0.jpg', // Usa la ruta correcta y extensión real
          width: 260,
          height: 260,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 120, color: Colors.red),
        ),
      ),
    );
  }
}