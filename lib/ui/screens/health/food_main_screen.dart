import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/health_viewmodel.dart';

class FoodMainScreen extends StatelessWidget {
  const FoodMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final healthVM = Provider.of<HealthViewModel>(context);
    final profile = healthVM.profile;

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Aquí puedes poner la UI de alimentación real
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tu objetivo diario: ${profile.kcalObjetivo.toStringAsFixed(0)} kcal",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text("Aquí va el resto de la funcionalidad de alimentación..."),
        ],
      ),
    );
  }
}