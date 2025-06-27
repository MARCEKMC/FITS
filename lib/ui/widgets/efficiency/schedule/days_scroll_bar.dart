import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DaysScrollBar extends StatelessWidget {
  final DateTime selectedDay;
  final void Function(DateTime) onSelect;

  const DaysScrollBar({
    super.key,
    required this.selectedDay,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();

    // 100 días antes y 100 después
    final List<DateTime> days = List.generate(
      201,
      (i) => today.subtract(Duration(days: 100 - i)),
    );

    final int selectedIndex = days.indexWhere(
      (d) => d.year == selectedDay.year && d.month == selectedDay.month && d.day == selectedDay.day,
    );

    return SizedBox(
      height: 62,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: ScrollController(
          initialScrollOffset: (selectedIndex - 3) * 44.0,
        ),
        itemCount: days.length,
        itemBuilder: (context, i) {
          final DateTime day = days[i];
          final bool isSelected = day.year == selectedDay.year && day.month == selectedDay.month && day.day == selectedDay.day;

          // Detectar cambio de mes
          bool isMonthChange = false;
          String? monthChangeLabel;
          if (i > 0) {
            final prev = days[i - 1];
            if (day.month != prev.month) {
              isMonthChange = true;
              final String prevMonth = DateFormat("MMM", 'es').format(prev).toUpperCase();
              final String thisMonth = DateFormat("MMM", 'es').format(day).toUpperCase();
              monthChangeLabel = "$prevMonth - $thisMonth";
            }
          }

          Widget dayWidget = GestureDetector(
            onTap: () => onSelect(day),
            child: Container(
              width: 44,
              height: 54,
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black12 : Colors.transparent,
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E('es').format(day).toUpperCase(),
                    style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.w400, letterSpacing: 1),
                  ),
                  Text(
                    day.day.toString().padLeft(2, '0'),
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          );

          if (isMonthChange) {
            // Separador de mes compacto, fuente pequeña, nunca salto de línea ni puntos suspensivos
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                dayWidget,
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 60, // Puedes ajustar a 62-65 si lo necesitas
                  height: 36,
                  child: Text(
                    monthChangeLabel!,
                    style: const TextStyle(
                      fontSize: 10, // Más pequeño
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                    overflow: TextOverflow.clip,
                    softWrap: false,
                  ),
                ),
              ],
            );
          } else {
            return dayWidget;
          }
        },
      ),
    );
  }
}