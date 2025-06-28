class FoodEntry {
  final String id;
  final String userId;
  final DateTime date;
  final String mealType; // desayuno, almuerzo, etc
  final String name;
  final int kcal;

  FoodEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.name,
    required this.kcal,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'date': date.toIso8601String(),
    'mealType': mealType,
    'name': name,
    'kcal': kcal,
  };

  static FoodEntry fromMap(Map<String, dynamic> map) => FoodEntry(
    id: map['id'],
    userId: map['userId'],
    date: DateTime.parse(map['date']),
    mealType: map['mealType'],
    name: map['name'],
    kcal: map['kcal'],
  );
}