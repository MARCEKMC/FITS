import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class MacrosCircularBar extends StatelessWidget {
  final double carbs;
  final double protein;
  final double fat;
  final double carbsGoal;
  final double proteinGoal;
  final double fatGoal;

  const MacrosCircularBar({
    Key? key,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.carbsGoal,
    required this.proteinGoal,
    required this.fatGoal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double carbsPercent = (carbsGoal > 0) ? (carbs / carbsGoal).clamp(0.0, 1.0) : 0.0;
    double proteinPercent = (proteinGoal > 0) ? (protein / proteinGoal).clamp(0.0, 1.0) : 0.0;
    double fatPercent = (fatGoal > 0) ? (fat / fatGoal).clamp(0.0, 1.0) : 0.0;

    return Center(
      child: SizedBox(
        height: 140,
        width: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularPercentIndicator(
              radius: 70,
              lineWidth: 12,
              percent: carbsPercent,
              animation: true,
              backgroundColor: Colors.grey.shade200,
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.blueAccent,
              center: Container(),
            ),
            CircularPercentIndicator(
              radius: 56,
              lineWidth: 12,
              percent: proteinPercent,
              animation: true,
              backgroundColor: Colors.transparent,
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.green,
              center: Container(),
            ),
            CircularPercentIndicator(
              radius: 42,
              lineWidth: 12,
              percent: fatPercent,
              animation: true,
              backgroundColor: Colors.transparent,
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.orange,
              center: Container(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Macros", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dot(color: Colors.blueAccent),
                    const Text("C "),
                    _dot(color: Colors.green),
                    const Text("P "),
                    _dot(color: Colors.orange),
                    const Text("G"),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "${carbs.toStringAsFixed(0)}/${carbsGoal.toStringAsFixed(0)}g",
                  style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                ),
                Text(
                  "${protein.toStringAsFixed(0)}/${proteinGoal.toStringAsFixed(0)}g",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
                Text(
                  "${fat.toStringAsFixed(0)}/${fatGoal.toStringAsFixed(0)}g",
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _dot({required Color color}) => Container(
    width: 8,
    height: 8,
    margin: const EdgeInsets.symmetric(horizontal: 2),
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}