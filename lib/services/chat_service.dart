import 'hive_service.dart';
import '../models/chat_thread.dart';
import '../models/chat_message.dart';
import '../models/ai_persona.dart';

class ChatService {
  static const String threadsKey =
      'chatThreads_v4'; // Version 4 for ChatMessage model
  static const String activePersonaIdKey = 'activePersonaId';

  static List<ChatThread> getAllThreads() {
    final box = HiveService.chatBox;
    final data = box.get(threadsKey, defaultValue: []);
    List<ChatThread> threads = [];

    if (data is List) {
      threads = data
          .map((e) => ChatThread.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    // Ensure all default personas have a thread
    bool updated = false;
    for (var persona in AIPersona.defaultPersonas) {
      final threadId = 'thread_${persona.id}';
      if (!threads.any((t) => t.id == threadId)) {
        threads.add(
          ChatThread.createNew(personaId: persona.id, title: persona.name),
        );
        updated = true;
      }
    }

    if (updated) {
      saveThreads(threads);
    }

    return threads;
  }

  static Future<void> saveThreads(List<ChatThread> threads) async {
    final box = HiveService.chatBox;
    final jsonThreads = threads.map((t) => t.toJson()).toList();
    await box.put(threadsKey, jsonThreads);
  }

  static String getActivePersonaId() {
    final box = HiveService.chatBox;
    return box.get(activePersonaIdKey, defaultValue: 'bestie');
  }

  static Future<void> setActivePersonaId(String id) async {
    final box = HiveService.chatBox;
    await box.put(activePersonaIdKey, id);
  }

  static Future<ChatThread> getThreadForPersona(String personaId) async {
    final threads = getAllThreads();
    final threadId = 'thread_$personaId';

    final existingIndex = threads.indexWhere((t) => t.id == threadId);
    if (existingIndex != -1) {
      return threads[existingIndex];
    }

    // Si le thread n'existe pas, on le crée
    final newThread = ChatThread.createNew(
      personaId: personaId,
      title: personaId,
    );
    threads.add(newThread);
    await saveThreads(threads);
    return newThread;
  }

  static Future<void> saveMessage(String personaId, ChatMessage message) async {
    final threads = getAllThreads();
    final threadId = 'thread_$personaId';
    final index = threads.indexWhere((t) => t.id == threadId);

    if (index != -1) {
      final thread = threads[index];
      final updatedMessages = List<ChatMessage>.from(thread.messages)
        ..add(message);
      threads[index] = thread.copyWith(
        messages: updatedMessages,
        lastMessageTime: DateTime.now(),
      );
      await saveThreads(threads);
    } else {
      // Create if doesn't exist (safety)
      final newThread = ChatThread.createNew(
        personaId: personaId,
        title: personaId,
      ).copyWith(messages: [message], lastMessageTime: DateTime.now());
      threads.add(newThread);
      await saveThreads(threads);
    }
  }

  static Future<void> clearHistory() async {
    final box = HiveService.chatBox;
    await box.delete(threadsKey);
  }
}
