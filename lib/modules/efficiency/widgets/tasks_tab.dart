import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/tasks_viewmodel.dart';
import '../../../data/models/task.dart';
import 'task_card.dart';
import 'task_editor_screen.dart';
import '../../../shared/widgets/elegant_confirm_dialog.dart';

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TasksViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            // Header with stats and filters
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Column(
                children: [
                  // Stats row
                  Row(
                    children: [
                      _buildStatCard(
                        'Pendientes',
                        viewModel.pendingTasksCount.toString(),
                        Colors.orange[100]!,
                        Colors.orange[600]!,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Completadas',
                        viewModel.completedTasksCount.toString(),
                        Colors.green[100]!,
                        Colors.green[600]!,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Total',
                        viewModel.totalTasksCount.toString(),
                        Colors.blue[100]!,
                        Colors.blue[600]!,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar tareas...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                viewModel.searchTasks('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: viewModel.searchTasks,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Filter chips
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip(
                          'Todas',
                          viewModel.filterStatus == 'all',
                          () => viewModel.filterByStatus('all'),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Pendientes',
                          viewModel.filterStatus == 'pending',
                          () => viewModel.filterByStatus('pending'),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Completadas',
                          viewModel.filterStatus == 'completed',
                          () => viewModel.filterByStatus('completed'),
                        ),
                        const SizedBox(width: 16),
                        _buildFilterChip(
                          'Prioridad Alta',
                          viewModel.filterPriority == 'high',
                          () => viewModel.filterByPriority('high'),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Prioridad Media',
                          viewModel.filterPriority == 'medium',
                          () => viewModel.filterByPriority('medium'),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Prioridad Baja',
                          viewModel.filterPriority == 'low',
                          () => viewModel.filterByPriority('low'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Tasks list
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.black87))
                  : viewModel.tasks.isEmpty
                      ? _buildEmptyState()
                      : _buildTasksList(viewModel.tasks),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: Colors.black87,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay tareas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón + para crear tu primera tarea',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(List<Task> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TaskCard(
            task: task,
            onTap: () => _editTask(task),
            onToggleComplete: () => _toggleTaskCompletion(task),
            onDelete: () => _deleteTask(task),
          ),
        );
      },
    );
  }

  void _editTask(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskEditorScreen(task: task),
      ),
    );
  }

  void _toggleTaskCompletion(Task task) {
    context.read<TasksViewModel>().toggleTaskCompletion(task.id);
  }

  void _deleteTask(Task task) {
    ElegantConfirmDialog.show(
      context: context,
      title: 'Eliminar tarea',
      content: '¿Estás seguro de que quieres eliminar "${task.title}"?',
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
      confirmColor: Colors.red[400],
      onConfirm: () {
        context.read<TasksViewModel>().deleteTask(task.id);
      },
    );
  }
}
