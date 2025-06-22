import 'package:flutter/material.dart';
import '../../../data/models/meal_entry.dart';
import '../../../data/models/food_entry.dart';
import 'add_food_modal.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/health_viewmodel.dart';

class MealSection extends StatelessWidget {
  final MealType mealType;
  final List<FoodEntry> foods;
  final DateTime date;

  const MealSection({
    super.key,
    required this.mealType,
    required this.foods,
    required this.date,
  });

  String get mealName {
    switch (mealType) {
      case MealType.breakfast: return "Desayuno";
      case MealType.snackMorning: return "Snack Mañana";
      case MealType.lunch: return "Almuerzo";
      case MealType.snackEvening: return "Snack Tarde";
      case MealType.dinner: return "Cena";
    }
  }

  IconData get mealIcon {
    switch (mealType) {
      case MealType.breakfast: return Icons.free_breakfast;
      case MealType.snackMorning: return Icons.cookie;
      case MealType.lunch: return Icons.lunch_dining;
      case MealType.snackEvening: return Icons.coffee;
      case MealType.dinner: return Icons.nightlife;
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthVM = Provider.of<HealthViewModel>(context, listen: false);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(mealIcon, color: Colors.black54, size: 20),
                const SizedBox(width: 7),
                Text(mealName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.black87),
                  onPressed: () async {
                    final food = await showDialog<FoodEntry>(
                      context: context,
                      builder: (ctx) => AddFoodModal(),
                    );
                    if (food != null) {
                      healthVM.addFood(date, mealType, food);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (foods.isEmpty)
              const Text("Nada agregado.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            ...foods.asMap().entries.map((entry) {
              final i = entry.key;
              final f = entry.value;
              return Dismissible(
                key: ValueKey("$mealType-$i-${f.name}-${f.amount}"),
                background: Container(color: Colors.red.withOpacity(0.8)),
                onDismissed: (dir) {
                  healthVM.removeFood(date, mealType, i);
                },
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text("${f.name} (${f.amount}g)"),
                  subtitle: Text(
                    "Kcal: ${f.calories.toStringAsFixed(0)} | P: ${f.protein.toStringAsFixed(1)}g | C: ${f.carbs.toStringAsFixed(1)}g | G: ${f.fat.toStringAsFixed(1)}g",
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: const Icon(Icons.delete, color: Colors.black26),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}