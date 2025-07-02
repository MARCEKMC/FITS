import 'package:flutter/material.dart';
import '../../../services/fitsi_service.dart';

class ScheduleAnalysisWidget extends StatefulWidget {
  const ScheduleAnalysisWidget({Key? key}) : super(key: key);

  @override
  State<ScheduleAnalysisWidget> createState() => _ScheduleAnalysisWidgetState();
}

class _ScheduleAnalysisWidgetState extends State<ScheduleAnalysisWidget> {
  final FitsiService _fitsiService = FitsiService();
  String? _analysis;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _generateAnalysis();
  }

  Future<void> _generateAnalysis() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final analysis = await _fitsiService.generateScheduleAnalysis();
      
      setState(() {
        _analysis = analysis;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - kToolbarHeight - kBottomNavigationBarHeight - 120; // Reservar espacio para barras y márgenes
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(32), // Padding más generoso
      constraints: BoxConstraints(
        minHeight: 450, // Altura mínima más grande
        maxHeight: (availableHeight * 0.85).clamp(450.0, 900.0), // 85% de la altura disponible, máximo 900px
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Bordes aún más redondeados para un look más moderno
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 16, // Sombra más suave y extendida
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14), // Padding más generoso
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(14), // Bordes más redondeados
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  size: 26, // Icono más grande
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 18), // Más espacio entre elementos
              const Expanded(
                child: Text(
                  'Análisis de tu Horario',
                  style: TextStyle(
                    fontSize: 22, // Texto más grande
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (!_isLoading)
                IconButton(
                  icon: const Icon(Icons.refresh, size: 24), // Icono más grande
                  onPressed: _generateAnalysis,
                  color: Colors.grey[600],
                ),
            ],
          ),
          
          const SizedBox(height: 28), // Más espacio entre header y contenido
          
          // Content - Expandible para usar el espacio disponible
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black87,
                      ),
                    ),
                  )
                : _hasError
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No pude generar el análisis',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _generateAnalysis,
                            child: const Text(
                              'Reintentar',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      )
                    : // Texto scrolleable para manejar reportes largos
                    SingleChildScrollView(
                        padding: const EdgeInsets.only(right: 8), // Padding para el scroll
                        child: Text(
                          _analysis ?? '',
                          style: TextStyle(
                            fontSize: 16, // Texto más grande para mejor legibilidad
                            color: Colors.grey[700],
                            height: 1.7, // Espaciado entre líneas más amplio
                            letterSpacing: 0.3, // Espaciado entre letras para mejor legibilidad
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
