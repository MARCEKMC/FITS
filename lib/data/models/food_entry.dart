class FoodEntry {
  final String id;
  final String userId;
  final DateTime date;
  final String mealType; // desayuno, almuerzo, etc
  final String name;
  final int kcal;
  final double? carbs;   // carbohidratos en gramos
  final double? protein; // proteínas en gramos
  final double? fat;     // grasas en gramos

  FoodEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.name,
    required this.kcal,
    this.carbs,
    this.protein,
    this.fat,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'date': date.toIso8601String(),
    'mealType': mealType,
    'name': name,
    'kcal': kcal,
    'carbs': carbs,
    'protein': protein,
    'fat': fat,
  };

  static FoodEntry fromMap(Map<String, dynamic> map) => FoodEntry(
    id: map['id'],
    userId: map['userId'],
    date: DateTime.parse(map['date']),
    mealType: map['mealType'],
    name: map['name'],
    kcal: map['kcal'],
    carbs: map['carbs'] != null ? (map['carbs'] as num).toDouble() : null,
    protein: map['protein'] != null ? (map['protein'] as num).toDouble() : null,
    fat: map['fat'] != null ? (map['fat'] as num).toDouble() : null,
  );
}