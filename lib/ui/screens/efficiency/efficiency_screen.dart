import 'package:flutter/material.dart';

class EfficiencyScreen extends StatelessWidget {
  const EfficiencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pantalla de Eficiencia',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes agregar la lógica para navegar a otra pantalla
                Navigator.pushNamed(context, '/some_other_screen');
              },
              child: const Text('Ir a otra pantalla'),
            ),
          ],

        ),
      ),
    );
  }
}