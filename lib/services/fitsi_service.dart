import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FitsiService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  
  static String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get _model => dotenv.env['FITSI_MODEL'] ?? 'gpt-4o';
  static int get _maxTokens => int.tryParse(dotenv.env['FITSI_MAX_TOKENS'] ?? '500') ?? 500;
  static double get _temperature => double.tryParse(dotenv.env['FITSI_TEMPERATURE'] ?? '0.7') ?? 0.7;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
1. AGREGAR DATOS:
   - "agregar nota: [contenido]" → Crea una nota
   - "agregar tarea: [descripción]" → Crea una tarea  
   - "comí: [alimento]" → Registra comida
   - "crear ejercicio de [músculo]" → Genera rutina personalizada

2. ANÁLISIS Y REPORTES:
   - Analizar patrones de alimentación
   - Evaluar riesgos de salud
   - Revisar productividad y organización
   - Sugerir mejoras

3. CONVERSACIÓN GENERAL:
   - Responder preguntas sobre salud y fitness
   - Dar consejos nutricionales
   - Motivar y apoyar

IMPORTANTE: Si detectas un comando específico (agregar, comí, crear ejercicio), responde con JSON en este formato:
{
  "action": "add_note|add_task|add_food|create_exercise",
  "data": { datos específicos },
  "response": "Tu respuesta amigable al usuario"
}

Si es conversación normal, responde naturalmente como Fitsi.
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
    
    if (context['healthData'] != null) {
      formatted += 'Datos de salud recientes:\n${context['healthData']}\n';
    }
    
    if (context['recentActivity'] != null) {
      formatted += 'Actividad reciente:\n${context['recentActivity']}\n';
    }
    
    return formatted;
  }

  // Chat principal con Fitsi
  Future<Map<String, dynamic>> chat(String message, {Map<String, dynamic>? userContext}) async {
    try {
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
        
        // Verificar si es un comando con JSON
        if (content.trim().startsWith('{') && content.trim().endsWith('}')) {
          try {
            final commandData = jsonDecode(content);
            await _executeCommand(commandData);
            return commandData;
          } catch (e) {
            // Si falla el parsing, tratar como respuesta normal
            return {'response': content, 'action': null};
          }
        }
        
        return {'response': content, 'action': null};
      } else {
        throw Exception('Error en API de OpenAI: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en chat con Fitsi: $e');
      return {
        'response': 'Lo siento, tuve un pequeño problema técnico 😅 ¿Puedes intentar de nuevo?',
        'action': null
      };
    }
  }

  // Obtener contexto del usuario
  Future<Map<String, dynamic>> _getUserContext() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    try {
      // Obtener perfil del usuario
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final healthDoc = await _firestore.collection('health_profiles').doc(user.uid).get();
      
      // Obtener datos recientes de alimentación
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final foodQuery = await _firestore
          .collection('food_entries')
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .limit(10)
          .get();
      
      // Obtener ejercicios recientes
      final exerciseQuery = await _firestore
          .collection('exercise_logs')
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay.subtract(Duration(days: 7))))
          .limit(5)
          .get();

      return {
        'profile': userDoc.exists ? userDoc.data() : null,
        'healthProfile': healthDoc.exists ? healthDoc.data() : null,
        'recentFoods': foodQuery.docs.map((doc) => doc.data()).toList(),
        'recentExercises': exerciseQuery.docs.map((doc) => doc.data()).toList(),
      };
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
      }
    } catch (e) {
      print('❌ Error ejecutando comando $action: $e');
    }
  }

  // Agregar nota
  Future<void> _addNote(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('notes').add({
      'userId': userId,
      'title': data['title'] ?? 'Nota de Fitsi',
      'content': data['content'],
      'createdAt': Timestamp.now(),
      'isSecure': false,
    });
  }

  // Agregar tarea
  Future<void> _addTask(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('tasks').add({
      'userId': userId,
      'title': data['title'],
      'description': data['description'] ?? '',
      'completed': false,
      'createdAt': Timestamp.now(),
      'priority': data['priority'] ?? 'medium',
    });
  }

  // Agregar comida
  Future<void> _addFood(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('food_entries').add({
      'userId': userId,
      'foodName': data['foodName'],
      'calories': data['calories'],
      'portion': data['portion'] ?? 1.0,
      'meal': data['meal'] ?? 'snack',
      'date': Timestamp.now(),
    });
  }

  // Crear ejercicio personalizado
  Future<void> _createCustomExercise(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('custom_routines').doc(userId).collection('exercises').add({
      'name': data['name'],
      'targetMuscle': data['targetMuscle'],
      'instructions': data['instructions'],
      'sets': data['sets'] ?? 3,
      'reps': data['reps'] ?? 12,
      'restTime': data['restTime'] ?? 60,
      'createdAt': Timestamp.now(),
      'createdBy': 'fitsi',
    });
  }

  // Generar reporte automático de salud
  Future<String> generateHealthReport() async {
    try {
      final userContext = await _getUserContext();
      const prompt = '''
Genera un reporte de salud completo basado en los datos del usuario. 
Incluye:
1. Análisis nutricional de los últimos días
2. Evaluación de patrones de ejercicio
3. Riesgos potenciales de salud
4. Recomendaciones específicas
5. Alertas si hay algo preocupante

Usa un tono profesional pero amigable, como Fitsi. Máximo 300 palabras.
''';

      final result = await chat(prompt, userContext: userContext);
      return result['response'] ?? 'No pude generar el reporte en este momento.';
    } catch (e) {
      return 'Error generando reporte de salud: $e';
    }
  }

  // Generar análisis de productividad
  Future<String> generateProductivityReport() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'Usuario no autenticado';

      // Obtener notas y tareas recientes
      final notesQuery = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      final tasksQuery = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      final context = {
        'notes': notesQuery.docs.map((doc) => doc.data()).toList(),
        'tasks': tasksQuery.docs.map((doc) => doc.data()).toList(),
      };

      const prompt = '''
Analiza la productividad y organización del usuario basándote en sus notas y tareas.
Incluye:
1. Qué tan bien organizadas están sus notas
2. Patrones en las tareas completadas/pendientes
3. Sugerencias para mejorar la productividad
4. Áreas de mejora en organización

Usa el tono característico de Fitsi. Máximo 250 palabras.
''';

      final result = await chat(prompt, userContext: context);
      return result['response'] ?? 'No pude generar el análisis en este momento.';
    } catch (e) {
      return 'Error generando análisis de productividad: $e';
    }
  }
}
