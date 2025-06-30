import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class SimpleTasksRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> _ensureUserAuthenticated() async {
    if (_auth.currentUser != null) {
      return _auth.currentUser!.uid;
    }
    
    // Sign in anonymously if no user is authenticated
    try {
      final userCredential = await _auth.signInAnonymously();
      print('Signed in anonymously with user ID: ${userCredential.user?.uid}');
      return userCredential.user?.uid;
    } catch (e) {
      print('Error signing in anonymously: $e');
      return null;
    }
  }

  Future<List<Task>> getAllTasks() async {
    final userId = await _ensureUserAuthenticated();
    if (userId == null) return [];

    try {
      print('Loading tasks for user: $userId');
      // Simple query without orderBy to avoid index requirements
      final snapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .get();

      print('Found ${snapshot.docs.length} tasks');
      final tasks = snapshot.docs
          .map((doc) {
            print('Processing task doc: ${doc.id} with data: ${doc.data()}');
            return Task.fromMap({...doc.data(), 'id': doc.id});
          })
          .toList();
      
      // Sort by updatedAt in memory
      tasks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      print('Returning ${tasks.length} sorted tasks');
      return tasks;
    } catch (e) {
      print('Error loading tasks from Firestore: $e');
      return [];
    }
  }

  Future<Task?> getTaskById(String id) async {
    final userId = await _ensureUserAuthenticated();
    if (userId == null) return null;

    try {
      final doc = await _firestore.collection('tasks').doc(id).get();
      if (doc.exists && doc.data()?['userId'] == userId) {
        return Task.fromMap({...doc.data()!, 'id': doc.id});
      }
    } catch (e) {
      print('Error getting task by id: $e');
    }
    return null;
  }

  Future<void> saveTask(Task task) async {
    final userId = await _ensureUserAuthenticated();
    if (userId == null) {
      print('Error: Could not authenticate user');
      return;
    }

    print('Saving task for user: $userId');
    print('Task data: ${task.toMap()}');

    try {
      final taskData = {
        ...task.toMap(),
        'userId': userId,
      };
      taskData.remove('id');

      if (task.id.isEmpty) {
        print('Creating new task...');
        final docRef = await _firestore.collection('tasks').add(taskData);
        print('Task created with ID: ${docRef.id}');
      } else {
        print('Updating existing task with ID: ${task.id}');
        await _firestore.collection('tasks').doc(task.id).set(taskData);
        print('Task updated successfully');
      }
    } catch (e) {
      print('Error saving task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    final userId = await _ensureUserAuthenticated();
    if (userId == null) return;

    try {
      final doc = await _firestore.collection('tasks').doc(id).get();
      if (doc.exists && doc.data()?['userId'] == userId) {
        await _firestore.collection('tasks').doc(id).delete();
        print('Task deleted successfully');
      }
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  Future<List<Task>> getTasksByStatus(String status) async {
    final allTasks = await getAllTasks();
    if (status == 'completed') {
      return allTasks.where((task) => task.isCompleted).toList();
    } else if (status == 'pending') {
      return allTasks.where((task) => !task.isCompleted).toList();
    }
    return allTasks;
  }

  Future<List<Task>> getTasksByPriority(String priority) async {
    final allTasks = await getAllTasks();
    return allTasks.where((task) => task.priority == priority).toList();
  }

  Future<List<Task>> getOverdueTasks() async {
    final allTasks = await getAllTasks();
    final now = DateTime.now();
    return allTasks.where((task) => 
        task.dueDate != null && 
        task.dueDate!.isBefore(now) && 
        !task.isCompleted
    ).toList();
  }

  Future<List<Task>> searchTasks(String query) async {
    final allTasks = await getAllTasks();
    if (query.isEmpty) return allTasks;

    final lowerQuery = query.toLowerCase();
    return allTasks.where((task) =>
        task.title.toLowerCase().contains(lowerQuery) ||
        task.description.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}
