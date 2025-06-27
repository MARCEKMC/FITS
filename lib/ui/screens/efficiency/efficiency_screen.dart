import 'package:flutter/material.dart';
import '../../widgets/efficiency/focus_button.dart';
import 'schedule_screen.dart'; // Import para navegar
// Podrías crear notes_screen.dart en el futuro

class EfficiencyScreen extends StatelessWidget {
  const EfficiencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FocusButton(),
              const SizedBox(height: 34),
              _EfficiencyRectangle(
                title: 'Ver Horario',
                icon: Icons.calendar_today_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ScheduleScreen()),
                  );
                },
              ),
              const SizedBox(height: 22),
              _EfficiencyRectangle(
                title: 'Ver Apuntes',
                icon: Icons.sticky_note_2_rounded,
                onTap: () {
                  // Navegarás a notes_screen.dart cuando lo crees
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EfficiencyRectangle extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _EfficiencyRectangle({
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.black),
              const SizedBox(width: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}