import 'package:flutter/material.dart';
import '../../../core/enums/view_mode.dart';

extension ViewModeIconExtension on ViewMode {
  IconData get icon {
    switch (this) {
      case ViewMode.day:
        return Icons.view_day;
      case ViewMode.month:
        return Icons.calendar_view_month;
    }
  }
}

class ViewModeWidget extends StatelessWidget {
  final ViewMode currentView;
  final Function(ViewMode) onViewChanged;

  const ViewModeWidget({
    super.key,
    required this.currentView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ViewMode.values.map((mode) {
          final isSelected = mode == currentView;
          return GestureDetector(
            onTap: () => onViewChanged(mode),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[600] : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                mode.icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
