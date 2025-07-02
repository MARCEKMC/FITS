import 'package:flutter/material.dart';
import '../../../services/fitsi_service.dart';

class FitsiProductivityReport extends StatefulWidget {
  const FitsiProductivityReport({Key? key}) : super(key: key);

  @override
  State<FitsiProductivityReport> createState() => _FitsiProductivityReportState();
}

class _FitsiProductivityReportState extends State<FitsiProductivityReport> {
  final FitsiService _fitsiService = FitsiService();
  String? _report;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isExpanded = false;

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

      final report = await _fitsiService.generateProductivityReport();
      
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
        children: [
          // Header siempre visible
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
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
                          'Análisis de Fitsi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        Text(
                          'Productividad y organización',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: const Color(0xFF6C5CE7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content expandible
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildContent(),
                ),
              ],
            ),
            crossFadeState: _isExpanded 
              ? CrossFadeState.showSecond 
              : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Column(
        children: [
          CircularProgressIndicator(color: Color(0xFF6C5CE7)),
          SizedBox(height: 12),
          Text(
            'Fitsi está analizando tu productividad...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      );
    }
    
    if (_hasError) {
      return Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.withOpacity(0.6),
            size: 32,
          ),
          const SizedBox(height: 8),
          const Text(
            'Error generando análisis',
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
      );
    }
    
    if (_report != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _report!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF2D3436),
            ),
          ),
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
              IconButton(
                icon: const Icon(Icons.refresh, size: 16),
                color: const Color(0xFF6C5CE7),
                onPressed: _generateReport,
                tooltip: 'Actualizar análisis',
              ),
            ],
          ),
        ],
      );
    }
    
    return const SizedBox.shrink();
  }
}
