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
                // Puedes mejorar los botones aquí también para un look más minimalista si quieres
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Próximamente: Ejercicios',
                          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: Colors.white,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.black12),
                        ),
                        elevation: 4,
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