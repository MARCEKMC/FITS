import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../../data/models/task.dart';
import '../../../data/repositories/simple_tasks_repository.dart';
import '../../../core/events/app_events.dart';

class TasksViewModel extends ChangeNotifier {
  final SimpleTasksRepository _repository = SimpleTasksRepository();
  StreamSubscription<String>? _eventSubscription;
  
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _filterStatus = 'all';
  String _filterPriority = 'all';

  List<Task> get tasks => _filteredTasks;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get filterStatus => _filterStatus;
  String get filterPriority => _filterPriority;

  int get completedTasksCount => _tasks.where((task) => task.isCompleted).length;
  int get pendingTasksCount => _tasks.where((task) => !task.isCompleted).length;
  int get totalTasksCount => _tasks.length;
  
  TasksViewModel() {
    // Escuchar eventos de actualización de tareas
    _eventSubscription = AppEvents().eventStream.listen((event) {
      if (event == AppEventTypes.tasksUpdated) {
        print('📋 TasksViewModel: Recibido evento de actualización de tareas');
        loadTasks();
      }
    });
  }
  
  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _repository.getAllTasks();
      _applyFilters();
    } catch (e) {
      print('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveTask(Task task) async {
    try {
      await _repository.saveTask(task);
      await loadTasks(); // Reload to update the list
    } catch (e) {
      print('Error saving task: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _repository.deleteTask(id);
      await loadTasks(); // Reload to update the list
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now(),
    );
    await saveTask(updatedTask);
  }

  void searchTasks(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void filterByStatus(String status) {
    _filterStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void filterByPriority(String priority) {
    _filterPriority = priority;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredTasks = _tasks.where((task) {
      final matchesSearch = _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _filterStatus == 'all' ||
          (_filterStatus == 'completed' && task.isCompleted) ||
          (_filterStatus == 'pending' && !task.isCompleted);

      final matchesPriority = _filterPriority == 'all' || task.priority == _filterPriority;

      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();
  }

  Task createNewTask() {
    return Task(
      id: '',
      title: '',
      description: '',
      isCompleted: false,
      priority: 'medium',
      dueDate: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red[300]!;
      case 'medium':
        return Colors.orange[300]!;
      case 'low':
        return Colors.green[300]!;
      default:
        return Colors.grey[300]!;
    }
  }

  IconData getPriorityIcon(String priority) {
    switch (priority) {
      case 'high':
        return Icons.keyboard_arrow_up;
      case 'medium':
        return Icons.remove;
      case 'low':
        return Icons.keyboard_arrow_down;
      default:
        return Icons.remove;
    }
  }

  Future<void> addQuickTask(String taskText) async {
    try {
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: taskText,
        description: '',
        isCompleted: false,
        priority: 'medium',
        dueDate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _repository.saveTask(newTask);
      await loadTasks(); // Reload to update the list
    } catch (e) {
      print('Error adding quick task: $e');
      rethrow;
    }
  }
}
