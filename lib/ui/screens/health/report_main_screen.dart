import 'package:flutter/material.dart';

class ReportMainScreen extends StatelessWidget {
  const ReportMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: const Center(
        child: Text(
          'Aquí irá el reporte de salud.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}