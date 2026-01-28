// pages/chat_list_page.dart
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../models/chat_thread.dart';
import '../services/chat_service.dart';
import '../core/theme_colors.dart';
import 'ai_coach_chat_page.dart';
import '../widgets/chat_thread_tile.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<ChatThread> _threads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  Future<void> _loadThreads() async {
    final threads = ChatService.getAllThreads();
    // Sort threads by last message time (most recent first)
    threads.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

    if (mounted) {
      setState(() {
        _threads = threads;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteThread(ChatThread thread) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la discussion ?'),
        content: const Text(
          'Toute l\'histoire avec ce persona sera effacée pour toujours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final updatedThreads = _threads.where((t) => t.id != thread.id).toList();
      await ChatService.saveThreads(updatedThreads);
      _loadThreads();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Tes discussions",
          style: TextStyle(
            color: ThemeColors.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _threads.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadThreads,
              child: ListView.separated(
                itemCount: _threads.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 80,
                  endIndent: 20,
                  color: ThemeColors.getBorderColor(context).withOpacity(0.5),
                ),
                itemBuilder: (context, index) {
                  final thread = _threads[index];
                  return Dismissible(
                    key: Key(thread.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(IconlyBold.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      await _deleteThread(thread);
                      return false; // UI handling in _deleteThread
                    },
                    child: ChatThreadTile(
                      thread: thread,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AiCoachChatPage(initialThread: thread),
                        ),
                      ).then((_) => _loadThreads()),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconlyLight.chat,
              size: 80,
              color: ThemeColors.getPrimaryColor(context).withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              "Aucune conversation",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeColors.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Choisis une amie AIDA pour commencer à discuter !",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ThemeColors.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
