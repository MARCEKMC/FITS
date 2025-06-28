import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/health_viewmodel.dart';
import '../../../viewmodel/food_viewmodel.dart';
import '../../../viewmodel/water_viewmodel.dart';
import '../../../viewmodel/selected_date_viewmodel.dart';
import '../../widgets/health/health_calendar_header.dart';
import '../../widgets/health/health_day_calendar.dart';
import '../../widgets/health/days_slider.dart';
import '../../widgets/health/calories_progress_bar.dart';
import '../../widgets/health/meal_section.dart';
import '../../widgets/health/water_tracker.dart';

class FoodMainScreen extends StatefulWidget {
  const FoodMainScreen({super.key});

  @override
  State<FoodMainScreen> createState() => _FoodMainScreenState();
}

class _FoodMainScreenState extends State<FoodMainScreen> {
  bool showCalendar = false;
  DateTime? _lastLoadedDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedDate = Provider.of<SelectedDateViewModel>(context).selectedDate;
    if (_lastLoadedDate != selectedDate) {
      final foodVM = Provider.of<FoodViewModel>(context, listen: false);
      final waterVM = Provider.of<WaterViewModel>(context, listen: false);
      foodVM.loadEntriesForDate(selectedDate);
      waterVM.loadEntryForDate(selectedDate);
      _lastLoadedDate = selectedDate;
    }
  }

  void _onSelectDate(DateTime date) {
    Provider.of<SelectedDateViewModel>(context, listen: false).setDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final healthVM = Provider.of<HealthViewModel>(context);
    final foodVM = Provider.of<FoodViewModel>(context);
    final selectedDate = Provider.of<SelectedDateViewModel>(context).selectedDate;

    final profile = healthVM.profile;
    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final kcalObjetivo = profile.kcalObjetivo.round();
    final totalKcal = foodVM.totalKcalDay();

    final mealTypes = [
      'Desayuno',
      'Media mañana',
      'Almuerzo',
      'Lonche',
      'Cena',
      'Antojos'
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            HealthCalendarHeader(
              onCalendarTap: () => setState(() => showCalendar = !showCalendar),
              caloriasHoy: totalKcal,
              diasActivos: 1,
              calendarioAbierto: showCalendar,
            ),
            if (showCalendar)
              HealthDayCalendar(
                selectedDate: selectedDate,
                minDate: DateTime.now().subtract(const Duration(days: 100)),
                maxDate: DateTime.now().add(const Duration(days: 100)),
                onDateSelected: (date) {
                  _onSelectDate(date);
                  setState(() => showCalendar = false);
                },
              ),
            DaysSlider(
              selectedDate: selectedDate,
              onDateSelected: _onSelectDate,
            ),
            const SizedBox(height: 18),
            CaloriesProgressBar(
              total: kcalObjetivo,
              consumed: totalKcal,
            ),
            const SizedBox(height: 18),
            ...mealTypes.map((meal) {
              final foods = foodVM.foodEntries
                  .where((f) => f.mealType == meal)
                  .map((f) => {'id': f.id, 'name': f.name, 'kcal': f.kcal})
                  .toList();
              final kcal = foodVM.totalKcalForMeal(meal);
              return MealSection(
                mealName: meal,
                calories: kcal,
                foods: foods,
                onAddFood: (name, kcal) async {
                  await foodVM.addFoodEntry(meal, name, kcal, selectedDate);
                },
                onDelete: (food) async {
                  await foodVM.deleteFoodEntry(food['id'], selectedDate);
                },
              );
            }),
            const SizedBox(height: 24),
            Selector<WaterViewModel, int>(
              selector: (_, vm) => vm.glasses,
              builder: (context, glasses, _) {
                final date = Provider.of<SelectedDateViewModel>(context).selectedDate;
                return WaterTracker(
                  glasses: glasses,
                  onTapGlass: (count) {
                    Provider.of<WaterViewModel>(context, listen: false).setGlasses(count, date);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}