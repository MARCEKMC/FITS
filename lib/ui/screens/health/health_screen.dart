import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/health_viewmodel.dart';
import '../../widgets/health/calories_progress_bar.dart';
import '../../widgets/health/water_tracker.dart';
import '../../widgets/health/food_section.dart';
import '../../widgets/health/day_slider.dart'; // IMPORTANTE: agrega esta línea

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final healthVM = Provider.of<HealthViewModel>(context);
    final profile = healthVM.profile;

    if (profile == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final today = DateTime.now();
    final selectedDay = healthVM.selectedDate;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          children: [
            // Calendario y "Hoy"
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 22),
                const SizedBox(width: 6),
                TextButton(
                  onPressed: () => healthVM.setSelectedDate(today),
                  child: const Text("Hoy", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Text(
                  "${profile.dailyCalories.toStringAsFixed(0)} kcal objetivo",
                  style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Barra de progreso de calorías
            CaloriesProgressBar(),
            const SizedBox(height: 22),
            // Barra de días
            DaySlider(
              initialDate: healthVM.selectedDate,
              onDateSelected: healthVM.setSelectedDate,
            ),
            const SizedBox(height: 22),
            // Comidas y calorías del día
            FoodSection(date: selectedDay),
            const SizedBox(height: 28),
            // Agua
            const Text("Agua:", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            WaterTracker(),
          ],
        ),
      ),
    );
  }
}