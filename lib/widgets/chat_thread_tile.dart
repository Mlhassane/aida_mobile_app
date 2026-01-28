// widgets/chat_thread_tile.dart
import 'package:flutter/material.dart';
import '../models/chat_thread.dart';
import '../models/ai_persona.dart';
import '../core/theme_colors.dart';

class ChatThreadTile extends StatelessWidget {
  final ChatThread thread;
  final VoidCallback onTap;

  const ChatThreadTile({super.key, required this.thread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final persona = AIPersona.defaultPersonas.firstWhere(
      (p) => p.id == thread.personaId,
      orElse: () => AIPersona.defaultPersonas.first,
    );

    final lastMsg = thread.messages.isNotEmpty ? thread.messages.last : null;
    final timeStr = lastMsg != null ? _formatTime(lastMsg.timestamp) : '';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: persona.color.withOpacity(0.5), width: 2),
        ),
        child: CircleAvatar(
          backgroundColor: persona.color.withOpacity(0.1),
          radius: 28,
          child: Text(persona.avatar, style: const TextStyle(fontSize: 24)),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            persona.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 12,
              color: ThemeColors.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                lastMsg?.text ?? "Commencez la discussion...",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ThemeColors.getSecondaryTextColor(context),
                  fontSize: 14,
                ),
              ),
            ),
            if (thread.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ThemeColors.getPrimaryColor(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${thread.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.day == yesterday.day &&
        dt.month == yesterday.month &&
        dt.year == yesterday.year) {
      return "Hier";
    }
    return "${dt.day}/${dt.month}/${dt.year.toString().substring(2)}";
  }
}
