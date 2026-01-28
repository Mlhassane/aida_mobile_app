import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/symptom_model.dart';
import '../services/symptom_service.dart';

/// Provider pour gérer les symptômes de manière centralisée
class SymptomsProvider extends ChangeNotifier {
  List<SymptomModel> _symptoms = [];
  StreamSubscription<BoxEvent>? _subscription;

  SymptomsProvider() {
    _loadSymptoms();
    _subscription = SymptomService.watchSymptoms().listen((_) {
      _loadSymptoms();
      notifyListeners();
    });
  }

  /// Liste des symptômes (triée par date décroissante)
  List<SymptomModel> get symptoms => List.unmodifiable(_symptoms);

  /// Nombre total de symptômes
  int get totalSymptoms => _symptoms.length;

  /// Charger les symptômes depuis Hive
  void _loadSymptoms() {
    _symptoms = SymptomService.getAllSymptoms();
  }

  /// Sauvegarder un symptôme
  Future<void> saveSymptom(SymptomModel symptom) async {
    await SymptomService.saveSymptom(symptom);
    // Le stream notifiera automatiquement
  }

  /// Supprimer un symptôme
  Future<void> deleteSymptom(String symptomId) async {
    await SymptomService.deleteSymptom(symptomId);
    // Le stream notifiera automatiquement
  }

  /// Obtenir le symptôme pour une date spécifique
  SymptomModel? getSymptomForDate(DateTime date) {
    return SymptomService.getSymptomForDate(date);
  }

  /// Obtenir les symptômes dans une plage de dates
  List<SymptomModel> getSymptomsInRange(DateTime start, DateTime end) {
    return SymptomService.getSymptomsInRange(start, end);
  }

  /// Obtenir les statistiques
  Map<String, dynamic> getStatistics() {
    return SymptomService.getSymptomStatistics();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
