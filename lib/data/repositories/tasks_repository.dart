import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TasksRepository {
  static const String _tasksKey = 'tasks';

  Future<List<Task>> getAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString(_tasksKey);
    
    if (tasksJson == null) return [];
    
    final List<dynamic> tasksList = json.decode(tasksJson);
    return tasksList.map((json) => Task.fromMap(json)).toList();
  }

  Future<Task?> getTaskById(String id) async {
    final tasks = await getAllTasks();
    try {
      return tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveTask(Task task) async {
    final tasks = await getAllTasks();
    final existingIndex = tasks.indexWhere((t) => t.id == task.id);
    
    if (existingIndex != -1) {
      tasks[existingIndex] = task;
    } else {
      tasks.add(task);
    }
    
    await _saveTasks(tasks);
  }

  Future<void> deleteTask(String id) async {
    final tasks = await getAllTasks();
    tasks.removeWhere((task) => task.id == id);
    await _saveTasks(tasks);
  }

  Future<void> toggleTaskCompletion(String id) async {
    final task = await getTaskById(id);
    if (task != null) {
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        updatedAt: DateTime.now(),
      );
      await saveTask(updatedTask);
    }
  }

  Future<List<Task>> getCompletedTasks() async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.isCompleted).toList();
  }

  Future<List<Task>> getPendingTasks() async {
    final tasks = await getAllTasks();
    return tasks.where((task) => !task.isCompleted).toList();
  }

  Future<List<Task>> getTasksByPriority(String priority) async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.priority == priority).toList();
  }

  Future<List<Task>> searchTasks(String query) async {
    final tasks = await getAllTasks();
    if (query.isEmpty) return tasks;
    
    final lowerQuery = query.toLowerCase();
    return tasks.where((task) =>
        task.title.toLowerCase().contains(lowerQuery) ||
        task.description.toLowerCase().contains(lowerQuery) ||
        task.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))
    ).toList();
  }

  Future<void> _saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = json.encode(tasks.map((task) => task.toMap()).toList());
    await prefs.setString(_tasksKey, tasksJson);
  }
}
