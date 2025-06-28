import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HealthDayCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime minDate;
  final DateTime maxDate;
  final Function(DateTime) onDateSelected;

  const HealthDayCalendar({
    super.key,
    required this.selectedDate,
    required this.minDate,
    required this.maxDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return CalendarDatePicker(
      initialDate: selectedDate,
      firstDate: minDate,
      lastDate: maxDate,
      onDateChanged: onDateSelected,
    );
  }
}