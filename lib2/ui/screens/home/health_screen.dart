import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// IMPORTA TU VIEWMODEL DE SALUD
import '../../../viewmodel/health_viewmodel.dart';
// IMPORTA LAS PANTALLAS DEL FLUJO DE SALUD
import '../../screens/health/health_onboarding_screen.dart';
import '../../screens/health/health_main_screen.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HealthViewModel(),
      child: Consumer<HealthViewModel>(
        builder: (context, healthVM, _) {
          // Si el perfil aún no está completado, muestra la encuesta
          if (healthVM.profile == null) {
            return const HealthOnboardingScreen();
          } else {
            // Si ya hay perfil, muestra el dashboard principal
            return const HealthMainScreen();
          }
        },
      ),
    );
  }
}