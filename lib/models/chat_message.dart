// models/chat_message.dart
class ChatMessage {
  final bool isUser;
  final String text;
  final DateTime timestamp;
  final String?
  personaId; // optionnel, utile si on mélange dans un futur thread multi-persona

  ChatMessage({
    required this.isUser,
    required this.text,
    DateTime? timestamp,
    this.personaId,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'isUser': isUser,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    if (personaId != null) 'personaId': personaId,
  };

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      isUser: map['isUser'] as bool,
      text: map['text'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      personaId: map['personaId'] as String?,
    );
  }
}
