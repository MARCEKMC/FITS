import 'package:flutter/material.dart';

class HealthCalendarHeader extends StatelessWidget {
  final VoidCallback onCalendarTap;
  final int caloriasHoy;
  final int diasActivos;
  final bool calendarioAbierto;

  const HealthCalendarHeader({
    super.key,
    required this.onCalendarTap,
    required this.caloriasHoy,
    required this.diasActivos,
    required this.calendarioAbierto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onCalendarTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today_rounded, size: 22),
              const SizedBox(width: 6),
              const Text("Hoy", style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                "$caloriasHoy kcal | $diasActivos días activos",
                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
              ),
            ],
          ),
        ),
        const Divider(height: 16),
      ],
    );
  }
}