import 'dart:async';

class AppEvents {
  static final AppEvents _instance = AppEvents._internal();
  factory AppEvents() => _instance;
  AppEvents._internal();

  final StreamController<String> _eventController = StreamController<String>.broadcast();
  
  Stream<String> get eventStream => _eventController.stream;
  
  void emit(String event) {
    print('🔄 AppEvents: Emitiendo evento: $event');
    _eventController.add(event);
  }
  
  void dispose() {
    _eventController.close();
  }
}

// Eventos disponibles
class AppEventTypes {
  static const String notesUpdated = 'notes_updated';
  static const String tasksUpdated = 'tasks_updated';
  static const String workoutsUpdated = 'workouts_updated';
}
