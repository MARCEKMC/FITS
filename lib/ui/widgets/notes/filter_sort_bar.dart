import 'package:flutter/material.dart';
import 'package:fits/ui/screens/home/notes_screen.dart';

class FilterSortBar extends StatelessWidget {
  final void Function(NotesSortMode) onSortChanged;
  final NotesSortMode currentMode;
  final void Function(DateTime?) onDateFilter;
  final DateTime? currentDate;

  const FilterSortBar({
    super.key,
    required this.onSortChanged,
    required this.currentMode,
    required this.onDateFilter,
    required this.currentDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PopupMenuButton<NotesSortMode>(
          tooltip: "Ordenar/Filtrar",
          icon: const Icon(Icons.filter_list, color: Colors.black),
          onSelected: onSortChanged,
          itemBuilder: (ctx) => [
            CheckedPopupMenuItem(
              value: NotesSortMode.fecha,
              checked: currentMode == NotesSortMode.fecha,
              child: const Text("Por fecha"),
            ),
            CheckedPopupMenuItem(
              value: NotesSortMode.added,
              checked: currentMode == NotesSortMode.added,
              child: const Text("Por orden añadido"),
            ),
            CheckedPopupMenuItem(
              value: NotesSortMode.nota,
              checked: currentMode == NotesSortMode.nota,
              child: const Text("Solo notas"),
            ),
            CheckedPopupMenuItem(
              value: NotesSortMode.tarea,
              checked: currentMode == NotesSortMode.tarea,
              child: const Text("Solo tareas"),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.today, color: Colors.black),
          tooltip: "Filtrar por fecha",
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: currentDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            onDateFilter(picked);
          },
        ),
        if (currentDate != null)
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 20),
            tooltip: "Quitar filtro de fecha",
            onPressed: () => onDateFilter(null),
          ),
      ],
    );
  }
}