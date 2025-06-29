class FoodSearchResult {
  final String name;
  final double? kcal;
  final double? carbs;
  final double? protein;
  final double? fat;

  FoodSearchResult({
    required this.name,
    this.kcal,
    this.carbs,
    this.protein,
    this.fat,
  });

  factory FoodSearchResult.fromJson(Map<String, dynamic> json) {
    final nutriments = json['nutriments'] ?? {};
    return FoodSearchResult(
      name: (json['product_name'] ?? json['generic_name'] ?? '').toString(),
      kcal: (nutriments['energy-kcal_100g'] as num?)?.toDouble(),
      carbs: (nutriments['carbohydrates_100g'] as num?)?.toDouble(),
      protein: (nutriments['proteins_100g'] as num?)?.toDouble(),
      fat: (nutriments['fat_100g'] as num?)?.toDouble(),
    );
  }
}