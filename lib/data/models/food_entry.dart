class FoodEntry {
  final String name;
  final double amount; // gramos
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodEntry({
    required this.name,
    required this.amount,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory FoodEntry.fromMap(Map<String, dynamic> map, double amount) {
    final factor = amount / (map['serving'] as double);
    return FoodEntry(
      name: map['name'],
      amount: amount,
      calories: (map['calories'] as double) * factor,
      protein: (map['protein'] as double) * factor,
      carbs: (map['carbs'] as double) * factor,
      fat: (map['fat'] as double) * factor,
    );
  }
}