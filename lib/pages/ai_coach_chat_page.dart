import 'dart:ui';
import 'package:aida/core/theme_colors.dart';
import 'package:aida/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import '../services/user_service.dart';
import '../services/ai_service.dart';
import '../services/chat_service.dart';
import 'voice_chat_page.dart';
import '../models/chat_thread.dart';
import '../models/ai_persona.dart';

class AiCoachChatPage extends StatefulWidget {
  final ChatThread initialThread;

  const AiCoachChatPage({super.key, required this.initialThread});

  @override
  State<AiCoachChatPage> createState() => _AiCoachChatPageState();
}

class _AiCoachChatPageState extends State<AiCoachChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  late ChatThread _currentThread;
  late AIPersona _activePersona;
  bool _isTyping = false;
  bool _hasText = false;
  String? _suggestedPersonaId;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ThemeData get theme => Theme.of(context);
  bool get isDark => theme.brightness == Brightness.dark;
  Color get primaryColor => _activePersona.color;
  Color get backgroundColor => theme.scaffoldBackgroundColor;
  Color get surfaceColor => theme.cardColor;
  Color get textDarkColor =>
      theme.textTheme.bodyLarge?.color ??
      (isDark ? Colors.white : Colors.black);

  @override
  void initState() {
    super.initState();
    _currentThread = widget.initialThread;
    _activePersona = AIPersona.defaultPersonas.firstWhere(
      (p) => p.id == _currentThread.personaId,
      orElse: () => AIPersona.defaultPersonas.first,
    );
    _messages.addAll(_currentThread.messages);
    _controller.addListener(_onTextChanged);

    // Clear unread count when opening
    if (_currentThread.unreadCount > 0) {
      _markAsRead();
    }

    Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
  }

  void _markAsRead() async {
    final threads = ChatService.getAllThreads();
    final index = threads.indexWhere((t) => t.id == _currentThread.id);
    if (index != -1) {
      threads[index] = _currentThread.copyWith(unreadCount: 0);
      await ChatService.saveThreads(threads);
    }
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.trim().isNotEmpty;
    });
  }

  Future<void> _changePersona(AIPersona persona) async {
    // Dans le nouveau système, changer de persona signifie probablement naviguer vers un autre fil.
    // Mais pour l'instant on garde la logique de "switch" si suggéré.
    await ChatService.setActivePersonaId(persona.id);
    final thread = await ChatService.getThreadForPersona(persona.id);
    if (mounted) {
      setState(() {
        _activePersona = persona;
        _currentThread = thread;
        _messages.clear();
        _messages.addAll(thread.messages);
        _suggestedPersonaId = null;
      });
      Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
    }
  }

  void _addMessage(ChatMessage msg) {
    if (!mounted) return;
    setState(() {
      _messages.add(msg);
    });
    _scrollToBottom();
    ChatService.saveMessage(_activePersona.id, msg);
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    final message = ChatMessage(isUser: true, text: userMessage);
    _addMessage(message);

    _controller.clear();
    setState(() {
      _isTyping = true;
      _suggestedPersonaId = null;
    });
    _scrollToBottom();

    _generateSmartResponse(userMessage);
  }

  void _sendSuggestion(String message) {
    _controller.text = message;
    _sendMessage();
  }

  void _scrollToBottom() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  Future<void> _generateSmartResponse(String query) async {
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final user = UserService.getUser();

      final history = _messages.reversed
          .take(10)
          .toList()
          .reversed
          .map(
            (m) => Content(
              role: m.isUser ? 'user' : 'model',
              parts: [Part.text(m.text)],
            ),
          )
          .toList();

      String aiResponse = await AIService.generateResponse(
        query,
        user,
        history,
        persona: _activePersona,
      );
      String? suggestion;

      // Parsing du switch suggéré
      if (aiResponse.contains('[SUGGEST_SWITCH:')) {
        final regExp = RegExp(r'\[SUGGEST_SWITCH:(\w+)\]');
        final match = regExp.firstMatch(aiResponse);
        if (match != null) {
          suggestion = match.group(1);
          aiResponse = aiResponse.replaceAll(regExp, '').trim();
        }
      }

      if (mounted) {
        setState(() {
          _isTyping = false;
          _suggestedPersonaId = suggestion;
        });
        _addMessage(ChatMessage(isUser: false, text: aiResponse));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTyping = false);
        _generateLocalResponse(query);
      }
    }
  }

  Future<void> _generateLocalResponse(String query) async {
    final lowerQuery = query.toLowerCase();
    String response = '';
    final user = UserService.getUser();

    if (user != null) {
      if (lowerQuery.contains('quand') ||
          lowerQuery.contains('prochaine') ||
          lowerQuery.contains('règle')) {
        if (user.nextPeriodDate != null) {
          final diff = user.nextPeriodDate!.difference(DateTime.now()).inDays;
          final dateStr =
              '${user.nextPeriodDate!.day}/${user.nextPeriodDate!.month}';
          if (diff < 0) {
            response =
                'Tes règles étaient prévues le $dateStr. Si elles ne sont pas arrivées, tu as peut-être du retard. 🩸';
          } else if (diff == 0) {
            response =
                'Tes règles sont prévues aujourd\'hui ! Prends soin de toi. 🌸';
          } else {
            response =
                'Tes prochaines règles sont prévues le $dateStr, soit dans environ $diff jour${diff > 1 ? 's' : ''}.';
          }
        } else {
          response =
              'Je n\'ai pas assez de données pour prédire tes règles. Enregistre-les dans le calendrier ! 📅';
        }
      } else if (lowerQuery.contains('cycle') || lowerQuery.contains('durée')) {
        response =
            'Ton cycle moyen dure ${user.averageCycleLength} jours, et tes règles environ ${user.averagePeriodLength} jours.';
      } else if (lowerQuery.contains('mal') ||
          lowerQuery.contains('douleur') ||
          lowerQuery.contains('symptôme')) {
        response =
            'Je suis désolée que tu ne te sentes pas bien. 😔 Note tes symptômes et repose-toi. Si ça persiste, consulte un professionnel.';
      } else if (lowerQuery.contains('bonjour') ||
          lowerQuery.contains('salut') ||
          lowerQuery.contains('coucou')) {
        response =
            'Bonjour ${user.name.split(' ').first} ! 🌷 Comment puis-je t\'aider aujourd\'hui ?';
      } else {
        response =
            'Je peux t\'aider sur tout ce qui concerne ton cycle. Essaie "Quand arrivent mes règles ?" ou pose-moi tes questions sur tes symptômes !';
      }
    } else {
      response =
          'Je ne te connais pas encore bien. Complète ton profil pour des réponses plus personnalisées ! 💕';
    }

    if (mounted) {
      setState(() => _isTyping = false);
      _addMessage(ChatMessage(isUser: false, text: response));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = UserService.getUser();
    final firstName = user?.name.split(' ').first ?? 'toi';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textDarkColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _activePersona.color.withOpacity(0.2),
              radius: 18,
              child: Text(
                _activePersona.avatar,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _activePersona.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDarkColor,
                    ),
                  ),
                  const Text(
                    'En ligne',
                    style: TextStyle(fontSize: 10, color: Color(0xFF4CAF50)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? _buildIntroState(firstName, size)
                    : _buildChatState(size),
              ),
              if (_suggestedPersonaId != null) _buildSwitchSuggestion(),
              _buildModernInputArea(size),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSuggestion() {
    final suggestedPersona = AIPersona.defaultPersonas.firstWhere(
      (p) => p.id == _suggestedPersonaId,
      orElse: () => AIPersona.defaultPersonas.first,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: suggestedPersona.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: suggestedPersona.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(suggestedPersona.avatar, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Veux-tu demander l'avis de ${suggestedPersona.name} ?",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textDarkColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _changePersona(suggestedPersona),
            style: TextButton.styleFrom(
              backgroundColor: suggestedPersona.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Changer",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _suggestedPersonaId = null),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildIntroState(String name, Size size) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: size.height * 0.1),
          Text(
            'Hello, $name',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            'Comment puis-je t\'aider ?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textDarkColor,
            ),
          ).animate().fadeIn(delay: 200.ms),
          SizedBox(height: size.height * 0.05),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.3,
              children: [
                _buildSuggestionCard(
                  'Analyse des\nsymptômes',
                  Icons.analytics_outlined,
                  () => _sendSuggestion("Peux-tu analyser mes symptômes ?"),
                ),
                _buildSuggestionCard(
                  'Prédiction du\ncycle',
                  Icons.calendar_today_outlined,
                  () =>
                      _sendSuggestion("Quand arrivent mes prochaines règles ?"),
                ),
                _buildSuggestionCard(
                  'Conseils\nbien-être',
                  Icons.lightbulb_outline,
                  () => _sendSuggestion("Donne-moi des conseils bien-être."),
                ),
                _buildSuggestionCard(
                  'Explications\nhormonales',
                  Icons.biotech_outlined,
                  () =>
                      _sendSuggestion("Explique-moi les phases de mon cycle."),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: primaryColor, size: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textDarkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatState(Size size) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            CircleAvatar(
              backgroundColor: _activePersona.color.withOpacity(0.2),
              radius: 16,
              child: Text(
                _activePersona.avatar,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          if (!isUser) const SizedBox(width: 8),

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? ThemeColors.getPrimaryColor(context)
                    : isDark
                    ? const Color(0xFF2C2C2E)
                    : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isUser ? Colors.white : textDarkColor,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _activePersona.color.withOpacity(0.2),
            radius: 16,
            child: Text(
              _activePersona.avatar,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(),
                SizedBox(width: 4),
                _Dot(delay: 200),
                SizedBox(width: 4),
                _Dot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInputArea(Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: ThemeColors.getBorderColor(context),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C1C1E)
                      : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Écris ton message...',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _hasText ? _sendMessage : _openVoiceChat,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeColors.getPrimaryColor(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _hasText ? Icons.send : Icons.mic,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openVoiceChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VoiceChatPage()),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({this.delay = 0});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.3 + (_controller.value * 0.4))
              : Colors.black.withOpacity(0.2 + (_controller.value * 0.3)),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
