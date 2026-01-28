import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:logging/logging.dart';
import '../models/user_model.dart';
import '../models/ai_persona.dart';
import 'chat_service.dart';
import 'symptom_service.dart';
import 'journal_service.dart';

class AIService {
  static final Logger _log = Logger('AIService');

  // REMPLACEZ CECI PAR VOTRE CLÉ API GEMINI
  // Obtenez-en une sur : https://makersuite.google.com/app/apikey
  static const String _apiKey = 'AIzaSyAiyecbO3PzMm4Hx71gjTvUhCN1gnyiDJA';

  static void init() {
    Gemini.init(apiKey: _apiKey);
  }

  static Future<String> generateResponse(
    String userMessage,
    UserModel? user,
    List<Content> history, {
    AIPersona? persona,
  }) async {
    try {
      final gemini = Gemini.instance;

      // Récupération de la persona active
      final effectivePersona =
          persona ??
          AIPersona.defaultPersonas.firstWhere(
            (p) => p.id == ChatService.getActivePersonaId(),
            orElse: () => AIPersona.defaultPersonas.first,
          );

      // Construction du prompt système avec le contexte utilisateur
      String systemContext = effectivePersona.systemPrompt;

      // Instructions globales pour la fluidité et concision
      systemContext +=
          '''
\nCONSIGNES DE RÉPONSE CRUCIALES :
1. RÉPONSE COURTE : Ne dépasse JAMAIS 50-60 mots par message, sauf demande explicite.
2. MÉMOIRE PARTAGÉE : Tu as accès à tout l'historique et aux données de l'utilisatrice. Ne fais pas comme si tu ne savais pas ce qui a été dit précédemment à d'autres personas.
3. TON NATUREL : Sois fluide, parle comme une humaine selon ton persona.
4. SWITCH INTELLIGENT : Si la demande de l'utilisatrice correspond MIEUX à une autre persona, termine ton message par cette balise exacte (et rien d'autre après) : [SUGGEST_SWITCH:id_persona] où id_persona est 'bestie', 'expert' ou 'coach'. Ne le fais que si c'est vraiment pertinent.
5. PERSONA : Garde ton rôle de ${effectivePersona.name} à 100%.
''';

      systemContext +=
          '\nInformations sur ta bestie (l\'utilisatrice) :\n- Prénom : ${user?.name ?? 'Copine'}\n';

      if (user != null) {
        if (user.minCycleLength == user.maxCycleLength) {
          systemContext +=
              '- Durée du cycle : ${user.averageCycleLength} jours\n';
        } else {
          systemContext +=
              '- Intervalle du cycle : entre ${user.minCycleLength} et ${user.maxCycleLength} jours\n';
        }

        if (user.minPeriodLength == user.maxPeriodLength) {
          systemContext +=
              '- Durée des règles : ${user.averagePeriodLength} jours\n';
        } else {
          systemContext +=
              '- Intervalle des règles : entre ${user.minPeriodLength} et ${user.maxPeriodLength} jours\n';
        }

        if (user.nextPeriodDate != null) {
          final diff = user.nextPeriodDate!.difference(DateTime.now()).inDays;
          systemContext +=
              '- Prochaines règles estimées vers le : ${user.nextPeriodDate!.day}/${user.nextPeriodDate!.month} (dans environ $diff jours)\n';
        }

        if (user.lastPeriodDate != null) {
          systemContext +=
              '- Dernières règles le : ${user.lastPeriodDate!.day}/${user.lastPeriodDate!.month}\n';
        }

        // --- NOUVEAU : CONNEXION AUX SYMPTÔMES (Si autorisé) ---
        if (user.allowAiSymptoms) {
          // On prend les 5 derniers jours pour avoir un contexte récent, ou les symptômes du jour
          final recentSymptoms = SymptomService.getAllSymptoms()
              .take(5)
              .toList();
          if (recentSymptoms.isNotEmpty) {
            systemContext += '\n--- État de santé récent ---\n';
            for (var s in recentSymptoms) {
              final dateStr = "${s.date.day}/${s.date.month}";
              final symptomsList = s.symptoms.isNotEmpty
                  ? s.symptoms.join(", ")
                  : "Rien de particulier";
              final mood = s.mood ?? "Non notée";
              final pain = s.painLevel != null ? "${s.painLevel}/10" : "-";

              systemContext +=
                  '- Le $dateStr : Symptômes [$symptomsList], Humeur [$mood], Douleur [$pain]\n';
            }
          }
        }

        // --- NOUVEAU : CONNEXION AU JOURNAL (Si autorisé) ---
        if (user.allowAiJournal) {
          final recentEntries = JournalService.getAllEntries().take(3).toList();
          if (recentEntries.isNotEmpty) {
            systemContext += '\n--- Notes du Journal (Pensées récentes) ---\n';
            for (var entry in recentEntries) {
              final dateStr = "${entry.date.day}/${entry.date.month}";
              // On limite la taille du contenu pour ne pas exploser le token limit
              String content = entry.content;
              if (content.length > 200) {
                content = "${content.substring(0, 200)}...";
              }

              systemContext +=
                  '- Le $dateStr : "${entry.title ?? ''} $content" (Tags: ${entry.tags.join(", ")})\n';
            }
          }
        }
      }

      systemContext +=
          '\n\nRéponds maintenant à l\'utilisatrice en restant 100% fidèle à ton caractère de ${effectivePersona.name}.';

      // Construction du prompt final incluant l'historique pour simuler une conversation fluide
      String finalPrompt = "CONTEXTE SYSTÈME :\n$systemContext\n\n";

      if (history.isNotEmpty) {
        finalPrompt += "HISTORIQUE DE LA CONVERSATION :\n";
        for (var content in history) {
          final role = content.role == 'user' ? 'Utilisatrice' : 'Toi (Aida)';
          // Extraction sécurisée du texte depuis l'historique
          String text = "";
          try {
            final parts = content.parts;
            if (parts != null && parts.isNotEmpty) {
              // tentative de récupération du texte via toJson si le getter direct échoue
              text = content.toJson()['parts']?[0]?['text'] ?? "";
            }
          } catch (_) {
            text = "";
          }

          if (text.isNotEmpty) {
            finalPrompt += "$role: $text\n";
          }
        }
        finalPrompt += "\n";
      }

      finalPrompt +=
          "DERNIER MESSAGE :\nUtilisatrice: \"$userMessage\"\nToi (Aida):";

      final response = await gemini.text(finalPrompt);

      return response?.output ??
          "Oups, je n'ai pas pu générer de réponse. Réessaie ?";
    } catch (e) {
      _log.severe('Erreur Gemini', e);
      throw Exception('Gemini Error: $e');
    }
  }

  static Future<Map<String, String>> generateBlogContent(
    UserModel? user,
  ) async {
    try {
      final gemini = Gemini.instance;

      String prompt =
          "Crée un court article de blog (max 2000 mots) personnalisé pour une application de santé féminine nommée AIDA.\n";
      prompt += "L'utilisatrice s'appelle ${user?.name ?? 'amie'}.\n";

      if (user != null) {
        if (user.nextPeriodDate != null) {
          final diff = user.nextPeriodDate!.difference(DateTime.now()).inDays;
          prompt +=
              "Ses prochaines règles sont dans environ $diff jours. Adapte le conseil à sa phase probable du cycle.\n";
        }
      }

      prompt += """
Format de réponse obligatoire (uniquement ces 3 blocs, pas d'autre texte) :
TITRE: [Titre accrocheur]
RESUME: [Résumé en une phrase]
CONTENU: [L'article complet. Mets en GRAS les mots-clés importants avec des astérisques comme **mots-clés** pour qu'ils ressortent visuellement.]
""";

      final response = await gemini.text(prompt);
      final output = response?.output ?? "";

      // Parsing basique
      String title = "Conseil du jour";
      String summary = "Découvre comment prendre soin de toi aujourd'hui.";
      String content = output;

      final lines = output.split('\n');
      for (var line in lines) {
        if (line.startsWith('TITRE:')) {
          title = line.replaceFirst('TITRE:', '').trim();
        }
        if (line.startsWith('RESUME:')) {
          summary = line.replaceFirst('RESUME:', '').trim();
        }
        if (line.startsWith('CONTENU:')) {
          content = output.substring(output.indexOf('CONTENU:') + 8).trim();
        }
      }

      return {
        'title': title,
        'summary': summary,
        'content': content,
        'date': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _log.severe('Erreur Blog Gemini', e);
      return {
        'title': "Prendre soin de soi",
        'summary': "Un petit conseil pour ta journée.",
        'content':
            "N'oublie pas de rester hydratée et de t'écouter. Chaque phase de ton cycle est unique !",
        'date': DateTime.now().toIso8601String(),
      };
    }
  }
}
