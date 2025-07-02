import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/health_viewmodel.dart';
import '../../profile/viewmodels/user_viewmodel.dart';
import 'health_survey_screen.dart';
import 'food_main_screen.dart';
import 'exercise_main_screen.dart';
import 'report_main_screen.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  Widget _buildHealthButton({
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
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 28,
                  color: Colors.black87,
                ),
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
    final healthVM = Provider.of<HealthViewModel>(context);
    final userVM = Provider.of<UserViewModel>(context, listen: false);

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
                      Icons.favorite,
                      size: 32,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Text(
                      'Salud',
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
                'Cuida tu cuerpo y tu estilo de vida',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Imagen de salud
              SizedBox(
                width: double.infinity,
                height: 205,
                child: Image.asset(
                  'lib/core/utils/images/imagensalud.png',
                  fit: BoxFit.contain,
                ),
              ),
              
              const Spacer(),
              
              // Botones de navegación
              _buildHealthButton(
                title: 'Alimentación',
                icon: Icons.restaurant_menu,
                onPressed: () async {
                  final hasProfile = await healthVM.hasHealthProfile();
                  if (!hasProfile) {
                    final completed = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HealthSurveyScreen(),
                      ),
                    );
                    if (completed == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FoodMainScreen(),
                        ),
                      );
                    }
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FoodMainScreen(),
                      ),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 20),
              
              _buildHealthButton(
                title: 'Ejercicios',
                icon: Icons.fitness_center,
                onPressed: () {
                  final gender = userVM.profile?.gender ?? "Masculino";
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExerciseMainScreen(gender: gender),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              _buildHealthButton(
                title: 'Reporte',
                icon: Icons.analytics,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReportMainScreen(),
                    ),
                  );
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
