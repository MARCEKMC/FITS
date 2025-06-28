import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DaysSlider extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DaysSlider({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 100));
    final end = today.add(const Duration(days: 100));
    final days = List<DateTime>.generate(
      end.difference(start).inDays + 1,
      (i) => start.add(Duration(days: i)),
    );

    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final date = days[index];
          final isSelected = date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day;
          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: 56,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DateFormat('E', 'es').format(date), style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
                    Text(date.day.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}