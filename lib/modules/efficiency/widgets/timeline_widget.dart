import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/schedule_activity.dart';

class TimelineWidget extends StatefulWidget {
  final DateTime selectedDate;
  final List<ScheduleActivity> activities;
  final Function(ScheduleActivity) onActivityTap;
  final Function(ScheduleActivity)? onActivityDelete;

  const TimelineWidget({
    super.key,
    required this.selectedDate,
    required this.activities,
    required this.onActivityTap,
    this.onActivityDelete,
  });

  @override
  State<TimelineWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            // Header del timeline
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Horario del ${DateFormat('dd/MM/yyyy').format(widget.selectedDate)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            
            // Timeline principal
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 24,
                itemBuilder: (context, index) {
                  final hour = index;
                  final hourActivities = _getActivitiesForHour(hour);
                  
                  return _buildHourSlot(hour, hourActivities);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourSlot(int hour, List<ScheduleActivity> hourActivities) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicador de hora
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
              ),
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Línea separadora
            Container(
              width: 1,
              color: Colors.grey[200],
            ),
            
            // Contenido de actividades
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 60),
                padding: const EdgeInsets.all(8),
                child: hourActivities.isEmpty
                    ? Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Sin actividades',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: hourActivities.map((activity) {
                          return _buildActivityCard(activity);
                        }).toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(ScheduleActivity activity) {
    Color categoryColor;
    switch (activity.category) {
      case ActivityCategory.actividades:
        categoryColor = Colors.blue[600]!;
        break;
      case ActivityCategory.habitos:
        categoryColor = Colors.green[600]!;
        break;
      case ActivityCategory.asuntosImportantes:
        categoryColor = Colors.orange[600]!;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showActivityOptions(activity),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: categoryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 30,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (activity.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          activity.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        '${DateFormat('HH:mm').format(activity.startTime)} - ${DateFormat('HH:mm').format(activity.endTime)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: categoryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_vert,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActivityOptions(ScheduleActivity activity) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle visual
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                activity.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const Divider(),
            
            // Opciones
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Editar actividad'),            onTap: () {
              Navigator.pop(context);
              widget.onActivityTap(activity);
            },
            ),
            
            if (widget.onActivityDelete != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar actividad'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(activity);
                },
              ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(ScheduleActivity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Eliminar actividad',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${activity.title}"?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onActivityDelete!(activity);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  List<ScheduleActivity> _getActivitiesForHour(int hour) {
    return widget.activities.where((activity) {
      final activityHour = activity.startTime.hour;
      return activityHour == hour;
    }).toList();
  }
}
