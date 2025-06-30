import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/schedule_activity.dart';
import '../../../data/services/schedule_activity_service.dart';
import '../../widgets/efficiency/date_selector_widget.dart';
import '../../widgets/efficiency/search_widget.dart';
import '../../widgets/efficiency/filter_widget.dart';
import '../../widgets/efficiency/view_mode_widget.dart';
import '../../widgets/efficiency/day_strip.dart';
import '../../widgets/efficiency/timeline_widget.dart';
import '../../widgets/efficiency/add_activity_dialog.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';
  Set<ActivityCategory> _selectedFilters = {};
  ViewMode _currentView = ViewMode.day;
  List<ScheduleActivity> _activities = [];
  final ScheduleActivityService _activityService = ScheduleActivityService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  void _loadActivities() async {
    setState(() => _isLoading = true);
    try {
      _activityService.getActivities().listen((activities) {
        if (mounted) {
          setState(() {
            _activities = activities;
            _isLoading = false;
          });
          // Eliminado: carga de datos de ejemplo
        }
      }, onError: (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showErrorMessage('Error al cargar actividades: $error');
          // Eliminado: carga de datos de ejemplo
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorMessage('Error al cargar actividades: $e');
      // Eliminado: carga de datos de ejemplo
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Horario',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header con controles principales
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Primera fila: Calendario, Búsqueda, Filtro y Vista
                  Row(
                    children: [
                      // Calendario (solo ícono)
                      DateSelectorWidget(
                        selectedDate: _selectedDate,
                        onDateSelected: (date) {
                          setState(() => _selectedDate = date);
                        },
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Búsqueda (expandida - toma más espacio)
                      Expanded(
                        flex: 3, // Le damos más proporción
                        child: SearchWidget(
                          searchQuery: _searchQuery,
                          onSearchChanged: (query) {
                            setState(() => _searchQuery = query);
                          },
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Filtro (solo ícono)
                      FilterWidget(
                        selectedFilters: _selectedFilters,
                        onFiltersChanged: (filters) {
                          setState(() => _selectedFilters = filters);
                        },
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Vista (solo íconos)
                      ViewModeWidget(
                        currentView: _currentView,
                        onViewChanged: (mode) {
                          setState(() => _currentView = mode);
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Cinta de días
                  DayStrip(
                    selectedDate: _selectedDate,
                    onDateSelected: (date) {
                      setState(() => _selectedDate = date);
                    },
                  ),
                ],
              ),
            ),
            
            // Timeline principal
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_currentView == ViewMode.day)
              TimelineWidget(
                selectedDate: _selectedDate,
                activities: _getFilteredActivities(),
                onActivityTap: _editActivity,
                onActivityDelete: _deleteActivity,
              )
            else
              _buildMonthView(),
          ],
        ),
      ),
      
      // Botón flotante para agregar actividad
      floatingActionButton: FloatingActionButton(
        onPressed: _addActivity,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildMonthView() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                'Vista Mensual',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Próximamente...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ScheduleActivity> _getFilteredActivities() {
    List<ScheduleActivity> filtered = _activities;
    
    // Filtrar por fecha y días de repetición
    filtered = filtered.where((activity) {
      final dayOfWeek = _selectedDate.weekday;
      return activity.repeatDays.contains(dayOfWeek) &&
             _selectedDate.isAfter(activity.startDate.subtract(const Duration(days: 1))) &&
             (activity.endDate == null || _selectedDate.isBefore(activity.endDate!.add(const Duration(days: 1))));
    }).toList();
    
    // Filtrar por categoría
    if (_selectedFilters.isNotEmpty) {
      filtered = filtered.where((activity) => _selectedFilters.contains(activity.category)).toList();
    }
    
    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((activity) {
        return activity.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (activity.description != null && activity.description!.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }
    
    return filtered;
  }

  void _addActivity() {
    showDialog(
      context: context,
      builder: (context) => AddActivityDialog(
        selectedDate: _selectedDate,
        onSave: (activity) async {
          try {
            await _activityService.createActivity(activity);
            _showSuccessMessage('Actividad agregada exitosamente');
          } catch (e) {
            _showErrorMessage('Error al agregar actividad: $e');
          }
        },
      ),
    );
  }

  void _editActivity(ScheduleActivity activity) {
    showDialog(
      context: context,
      builder: (context) => AddActivityDialog(
        activity: activity,
        selectedDate: _selectedDate,
        onSave: (updatedActivity) async {
          try {
            await _activityService.updateActivity(updatedActivity);
            _showSuccessMessage('Actividad actualizada exitosamente');
          } catch (e) {
            _showErrorMessage('Error al actualizar actividad: $e');
          }
        },
        onDelete: _deleteActivity,
      ),
    );
  }

  void _deleteActivity(ScheduleActivity activity) async {
    try {
      await _activityService.deleteActivity(activity.id);
      _showSuccessMessage('Actividad eliminada exitosamente');
    } catch (e) {
      _showErrorMessage('Error al eliminar actividad: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}