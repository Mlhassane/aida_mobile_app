import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/period_model.dart';
import '../services/period_service.dart';

/// Provider pour gérer les périodes de manière centralisée
class PeriodsProvider extends ChangeNotifier {
  List<PeriodModel> _periods = [];
  StreamSubscription<BoxEvent>? _subscription;

  PeriodsProvider() {
    _loadPeriods();
    _subscription = PeriodService.watchPeriods().listen((_) {
      _loadPeriods();
      notifyListeners();
    });
  }

  /// Liste des périodes (triée par date décroissante)
  List<PeriodModel> get periods => List.unmodifiable(_periods);

  /// Période active (en cours)
  PeriodModel? get activePeriod => PeriodService.getActivePeriod();

  /// Vérifier s'il y a une période active
  bool get hasActivePeriod => activePeriod != null;

  /// Nombre total de périodes
  int get totalPeriods => _periods.length;

  /// Charger les périodes depuis Hive
  void _loadPeriods() {
    _periods = PeriodService.getAllPeriods();
  }

  /// Enregistrer une nouvelle période
  Future<void> recordPeriod(DateTime date, {int? duration}) async {
    await PeriodService.recordPeriod(date, duration: duration);
    // Le stream notifiera automatiquement
  }

  /// Marquer la fin d'une période
  Future<void> endPeriod(DateTime endDate) async {
    await PeriodService.endPeriod(endDate);
    // Le stream notifiera automatiquement
  }

  /// Supprimer une période
  Future<void> deletePeriod(String periodId) async {
    await PeriodService.deletePeriod(periodId);
    // Le stream notifiera automatiquement
  }

  /// Obtenir les périodes dans une plage de dates
  List<PeriodModel> getPeriodsInRange(DateTime start, DateTime end) {
    return PeriodService.getPeriodsInRange(start, end);
  }

  /// Vérifier si une date est dans une période
  bool isDateInPeriod(DateTime date) {
    return PeriodService.isDateInPeriod(date);
  }

  /// Obtenir les statistiques
  Map<String, dynamic> getStatistics() {
    return PeriodService.getStatistics();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
