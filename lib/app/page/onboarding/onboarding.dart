import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:intl/intl.dart';
import '../../../services/user_service.dart';
import '../../../services/period_service.dart';
import '../../../models/user_model.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  int _currentStep = 0;
  bool _isTyping = false;
  final List<ChatMessage> _messages = [];

  // User Data
  String _name = '';
  DateTime? _dateOfBirth;
  DateTime? _lastPeriodDate;
  int _minPeriodLength = 3;
  int _maxPeriodLength = 7;
  int _minCycleLength = 26;
  int _maxCycleLength = 30;

  // UI States
  bool _showInput = false;
  bool _showOptions = false;

  // Palette de couleurs
  static const Color primaryColor = Color(0xFFFF85A1);
  static const Color secondaryColor = Color(0xFF9181F4);
  static const Color accentColor = Color(0xFFFFAACC);
  static const Color backgroundColor = Color(0xFFFDFCFB);
  static const Color textDarkColor = Color(0xFF2D3142);
  static const Color textLightColor = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _startOnboarding();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startOnboarding() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _addBotMessage(
      "Coucou ! Je suis Aida, ton assistante personnelle pour ton cycle. 👋",
      "🌸",
    );
    await Future.delayed(const Duration(seconds: 1));
    _addBotMessage(
      "Prête à mieux comprendre ton corps ? On va commencer par faire connaissance. ✨",
      "🌷",
    );
    await Future.delayed(const Duration(seconds: 1));
    _addBotMessage("Comment dois-je t'appeler ?", "✍️");
    setState(() => _showInput = true);
  }

  void _addBotMessage(String text, String emoji) {
    if (!mounted) return;
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: false,
          timestamp: DateTime.now(),
          emoji: emoji,
        ),
      );
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleUserInput() {
    if (_inputController.text.trim().isEmpty) return;

    final input = _inputController.text.trim();
    _inputController.clear();
    _addUserMessage(input);
    _showInput = false;

    _processStep(input);
  }

  void _processStep(String input) async {
    setState(() => _isTyping = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isTyping = false);

    switch (_currentStep) {
      case 0: // Nom
        _name = input;
        _addBotMessage("Enchantée $_name ! Ravi de te rencontrer. 😍", "✨");
        await Future.delayed(const Duration(seconds: 1));
        _addBotMessage(
          "Quelle est ta date de naissance ? C'est important pour la précision de mes analyses.",
          "🎂",
        );
        setState(() => _currentStep = 1);
        break;
      case 1: // Date de naissance (via picker)
        break;
    }
  }

  void _handleDateSelected(DateTime date) {
    if (_currentStep == 1) {
      _dateOfBirth = date;
    } else if (_currentStep == 2) {
      _lastPeriodDate = date;
    }
    _addUserMessage(DateFormat('dd MMMM yyyy', 'fr_FR').format(date));
    _nextStep();
  }

  void _nextStep() async {
    _currentStep++;
    setState(() => _isTyping = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isTyping = false);

    switch (_currentStep) {
      case 2:
        _addBotMessage(
          "Merci ! Maintenant, dis-moi, quand ont commencé tes dernières règles ?",
          "🩸",
        );
        break;
      case 3:
        _addBotMessage(
          "Et combien de temps durent-elles en moyenne ? Tu peux me donner un intervalle.",
          "⏳",
        );
        break;
      case 4:
        _addBotMessage(
          "Presque fini ! Quelle est la durée habituelle de ton cycle ? (D'habitude entre 25 et 35 jours)",
          "🔄",
        );
        break;
      case 5:
        _addBotMessage(
          "C'est parfait ! Je vais pouvoir te donner des prédictions très précises. ✨",
          "🌈",
        );
        await Future.delayed(const Duration(seconds: 1));
        _addBotMessage(
          "Est-ce que tu veux que je t'envoie des petits rappels pour ton cycle ?",
          "🔔",
        );
        setState(() => _showOptions = true);
        break;
    }
  }

  void _handleOptionSelected(String option) async {
    _addUserMessage(option);
    setState(() => _showOptions = false);

    await Future.delayed(const Duration(seconds: 1));
    _addBotMessage(
      "C'est noté ! Nous sommes maintenant prêtes à commencer. 🚀",
      "💖",
    );
    await Future.delayed(const Duration(seconds: 1));

    _finishOnboarding();
  }

  void _finishOnboarding() async {
    final newUser = UserModel(
      id: "user_main",
      name: _name,
      dateOfBirth: _dateOfBirth,
      minCycleLength: _minCycleLength,
      maxCycleLength: _maxCycleLength,
      averageCycleLength: ((_minCycleLength + _maxCycleLength) / 2).round(),
      minPeriodLength: _minPeriodLength,
      maxPeriodLength: _maxPeriodLength,
      averagePeriodLength: ((_minPeriodLength + _maxPeriodLength) / 2).round(),
      lastPeriodDate: _lastPeriodDate,
      createdAt: DateTime.now(),
    );

    // D'abord sauvegarder l'utilisateur pour que PeriodService puisse y accéder
    await UserService.saveUser(newUser);

    // Puis enregistrer la date des règles comme une Période réelle
    if (_lastPeriodDate != null) {
      await PeriodService.recordPeriod(_lastPeriodDate!);
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/entry');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildProgressBar(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) return _buildTypingIndicator();
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
            _buildInteractionArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [primaryColor, accentColor]),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aida',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDarkColor,
                ),
              ),
              Text(
                'En ligne',
                style: TextStyle(fontSize: 12, color: Color(0xFF4CAF50)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    double progress = (_currentStep + 1) / 7;
    final isSmallScreen = MediaQuery.of(context).size.height < 650;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: isSmallScreen ? 4 : 8,
      ),
      child: LinearPercentIndicator(
        lineHeight: 6.0,
        percent: progress.clamp(0.0, 1.0),
        backgroundColor: Colors.grey[200],
        progressColor: primaryColor,
        barRadius: const Radius.circular(3),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) _buildBotAvatar(message.emoji ?? "🌸"),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? secondaryColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 15,
                  color: message.isUser ? Colors.white : textDarkColor,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 10),
          if (message.isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildBotAvatar(String emoji) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: secondaryColor, size: 20),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _buildBotAvatar("💭"),
          const SizedBox(width: 10),
          const Text(
            "Aida écrit...",
            style: TextStyle(fontSize: 12, color: textLightColor),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionArea() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safePadding = MediaQuery.of(context).padding.bottom;

    Widget? activeWidget;
    if (_showOptions) {
      activeWidget = _buildOptionsButtons();
    } else if (_currentStep == 1 && !_isTyping) {
      activeWidget = _buildScrollingDatePicker(
        initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
        firstDate: DateTime(1950),
        lastDate: DateTime.now(),
        onDateSelected: _handleDateSelected,
      );
    } else if (_currentStep == 2 && !_isTyping) {
      activeWidget = _buildScrollingDatePicker(
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 60)),
        lastDate: DateTime.now(),
        onDateSelected: _handleDateSelected,
      );
    } else if (_currentStep == 3 && !_isTyping) {
      activeWidget = _buildRangeDurationSelector(
        start: _minPeriodLength,
        end: _maxPeriodLength,
        minValue: 1,
        maxValue: 15,
        unit: "jours",
        onChanged: (s, e) => setState(() {
          _minPeriodLength = s;
          _maxPeriodLength = e;
        }),
        onConfirm: _nextStep,
      );
    } else if (_currentStep == 4 && !_isTyping) {
      activeWidget = _buildRangeDurationSelector(
        start: _minCycleLength,
        end: _maxCycleLength,
        minValue: 20,
        maxValue: 45,
        unit: "jours",
        onChanged: (s, e) => setState(() {
          _minCycleLength = s;
          _maxCycleLength = e;
        }),
        onConfirm: _nextStep,
      );
    } else if (_showInput) {
      activeWidget = _buildInputField();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        bottomInset > 0 ? 12 : (safePadding > 0 ? safePadding : 20),
      ),
      child: activeWidget ?? const SizedBox(height: 10),
    );
  }

  Widget _buildOptionsButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          "Oui, bien sûr",
          secondaryColor,
          () => _handleOptionSelected("Oui, bien sûr"),
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          "Peut-être plus tard",
          Colors.grey,
          () => _handleOptionSelected("Peut-être plus tard"),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInputField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _inputController,
            focusNode: _focusNode,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Tape ton nom ici...',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _handleUserInput(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _handleUserInput,
          icon: const Icon(Icons.send, color: secondaryColor),
        ),
      ],
    );
  }

  Widget _buildScrollingDatePicker({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required Function(DateTime) onDateSelected,
  }) {
    DateTime selected = initialDate;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 200,
          child: CupertinoDatePicker(
            initialDateTime: initialDate,
            minimumDate: firstDate,
            maximumDate: lastDate,
            mode: CupertinoDatePickerMode.date,
            use24hFormat: true,
            onDateTimeChanged: (DateTime newDate) {
              selected = newDate;
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          "Enregistrer cette date",
          secondaryColor,
          () => onDateSelected(selected),
        ),
      ],
    );
  }

  Widget _buildRangeDurationSelector({
    required int start,
    required int end,
    required int minValue,
    required int maxValue,
    required String unit,
    required Function(int, int) onChanged,
    required VoidCallback onConfirm,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: primaryColor.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textBaseline: TextBaseline.alphabetic,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  Text(
                    start == end ? '$start' : '$start - $end',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textLightColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                start == end
                    ? "Durée fixe sélectionnée"
                    : "Intervalle de variabilité",
                style: TextStyle(
                  fontSize: 13,
                  color: primaryColor.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 12,
                  activeTrackColor: primaryColor,
                  inactiveTrackColor: primaryColor.withOpacity(0.1),
                  rangeThumbShape: const RoundRangeSliderThumbShape(
                    enabledThumbRadius: 14,
                    elevation: 5,
                  ),
                  overlayColor: primaryColor.withOpacity(0.2),
                  rangeTickMarkShape: const RoundRangeSliderTickMarkShape(
                    tickMarkRadius: 2,
                  ),
                  activeTickMarkColor: Colors.white.withOpacity(0.5),
                ),
                child: RangeSlider(
                  values: RangeValues(start.toDouble(), end.toDouble()),
                  min: minValue.toDouble(),
                  max: maxValue.toDouble(),
                  divisions: maxValue - minValue,
                  onChanged: (values) {
                    onChanged(values.start.round(), values.end.round());
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$minValue $unit',
                      style: const TextStyle(
                        color: textLightColor,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '$maxValue $unit',
                      style: const TextStyle(
                        color: textLightColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildActionButton(
          "Confirmer cet intervalle",
          secondaryColor,
          onConfirm,
        ),
      ],
    );
  }

  Widget _buildSimpleRoundButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: onTap == null
              ? Colors.grey[200]
              : primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: onTap == null ? Colors.grey[400] : primaryColor,
          size: 24,
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? emoji;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.emoji,
  });
}
