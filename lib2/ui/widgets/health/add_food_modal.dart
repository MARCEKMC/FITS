import 'package:flutter/material.dart';
import '../../../data/food_database.dart';
import '../../../data/models/food_entry.dart';

class AddFoodModal extends StatefulWidget {
  const AddFoodModal({super.key});

  @override
  State<AddFoodModal> createState() => _AddFoodModalState();
}

class _AddFoodModalState extends State<AddFoodModal> {
  String? _selectedFood;
  double _amount = 100;
  final _amountCtrl = TextEditingController(text: "100");

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foods = foodDatabase.map((f) => f['name'] as String).toList();
    final foodMap = foodDatabase.firstWhere(
      (f) => f['name'] == _selectedFood,
      orElse: () => foodDatabase.first,
    );
    return AlertDialog(
      title: const Text("Agregar alimento"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedFood ?? foods.first,
            items: foods
                .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedFood = val;
              });
            },
            decoration: const InputDecoration(labelText: "Alimento"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Cantidad (g)",
              suffix: Text("g"),
            ),
            onChanged: (v) {
              final newV = double.tryParse(v);
              if (newV != null && newV > 0) {
                setState(() => _amount = newV);
              }
            },
          ),
          const SizedBox(height: 10),
          if (_selectedFood != null)
            Text(
              "Kcal x 100g: ${foodMap['calories']}, P: ${foodMap['protein']}g, C: ${foodMap['carbs']}g, G: ${foodMap['fat']}g",
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            final foodMap = foodDatabase.firstWhere((f) => f['name'] == (_selectedFood ?? foods.first));
            final food = FoodEntry.fromMap(foodMap, _amount);
            Navigator.of(context).pop(food);
          },
          child: const Text("Agregar"),
        ),
      ],
    );
  }
}