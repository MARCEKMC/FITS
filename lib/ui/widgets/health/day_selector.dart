import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DaySelector extends StatefulWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onChanged;

  const DaySelector({super.key, required this.selected, required this.onChanged});

  @override
  State<DaySelector> createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  late final List<DateTime> days;
  late final int todayIndex;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    days = List.generate(
      201,
      (i) => today.subtract(Duration(days: 100 - i)),
    );
    todayIndex = 100;

    // Scroll automático al día de hoy (centrado)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Calcula el ancho estimado de un ítem (ajusta si cambias el padding)
      const itemWidth = 56.0; // padding horizontal + texto aproximado
      final offset = (todayIndex - 2) * (itemWidth + 10);
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(offset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68, // MÁS ALTO PARA DOS LÍNEAS
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final d = days[i];
          final isSelected = d.year == widget.selected.year && d.month == widget.selected.month && d.day == widget.selected.day;
          return GestureDetector(
            onTap: () => widget.onChanged(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Día de la semana
                  SizedBox(
                    height: 17,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        DateFormat.E('es').format(d).toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Número del día
                  SizedBox(
                    height: 20,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "${d.day}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}