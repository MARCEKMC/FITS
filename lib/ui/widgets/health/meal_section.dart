import 'package:flutter/material.dart';

class MealSection extends StatelessWidget {
  final String mealName;
  final int calories;
  final VoidCallback onAdd;
  final List<Map<String, dynamic>> foods; // {name, kcal}

  const MealSection({
    super.key,
    required this.mealName,
    required this.calories,
    required this.onAdd,
    required this.foods,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        title: Text(mealName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$calories kcal'),
        children: [
          ...foods.map((food) => ListTile(
            title: Text(food['name']),
            trailing: Text('${food['kcal']} kcal'),
          )),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text("Agregar alimento"),
            ),
          ),
        ],
      ),
    );
  }
}