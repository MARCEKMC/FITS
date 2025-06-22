import 'package:flutter/material.dart';
import 'package:fits/data/models/activity.dart';
import 'package:fits/ui/widgets/schedule/search_bar_with_filters.dart';
import 'package:fits/ui/widgets/schedule/days_scroll_bar.dart';
import 'package:fits/ui/widgets/schedule/hourly_table.dart';
import 'package:fits/ui/widgets/schedule/add_activity_modal.dart';
import 'package:fits/ui/widgets/schedule/category_manager_dialog.dart';
import 'package:fits/ui/widgets/schedule/filter_mode_dialog.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<String> categories = [
    "Asuntos personales",
    "Estudios",
    "Trabajo",
  ];

  List<Activity> activities = [];

  String searchQuery = '';
  String filterMode = 'Semanal';
  String selectedCategory = 'Todas';
  DateTime selectedDay = DateTime.now();

  void _openCategoryManager() async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => CategoryManagerDialog(initialCategories: categories),
    );
    if (result != null) {
      setState(() => categories = result);
    }
  }

  void _openFilterMode() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => FilterModeDialog(selected: filterMode),
    );
    if (result != null) {
      setState(() => filterMode = result);
    }
  }

  void _openAddActivityModal() async {
    final result = await showModalBottomSheet<Activity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddActivityModal(
        categories: categories,
        initialDate: selectedDay,
      ),
    );
    if (result != null) {
      setState(() => activities.add(result));
    }
  }

  void _editActivity(Activity activity) async {
    final edited = await showModalBottomSheet<Activity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddActivityModal(
        categories: categories,
        initialDate: activity.date,
        activity: activity,
      ),
    );
    if (edited != null) {
      setState(() {
        // Busca por igualdad de campos (idealmente deberías usar un id único!)
        final idx = activities.indexWhere((a) =>
          a.title == activity.title &&
          a.start == activity.start &&
          a.end == activity.end &&
          a.date == activity.date &&
          a.category == activity.category &&
          a.priority == activity.priority &&
          a.important == activity.important
        );
        if (idx != -1) activities[idx] = edited;
      });
    }
  }

  void _deleteActivity(Activity activity) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar actividad'),
        content: const Text('¿Estás seguro de eliminar esta actividad?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                activities.removeWhere((a) =>
                  a.title == activity.title &&
                  a.start == activity.start &&
                  a.end == activity.end &&
                  a.date == activity.date &&
                  a.category == activity.category &&
                  a.priority == activity.priority &&
                  a.important == activity.important
                );
              });
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<Activity> get filteredActivities {
    return activities
        .where((a) =>
            (selectedCategory == "Todas" || a.category == selectedCategory) &&
            (a.date.year == selectedDay.year &&
                a.date.month == selectedDay.month &&
                a.date.day == selectedDay.day) &&
            (searchQuery.isEmpty ||
                a.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                a.category.toLowerCase().contains(searchQuery.toLowerCase())))
        .toList();
  }

  // Para el panel de búsqueda avanzada
  Map<DateTime, List<Activity>> get searchGroupedByDay {
    final m = <DateTime, List<Activity>>{};
    if (searchQuery.isEmpty) return m;
    for (final a in activities) {
      final matchesText = a.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          a.category.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCat = (selectedCategory == "Todas" || a.category == selectedCategory);
      if (matchesText && matchesCat) {
        final dayKey = DateTime(a.date.year, a.date.month, a.date.day);
        m.putIfAbsent(dayKey, () => []).add(a);
      }
    }
    return m;
  }

  List<DateTime> get days {
    final today = DateTime.now();
    return List.generate(
      14,
      (i) => today.subtract(Duration(days: 7 - i)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = searchQuery.trim().isNotEmpty && searchGroupedByDay.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SearchBarWithFilters(
              onChanged: (val) => setState(() => searchQuery = val),
              onCategoryTap: _openCategoryManager,
              onFilterTap: _openFilterMode,
              filterMode: filterMode,
              selectedCategory: selectedCategory,
              onCategorySelected: (cat) => setState(() => selectedCategory = cat),
              categories: ['Todas', ...categories],
            ),
            if (isSearching)
              // Panel de resultados de búsqueda
              Expanded(
                child: ListView(
                  children: [
                    for (final entry in searchGroupedByDay.entries)
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        elevation: 1,
                        child: ExpansionTile(
                          initiallyExpanded: entry.key ==
                              DateTime(
                                selectedDay.year,
                                selectedDay.month,
                                selectedDay.day,
                              ),
                          title: Text(
                            'Encontrado el ${entry.key.day.toString().padLeft(2, '0')}/${entry.key.month.toString().padLeft(2, '0')}/${entry.key.year}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: entry.value
                              .map(
                                (a) => ListTile(
                                  title: Text(a.title),
                                  subtitle: Text(
                                    '${a.category}  ·  ${a.start.format(context)} - ${a.end.format(context)}',
                                  ),
                                  onTap: () {
                                    // Navegar al día de la actividad
                                    setState(() {
                                      selectedDay = a.date;
                                      searchQuery = '';
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
                  ],
                ),
              )
            else ...[
              DaysScrollBar(
                selectedDay: selectedDay,
                onSelect: (day) => setState(() => selectedDay = day),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filterMode == "Semanal"
                    ? HourlyTable(
                        activities: filteredActivities,
                        onEdit: _editActivity,
                        onDelete: _deleteActivity,
                      )
                    : CalendarView(
                        activities: activities,
                        selectedDay: selectedDay,
                        onSelect: (day) => setState(() => selectedDay = day),
                      ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black, width: 1),
        ),
        onPressed: _openAddActivityModal,
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class CalendarView extends StatelessWidget {
  final List<Activity> activities;
  final DateTime selectedDay;
  final void Function(DateTime) onSelect;

  const CalendarView({
    super.key,
    required this.activities,
    required this.selectedDay,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(
      30,
      (i) => DateTime(now.year, now.month, i + 1),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: GridView.count(
        crossAxisCount: 7,
        childAspectRatio: 1.1,
        children: days.map((day) {
          final hasImportant = activities.any((a) =>
              a.date.year == day.year &&
              a.date.month == day.month &&
              a.date.day == day.day &&
              a.important);
          final isSelected = selectedDay.year == day.year &&
              selectedDay.month == day.month &&
              selectedDay.day == day.day;
          return GestureDetector(
            onTap: () => onSelect(day),
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.black12
                    : hasImportant
                        ? Colors.yellow[100]
                        : Colors.transparent,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                "${day.day}",
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}