import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/home/quick_action_card.dart';
import '../../widgets/home/quick_note_widget.dart';
import '../../widgets/home/quick_task_widget.dart';
import '../../widgets/home/quick_food_widget.dart';
import '../../../viewmodel/notes_viewmodel.dart';
import '../../../viewmodel/tasks_viewmodel.dart';
import '../../../viewmodel/user_viewmodel.dart';
import '../health/food_main_screen.dart';
import '../health/exercise_main_screen.dart';
import '../efficiency/schedule_screen.dart';
import '../efficiency/notes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final notesVM = Provider.of<NotesViewModel>(context, listen: false);
    final tasksVM = Provider.of<TasksViewModel>(context, listen: false);
    
    notesVM.loadNotes();
    tasksVM.loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final userVM = Provider.of<UserViewModel>(context);
    final notesVM = Provider.of<NotesViewModel>(context);
    final tasksVM = Provider.of<TasksViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Welcome header
              _buildWelcomeHeader(userVM),
              
              const SizedBox(height: 24),
              
              // Notes and tasks section (arriba)
              _buildNotesAndTasksSection(notesVM, tasksVM),
              
              const SizedBox(height: 20),
              
              // Food widgets
              _buildFoodSection(),
              
              const SizedBox(height: 20),
              
              // Quick actions grid (abajo)
              _buildQuickActionsGrid(userVM),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(UserViewModel userVM) {
    final now = DateTime.now();
    String greeting;
    IconData greetingIcon;
    Color greetingColor;

    if (now.hour < 12) {
      greeting = 'Buenos días';
      greetingIcon = Icons.wb_sunny;
      greetingColor = Colors.orange;
    } else if (now.hour < 18) {
      greeting = 'Buenas tardes';
      greetingIcon = Icons.wb_sunny_outlined;
      greetingColor = Colors.amber;
    } else {
      greeting = 'Buenas noches';
      greetingIcon = Icons.nights_stay;
      greetingColor = Colors.indigo;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              greetingIcon,
              size: 28,
              color: greetingColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                greeting,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: greetingColor,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          userVM.profile?.realName != null && userVM.profile!.realName.isNotEmpty
              ? '¡Hola, ${userVM.profile!.realName}!'
              : '¡Hola!',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '¿Qué quieres hacer hoy?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(UserViewModel userVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accesos Rápidos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 12),
        
        // Grid de 2x2 más compacto
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                title: 'Ejercicios',
                subtitle: 'Entrenar',
                icon: Icons.fitness_center,
                iconColor: Colors.red[600]!,
                isLarge: false,
                onTap: () {
                  final gender = userVM.profile?.gender ?? "Masculino";
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExerciseMainScreen(gender: gender),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                title: 'Horario',
                subtitle: 'Agenda',
                icon: Icons.schedule,
                iconColor: Colors.blue[600]!,
                isLarge: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ScheduleScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Segunda fila
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                title: 'Alimentación',
                subtitle: 'Comidas',
                icon: Icons.restaurant_menu,
                iconColor: Colors.orange[600]!,
                isLarge: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FoodMainScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                title: 'Notas',
                subtitle: 'Ver todas',
                icon: Icons.note_alt,
                iconColor: Colors.green[600]!,
                isLarge: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotesScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFoodSection() {
    return QuickFoodWidget(
      onMealTypeSelected: (mealType) {
        // Navegar a la pantalla de alimentos con el tipo de comida preseleccionado
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FoodMainScreen(),
          ),
        );
        
        // Mostrar información del tipo de comida seleccionado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registrando $mealType'),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesAndTasksSection(NotesViewModel notesVM, TasksViewModel tasksVM) {
    return Column(
      children: [
        QuickNoteWidget(
          onNoteSaved: (note) async {
            try {
              await notesVM.addQuickNote(note);
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al guardar nota: $e'),
                    backgroundColor: Colors.red[600],
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            }
          },
        ),
        
        const SizedBox(height: 16),
        
        QuickTaskWidget(
          onTaskSaved: (task) async {
            try {
              await tasksVM.addQuickTask(task);
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al agregar tarea: $e'),
                    backgroundColor: Colors.red[600],
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }
}