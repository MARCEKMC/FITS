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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0), // Mismo margen que water_tracker
      padding: const EdgeInsets.all(18), // Mismo padding que water_tracker
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18), // Mismo radio que water_tracker
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[100]!, // Misma sombra que water_tracker
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Círculos a la izquierda
          SizedBox(
            height: 140,
            width: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularPercentIndicator(
                  radius: 70,
                  lineWidth: 8,
                  percent: carbsPercent,
                  animation: true,
                  animationDuration: 1000,
                  backgroundColor: Colors.blue.shade50,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: const Color(0xFF4FC3F7),
                  center: Container(),
                ),
                CircularPercentIndicator(
                  radius: 56,
                  lineWidth: 8,
                  percent: proteinPercent,
                  animation: true,
                  animationDuration: 1200,
                  backgroundColor: Colors.green.shade50,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: const Color(0xFF66BB6A),
                  center: Container(),
                ),
                CircularPercentIndicator(
                  radius: 42,
                  lineWidth: 8,
                  percent: fatPercent,
                  animation: true,
                  animationDuration: 1400,
                  backgroundColor: Colors.orange.shade50,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: const Color(0xFFFF9800),
                  center: Container(),
                ),
                Text(
                  "Macros",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Información a la derecha
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMacroRow(
                  color: const Color(0xFF4FC3F7),
                  label: "Carbohidratos",
                  consumed: carbs,
                  goal: carbsGoal,
                  percent: carbsPercent,
                ),
                const SizedBox(height: 16),
                _buildMacroRow(
                  color: const Color(0xFF66BB6A),
                  label: "Proteínas",
                  consumed: protein,
                  goal: proteinGoal,
                  percent: proteinPercent,
                ),
                const SizedBox(height: 16),
                _buildMacroRow(
                  color: const Color(0xFFFF9800),
                  label: "Grasas",
                  consumed: fat,
                  goal: fatGoal,
                  percent: fatPercent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow({
    required Color color,
    required String label,
    required double consumed,
    required double goal,
    required double percent,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  Text(
                    "${consumed.toStringAsFixed(0)}/${goal.toStringAsFixed(0)}g",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _dot({required Color color}) => Container(
    width: 8,
    height: 8,
    margin: const EdgeInsets.symmetric(horizontal: 2),
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
