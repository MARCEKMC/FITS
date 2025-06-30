import 'package:flutter/material.dart';

class EfficiencyScreen extends StatelessWidget {
  const EfficiencyScreen({super.key});

  Widget _buildEfficiencyButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 24,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Título con icono
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      size: 32,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Text(
                      'Eficiencia',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Organiza tu tiempo y mejora tu productividad',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
              
              const Spacer(),
              
              // Botones de navegación
              _buildEfficiencyButton(
                title: 'Horario',
                icon: Icons.schedule,
                onPressed: () {
                  Navigator.pushNamed(context, '/schedule');
                },
              ),
              
              const SizedBox(height: 20),
              
              _buildEfficiencyButton(
                title: 'Apuntes',
                icon: Icons.note_alt,
                onPressed: () {
                  Navigator.pushNamed(context, '/notes');
                },
              ),
              
              const SizedBox(height: 20),
              
              _buildEfficiencyButton(
                title: 'Reportes',
                icon: Icons.analytics,
                onPressed: () {
                  Navigator.pushNamed(context, '/reports');
                },
              ),
              
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}