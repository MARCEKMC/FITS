import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DaysSlider extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DaysSlider({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DaysSlider> createState() => _DaysSliderState();
}

class _DaysSliderState extends State<DaysSlider> {
  late final ScrollController _scrollController;
  late List<DateTime> _days;
  static const double _itemWidth = 56.0;
  static const int _daysRange = 100;

  @override
  void initState() {
    super.initState();
    _generateDays();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerSelected(immediate: true);
    });
  }

  @override
  void didUpdateWidget(DaysSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _generateDays();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _centerSelected(immediate: false);
      });
    }
  }

  void _generateDays() {
    final center = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day);
    final start = center.subtract(const Duration(days: _daysRange));
    final end = center.add(const Duration(days: _daysRange));
    _days = List<DateTime>.generate(
      end.difference(start).inDays + 1,
      (i) => start.add(Duration(days: i)),
    );
  }

  void _centerSelected({required bool immediate, int retry = 0}) {
    final selectedIndex = _days.indexWhere(
      (d) =>
          d.year == widget.selectedDate.year &&
          d.month == widget.selectedDate.month &&
          d.day == widget.selectedDate.day,
    );
    if (selectedIndex == -1) return;

    if (!_scrollController.hasClients ||
        (_scrollController.position.maxScrollExtent == 0 && _days.length > 7)) {
      if (retry < 5) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _centerSelected(immediate: immediate, retry: retry + 1);
        });
      }
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    double offset = selectedIndex * _itemWidth - (screenWidth / 2) + (_itemWidth / 2);

    final maxScroll = _scrollController.position.maxScrollExtent;
    offset = offset.clamp(0.0, maxScroll);

    if (immediate) {
      _scrollController.jumpTo(offset);
    } else {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final date = _days[index];
          final isSelected = date.year == widget.selectedDate.year &&
              date.month == widget.selectedDate.month &&
              date.day == widget.selectedDate.day;
          final weekday = DateFormat('E', 'es').format(date);

          return GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: Container(
              width: _itemWidth,
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
                border: Border.all(
                  color: isSelected
                      ? Colors.black
                      : Colors.grey.withOpacity(0.12),
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekday.substring(0, 1).toUpperCase() +
                        weekday.substring(1, 3),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isSelected
                          ? Colors.white
                          : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: isSelected
                          ? Colors.white
                          : Colors.black87,
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