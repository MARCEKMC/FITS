import 'package:flutter/material.dart';

class CaloriesProgressBar extends StatelessWidget {
  final int total;
  final int consumed;

  const CaloriesProgressBar({
    super.key,
    required this.total,
    required this.consumed,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : (consumed / total).clamp(0.0, 1.0);
    final overConsumed = consumed > total;

    // Colores de barra: verde -> naranja -> rojo si excedes
    final Gradient progressGradient = LinearGradient(
      colors: overConsumed
          ? [Colors.redAccent, Colors.red]
          : percent < 0.85
              ? [Colors.green, Colors.lightGreen]
              : [Colors.orange, Colors.deepOrange],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Fondo redondeado
            Container(
              height: 28,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            // Barra de progreso
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth * (overConsumed ? 1.0 : percent);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: width,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: progressGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                );
              },
            ),
            // Texto encima
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(Icons.local_fire_department, color: Colors.orange, size: 22),
                      ),
                      Text(
                        "$consumed kcal",
                        style: TextStyle(
                          color: overConsumed ? Colors.red[900] : Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          shadows: [
                            Shadow(
                              blurRadius: 2,
                              color: Colors.white.withOpacity(0.5),
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "$total kcal",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        shadows: [
                          Shadow(
                            blurRadius: 1,
                            color: Colors.white.withOpacity(0.5),
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (overConsumed)
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 18),
              const SizedBox(width: 4),
              Text(
                "¡Has superado tu meta diaria!",
                style: TextStyle(
                  color: Colors.red[800],
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
      ],
    );
  }
}