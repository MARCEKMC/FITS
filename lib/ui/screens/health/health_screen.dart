import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/health_viewmodel.dart';
import '../../../viewmodel/user_viewmodel.dart';
import 'health_survey_screen.dart';
import 'food_main_screen.dart';
import 'exercise_main_screen.dart';
import 'report_main_screen.dart';

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                // Título SALUD en la parte superior (más abajo y con nuevo formato)
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "SALUD",
                      style: TextStyle(
                        fontSize: 38,
                        fontFamily: 'SF Pro Display', // Cambio de fuente más moderna
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black87,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red[500],
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                // Más espacio arriba para bajar los botones
                const Spacer(flex: 3),
                // Botones principales más altos y con bordes
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: OutlinedButton(
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
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 140), // Más alto
                      textStyle: const TextStyle(
                        fontSize: 22, // Texto más grande
                        fontFamily: 'SF Pro Display', // Cambio de fuente
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                      side: BorderSide(color: Colors.black87, width: 1.5), // Borde negro
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.restaurant_menu, size: 26, color: Colors.green[700]),
                        ),
                        const SizedBox(width: 20),
                        const Text("Alimentación", style: TextStyle(letterSpacing: 0.8)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: OutlinedButton(
                    onPressed: () {
                      final userVM = Provider.of<UserViewModel>(context, listen: false);
                      final gender = userVM.profile?.gender ?? "Masculino";
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExerciseMainScreen(gender: gender),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 140), // Más alto
                      textStyle: const TextStyle(
                        fontSize: 22, // Texto más grande
                        fontFamily: 'SF Pro Display', // Cambio de fuente
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                      side: BorderSide(color: Colors.black87, width: 1.5), // Borde negro
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.fitness_center, size: 26, color: Colors.blue[700]),
                        ),
                        const SizedBox(width: 20),
                        const Text("Ejercicios", style: TextStyle(letterSpacing: 0.8)),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 2), // Menos espacio abajo para bajar los botones principales
                // Fila inferior con botón de reporte y imagen expandidos para llenar el espacio
                Row(
                  children: [
                    // Botón REPORTE más pequeño en ancho
                    Expanded(
                      flex: 2, // Menos espacio para el reporte
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReportMainScreen(),
                            ),
                          );
                        },
                        child: Container(
                          height: 180, // Más pequeño (era 200)
                          margin: const EdgeInsets.only(right: 8), // Pequeño margen entre elementos
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black87, width: 1.5), // Marco agregado
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 90, // Más ancho
                                height: 120, // Más alto
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!, width: 1),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.analytics_outlined,
                                      size: 42, // Ícono más grande
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: 36,
                                      height: 2,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 32,
                                      height: 2,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 34,
                                      height: 2,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 30,
                                      height: 2,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "📊 REPORTE",
                                style: TextStyle(
                                  fontSize: 16, // Texto más grande
                                  fontFamily: 'SF Pro Display',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                  letterSpacing: 0.8,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Imagen del personaje más grande
                    Expanded(
                      flex: 3, // Más espacio para la imagen (20% más grande proporcionalmente)
                      child: Container(
                        height: 240, // 20% más grande que 200px
                        margin: const EdgeInsets.only(left: 0), // Sin margen para que toque el reporte
                        child: Image.asset(
                          'lib/core/utils/images/imagensalud.png',
                          fit: BoxFit.contain, // Mantiene el tamaño original sin distorsión
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      size: 64, // Ícono más grande
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Imagen\nno encontrada",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                        fontFamily: 'SF Pro Display',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50), // Más separación del borde inferior
              ],
            ),
          ),
        ),
      );
    }

    // Pantalla de alimentación
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