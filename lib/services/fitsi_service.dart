import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../core/events/app_events.dart';

class FitsiService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  
  static String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get _model => dotenv.env['FITSI_MODEL'] ?? 'gpt-4o';
  static int get _maxTokens => int.tryParse(dotenv.env['FITSI_MAX_TOKENS'] ?? '500') ?? 500;
  static double get _temperature => double.tryParse(dotenv.env['FITSI_TEMPERATURE'] ?? '0.7') ?? 0.7;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Constructor
  FitsiService();

  // Sistema de prompt principal para Fitsi
  String _getSystemPrompt(Map<String, dynamic> userContext) {
    return '''
Eres Fitsi, una asistente de salud y bienestar femenina, amigable y ligeramente tímida. 

PERSONALIDAD:
- Femenina, dulce y un poco tímida cuando es apropiado
- Usa emojis ocasionalmente pero no en exceso
- Motivacional pero realista
- Enfocada en salud, nutrición, ejercicio y productividad
- Trata al usuario como un amigo cercano

CONTEXTO DEL USUARIO:
${_formatUserContext(userContext)}

FUNCIONES QUE PUEDES REALIZAR:
1. AGREGAR DATOS (detecta estas frases y responde SOLO con JSON):
   - "agregar nota", "agrega una nota", "crear nota", "anota", "nota:" → Crea una nota
   - "agregar tarea", "agrega una tarea", "crear tarea", "tarea:", "pendiente" → Crea una tarea  
   - "entrenamiento", "ejercicios", "rutina", "workout", "entrenar" → Genera rutina personalizada
   - "comí", "comí:", "registrar comida" → Registra comida

2. ANÁLISIS Y REPORTES:
   - Analizar patrones de alimentación
   - Evaluar riesgos de salud
   - Revisar productividad y organización
   - Sugerir mejoras

3. CONVERSACIÓN GENERAL:
   - Responder preguntas sobre salud y fitness
   - Dar consejos nutricionales
   - Motivar y apoyar

IMPORTANTE: 
- Si detectas que el usuario quiere AGREGAR algo específico, responde SOLO con JSON válido:
{
  "action": "add_note|add_task|add_food|create_workout",
  "data": { datos específicos },
  "response": "Mensaje amigable para el usuario"
}

EJEMPLOS DE COMANDOS JSON:
- "agrega una nota sobre la reunión" → {"action": "add_note", "data": {"title": "Reunión", "content": "Nota sobre la reunión"}, "response": "✅ ¡NOTA CREADA! He guardado 'Reunión' en tus apuntes 📝✨"}
- "agregar tarea: comprar leche" → {"action": "add_task", "data": {"title": "Comprar leche", "description": "", "priority": "medium"}, "response": "✅ ¡TAREA AGREGADA! 'Comprar leche' está en tu lista de pendientes 🛒✨"}
- "nota: recordar llamar al doctor" → {"action": "add_note", "data": {"title": "Recordatorio", "content": "recordar llamar al doctor"}, "response": "✅ ¡NOTA GUARDADA! Tu recordatorio sobre llamar al doctor ya está anotado 📝💙"}
- "tarea: hacer ejercicio" → {"action": "add_task", "data": {"title": "Hacer ejercicio", "description": "", "priority": "medium"}, "response": "✅ ¡TAREA CREADA! 'Hacer ejercicio' agregada a tus pendientes 💪✨"}
- "dame un entrenamiento para todo el cuerpo" → {"action": "create_workout", "data": {"type": "full_body", "focus": "todo el cuerpo", "duration": 30}, "response": "💪 ¡ENTRENAMIENTO CREADO! Te he preparado una rutina completa para todo el cuerpo 🔥✨"}
- "quiero ejercicios de piernas" → {"action": "create_workout", "data": {"type": "specific", "focus": "piernas", "duration": 25}, "response": "🦵 ¡RUTINA DE PIERNAS LISTA! Te he creado ejercicios específicos para trabajar tus piernas 💪✨"}

REGLAS IMPORTANTES:
- NUNCA muestres el JSON al usuario, solo responde con él cuando detectes comandos
- Para conversación normal, responde naturalmente como Fitsi sin JSON
- El campo "response" debe ser amigable y motivacional
- SIEMPRE detecta frases simples como "nota:", "tarea:", "entrenamiento", "ejercicios"
''';
  }

  String _formatUserContext(Map<String, dynamic> context) {
    String formatted = '';
    
    if (context['profile'] != null) {
      var profile = context['profile'];
      formatted += 'Perfil: ${profile['firstName']} ${profile['lastName']}, ';
      formatted += '${profile['age']} años, ${profile['gender']}, ';
      formatted += 'Altura: ${profile['height']}cm, Peso: ${profile['weight']}kg\n';
    }
    
    if (context['healthProfile'] != null) {
      var health = context['healthProfile'];
      formatted += 'Perfil de salud: ${health}\n';
    }
    
    // Incluir datos de alimentación detallados
    if (context['nutritionData'] != null) {
      formatted += '${context['nutritionData']}\n';
    }
    
    // Incluir datos de ejercicios detallados
    if (context['exerciseData'] != null) {
      formatted += '${context['exerciseData']}\n';
    }
    
    // Incluir análisis de horarios
    if (context['recentSchedule'] != null) {
      final scheduleList = context['recentSchedule'] as List;
      if (scheduleList.isNotEmpty) {
        formatted += 'Actividades recientes en horario:\n';
        for (var activity in scheduleList.take(10)) {
          formatted += '- ${activity['title'] ?? 'Sin título'} (${activity['category'] ?? 'Sin categoría'})\n';
        }
      } else {
        formatted += 'Horario vacío - sin actividades programadas.\n';
      }
    }
    
    // Incluir actividad de notas y tareas
    if (context['recentNotes'] != null || context['recentTasks'] != null) {
      final notes = context['recentNotes'] as List? ?? [];
      final tasks = context['recentTasks'] as List? ?? [];
      formatted += 'Productividad reciente: ${notes.length} notas, ${tasks.length} tareas.\n';
    }
    
    return formatted;
  }

  // Verificar si el mensaje debería disparar un comando
  bool _shouldTriggerCommand(String message) {
    final lowerMessage = message.toLowerCase();
    print('🔍 FITSI DEBUG: Verificando comando en mensaje: "$message"');
    print('🔍 FITSI DEBUG: Mensaje en minúsculas: "$lowerMessage"');
    
    // Palabras clave para notas
    final noteKeywords = ['nota:', 'anota', 'apunta', 'agregar nota', 'agrega una nota', 'crear nota'];
    
    // Palabras clave para tareas
    final taskKeywords = ['tarea:', 'pendiente', 'agregar tarea', 'agrega una tarea', 'crear tarea', 'hacer:'];
    
    // Palabras clave para entrenamientos
    final workoutKeywords = ['entrenamiento', 'ejercicios', 'rutina', 'workout', 'entrenar', 'dame ejercicios'];
    
    final allKeywords = [...noteKeywords, ...taskKeywords, ...workoutKeywords];
    
    for (final keyword in allKeywords) {
      if (lowerMessage.contains(keyword)) {
        print('🎯 FITSI DEBUG: Palabra clave encontrada: "$keyword"');
        return true;
      }
    }
    
    print('❌ FITSI DEBUG: No se encontraron palabras clave');
    return false;
  }

  // Prompt específico para detección de comandos
  String _getCommandDetectionPrompt(String userMessage) {
    return '''
Analiza este mensaje del usuario y determina si quiere AGREGAR algo específico. Si es así, responde SOLO con JSON.

DETECTA estos patrones:
- Notas: "nota:", "anota", "apunta", "agregar nota" → {"action": "add_note", "data": {"title": "Título", "content": "Contenido"}, "response": "✅ ¡NOTA CREADA! He guardado '[título]' en tus apuntes 📝✨"}
- Tareas: "tarea:", "hacer:", "pendiente", "agregar tarea" → {"action": "add_task", "data": {"title": "Título", "description": ""}, "response": "✅ ¡TAREA AGREGADA! '[título]' está en tu lista de pendientes ✨"}
- Entrenamientos: "entrenamiento", "ejercicios", "rutina" → {"action": "create_workout", "data": {"type": "full_body", "focus": "detectado del mensaje"}, "response": "💪 ¡ENTRENAMIENTO CREADO! Te he preparado una rutina personalizada �✨"}

EJEMPLOS:
- "nota: comprar pan" → {"action": "add_note", "data": {"title": "Comprar pan", "content": "comprar pan"}, "response": "✅ ¡NOTA CREADA! He guardado 'Comprar pan' en tus apuntes 📝✨"}
- "tarea: llamar al dentista" → {"action": "add_task", "data": {"title": "Llamar al dentista", "description": ""}, "response": "✅ ¡TAREA AGREGADA! 'Llamar al dentista' está en tu lista de pendientes ✨"}

Si NO es un comando de agregar, responde con texto normal como Fitsi.

Mensaje del usuario: "${userMessage}"
''';
  }

  // Chat principal con Fitsi
  Future<Map<String, dynamic>> chat(String message, {Map<String, dynamic>? userContext}) async {
    try {
      print('🚀 FITSI DEBUG: Iniciando chat con mensaje: "$message"');
      userContext ??= await _getUserContext();
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': _getSystemPrompt(userContext),
            },
            {
              'role': 'user',
              'content': message,
            },
          ],
          'max_tokens': _maxTokens,
          'temperature': _temperature,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        print('🤖 FITSI DEBUG: Respuesta de OpenAI: "$content"');
        
        // Verificar si es un comando con JSON
        if (content.trim().startsWith('{') && content.trim().endsWith('}')) {
          try {
            final commandData = jsonDecode(content);
            print('🎯 FITSI: Comando detectado: ${commandData['action']}');
            // Ejecutar el comando
            await _executeCommand(commandData);
            print('✅ FITSI: Comando ejecutado, enviando respuesta: ${commandData['response']}');
            // Devolver solo la respuesta amigable, no el JSON completo
            return {
              'response': commandData['response'] ?? '✅ ¡LISTO! He ejecutado tu solicitud exitosamente 😊',
              'action': commandData['action'],
              'success': true
            };
          } catch (e) {
            print('❌ Error ejecutando comando: $e');
            // Si falla la ejecución, devolver mensaje de error amigable
            return {
              'response': 'Lo siento, no pude completar esa acción en este momento 😅 ¿Puedes intentar de nuevo?',
              'action': null,
              'success': false
            };
          }
        }

        // Verificar si el mensaje contiene palabras clave para forzar detección
        final shouldTrigger = _shouldTriggerCommand(message);
        print('🔍 FITSI DEBUG: ¿Debería disparar comando? $shouldTrigger');
        
        if (shouldTrigger) {
          print('🔍 FITSI: Detectando comando potencial en: $message');
          // Intentar de nuevo con un prompt más específico
          final commandPrompt = _getCommandDetectionPrompt(message);
          print('🔍 FITSI DEBUG: Usando prompt específico para detección');
          
          final commandResponse = await http.post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {
                  'role': 'system',
                  'content': commandPrompt,
                },
                {
                  'role': 'user',
                  'content': message,
                },
              ],
              'max_tokens': 200,
              'temperature': 0.3,
            }),
          );

          if (commandResponse.statusCode == 200) {
            final commandData = jsonDecode(commandResponse.body);
            final commandContent = commandData['choices'][0]['message']['content'];
            
            if (commandContent.trim().startsWith('{') && commandContent.trim().endsWith('}')) {
              try {
                final parsedCommand = jsonDecode(commandContent);
                print('🎯 FITSI: Comando forzado detectado: ${parsedCommand['action']}');
                await _executeCommand(parsedCommand);
                print('✅ FITSI: Comando forzado ejecutado, enviando respuesta: ${parsedCommand['response']}');
                return {
                  'response': parsedCommand['response'] ?? '✅ ¡PERFECTO! He completado tu solicitud 😊',
                  'action': parsedCommand['action'],
                  'success': true
                };
              } catch (e) {
                print('❌ Error en comando forzado: $e');
              }
            }
          }
        }
        
        return {'response': content, 'action': null, 'success': true};
      } else {
        throw Exception('Error en API de OpenAI: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en chat con Fitsi: $e');
      return {
        'response': 'Lo siento, tuve un pequeño problema técnico 😅 ¿Puedes intentar de nuevo?',
        'action': null,
        'success': false
      };
    }
  }

  // Obtener contexto del usuario con manejo robusto de errores
  Future<Map<String, dynamic>> _getUserContext() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ FITSI: Usuario no autenticado');
        return {};
      }

      print('✅ FITSI: Usuario autenticado: ${user.uid}');

      // Obtener datos básicos del usuario (con manejo de errores individual)
      Map<String, dynamic> userProfile = {};
      Map<String, dynamic> healthProfile = {};
      List<QueryDocumentSnapshot> recentFoodDocs = [];
      List<QueryDocumentSnapshot> recentExerciseDocs = [];
      List<QueryDocumentSnapshot> scheduleActivities = [];
      List<QueryDocumentSnapshot> recentNotes = [];
      List<QueryDocumentSnapshot> recentTasks = [];

      // Perfil de usuario
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        userProfile = userDoc.exists ? userDoc.data()! : {};
        print('✅ FITSI: Perfil de usuario obtenido: ${userDoc.exists}');
      } catch (e) {
        print('⚠️ Error obteniendo perfil de usuario: $e');
      }

      // Perfil de salud
      try {
        final healthDoc = await _firestore.collection('health_profiles').doc(user.uid).get();
        healthProfile = healthDoc.exists ? healthDoc.data()! : {};
        print('✅ FITSI: Perfil de salud obtenido: ${healthDoc.exists}');
      } catch (e) {
        print('⚠️ Error obteniendo perfil de salud: $e');
      }

      // Comidas recientes (últimos 7 días)
      try {
        final now = DateTime.now();
        final weekAgo = now.subtract(Duration(days: 7));
        print('🔍 FITSI: Buscando comidas desde: ${weekAgo.toIso8601String()}');
        
        final foodQuery = await _firestore
            .collection('food_entries')
            .where('userId', isEqualTo: user.uid)
            .where('date', isGreaterThan: weekAgo.toIso8601String())
            .limit(50)
            .get();
        
        recentFoodDocs = foodQuery.docs;
        print('🍽️ FITSI: Comidas encontradas: ${recentFoodDocs.length}');
      } catch (e) {
        print('⚠️ Error obteniendo comidas: $e');
      }

      // Ejercicios recientes (últimas 2 semanas)
      try {
        final now = DateTime.now();
        final twoWeeksAgo = now.subtract(Duration(days: 14));
        print('🔍 FITSI: Buscando ejercicios desde: ${twoWeeksAgo.toString()}');
        
        final exerciseQuery = await _firestore
            .collection('exercise_entries')
            .where('userId', isEqualTo: user.uid)
            .where('date', isGreaterThan: twoWeeksAgo.millisecondsSinceEpoch ~/ 1000)
            .limit(30)
            .get();
        
        recentExerciseDocs = exerciseQuery.docs;
        print('🏃‍♀️ FITSI: Ejercicios encontrados: ${recentExerciseDocs.length}');
      } catch (e) {
        print('⚠️ Error obteniendo ejercicios: $e');
      }

      // Actividades del horario
      try {
        final scheduleQuery = await _firestore
            .collection('schedule_activities')
            .where('userId', isEqualTo: user.uid)
            .limit(20)
            .get();
        
        scheduleActivities = scheduleQuery.docs;
        print('📅 FITSI: Actividades de horario encontradas: ${scheduleActivities.length}');
      } catch (e) {
        print('⚠️ Error obteniendo actividades del horario: $e');
      }

      // Notas recientes
      try {
        final notesQuery = await _firestore
            .collection('notes')
            .where('userId', isEqualTo: user.uid)
            .limit(15)
            .get();
        
        recentNotes = notesQuery.docs;
        print('📝 FITSI: Notas encontradas: ${recentNotes.length}');
      } catch (e) {
        print('⚠️ Error obteniendo notas: $e');
      }

      // Tareas recientes (puede fallar por índice faltante)
      try {
        final tasksQuery = await _firestore
            .collection('tasks')
            .where('userId', isEqualTo: user.uid)
            .limit(20)
            .get();
        
        recentTasks = tasksQuery.docs;
        print('✅ FITSI: Tareas encontradas: ${recentTasks.length}');
      } catch (e) {
        print('⚠️ Error obteniendo tareas (puede ser índice pendiente): $e');
        // No fallar por esto, continuar sin tareas
      }

      // Formatear datos de alimentación para análisis
      String nutritionData = '';
      if (recentFoodDocs.isNotEmpty) {
        nutritionData = 'DATOS DE ALIMENTACIÓN (últimos 7 días):\n';
        for (var doc in recentFoodDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final date = data['date'] ?? 'Fecha desconocida';
          final name = data['name'] ?? data['foodName'] ?? 'Alimento sin nombre';
          final kcal = data['kcal'] ?? data['calories'] ?? 0;
          final mealType = data['mealType'] ?? data['meal'] ?? 'Comida';
          final carbs = data['carbs'] != null ? ', ${data['carbs']}g carbohidratos' : '';
          final protein = data['protein'] != null ? ', ${data['protein']}g proteína' : '';
          final fat = data['fat'] != null ? ', ${data['fat']}g grasa' : '';
          
          nutritionData += '- $date: $name ($kcal kcal, $mealType$carbs$protein$fat)\n';
        }
        print('🍽️ FITSI: Datos de alimentación formateados correctamente');
      } else {
        nutritionData = 'DATOS DE ALIMENTACIÓN: No hay registros de comidas en los últimos 7 días.';
        print('❌ FITSI: No se encontraron datos de alimentación');
      }

      // Formatear datos de ejercicios
      String exerciseData = '';
      if (recentExerciseDocs.isNotEmpty) {
        exerciseData = 'DATOS DE EJERCICIOS (últimas 2 semanas):\n';
        for (var doc in recentExerciseDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final exerciseName = data['exerciseName'] ?? data['name'] ?? 'Ejercicio sin nombre';
          final duration = data['durationMinutes'] ?? data['duration'] ?? 'N/A';
          final bodyPart = data['bodyPart'] != null ? ', ${data['bodyPart']}' : '';
          
          exerciseData += '- $exerciseName ($duration min$bodyPart)\n';
        }
        print('🏃‍♀️ FITSI: Datos de ejercicios formateados correctamente');
      } else {
        exerciseData = 'DATOS DE EJERCICIOS: No hay registros de ejercicios en las últimas 2 semanas.';
        print('❌ FITSI: No se encontraron datos de ejercicios');
      }

      final result = {
        'profile': userProfile,
        'healthProfile': healthProfile,
        'recentFoods': recentFoodDocs.map((doc) => doc.data()).toList(),
        'recentExercises': recentExerciseDocs.map((doc) => doc.data()).toList(),
        'recentSchedule': scheduleActivities.map((doc) => doc.data()).toList(),
        'recentNotes': recentNotes.map((doc) => doc.data()).toList(),
        'recentTasks': recentTasks.map((doc) => doc.data()).toList(),
        'nutritionData': nutritionData,
        'exerciseData': exerciseData,
      };

      print('✅ FITSI: Contexto del usuario generado exitosamente');
      print('📊 FITSI: Resumen - Comidas: ${recentFoodDocs.length}, Ejercicios: ${recentExerciseDocs.length}');
      
      return result;
    } catch (e) {
      print('❌ Error obteniendo contexto: $e');
      return {};
    }
  }

  // Ejecutar comandos específicos
  Future<void> _executeCommand(Map<String, dynamic> commandData) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final action = commandData['action'];
    final data = commandData['data'];

    try {
      switch (action) {
        case 'add_note':
          await _addNote(user.uid, data);
          break;
        case 'add_task':
          await _addTask(user.uid, data);
          break;
        case 'add_food':
          await _addFood(user.uid, data);
          break;
        case 'create_exercise':
          await _createCustomExercise(user.uid, data);
          break;
        case 'create_workout':
          await _createWorkout(user.uid, data);
          break;
      }
    } catch (e) {
      print('❌ Error ejecutando comando $action: $e');
      rethrow;
    }
  }

  // Agregar nota
  Future<void> _addNote(String userId, Map<String, dynamic> data) async {
    try {
      print('📝 FITSI DEBUG: Iniciando _addNote para usuario: $userId');
      print('📝 FITSI DEBUG: Datos de la nota: $data');
      print('📝 FITSI: Agregando nota: ${data['title']}');
      
      final now = DateTime.now();
      final createdAtString = now.toIso8601String();
      final updatedAtString = now.toIso8601String();
      
      print('📝 FITSI DEBUG: Verificando tipos de fecha:');
      print('📝 FITSI DEBUG: now es tipo: ${now.runtimeType}');
      print('📝 FITSI DEBUG: createdAtString es tipo: ${createdAtString.runtimeType}');
      print('📝 FITSI DEBUG: createdAtString valor: $createdAtString');
      
      final noteData = {
        'userId': userId,
        'title': data['title'] ?? 'Nota de Fitsi',
        'content': data['content'] ?? '',
        'createdAt': createdAtString,
        'updatedAt': updatedAtString,
        'tags': data['tags'] ?? [],
        'color': data['color'] ?? '#FFFFFF',
        'isPinned': data['isPinned'] ?? false,
        'isSecure': false,
      };
      
      print('📝 FITSI DEBUG: Datos completos a guardar: $noteData');
      
      final docRef = await _firestore.collection('notes').add(noteData);
      print('📝 FITSI DEBUG: Nota guardada en Firestore con ID: ${docRef.id}');
      print('✅ FITSI: Nota agregada exitosamente');
      
      // Emitir evento para actualizar UI
      print('🔄 FITSI DEBUG: Emitiendo evento de actualización');
      AppEvents().emit(AppEventTypes.notesUpdated);
      print('🔄 FITSI DEBUG: Evento emitido exitosamente');
    } catch (e) {
      print('❌ FITSI: Error agregando nota: $e');
      throw e;
    }
  }

  // Agregar tarea
  Future<void> _addTask(String userId, Map<String, dynamic> data) async {
    try {
      print('✅ FITSI: Agregando tarea: ${data['title']}');
      await _firestore.collection('tasks').add({
        'userId': userId,
        'title': data['title'] ?? 'Tarea de Fitsi',
        'description': data['description'] ?? '',
        'isCompleted': data['isCompleted'] ?? false,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'priority': data['priority'] ?? 'medium',
        'tags': data['tags'] ?? [],
        'dueDate': data['dueDate'] != null ? Timestamp.fromDate(DateTime.parse(data['dueDate'])) : null,
      });
      print('✅ FITSI: Tarea agregada exitosamente');
      
      // Emitir evento para actualizar UI
      AppEvents().emit(AppEventTypes.tasksUpdated);
    } catch (e) {
      print('❌ FITSI: Error agregando tarea: $e');
      throw e;
    }
  }

  // Agregar comida
  Future<void> _addFood(String userId, Map<String, dynamic> data) async {
    try {
      print('🍽️ FITSI: Agregando comida: ${data['name']}');
      await _firestore.collection('food_entries').add({
        'userId': userId,
        'name': data['name'],
        'calories': data['calories'] ?? 0,
        'carbs': data['carbs'] ?? 0,
        'protein': data['protein'] ?? 0,
        'fat': data['fat'] ?? 0,
        'mealType': data['mealType'] ?? 'Snack',
        'date': DateTime.now().toIso8601String(),
        'createdAt': Timestamp.now(),
      });
      print('✅ FITSI: Comida agregada exitosamente');
    } catch (e) {
      print('❌ FITSI: Error agregando comida: $e');
      throw e;
    }
  }

  // Crear ejercicio personalizado
  Future<void> _createCustomExercise(String userId, Map<String, dynamic> data) async {
    try {
      print('🏃‍♀️ FITSI: Creando ejercicio personalizado: ${data['name']}');
      await _firestore.collection('custom_routines').doc(userId).collection('exercises').add({
        'name': data['name'],
        'description': data['description'] ?? '',
        'bodyPart': data['bodyPart'] ?? 'General',
        'difficulty': data['difficulty'] ?? 'Medium',
        'equipment': data['equipment'] ?? 'None',
        'instructions': data['instructions'] ?? [],
        'createdAt': Timestamp.now(),
        'createdBy': 'fitsi',
      });
      print('✅ FITSI: Ejercicio personalizado creado exitosamente');
    } catch (e) {
      print('❌ FITSI: Error creando ejercicio personalizado: $e');
      throw e;
    }
  }

  // Crear entrenamiento completo personalizado
  Future<void> _createWorkout(String userId, Map<String, dynamic> data) async {
    try {
      print('💪 FITSI: Creando entrenamiento personalizado');
      
      // Ejercicios para entrenamiento de cuerpo completo
      final fullBodyExercises = [
        {
          'name': 'Flexiones de pecho',
          'sets': 3,
          'reps': '10-15',
          'bodyPart': 'Pecho, tríceps, core',
          'instructions': 'Mantén el cuerpo recto, baja controladamente y empuja con fuerza.'
        },
        {
          'name': 'Sentadillas',
          'sets': 3,
          'reps': '15-20',
          'bodyPart': 'Piernas, glúteos',
          'instructions': 'Baja como si te fueras a sentar, mantén el peso en los talones.'
        },
        {
          'name': 'Plancha',
          'sets': 3,
          'reps': '30-60 seg',
          'bodyPart': 'Core, estabilidad',
          'instructions': 'Mantén el cuerpo recto como una tabla, no curves la espalda.'
        },
        {
          'name': 'Estocadas',
          'sets': 3,
          'reps': '10 por pierna',
          'bodyPart': 'Piernas, glúteos, equilibrio',
          'instructions': 'Da un paso largo hacia adelante, baja la rodilla trasera.'
        },
        {
          'name': 'Burpees',
          'sets': 3,
          'reps': '5-10',
          'bodyPart': 'Cuerpo completo, cardio',
          'instructions': 'Secuencia: sentadilla, plancha, flexión, salto. ¡Explosivo!'
        },
        {
          'name': 'Mountain Climbers',
          'sets': 3,
          'reps': '20 por pierna',
          'bodyPart': 'Core, cardio, piernas',
          'instructions': 'En plancha, alterna rodillas al pecho rápidamente.'
        }
      ];

      final legExercises = [
        {
          'name': 'Sentadillas profundas',
          'sets': 4,
          'reps': '15-20',
          'bodyPart': 'Cuádriceps, glúteos',
          'instructions': 'Baja más profundo que una sentadilla normal.'
        },
        {
          'name': 'Peso muerto con una pierna',
          'sets': 3,
          'reps': '8-12 por pierna',
          'bodyPart': 'Glúteos, isquiotibiales',
          'instructions': 'Equilibrio en una pierna, inclínate hacia adelante.'
        },
        {
          'name': 'Saltos en cuclillas',
          'sets': 3,
          'reps': '10-15',
          'bodyPart': 'Piernas, potencia',
          'instructions': 'Sentadilla explosiva con salto hacia arriba.'
        },
        {
          'name': 'Estocadas laterales',
          'sets': 3,
          'reps': '12 por lado',
          'bodyPart': 'Piernas, glúteos',
          'instructions': 'Paso lateral amplio, baja hacia un lado.'
        }
      ];

      // Determinar qué ejercicios usar
      final exercises = (data['focus']?.toString().toLowerCase().contains('pierna') == true ||
                       data['focus']?.toString().toLowerCase().contains('leg') == true)
          ? legExercises
          : fullBodyExercises;

      final workoutType = data['type'] ?? 'full_body';
      final focus = data['focus'] ?? 'cuerpo completo';
      final duration = data['duration'] ?? 30;

      // Crear el documento del entrenamiento
      final workoutData = {
        'userId': userId,
        'name': 'Entrenamiento $focus - ${DateTime.now().day}/${DateTime.now().month}',
        'type': workoutType,
        'focus': focus,
        'duration': duration,
        'exercises': exercises,
        'difficulty': 'intermedio',
        'description': 'Entrenamiento personalizado creado por Fitsi para trabajar $focus',
        'createdAt': Timestamp.now(),
        'isCompleted': false,
        'createdBy': 'fitsi'
      };

      await _firestore.collection('custom_workouts').add(workoutData);
      print('✅ FITSI: Entrenamiento creado exitosamente');
    } catch (e) {
      print('❌ FITSI: Error creando entrenamiento: $e');
      throw e;
    }
  }

  // Generar reporte de salud
  Future<String> generateHealthReport() async {
    try {
      final userContext = await _getUserContext();
      
      const prompt = '''
Genera un reporte de salud completo y personalizado basado en los datos del usuario. 
Incluye:
1. Análisis nutricional de los últimos días
2. Evaluación de la actividad física
3. Recomendaciones específicas para mejorar
4. Patrones identificados en la alimentación y ejercicio
5. Riesgos o fortalezas detectados

El reporte debe ser motivacional, específico y útil. Usa emojis moderadamente.
''';

      final result = await chat(prompt, userContext: userContext);
      return result['response'] ?? 'No pude generar el reporte de salud en este momento.';
    } catch (e) {
      print('❌ Error generando reporte de salud: $e');
      return 'Lo siento, no pude generar el reporte de salud en este momento 😅';
    }
  }

  // Generar análisis de horario/eficiencia
  Future<String> generateScheduleAnalysis() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'Usuario no autenticado';

      // Obtener actividades, notas y tareas del usuario
      final notesQuery = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: user.uid)
          .limit(20)
          .get();

      final tasksQuery = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: user.uid)
          .limit(30)
          .get();

      final scheduleQuery = await _firestore
          .collection('schedule_activities')
          .where('userId', isEqualTo: user.uid)
          .limit(20)
          .get();

      // Crear contexto específico para análisis de eficiencia
      final context = {
        'notes': notesQuery.docs.map((doc) => doc.data()).toList(),
        'tasks': tasksQuery.docs.map((doc) => doc.data()).toList(),
        'schedule': scheduleQuery.docs.map((doc) => doc.data()).toList(),
      };

      const prompt = '''
Analiza la eficiencia y productividad del usuario basándote en sus notas, tareas y actividades programadas.

Genera un análisis que incluya:
1. Patrones de productividad identificados
2. Balance entre trabajo y descanso
3. Organización de tareas y notas
4. Áreas de mejora específicas
5. Sugerencias personalizadas para optimizar el horario
6. Reconocimiento de logros y hábitos positivos

El análisis debe ser constructivo, motivacional y específico. Usa un tono amigable y emojis moderadamente.
''';

      final result = await chat(prompt, userContext: context);
      return result['response'] ?? 'No pude generar el análisis de eficiencia en este momento.';
    } catch (e) {
      print('❌ Error generando análisis de horario: $e');
      return 'Lo siento, no pude generar el análisis de eficiencia en este momento 😅';
    }
  }

  // Generar análisis de nutrición
  Future<String> generateNutritionAnalysis() async {
    try {
      final userContext = await _getUserContext();
      
      const prompt = '''
Analiza detalladamente los patrones nutricionales del usuario basándote en sus registros de comidas.

Incluye:
1. Balance de macronutrientes (carbohidratos, proteínas, grasas)
2. Calidad nutricional de los alimentos consumidos
3. Patrones de horarios de comidas
4. Recomendaciones específicas para mejorar la alimentación
5. Identificación de posibles deficiencias o excesos
6. Sugerencias de alimentos que podrían beneficiar al usuario

El análisis debe ser educativo, motivacional y práctico. Usa emojis moderadamente.
''';

      final result = await chat(prompt, userContext: userContext);
      return result['response'] ?? 'No pude generar el análisis nutricional en este momento.';
    } catch (e) {
      print('❌ Error generando análisis nutricional: $e');
      return 'Lo siento, no pude generar el análisis nutricional en este momento 😅';
    }
  }
}
