import 'dart:math';
import 'notification_service.dart';
import 'ai_service.dart';
import 'user_service.dart';

class AIMotivationService {
  static final List<String> _staticMotivations = [
    "Tu es plus forte que tu ne le penses ! ✨",
    "Prends un moment pour respirer aujourd'hui. 🌸",
    "N'oublie pas de t'hydrater, ton corps te remerciera. 💧",
    "Chaque phase de ton cycle est une force différente. 🌙",
    "Tu rayonnes ! Continue comme ça. ☀️",
    "Écoute ton corps, il sait ce dont il a besoin. 🌿",
  ];

  static Future<void> sendDailyMotivation() async {
    final user = UserService.getUser();
    if (user == null || !user.notificationsEnabled) return;

    String message;
    try {
      // Tentative de génération via IA pour plus de personnalisation
      // On utilise un prompt très court pour la notification
      final response = await AIService.generateResponse(
        "Génère une seule phrase courte (max 10 mots) de motivation ou de bien-être pour ma notification du jour, en lien avec ma santé féminine.",
        user,
        [],
      );
      message = response.split('\n').first;
      if (message.length > 100)
        message =
            _staticMotivations[Random().nextInt(_staticMotivations.length)];
    } catch (e) {
      // Fallback sur les messages statiques
      message = _staticMotivations[Random().nextInt(_staticMotivations.length)];
    }

    await NotificationService.showTestNotification(
      title: "AIDA Motivation ✨",
      body: message,
    );
  }
}
