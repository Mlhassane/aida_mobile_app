import 'package:hive_flutter/hive_flutter.dart';
import '../models/journal_model.dart';
import 'hive_service.dart';

class JournalService {
  // Créer une nouvelle entrée de journal
  static Future<JournalModel> createEntry({
    required DateTime date,
    String? title,
    required String content,
    String? mood,
    List<String> tags = const [],
  }) async {
    final entry = JournalModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      title: title,
      content: content,
      mood: mood,
      tags: tags,
      createdAt: DateTime.now(),
    );

    final box = HiveService.journalBox;
    await box.add(entry);

    return entry;
  }

  // Mettre à jour une entrée
  static Future<void> updateEntry(JournalModel entry) async {
    final box = HiveService.journalBox;

    final key = box.keys.firstWhere(
      (k) => (box.get(k) as JournalModel).id == entry.id,
      orElse: () => null,
    );

    if (key != null) {
      final updatedEntry = entry.copyWith(updatedAt: DateTime.now());
      await box.put(key, updatedEntry);
    }
  }

  // Supprimer une entrée
  static Future<void> deleteEntry(String id) async {
    final box = HiveService.journalBox;
    final key = box.keys.firstWhere(
      (k) => (box.get(k) as JournalModel).id == id,
      orElse: () => null,
    );

    if (key != null) {
      await box.delete(key);
    }
  }

  // Obtenir toutes les entrées
  static List<JournalModel> getAllEntries() {
    final box = HiveService.journalBox;
    final entries = box.values.toList();
    entries.sort((a, b) => b.date.compareTo(a.date)); // Plus récent en premier
    return entries;
  }

  // Obtenir les entrées d'une date spécifique
  static List<JournalModel> getEntriesByDate(DateTime date) {
    final allEntries = getAllEntries();
    return allEntries.where((entry) {
      return entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day;
    }).toList();
  }

  // Obtenir les entrées favorites
  static List<JournalModel> getFavoriteEntries() {
    return getAllEntries().where((e) => e.isFavorite).toList();
  }

  // Rechercher dans les entrées
  static List<JournalModel> searchEntries(String query) {
    final allEntries = getAllEntries();
    final lowerQuery = query.toLowerCase();

    return allEntries.where((entry) {
      return (entry.title?.toLowerCase().contains(lowerQuery) ?? false) ||
          entry.content.toLowerCase().contains(lowerQuery) ||
          entry.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // Obtenir les entrées par humeur
  static List<JournalModel> getEntriesByMood(String mood) {
    return getAllEntries().where((e) => e.mood == mood).toList();
  }

  // Stream pour écouter les changements
  static Stream<BoxEvent> watchJournals() {
    return HiveService.journalBox.watch();
  }

  // Obtenir les statistiques
  static Map<String, dynamic> getStatistics() {
    final entries = getAllEntries();

    if (entries.isEmpty) {
      return {
        'totalEntries': 0,
        'favoriteEntries': 0,
        'moodDistribution': <String, int>{},
        'mostUsedTags': <String, int>{},
      };
    }

    // Distribution des humeurs
    final moodDistribution = <String, int>{};
    for (var entry in entries) {
      if (entry.mood != null) {
        moodDistribution[entry.mood!] =
            (moodDistribution[entry.mood!] ?? 0) + 1;
      }
    }

    // Tags les plus utilisés
    final tagCount = <String, int>{};
    for (var entry in entries) {
      for (var tag in entry.tags) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }
    }
    final mostUsedTags = Map.fromEntries(
      tagCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    return {
      'totalEntries': entries.length,
      'favoriteEntries': entries.where((e) => e.isFavorite).length,
      'moodDistribution': moodDistribution,
      'mostUsedTags': mostUsedTags,
    };
  }
}
