import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/journal_model.dart';
import '../services/journal_service.dart';

/// Provider pour gérer le journal de manière centralisée
class JournalProvider extends ChangeNotifier {
  List<JournalModel> _entries = [];
  StreamSubscription<BoxEvent>? _subscription;

  JournalProvider() {
    _loadEntries();
    _subscription = JournalService.watchJournals().listen((_) {
      _loadEntries();
      notifyListeners();
    });
  }

  /// Liste des entrées (triée par date décroissante)
  List<JournalModel> get entries => List.unmodifiable(_entries);

  /// Nombre total d'entrées
  int get totalEntries => _entries.length;

  /// Entrées favorites
  List<JournalModel> get favoriteEntries =>
      _entries.where((e) => e.isFavorite).toList();

  /// Charger les entrées depuis Hive
  void _loadEntries() {
    _entries = JournalService.getAllEntries();
  }

  /// Créer une nouvelle entrée
  Future<JournalModel> createEntry({
    required DateTime date,
    String? title,
    required String content,
    String? mood,
    List<String> tags = const [],
  }) async {
    final entry = await JournalService.createEntry(
      date: date,
      title: title,
      content: content,
      mood: mood,
      tags: tags,
    );
    // Le stream notifiera automatiquement
    return entry;
  }

  /// Mettre à jour une entrée
  Future<void> updateEntry(JournalModel entry) async {
    await JournalService.updateEntry(entry);
    // Le stream notifiera automatiquement
  }

  /// Supprimer une entrée
  Future<void> deleteEntry(String id) async {
    await JournalService.deleteEntry(id);
    // Le stream notifiera automatiquement
  }

  /// Obtenir les entrées pour une date spécifique
  List<JournalModel> getEntriesByDate(DateTime date) {
    return JournalService.getEntriesByDate(date);
  }

  /// Rechercher dans les entrées
  List<JournalModel> searchEntries(String query) {
    return JournalService.searchEntries(query);
  }

  /// Obtenir les entrées par humeur
  List<JournalModel> getEntriesByMood(String mood) {
    return JournalService.getEntriesByMood(mood);
  }

  /// Obtenir les statistiques
  Map<String, dynamic> getStatistics() {
    return JournalService.getStatistics();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
