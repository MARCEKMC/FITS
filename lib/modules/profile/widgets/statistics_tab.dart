import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodels/user_viewmodel.dart';
import '../viewmodels/statistics_viewmodel.dart';

class StatisticsTab extends StatefulWidget {
  final UserViewModel userViewModel;

  const StatisticsTab({super.key, required this.userViewModel});

  @override
  State<StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab> {
  String _selectedMetric = 'calories';
  String _selectedPeriod = 'week';
  List<double> _chartData = [];
  Map<String, String> _summaryStats = {};
  bool _isLoading = false;

  final Map<String, String> _metrics = {
    'calories': 'Calorías',
    'exercises': 'Ejercicios',
  };

  final Map<String, String> _periods = {
    'week': 'Última semana',
    'month': 'Último mes',
    'year': 'Último año',
  };

  @override
  void initState() {
    super.initState();
    // Usar post frame callback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (!mounted) return; // Verificar si el widget sigue montado

    setState(() => _isLoading = true);

    try {
      final statisticsVM = Provider.of<StatisticsViewModel>(context, listen: false);
      
      List<double> data = [];
      
      switch (_selectedMetric) {
        case 'calories':
          data = await statisticsVM.getCaloriesData(user.uid, _selectedPeriod);
          break;
        case 'exercises':
          data = await statisticsVM.getExercisesData(user.uid, _selectedPeriod);
          break;
      }
      
      if (!mounted) return; // Verificar nuevamente antes de setState
      
      _chartData = data.isNotEmpty ? data : [0.0]; // Asegurar que siempre hay al menos un valor
      _calculateSummaryStats();
    } catch (e) {
      print('Error loading statistics: $e');
      if (!mounted) return;
      
      _chartData = [0.0]; // Datos por defecto en caso de error
      _summaryStats = {'total': '0', 'average': '0.0', 'best': '0'};
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _calculateSummaryStats() {
    if (_chartData.isEmpty || (_chartData.length == 1 && _chartData[0] == 0.0)) {
      _summaryStats = {'total': '0', 'average': '0.0', 'best': '0'};
      return;
    }

    final total = _chartData.reduce((a, b) => a + b);
    final average = total / _chartData.length;
    final best = _chartData.reduce((a, b) => a > b ? a : b);

    _summaryStats = {
      'total': total.toStringAsFixed(_selectedMetric == 'calories' ? 0 : 0),
      'average': average.toStringAsFixed(1),
      'best': best.toStringAsFixed(0),
    };
  }

  void _onMetricChanged(String metric) {
    setState(() {
      _selectedMetric = metric;
    });
    _loadData();
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector de métricas
          _buildMetricSelector(),
          
          const SizedBox(height: 24),

          // Selector de período
          _buildPeriodSelector(),

          const SizedBox(height: 32),

          // Gráfico principal
          _isLoading ? _buildLoadingWidget() : _buildMainChart(),

          const SizedBox(height: 32),

          // Estadísticas rápidas
          _buildQuickStats(),

          const SizedBox(height: 24),

          // Resumen de progreso
          _buildProgressSummary(),
        ],
      ),
    );
  }

  Widget _buildMetricSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Métrica',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _metrics.entries.map((entry) {
              final isSelected = _selectedMetric == entry.key;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _onMetricChanged(entry.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black87 : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Período',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _periods.entries.map((entry) {
            final isSelected = _selectedPeriod == entry.key;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _onPeriodChanged(entry.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black87 : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? Colors.black87 : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      entry.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
            ),
            SizedBox(height: 12),
            Text(
              'Cargando estadísticas...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainChart() {
    if (_chartData.isEmpty || (_chartData.length == 1 && _chartData[0] == 0.0)) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_outlined,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 12),
              Text(
                'No hay datos disponibles',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Comienza a registrar tu actividad',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildChart();
  }

  Widget _buildChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _getChartInterval(),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[200]!,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return _getBottomTitleWidget(value.toInt());
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: _getChartInterval(),
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey[200]!),
          ),
          minX: 0,
          maxX: (_chartData.length - 1).toDouble(),
          minY: 0,
          maxY: _getMaxY(),
          lineBarsData: [
            LineChartBarData(
              spots: _chartData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value);
              }).toList(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  Colors.black87,
                  Colors.grey[600]!,
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: Colors.black87,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.black87.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBottomTitleWidget(int value) {
    if (_selectedPeriod == 'week') {
      final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
      if (value < days.length) {
        return Text(
          days[value],
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        );
      }
    } else if (_selectedPeriod == 'month') {
      // Para mes: mostrar rangos de días
      final ranges = ['1-5', '6-10', '11-15', '16-20', '21-25', '26-30'];
      if (value < ranges.length) {
        return Text(
          ranges[value],
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        );
      }
    } else if (_selectedPeriod == 'year') {
      // Para año: mostrar meses
      final months = ['E', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
      if (value < months.length) {
        return Text(
          months[value],
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        );
      }
    }
    
    return Text(
      (value + 1).toString(),
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
      ),
    );
  }

  double _getMaxY() {
    if (_chartData.isEmpty) return 100;
    final max = _chartData.reduce((a, b) => a > b ? a : b);
    // Asegurar que el máximo no sea 0
    final maxValue = max == 0 ? 10 : max;
    return (maxValue * 1.2);
  }

  double _getChartInterval() {
    final maxY = _getMaxY();
    final interval = maxY / 5;
    // Asegurar que el intervalo nunca sea 0
    return interval <= 0 ? 1 : interval;
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total',
                _summaryStats['total'] ?? '0',
                Icons.analytics,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Promedio',
                _summaryStats['average'] ?? '0.0',
                Icons.trending_up,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Mejor',
                _summaryStats['best'] ?? '0',
                Icons.star,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[50]!,
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatIcon(),
                size: 28,
                color: Colors.black87,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Progreso',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                '${(_getProgressPercentage() * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _getProgressPercentage(),
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.black87),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getProgressMessage(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatIcon() {
    switch (_selectedMetric) {
      case 'calories':
        return Icons.local_fire_department;
      case 'exercises':
        return Icons.fitness_center;
      case 'active_days':
        return Icons.calendar_today;
      default:
        return Icons.analytics;
    }
  }

  String _getProgressMessage() {
    switch (_selectedMetric) {
      case 'calories':
        return 'Has mantenido un buen balance calórico este período. Continúa con este ritmo para alcanzar tus objetivos de salud.';
      case 'exercises':
        return 'Tu constancia en el ejercicio ha mejorado significativamente. ¡Sigue así para fortalecer tu rutina!';
      case 'active_days':
        return 'Has sido muy activo este período. La consistencia es clave para mantener un estilo de vida saludable.';
      default:
        return 'Continúa monitoreando tu progreso para alcanzar tus objetivos.';
    }
  }

  double _getProgressPercentage() {
    if (_chartData.isEmpty) return 0.0;
    
    // Calcular progreso basado en datos reales
    final total = _chartData.reduce((a, b) => a + b);
    final average = total / _chartData.length;
    
    switch (_selectedMetric) {
      case 'calories':
        // Meta aproximada de 1500-2000 calorías por día
        return (average / 1750).clamp(0.0, 1.0);
      case 'exercises':
        // Meta de ejercicio diario
        return average.clamp(0.0, 1.0);
      case 'active_days':
        // Meta de días activos
        return average.clamp(0.0, 1.0);
      default:
        return 0.75;
    }
  }
}
