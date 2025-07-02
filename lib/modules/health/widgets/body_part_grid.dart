import 'package:flutter/material.dart';

class BodyPartGrid extends StatelessWidget {
  final String gender;
  final void Function(String partName, int muscleId) onTap;

  const BodyPartGrid({
    super.key,
    required this.gender,
    required this.onTap,
  });

  Widget _buildMuscleGroupCard({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    bool isFullWidth = false,
    Color iconColor = Colors.black87,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      height: isFullWidth ? 85 : 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: isFullWidth 
                ? Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          size: 24,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Colors.grey[400],
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          icon,
                          size: 26,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForMuscleGroup(String groupName) {
    switch (groupName.toLowerCase()) {
      case 'pecho':
        return Icons.fitness_center;
      case 'espalda':
        return Icons.sports_gymnastics;
      case 'brazos':
        return Icons.sports_martial_arts;
      case 'abdomen':
        return Icons.sentiment_very_satisfied;
      case 'piernas':
        return Icons.directions_run;
      case 'glúteos':
        return Icons.sports_tennis;
      case 'todo el cuerpo':
        return Icons.accessibility_new;
      default:
        return Icons.fitness_center;
    }
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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Texto descriptivo principal
            const Text(
              'Selecciona qué trabajar hoy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: -0.3,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Botón "Todo el cuerpo" destacado arriba
            _buildMuscleGroupCard(
              title: 'Todo el cuerpo',
              icon: Icons.accessibility_new,
              onPressed: () {
                final todoCuerpo = parts.firstWhere((p) => p['name'] == 'Todo el cuerpo');
                onTap(todoCuerpo['name'], todoCuerpo['id']);
              },
              isFullWidth: true,
              iconColor: Colors.purple[700]!,
            ),
            
            const SizedBox(height: 24),
            
            // Texto descriptivo
            Text(
              'O selecciona un grupo específico:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                letterSpacing: 0.2,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Grid de grupos musculares específicos
            if (gender == 'Masculino') ...[
              // Primera fila: Pecho y Espalda
              Row(
                children: [
                  Expanded(
                    child: _buildMuscleGroupCard(
                      title: 'Pecho',
                      icon: Icons.fitness_center,
                      onPressed: () {
                        final pecho = parts.firstWhere((p) => p['name'] == 'Pecho');
                        onTap(pecho['name'], pecho['id']);
                      },
                      iconColor: Colors.red[600]!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMuscleGroupCard(
                      title: 'Espalda',
                      icon: Icons.sports_gymnastics,
                      onPressed: () {
                        final espalda = parts.firstWhere((p) => p['name'] == 'Espalda');
                        onTap(espalda['name'], espalda['id']);
                      },
                      iconColor: Colors.blue[600]!,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Segunda fila: Brazos y Abdomen
              Row(
                children: [
                  Expanded(
                    child: _buildMuscleGroupCard(
                      title: 'Brazos',
                      icon: Icons.sports_martial_arts,
                      onPressed: () {
                        final brazos = parts.firstWhere((p) => p['name'] == 'Brazos');
                        onTap(brazos['name'], brazos['id']);
                      },
                      iconColor: Colors.orange[600]!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMuscleGroupCard(
                      title: 'Abdomen',
                      icon: Icons.sentiment_very_satisfied,
                      onPressed: () {
                        final abdomen = parts.firstWhere((p) => p['name'] == 'Abdomen');
                        onTap(abdomen['name'], abdomen['id']);
                      },
                      iconColor: Colors.green[600]!,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Tercera fila: Piernas e Imagen
              Row(
                children: [
                  Expanded(
                    child: _buildMuscleGroupCard(
                      title: 'Piernas',
                      icon: Icons.directions_run,
                      onPressed: () {
                        final piernas = parts.firstWhere((p) => p['name'] == 'Piernas');
                        onTap(piernas['name'], piernas['id']);
                      },
                      iconColor: Colors.indigo[600]!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 130,
                      child: Image.asset(
                        'lib/core/utils/images/imagenejercicios.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.fitness_center,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Layout para género femenino
              // Primera fila: Glúteos y Piernas
              Row(
                children: [
                  Expanded(
                    child: _buildMuscleGroupCard(
                      title: 'Glúteos',
                      icon: Icons.sports_tennis,
                      onPressed: () {
                        final gluteos = parts.firstWhere((p) => p['name'] == 'Glúteos');
                        onTap(gluteos['name'], gluteos['id']);
                      },
                      iconColor: Colors.pink[600]!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMuscleGroupCard(
                      title: 'Piernas',
                      icon: Icons.directions_run,
                      onPressed: () {
                        final piernas = parts.firstWhere((p) => p['name'] == 'Piernas');
                        onTap(piernas['name'], piernas['id']);
                      },
                      iconColor: Colors.indigo[600]!,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Segunda fila: Abdomen y Brazos
              Row(
                children: [
                  Expanded(
                    child: _buildMuscleGroupCard(
                      title: 'Abdomen',
                      icon: Icons.sentiment_very_satisfied,
                      onPressed: () {
                        final abdomen = parts.firstWhere((p) => p['name'] == 'Abdomen');
                        onTap(abdomen['name'], abdomen['id']);
                      },
                      iconColor: Colors.green[600]!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMuscleGroupCard(
                      title: 'Brazos',
                      icon: Icons.sports_martial_arts,
                      onPressed: () {
                        final brazos = parts.firstWhere((p) => p['name'] == 'Brazos');
                        onTap(brazos['name'], brazos['id']);
                      },
                      iconColor: Colors.orange[600]!,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Imagen centrada para género femenino
              SizedBox(
                width: double.infinity,
                height: 130,
                child: Image.asset(
                  'lib/core/utils/images/imagenejercicios.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.fitness_center,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              ),
            ],
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
