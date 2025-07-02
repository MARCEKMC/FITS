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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Stack(
            children: [
              Icon(
                Icons.filter_list,
                size: 20,
                color: selectedFilters.isNotEmpty 
                    ? Colors.blue[600] 
                    : Colors.grey[600],
              ),
              if (selectedFilters.isNotEmpty)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${selectedFilters.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
