import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class FirestoreTasksRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

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
      final snapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .get();

      final tasks = snapshot.docs
          .map((doc) => Task.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Sort in memory instead of using Firestore orderBy
      tasks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
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
      taskData.remove('id'); // Remove id from data

      if (task.id.isEmpty) {
        // Create new task - let Firestore generate the ID
        print('Creating new task...');
        final docRef = await _firestore.collection('tasks').add(taskData);
        print('Task created with ID: ${docRef.id}');
      } else {
        // Update existing task
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
      // Verify ownership before deleting
      final doc = await _firestore.collection('tasks').doc(id).get();
      if (doc.exists && doc.data()?['userId'] == userId) {
        await _firestore.collection('tasks').doc(id).delete();
      }
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    if (_userId == null) return;

    try {
      final doc = await _firestore.collection('tasks').doc(id).get();
      if (doc.exists && doc.data()?['userId'] == _userId) {
        final currentStatus = doc.data()?['isCompleted'] ?? false;
        await _firestore.collection('tasks').doc(id).update({
          'isCompleted': !currentStatus,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error toggling task completion: $e');
      rethrow;
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
    final allTasks = await getAllTasks();
    if (query.isEmpty) return allTasks;

    final lowerQuery = query.toLowerCase();
    return allTasks.where((task) =>
        task.title.toLowerCase().contains(lowerQuery) ||
        task.description.toLowerCase().contains(lowerQuery) ||
        task.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))
    ).toList();
  }
}
