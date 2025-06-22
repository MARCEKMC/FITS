enum GoalType { gain, lose, maintain }

class HealthProfile {
  final double weight; // kg
  final double height; // cm
  final double targetWeight; // kg
  final GoalType goal;
  final int recommendedCalories;

  HealthProfile({
    required this.weight,
    required this.height,
    required this.targetWeight,
    required this.goal,
    required this.recommendedCalories,
  });

  factory HealthProfile.calculate({
    required double weight,
    required double height,
    required double targetWeight,
    required GoalType goal,
    int age = 25,
    String gender = "male",
  }) {
    // Mifflin-St Jeor formula (simple, sin actividad)
    final bmr = gender == "male"
        ? 10 * weight + 6.25 * height - 5 * age + 5
        : 10 * weight + 6.25 * height - 5 * age - 161;
    int calories = bmr.round();
    switch (goal) {
      case GoalType.gain:
        calories += 300;
        break;
      case GoalType.lose:
        calories -= 300;
        break;
      default:
        break;
    }
    return HealthProfile(
      weight: weight,
      height: height,
      targetWeight: targetWeight,
      goal: goal,
      recommendedCalories: calories,
    );
  }
}