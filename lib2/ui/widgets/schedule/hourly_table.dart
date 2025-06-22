import 'package:flutter/material.dart';
import 'dart:ui'; // Para FontFeature
import 'package:fits/data/models/activity.dart';
import 'activity_card.dart';

class HourlyTable extends StatelessWidget {
  final List<Activity> activities;
  final void Function(Activity activity)? onEdit;
  final void Function(Activity activity)? onDelete;

  const HourlyTable({
    Key? key,
    required this.activities,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  static const double leftPadding = 16.0;
  static const double rowHeight = 81.0;
  static const double hourWidth = 28.0;
  static const double fontSize = 16.0;
  static const double activityWidth = 144.0; // 20% más ancho que antes
  static const double activitySpacing = 8.0;

  int _maxOverlaps(List<_PositionedActivity> positioned) {
    if (positioned.isEmpty) return 1;
    int max = 1;
    for (final p in positioned) {
      int overlaps = positioned.where((o) =>
        !(o.end <= p.start || o.start >= p.end)
      ).length;
      if (overlaps > max) max = overlaps;
    }
    return max;
  }

  @override
  Widget build(BuildContext context) {
    final positionedActivities = _calculatePositionedActivities(activities);
    final screenWidth = MediaQuery.of(context).size.width;
    final int maxOverlap = _maxOverlaps(positionedActivities);
    final double minScrollableWidth = (maxOverlap) * (activityWidth + activitySpacing);
    final double totalHeight = 25 * rowHeight;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: leftPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna fija con las horas
            Column(
              children: List.generate(25, (i) {
                return SizedBox(
                  width: hourWidth,
                  height: rowHeight,
                  child: Center(
                    child: Text(
                      i.toString().padLeft(2, '0'),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: fontSize,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }),
            ),
            // Scroll horizontal con líneas y actividades
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: minScrollableWidth < screenWidth ? screenWidth : minScrollableWidth,
                  height: totalHeight,
                  child: Stack(
                    children: [
                      // Líneas horizontales (25 líneas: 0-24)
                      ...List.generate(25, (i) {
                        return Positioned(
                          top: i * rowHeight + (rowHeight / 2),
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 1,
                            color: Colors.grey.withOpacity(0.32),
                          ),
                        );
                      }),
                      ..._buildAllActivities(context, positionedActivities),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_PositionedActivity> _calculatePositionedActivities(List<Activity> activities) {
    final sorted = List<Activity>.from(activities)
      ..sort((a, b) {
        final aStart = a.start.hour * 60 + a.start.minute;
        final bStart = b.start.hour * 60 + b.start.minute;
        return aStart.compareTo(bStart);
      });
    final List<_PositionedActivity> result = [];

    for (var i = 0; i < sorted.length; i++) {
      final activity = sorted[i];
      final startHour = activity.start.hour;
      final startMinute = activity.start.minute;
      final endHour = activity.end?.hour ?? (startHour + 1);
      final endMinute = activity.end?.minute ?? 0;

      final double start = startHour + startMinute / 60.0;
      final double end = endHour + endMinute / 60.0;

      int col = 0;
      while (true) {
        bool hasCollision = result.any((other) =>
          other.column == col &&
          !(end <= other.start || start >= other.end)
        );
        if (!hasCollision) break;
        col++;
      }

      result.add(_PositionedActivity(
        activity: activity,
        start: start,
        end: end,
        column: col,
      ));
    }
    return result;
  }

  List<Widget> _buildAllActivities(BuildContext context, List<_PositionedActivity> positioned) {
    final List<Widget> widgets = [];

    for (final p in positioned) {
      final activity = p.activity;
      final double top = p.start * rowHeight + (rowHeight / 2);
      final double height = (p.end - p.start) * rowHeight;
      final double left = p.column * (activityWidth + activitySpacing);

      widgets.add(Positioned(
        top: top,
        left: left,
        width: activityWidth,
        height: height > 30 ? height : 30,
        child: ActivityCard(
          activity: activity,
          onEdit: onEdit != null ? () => onEdit!(activity) : null,
          onDelete: onDelete != null ? () => onDelete!(activity) : null,
        ),
      ));
    }
    return widgets;
  }
}

// Clase para calcular la posición de cada actividad en el horario visual
class _PositionedActivity {
  final Activity activity;
  final double start; // en horas decimales
  final double end;   // en horas decimales
  final int column;   // columna horizontal si se superponen

  _PositionedActivity({
    required this.activity,
    required this.start,
    required this.end,
    required this.column,
  });
}