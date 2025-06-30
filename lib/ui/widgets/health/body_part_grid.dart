import 'package:flutter/material.dart';

class BodyPartGrid extends StatelessWidget {
  final String gender;
  final void Function(String partName, int muscleId) onTap;

  const BodyPartGrid({
    super.key,
    required this.gender,
    required this.onTap,
  });

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    bool isFullWidth = false,
  }) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: isFullWidth ? 80 : 120, // Todo el cuerpo: 80px, otros: 120px (cuadrados)
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
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> parts = gender == 'Femenino'
        ? [
            {'name': 'Glúteos', 'id': 8},
            {'name': 'Piernas', 'id': 10},
            {'name': 'Abdomen', 'id': 6},
            {'name': 'Brazos', 'id': 1},
            {'name': 'Todo el cuerpo', 'id': -1},
          ]
        : [
            {'name': 'Pecho', 'id': 4},
            {'name': 'Espalda', 'id': 12},
            {'name': 'Brazos', 'id': 1},
            {'name': 'Abdomen', 'id': 6},
            {'name': 'Piernas', 'id': 10},
            {'name': 'Todo el cuerpo', 'id': -1},
          ];

    // Encontrar cada parte por nombre para el layout específico
    final todoCuerpo = parts.firstWhere((p) => p['name'] == 'Todo el cuerpo');
    final pecho = parts.firstWhere((p) => p['name'] == 'Pecho', orElse: () => {'name': 'Glúteos', 'id': 8});
    final espalda = parts.firstWhere((p) => p['name'] == 'Espalda', orElse: () => {'name': 'Piernas', 'id': 10});
    final brazos = parts.firstWhere((p) => p['name'] == 'Brazos');
    final abdomen = parts.firstWhere((p) => p['name'] == 'Abdomen');
    final piernas = parts.firstWhere((p) => p['name'] == 'Piernas');

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título elegante
              const Text(
                'Selecciona el grupo muscular',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Elige la zona que quieres trabajar hoy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 50), // Aumenté de 40 a 50
              
              // 1. Todo el cuerpo (arriba, ancho completo)
              _buildButton(
                text: todoCuerpo['name'],
                onPressed: () => onTap(todoCuerpo['name'], todoCuerpo['id']),
                isFullWidth: true,
              ),
              
              const SizedBox(height: 30), // Aumenté de 20 a 30
              
              // 2. Pecho y Espalda (fila de 2)
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      text: pecho['name'],
                      onPressed: () => onTap(pecho['name'], pecho['id']),
                    ),
                  ),
                  const SizedBox(width: 20), // Aumenté de 16 a 20
                  Expanded(
                    child: _buildButton(
                      text: espalda['name'],
                      onPressed: () => onTap(espalda['name'], espalda['id']),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30), // Aumenté de 20 a 30
              
              // 3. Brazos y Abdomen (fila de 2)
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      text: brazos['name'],
                      onPressed: () => onTap(brazos['name'], brazos['id']),
                    ),
                  ),
                  const SizedBox(width: 20), // Aumenté de 16 a 20
                  Expanded(
                    child: _buildButton(
                      text: abdomen['name'],
                      onPressed: () => onTap(abdomen['name'], abdomen['id']),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // 4. Imagen y Piernas (fila final)
              Row(
                children: [
                  // Imagen a la izquierda (libre, sin contenedor)
                  Expanded(
                    child: SizedBox(
                      height: 120, // Misma altura que los botones cuadrados
                      child: Image.asset(
                        'lib/core/utils/images/imagenejercicios.png',
                        fit: BoxFit.contain, // Imagen completa sin cortarse
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.fitness_center,
                            size: 60,
                            color: Colors.grey[400],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Botón Piernas a la derecha
                  Expanded(
                    child: _buildButton(
                      text: piernas['name'],
                      onPressed: () => onTap(piernas['name'], piernas['id']),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 60), // Aumenté de 40 a 60 para más espacio final
            ],
          ),
        ),
      ),
    );
  }
}