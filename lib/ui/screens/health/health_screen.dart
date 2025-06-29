import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/health_viewmodel.dart';
import '../../../viewmodel/user_viewmodel.dart';
import 'health_survey_screen.dart';
import 'food_main_screen.dart';
// Importa tu pantalla de ejercicios cuando la crees:
import 'exercise_main_screen.dart';

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
                    final hasProfile = await healthVM.hasHealthProfile();
                    if (!hasProfile) {
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
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.black12, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text("Alimentación"),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Obtén el género desde el perfil del usuario para pasarlo a la pantalla de ejercicios
                    final userVM = Provider.of<UserViewModel>(context, listen: false);
                    final gender = userVM.profile?.gender ?? "Masculino";
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExerciseMainScreen(gender: gender),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(220, 60),
                    textStyle: const TextStyle(fontSize: 20),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.black12, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text("Ejercicios"),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: const Text(
            "Alimentación",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 0.2,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
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