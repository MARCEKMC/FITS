import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/health_viewmodel.dart';
import '../../../data/models/meal_entry.dart';
import '../../../data/models/food_entry.dart';
import '../../widgets/health/day_selector.dart';
import '../../widgets/health/calorie_progress_bar.dart';
import '../../widgets/health/meal_section.dart';
import '../../widgets/health/water_tracker.dart';

class HealthMainScreen extends StatefulWidget {
  const HealthMainScreen({super.key});

  @override
  State<HealthMainScreen> createState() => _HealthMainScreenState();
}

class _HealthMainScreenState extends State<HealthMainScreen> {
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final healthVM = Provider.of<HealthViewModel>(context);
    final profile = healthVM.profile;
    if (profile == null) {
      // Si el usuario no tiene perfil, redirige a encuesta
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/health_onboarding');
      });
      return const SizedBox();
    }
    final meals = healthVM.mealsForDay(_selectedDay);
    final totalCalories = healthVM.caloriesForDay(_selectedDay);
    final protein = healthVM.proteinForDay(_selectedDay);
    final carbs = healthVM.carbsForDay(_selectedDay);
    final fat = healthVM.fatForDay(_selectedDay);
    final water = healthVM.waterForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Salud"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DaySelector(
              selected: _selectedDay,
              onChanged: (d) => setState(() => _selectedDay = d),
            ),
            const SizedBox(height: 18),
            CalorieProgressBar(consumed: totalCalories, target: profile.recommendedCalories),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Proteína: ${protein.toStringAsFixed(1)}g"),
                Text("Carbs: ${carbs.toStringAsFixed(1)}g"),
                Text("Grasas: ${fat.toStringAsFixed(1)}g"),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  MealSection(
                    mealType: MealType.breakfast,
                    foods: meals[MealType.breakfast]?.foods ?? const [],
                    date: _selectedDay,
                  ),
                  MealSection(
                    mealType: MealType.snackMorning,
                    foods: meals[MealType.snackMorning]?.foods ?? const [],
                    date: _selectedDay,
                  ),
                  MealSection(
                    mealType: MealType.lunch,
                    foods: meals[MealType.lunch]?.foods ?? const [],
                    date: _selectedDay,
                  ),
                  MealSection(
                    mealType: MealType.snackEvening,
                    foods: meals[MealType.snackEvening]?.foods ?? const [],
                    date: _selectedDay,
                  ),
                  MealSection(
                    mealType: MealType.dinner,
                    foods: meals[MealType.dinner]?.foods ?? const [],
                    date: _selectedDay,
                  ),
                  const SizedBox(height: 18),
                  Text("Agua", style: Theme.of(context).textTheme.titleMedium),
                  WaterTracker(
                    cups: water,
                    goal: 8,
                    onTap: (c) => healthVM.setWater(_selectedDay, c),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}