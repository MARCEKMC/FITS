import 'package:flutter/material.dart';
import '../../../data/models/schedule_activity.dart';

class FilterWidget extends StatelessWidget {
  final Set<ActivityCategory> selectedFilters;
  final Function(Set<ActivityCategory>) onFiltersChanged;

  const FilterWidget({
    super.key,
    required this.selectedFilters,
    required this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: PopupMenuButton<ActivityCategory>(
        onSelected: (category) {
          final newFilters = Set<ActivityCategory>.from(selectedFilters);
          if (newFilters.contains(category)) {
            newFilters.remove(category);
          } else {
            newFilters.add(category);
          }
          onFiltersChanged(newFilters);
        },
        itemBuilder: (context) => ActivityCategory.values
            .map((category) => PopupMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(
                        selectedFilters.contains(category)
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: selectedFilters.contains(category)
                            ? Colors.blue[600]
                            : Colors.grey[400],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: selectedFilters.contains(category)
                              ? Colors.black87
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.filter_list,
                size: 20,
                color: selectedFilters.isNotEmpty 
                    ? Colors.blue[600] 
                    : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: selectedFilters.isNotEmpty 
                      ? Colors.blue[600] 
                      : Colors.grey[600],
                ),
              ),
              if (selectedFilters.isNotEmpty) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${selectedFilters.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: selectedFilters.isNotEmpty 
                    ? Colors.blue[600] 
                    : Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
