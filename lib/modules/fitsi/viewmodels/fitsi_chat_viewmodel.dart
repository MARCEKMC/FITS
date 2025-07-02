import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../../../services/fitsi_service.dart';
import '../../../data/models/chat_message.dart';

class FitsiChatViewModel extends ChangeNotifier {
  final FitsiService _fitsiService = FitsiService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  
  // Callback para notificar cuando se agrega contenido
  Function()? _onContentAdded;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  
  // Configurar callback para cuando se agrega contenido
  void setOnContentAddedCallback(Function()? callback) {
    _onContentAdded = callback;
  }

  // Inicializar el chat
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _loadChatHistory();
    
    // Mensaje de bienvenida si no hay historial
    if (_messages.isEmpty) {
      _addFitsiMessage(
        '¡Hola! Soy Fitsi, tu asistente personal de salud y bienestar 😊\n\n'
        'Puedo ayudarte con:\n'
        '• Agregar notas y tareas\n'
        '• Registrar comidas\n'
        '• Crear ejercicios personalizados\n'
        '• Analizar tu progreso\n'
        '• ¡Y mucho más!\n\n'
        '¿En qué te puedo ayudar hoy?'
      );
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  // Enviar mensaje al chat
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Agregar mensaje del usuario
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      content: content.trim(),
      isFromUser: true,
      timestamp: DateTime.now(),
    );
    
    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      // Obtener respuesta de Fitsi
      final response = await _fitsiService.chat(content);
      
      // Agregar respuesta de Fitsi
      final fitsiMessage = ChatMessage(
        id: const Uuid().v4(),
        content: response['response'] ?? 'No pude procesar tu mensaje.',
        isFromUser: false,
        timestamp: DateTime.now(),
        type: response['action'] != null ? ChatMessageType.command : ChatMessageType.text,
        commandData: response['action'] != null ? response : null,
      );
      
      _messages.add(fitsiMessage);
      
      // Si se ejecutó una acción (nota, tarea, etc.), notificar para actualizar
      if (response['action'] != null) {
        print('🔄 FitsiChatViewModel: Acción ejecutada, notificando actualización');
        _onContentAdded?.call();
      }
      
      // Guardar historial
      await _saveChatHistory();
      
    } catch (e) {
      // Agregar mensaje de error
      _addFitsiMessage(
        'Ups, tuve un problemita técnico 😅 ¿Puedes intentar de nuevo?',
        type: ChatMessageType.error,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar mensaje de Fitsi
  void _addFitsiMessage(String content, {ChatMessageType type = ChatMessageType.text}) {
    final message = ChatMessage(
      id: const Uuid().v4(),
      content: content,
      isFromUser: false,
      timestamp: DateTime.now(),
      type: type,
    );
    
    _messages.add(message);
  }

  // Limpiar chat
  Future<void> clearChat() async {
    _messages.clear();
    await _saveChatHistory();
    
    // Agregar mensaje de bienvenida nuevamente
    _addFitsiMessage(
      '¡Chat limpio! 🧹✨\n¿En qué puedo ayudarte ahora?'
    );
    
    notifyListeners();
  }

  // Guardar historial del chat
  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _messages.map((msg) => msg.toJson()).toList();
      await prefs.setString('fitsi_chat_history', jsonEncode(historyJson));
    } catch (e) {
      print('❌ Error guardando historial: $e');
    }
  }

  // Cargar historial del chat
  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyString = prefs.getString('fitsi_chat_history');
      
      if (historyString != null) {
        final historyJson = jsonDecode(historyString) as List;
        _messages.clear();
        _messages.addAll(
          historyJson.map((json) => ChatMessage.fromJson(json)).toList()
        );
        
        // Limitar a los últimos 50 mensajes para performance
        if (_messages.length > 50) {
          _messages.removeRange(0, _messages.length - 50);
        }
      }
    } catch (e) {
      print('❌ Error cargando historial: $e');
      _messages.clear();
    }
  }

  // Comandos rápidos predefinidos
  Future<void> sendQuickCommand(String command) async {
    switch (command) {
      case 'health_report':
        await sendMessage('Genera un reporte de mi salud actual');
        break;
      case 'productivity_report':
        await sendMessage('Analiza mi productividad y organización');
        break;
      case 'add_water':
        await sendMessage('Registra un vaso de agua');
        break;
      case 'motivate':
        await sendMessage('Dame motivación para hoy');
        break;
    }
  }

  // Obtener sugerencias de comandos
  List<String> getCommandSuggestions() {
    return [
      'Agregar nota: ',
      'Agregar tarea: ',
      'Comí: ',
      'Crear ejercicio de pecho',
      'Crear ejercicio de piernas',
      'Crear ejercicio de espalda',
      '¿Cómo está mi alimentación?',
      '¿Qué ejercicio me recomiendas?',
      'Dame un reporte de salud',
      'Analiza mi productividad',
    ];
  }
}
