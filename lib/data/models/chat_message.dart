class ChatMessage {
  final String id;
  final String content;
  final bool isFromUser;
  final DateTime timestamp;
  final ChatMessageType type;
  final Map<String, dynamic>? commandData;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isFromUser,
    required this.timestamp,
    this.type = ChatMessageType.text,
    this.commandData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isFromUser': isFromUser,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type.toString(),
      'commandData': commandData,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      isFromUser: json['isFromUser'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      type: ChatMessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ChatMessageType.text,
      ),
      commandData: json['commandData'],
    );
  }
}

enum ChatMessageType {
  text,
  command,
  error,
  system,
}

class FitsiCommand {
  final String action;
  final Map<String, dynamic> data;
  final String response;

  FitsiCommand({
    required this.action,
    required this.data,
    required this.response,
  });

  factory FitsiCommand.fromJson(Map<String, dynamic> json) {
    return FitsiCommand(
      action: json['action'],
      data: json['data'],
      response: json['response'],
    );
  }
}
