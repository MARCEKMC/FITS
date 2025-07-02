import 'package:flutter/material.dart';
import '../../../services/fitsi_service.dart';

class FitsiHealthReport extends StatefulWidget {
  const FitsiHealthReport({Key? key}) : super(key: key);

  @override
  State<FitsiHealthReport> createState() => _FitsiHealthReportState();
}

class _FitsiHealthReportState extends State<FitsiHealthReport> {
  final FitsiService _fitsiService = FitsiService();
  String? _report;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  Future<void> _generateReport() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final report = await _fitsiService.generateHealthReport();
      
      setState(() {
        _report = report;
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
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Color(0xFF6C5CE7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reporte de Fitsi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    Text(
                      'Análisis automático de tu salud',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF6C5CE7)),
                onPressed: _generateReport,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          
          // Content
          if (_isLoading)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: Color(0xFF6C5CE7)),
                  SizedBox(height: 12),
                  Text(
                    'Fitsi está analizando tus datos...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else if (_hasError)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.withOpacity(0.6),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Error generando reporte',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _generateReport,
                    child: const Text('Intentar nuevamente'),
                  ),
                ],
              ),
            )
          else if (_report != null)
            // Texto scrolleable para reportes largos
            Container(
              constraints: const BoxConstraints(
                maxHeight: 300, // Altura máxima para evitar overflow
              ),
              child: SingleChildScrollView(
                child: Text(
                  _report!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ),
            ),
          
          if (!_isLoading && !_hasError) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF6C5CE7),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Generado por Fitsi IA',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF6C5CE7).withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  'Actualizado: ${_formatTime(DateTime.now())}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
