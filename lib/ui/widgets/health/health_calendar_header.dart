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
              const Icon(Icons.calendar_today_rounded, size: 22, color: Colors.black87),
              const SizedBox(width: 8),
              const Text(
                "Hoy",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.black87,
                  letterSpacing: 0.1,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 13),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$diasActivos días activos",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 16, thickness: 1, color: Color(0xFFEFEFEF)),
      ],
    );
  }
}