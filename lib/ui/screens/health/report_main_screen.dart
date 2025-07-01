import 'package:flutter/material.dart';
import '../../widgets/fitsi/fitsi_health_report.dart';

class ReportMainScreen extends StatelessWidget {
  const ReportMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Reporte de Salud'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            // Reporte automático de Fitsi
            FitsiHealthReport(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}