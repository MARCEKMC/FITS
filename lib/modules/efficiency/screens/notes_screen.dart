import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/notes_viewmodel.dart';
import '../viewmodels/secure_notes_viewmodel.dart';
import '../viewmodels/tasks_viewmodel.dart';
import '../widgets/notes_tab.dart';
import '../widgets/secure_notes_tab.dart';
import '../widgets/tasks_tab.dart';
import '../widgets/notes_floating_action_button.dart';
import '../../fitsi/viewmodels/fitsi_chat_viewmodel.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load data for each tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesViewModel>().loadNotes();
      context.read<TasksViewModel>().loadTasks();
      
      // Configurar callback para que FITSI actualice las notas cuando agregue contenido
      final fitsiViewModel = context.read<FitsiChatViewModel>();
      fitsiViewModel.setOnContentAddedCallback(() {
        print('🔄 NotesScreen: Recibida notificación de FITSI, actualizando datos...');
        context.read<NotesViewModel>().loadNotes();
        context.read<TasksViewModel>().loadTasks();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Apuntes',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.black87,
          indicatorWeight: 2,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.note_alt_outlined, size: 20),
              text: 'Notas',
            ),
            Tab(
              icon: Icon(Icons.lock_outline, size: 20),
              text: 'Bóveda',
            ),
            Tab(
              icon: Icon(Icons.task_alt_outlined, size: 20),
              text: 'Tareas',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Contenido de las tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                NotesTab(),
                SecureNotesTab(),
                TasksTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          return NotesFloatingActionButton(
            currentTabIndex: _tabController.index,
          );
        },
      ),
    );
  }
}
