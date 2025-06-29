import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/exercise_viewmodel.dart';
import '../../../viewmodel/health_viewmodel.dart';
import '../../widgets/health/exercise_survey.dart';
import '../../widgets/health/body_part_grid.dart';
import '../../widgets/health/intensity_selector.dart';
// Importa la nueva pantalla tipo "player"
import 'exercise_player_screen.dart';

class ExerciseMainScreen extends StatefulWidget {
  final String gender;
  const ExerciseMainScreen({super.key, required this.gender});

  @override
  State<ExerciseMainScreen> createState() => _ExerciseMainScreenState();
}

class _ExerciseMainScreenState extends State<ExerciseMainScreen> {
  bool surveyDone = false;
  bool gridVisible = false;
  bool showIntensitySelector = false;
  String? selectedGroupName;

  // Ejercicios por grupo (puedes mover esto a un helper/file aparte si prefieres)
  List<String> getCarpetasPorGrupo(String group) {
    switch (group.toLowerCase()) {
      case 'pecho':
        return [
          'Machine_Bench_Press', 'Pushups', 'Push-Ups_With_Feet_Elevated',
          'Smith_Machine_Bench_Press', 'Dumbbell_Flyes', 'Standing_Cable_Chest_Press',
          'Medicine_Ball_Chest_Pass', 'Plyo_Push-up', 'Push_Up_to_Side_Plank',
          'Smith_Machine_Decline_Press', 'Pushups_Close_and_Wide_Hand_Positions', 'One_Arm_Dumbbell_Bench_Press'
        ];
      case 'espalda':
        return [
          'Pullups', 'One-Arm_Dumbbell_Row', 'Seated_Cable_Rows', 'Smith_Machine_Bent_Over_Row',
          'Lying_T-Bar_Row', 'One_Arm_Lat_Pulldown', 'Mixed_Grip_Chin', 'Rocky_Pull-Ups_Pulldowns',
          'Rope_Straight-Arm_Pulldown', 'Shotgun_Row', 'Reverse_Grip_Bent-Over_Rows', 'Muscle_Up'
        ];
      case 'brazos':
        return [
          'Standing_Biceps_Cable_Curl', 'Preacher_Curl', 'Machine_Bicep_Curl', 'Lying_Close-Grip_Bar_Curl_On_High_Pulley',
          'Lying_Dumbbell_Tricep_Extension', 'Reverse_Grip_Triceps_Pushdown', 'Seated_Dumbbell_Curl',
          'One_Arm_Dumbbell_Preacher_Curl', 'Standing_Dumbbell_Reverse_Curl', 'One-Arm_Kettlebell_Row',
          'Standing_One-Arm_Cable_Curl', 'Seated_Triceps_Press'
        ];
      case 'abdomen':
      case 'abdomen':
        return [
          'Plank', 'Sit-Up', 'Russian_Twist', 'Scissor_Kick', 'Mountain_Climbers', 'Side_Jackknife',
          'Rope_Crunch', 'Standing_Rope_Crunch', 'Otis-Up', 'Reverse_Crunch', 'Seated_Flat_Bench_Leg_Pull-In',
          'Spider_Crawl'
        ];
      case 'piernas':
        return [
          'Lying_Leg_Curls', 'Smith_Machine_Squat', 'Smith_Machine_Leg_Press', 'Narrow_Stance_Squats',
          'Split_Squat_with_Dumbbells', 'Sled_Push', 'Romanian_Deadlift', 'Single_Leg_Glute_Bridge',
          'Dumbbell_Lunges', 'Dumbbell_Step_Ups', 'Seated_Leg_Curl', 'Standing_Calf_Raises'
        ];
      case 'todo el cuerpo':
        return [
          'Burpee', 'Mountain_Climbers', 'Freehand_Jump_Squat', 'Pushups',
          'Pullups', 'Plank', 'Medicine_Ball_Chest_Pass', 'Plyo_Push-up',
          'Muscle_Up', 'Sled_Push', 'Dumbbell_Lunges', 'Spider_Crawl'
        ];
      // Puedes agregar más casos para otros grupos si lo deseas
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final exerciseVM = Provider.of<ExerciseViewModel>(context);
    final healthVM = Provider.of<HealthViewModel>(context, listen: false);

    final objetivoAlimentacion = healthVM.profile?.objetivo;

    Widget content;

    if (!surveyDone) {
      content = ExerciseSurvey(
        gender: widget.gender,
        objetivoAlimentacion: objetivoAlimentacion,
        onFinish: ({
          required String objetivoAlimentacion,
          required String objetivoEntrenamiento,
          required List<int> selectedMuscleIds,
          required bool experiencia,
          required String lugar,
        }) {
          setState(() {
            surveyDone = true;
            gridVisible = true;
            selectedGroupName = null;
          });
        },
      );
    } else if (gridVisible) {
      content = BodyPartGrid(
        gender: widget.gender,
        onTap: (groupName, _) async {
          setState(() {
            gridVisible = false;
            showIntensitySelector = true;
            selectedGroupName = groupName;
          });
        },
      );
    } else if (showIntensitySelector) {
      content = IntensitySelector(
        onSelect: (intensity) async {
          setState(() {
            showIntensitySelector = false;
          });

          // --- CAMBIO PRINCIPAL: Navegar a la pantalla tipo "player" ---
          if (selectedGroupName != null && selectedGroupName!.isNotEmpty) {
            final ejercicios = getCarpetasPorGrupo(selectedGroupName!);
            if (ejercicios.isNotEmpty) {
              // Lanza la pantalla "player"
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExercisePlayerScreen(
                    exerciseFolders: ejercicios,
                    groupName: selectedGroupName!,
                  ),
                ),
              );
              // Al volver, puedes resetear si deseas
              setState(() {
                surveyDone = false;
                gridVisible = false;
                showIntensitySelector = false;
                selectedGroupName = null;
              });
              return;
            }
          }
        },
      );
    } else if (exerciseVM.loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (exerciseVM.routine.isNotEmpty) {
      // No deberías llegar aquí si usas el nuevo flujo tipo "player"
      content = const Center(child: Text("¡Rutina generada!"));
    } else {
      content = const Center(child: Text("No hay rutina disponible."));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicios'),
        leading: (surveyDone &&
                (showIntensitySelector ||
                    (gridVisible && selectedGroupName != null)))
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (showIntensitySelector) {
                    setState(() {
                      showIntensitySelector = false;
                      gridVisible = true;
                    });
                  } else if (gridVisible && selectedGroupName != null) {
                    setState(() {
                      gridVisible = true;
                      selectedGroupName = null;
                    });
                  }
                },
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: content,
      ),
    );
  }
}