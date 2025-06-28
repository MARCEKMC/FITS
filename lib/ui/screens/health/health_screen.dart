import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/health_viewmodel.dart';
import 'health_survey_screen.dart';
import 'food_main_screen.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  int _selectedSection = 0;

  @override
  Widget build(BuildContext context) {
    final healthVM = Provider.of<HealthViewModel>(context);

    // Pantalla inicial con los dos botones
    if (_selectedSection == 0) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Verifica si ya hay perfil de salud
                    final hasProfile = await healthVM.hasHealthProfile();
                    if (!hasProfile) {
                      // Si no hay perfil, muestra la encuesta y espera el resultado
                      final completed = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HealthSurveyScreen(),
                        ),
                      );
                      if (completed == true) {
                        setState(() => _selectedSection = 1);
                      }
                    } else {
                      setState(() => _selectedSection = 1);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(220, 60),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: const Text("Alimentación"),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente: Ejercicios')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(220, 60),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: const Text("Ejercicios"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Sección de alimentación (ya respondió encuesta)
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          _selectedSection = 0;
        });
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Alimentación"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _selectedSection = 0;
              });
            },
          ),
        ),
        body: const FoodMainScreen(),
      ),
    );
  }
}