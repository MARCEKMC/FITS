import 'package:flutter/material.dart';

class SearchBarWithFilters extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onCategoryTap;
  final VoidCallback onFilterTap;
  final String filterMode;
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String> onCategorySelected;

  const SearchBarWithFilters({
    super.key,
    required this.onChanged,
    required this.onCategoryTap,
    required this.onFilterTap,
    required this.filterMode,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Buscar actividad...",
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                style: const TextStyle(fontSize: 15),
                onChanged: onChanged,
              ),
            ),
          ),
          const SizedBox(width: 6),
          PopupMenuButton<String>(
            icon: const Icon(Icons.category, color: Colors.black),
            tooltip: "Categoría",
            onSelected: (value) {
              if (value == "__manage__") {
                onCategoryTap();
              } else {
                onCategorySelected(value);
              }
            },
            itemBuilder: (context) => [
              for (final cat in categories)
                PopupMenuItem(
                  value: cat,
                  child: Text(cat),
                ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: "__manage__",
                child: Row(
                  children: const [
                    Icon(Icons.settings, size: 18),
                    SizedBox(width: 7),
                    Text("Gestionar categorías"),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              filterMode == "Semanal" ? Icons.calendar_view_week : Icons.calendar_month,
              color: Colors.black,
            ),
            tooltip: "Cambiar visualización",
            onPressed: onFilterTap,
          ),
        ],
      ),
    );
  }
}