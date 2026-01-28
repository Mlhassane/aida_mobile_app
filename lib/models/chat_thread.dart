import 'chat_message.dart';

class ChatThread {
  final String id;
  final String personaId;
  final String title;
  final DateTime lastMessageTime;
  final List<ChatMessage> messages;
  final int unreadCount;

  ChatThread({
    required this.id,
    required this.personaId,
    required this.title,
    required this.lastMessageTime,
    required this.messages,
    this.unreadCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personaId': personaId,
      'title': title,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'messages': messages.map((m) => m.toMap()).toList(),
      'unreadCount': unreadCount,
    };
  }

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    return ChatThread(
      id: json['id'] as String,
      personaId: json['personaId'] as String? ?? 'bestie',
      title: json['title'] as String,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      messages: (json['messages'] as List)
          .map((e) => ChatMessage.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }

  static ChatThread createNew({
    required String personaId,
    String title = 'Nouvelle discussion',
  }) {
    return ChatThread(
      id: 'thread_$personaId', // Using predictable ID for per-persona threads as in current logic
      personaId: personaId,
      title: title,
      lastMessageTime: DateTime.now(),
      messages: [],
      unreadCount: 0,
    );
  }

  ChatThread copyWith({
    String? personaId,
    String? title,
    DateTime? lastMessageTime,
    List<ChatMessage>? messages,
    int? unreadCount,
  }) {
    return ChatThread(
      id: id,
      personaId: personaId ?? this.personaId,
      title: title ?? this.title,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
