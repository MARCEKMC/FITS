import 'dart:async';
import 'package:flutter/material.dart';

class ExercisePlayerScreen extends StatefulWidget {
  final List<String> exerciseFolders; // Ej: ['Push-Ups_With_Feet_Elevated', ...]
  final String groupName;

  const ExercisePlayerScreen({
    Key? key,
    required this.exerciseFolders,
    required this.groupName,
  }) : super(key: key);

  @override
  State<ExercisePlayerScreen> createState() => _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends State<ExercisePlayerScreen> {
  int current = 0;
  int imageIndex = 0;
  Timer? timer;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    timer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (!isPaused) {
        setState(() => imageIndex = (imageIndex + 1) % 2);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  void nextExercise() {
    if (current < widget.exerciseFolders.length - 1) {
      setState(() {
        current++;
        imageIndex = 0;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de completado
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Título
              const Text(
                '¡Rutina Completada!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Mensaje
              Text(
                'Excelente trabajo. Has terminado todos los ejercicios de ${widget.groupName}.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Botón
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar diálogo
                    Navigator.pop(context); // Volver a la pantalla de partes del cuerpo
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Finalizar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getImagePath(String folder, int index) {
    // Intentar primero con .jpg, luego .png
    return 'assets/exercises/$folder/$index.jpg';
  }

  Widget _buildExerciseImage(String folder, int imageIndex) {
    final jpgPath = 'assets/exercises/$folder/$imageIndex.jpg';
    final pngPath = 'assets/exercises/$folder/$imageIndex.png';
    
    return Container(
      width: double.infinity,
      height: 280, // Altura fija basada en la proporción 850x567
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          jpgPath,
          width: double.infinity,
          height: 280,
          fit: BoxFit.cover, // Mantiene la proporción y llena el contenedor
          errorBuilder: (context, error, stackTrace) {
            print('Error loading JPG: $jpgPath');
            return Image.asset(
              pngPath,
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
              errorBuilder: (context, pngError, pngStackTrace) {
                print('Error loading PNG: $pngPath');
                return Container(
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'Imagen no disponible',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final folder = widget.exerciseFolders[current];
    final title = folder.replaceAll("_", " ");

    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco completo
      appBar: AppBar(
        title: Text(
          widget.groupName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPaused ? Colors.orange[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPaused ? Icons.play_arrow : Icons.pause,
                  color: isPaused ? Colors.orange : Colors.green,
                  size: 20,
                ),
              ),
              onPressed: _togglePause,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32), // Aumenté el padding vertical
          child: Column(
            children: [
              const SizedBox(height: 20), // Espacio adicional arriba
              
              // Título del ejercicio (minimalista)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24), // Aumenté el padding
                child: Column(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${current + 1} de ${widget.exerciseFolders.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Barra de progreso minimalista
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20), // Aumenté el margen
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progreso',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPaused ? Colors.orange[50] : Colors.green[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isPaused ? 'PAUSADO' : 'ACTIVO',
                            style: TextStyle(
                              fontSize: 10,
                              color: isPaused ? Colors.orange[700] : Colors.green[700],
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.grey[200],
                      ),
                      child: LinearProgressIndicator(
                        value: (current + 1) / widget.exerciseFolders.length,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32), // Aumenté el espaciado

              // Imagen del ejercicio (proporción optimizada)
              Container(
                width: double.infinity,
                child: _buildExerciseImage(folder, imageIndex),
              ),
              
              const SizedBox(height: 40), // Reducí el espacio entre imagen y botones
              
              // Botones de control (minimalistas)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16), // Reducí el padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botón Anterior
                    SizedBox(
                      width: 90,
                      height: 50,
                      child: current > 0
                          ? ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  current--;
                                  imageIndex = 0;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[100],
                                foregroundColor: Colors.grey[700],
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Icon(Icons.chevron_left, size: 24),
                            )
                          : Container(),
                    ),
                    
                    // Botón Omitir
                    SizedBox(
                      width: 100,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text(
                                '¿Omitir ejercicio?',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              content: const Text('¿Quieres pasar al siguiente ejercicio?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cancelar',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    nextExercise();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Omitir'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[50],
                          foregroundColor: Colors.orange[700],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Omitir',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    
                    // Botón Siguiente
                    SizedBox(
                      width: 90,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: nextExercise,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: current < widget.exerciseFolders.length - 1 
                              ? Colors.blue 
                              : Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Icon(
                          current < widget.exerciseFolders.length - 1 
                              ? Icons.chevron_right 
                              : Icons.check,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20), // Espaciado final más pequeño
            ],
          ),
        ),
      ),
    );
  }
}