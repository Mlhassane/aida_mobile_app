import 'dart:math' as math;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/period_model.dart';
import 'hive_service.dart';
import 'user_service.dart';

class PeriodService {
  // Enregistrer une nouvelle période
  static Future<void> recordPeriod(DateTime startDate, {int? duration}) async {
    final user = UserService.getUser();
    if (user == null) return;

    final periodDuration = duration ?? user.averagePeriodLength;

    final period = PeriodModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startDate: startDate,
      duration: periodDuration,
      createdAt: DateTime.now(),
    );

    // Sauvegarder directement l'objet dans la box typée
    final box = HiveService.periodsBox;
    await box.add(period);

    // Trouver la période la plus récente (la plus proche de maintenant)
    final allPeriods = getAllPeriods();
    if (allPeriods.isNotEmpty) {
      // Trier par date de début décroissante
      allPeriods.sort((a, b) => b.startDate.compareTo(a.startDate));
      // La première est la plus récente
      await UserService.updateLastPeriodDate(allPeriods.first.startDate);
    }

    // Recalculer les moyennes basées sur l'historique pour affiner les prédictions
    await _updateUserStats();
  }

  // Obtenir toutes les périodes
  static List<PeriodModel> getAllPeriods() {
    final box = HiveService.periodsBox;
    final periods = box.values.toList();
    periods.sort(
      (a, b) => b.startDate.compareTo(a.startDate),
    ); // Plus récent en premier
    return periods;
  }

  // Obtenir les périodes d'une plage de dates
  static List<PeriodModel> getPeriodsInRange(DateTime start, DateTime end) {
    final allPeriods = getAllPeriods();
    return allPeriods.where((period) {
      final periodEnd = period.endDate ?? period.calculatedEndDate;
      return period.startDate.isBefore(end) && periodEnd.isAfter(start);
    }).toList();
  }

  // Obtenir la période correspondant à une date
  static PeriodModel? getPeriodAtDate(DateTime date) {
    final allPeriods = getAllPeriods();
    try {
      return allPeriods.firstWhere((period) {
        final periodEnd = period.endDate ?? period.calculatedEndDate;
        return date.isAfter(
              period.startDate.subtract(const Duration(days: 1)),
            ) &&
            date.isBefore(periodEnd.add(const Duration(days: 1)));
      });
    } catch (e) {
      return null;
    }
  }

  // Vérifier si une date est dans une période
  static bool isDateInPeriod(DateTime date) {
    final allPeriods = getAllPeriods();
    return allPeriods.any((period) {
      final periodEnd = period.endDate ?? period.calculatedEndDate;
      return date.isAfter(period.startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(periodEnd.add(const Duration(days: 1)));
    });
  }

  // Obtenir la période active (en cours)
  static PeriodModel? getActivePeriod() {
    final allPeriods = getAllPeriods();
    try {
      return allPeriods.firstWhere((period) => period.isActive);
    } catch (e) {
      return null;
    }
  }

  // Vérifier s'il y a une période active
  static bool hasActivePeriod() {
    return getActivePeriod() != null;
  }

  // Marquer la fin d'une période
  static Future<void> endPeriod(DateTime endDate) async {
    final activePeriod = getActivePeriod();
    if (activePeriod == null) return;

    // Recalculer la durée réelle
    final realDuration = endDate.difference(activePeriod.startDate).inDays + 1;
    final updatedPeriod = activePeriod.copyWith(
      endDate: endDate,
      duration: realDuration,
    );

    // Mettre à jour l'objet dans la box
    final box = HiveService.periodsBox;
    final key = box.keys.firstWhere(
      (k) => (box.get(k) as PeriodModel).id == activePeriod.id,
      orElse: () => null,
    );

    if (key != null) {
      await box.put(key, updatedPeriod);
      // Recalculer les stats après fermeture d'une période
      await _updateUserStats();
    }
  }

  // Supprimer une période
  static Future<void> deletePeriod(String periodId) async {
    final box = HiveService.periodsBox;
    final key = box.keys.firstWhere(
      (k) => (box.get(k) as PeriodModel).id == periodId,
      orElse: () => null,
    );

    if (key != null) {
      await box.delete(key);

      // Mettre à jour la date de dernière période en trouvant la plus récente
      final remainingPeriods = getAllPeriods();
      if (remainingPeriods.isNotEmpty) {
        // Trier par date de début décroissante
        remainingPeriods.sort((a, b) => b.startDate.compareTo(a.startDate));
        // La première est la plus récente
        await UserService.updateLastPeriodDate(
          remainingPeriods.first.startDate,
        );
      }
      // Recalculer les stats
      await _updateUserStats();
    }
  }

  // Recalculer et mettre à jour les statistiques de l'utilisatrice
  static Future<void> _updateUserStats() async {
    final stats = getStatistics();
    if (stats['totalPeriods'] > 2) {
      // On ne met à jour que si on a assez de données pour être pertinent
      final avgCycle = stats['averageCycleLength'] as int;
      final avgPeriod = stats['averagePeriodLength'] as int;

      if (avgCycle > 20 && avgCycle < 45) {
        // Valeurs cohérentes uniquement
        await UserService.updateAverageCycleLength(avgCycle);
      }
      if (avgPeriod > 2 && avgPeriod < 10) {
        await UserService.updateAveragePeriodLength(avgPeriod);
      }
    }
  }

  // Stream pour écouter les changements
  static Stream<BoxEvent> watchPeriods() {
    return HiveService.periodsBox.watch();
  }

  // Obtenir les statistiques
  static Map<String, dynamic> getStatistics() {
    final periods = getAllPeriods();
    if (periods.isEmpty) {
      return {
        'totalPeriods': 0,
        'averageCycleLength': 0,
        'averagePeriodLength': 0,
        'regularity': 0,
        'regularityStatus': 'Données insuffisantes',
      };
    }

    // Calculer la durée moyenne des règles (seulement les périodes terminées si on en a plusieurs)
    final finishedPeriods = periods.where((p) => p.endDate != null).toList();
    final periodsForAvgLength = finishedPeriods.isNotEmpty
        ? finishedPeriods
        : periods;

    final avgPeriodLength =
        periodsForAvgLength.map((p) => p.duration).reduce((a, b) => a + b) /
        periodsForAvgLength.length;

    // Calculer la durée moyenne du cycle (entre les débuts de périodes : Start-to-Start)
    final sortedPeriodsForCycle = List<PeriodModel>.from(periods)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    double avgCycleLength = 0;
    if (sortedPeriodsForCycle.length > 1) {
      final cycleLengths = <int>[];
      for (int i = 0; i < sortedPeriodsForCycle.length - 1; i++) {
        final currentStart = sortedPeriodsForCycle[i].startDate;
        final nextStart = sortedPeriodsForCycle[i + 1].startDate;
        final cycleLength = nextStart.difference(currentStart).inDays;
        if (cycleLength > 15 && cycleLength < 60) {
          cycleLengths.add(cycleLength);
        }
      }
      if (cycleLengths.isNotEmpty) {
        avgCycleLength =
            cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
      }
    }

    // Calculer la régularité
    double regularity = 0;
    String regularityStatus = 'Inconnu';

    if (periods.length >= 3) {
      final cycleLengths = <int>[];
      for (int i = 0; i < sortedPeriodsForCycle.length - 1; i++) {
        final currentStart = sortedPeriodsForCycle[i].startDate;
        final nextStart = sortedPeriodsForCycle[i + 1].startDate;
        final cycleLength = nextStart.difference(currentStart).inDays;

        if (cycleLength >= 15 && cycleLength <= 45) {
          cycleLengths.add(cycleLength);
        }
      }

      if (cycleLengths.length >= 2) {
        final mean = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
        final variance =
            cycleLengths
                .map((x) => (x - mean) * (x - mean))
                .reduce((a, b) => a + b) /
            cycleLengths.length;

        final stdDev = math.sqrt(variance);
        final coefficientOfVariation = mean > 0 ? (stdDev / mean) * 100 : 0;

        if (coefficientOfVariation < 5) {
          regularity = 100;
          regularityStatus = 'Très régulier';
        } else if (coefficientOfVariation < 12) {
          regularity = 90 - (coefficientOfVariation - 5) * 2;
          regularityStatus = 'Régulier';
        } else if (coefficientOfVariation < 25) {
          regularity = 80 - (coefficientOfVariation - 12) * 2;
          regularityStatus = 'Modérément régulier';
        } else {
          regularity = (50 - (coefficientOfVariation - 25) * 1.5).clamp(0, 49);
          regularityStatus = 'Irrégulier';
        }

        regularity = regularity.clamp(0, 100);
      } else {
        regularityStatus = 'Données insuffisantes';
      }
    } else if (periods.length == 2) {
      regularityStatus = 'En cours d\'analyse';
      regularity = 50;
    } else {
      regularityStatus = 'Données insuffisantes';
    }

    return {
      'totalPeriods': periods.length,
      'averageCycleLength': avgCycleLength.round(),
      'averagePeriodLength': avgPeriodLength.round(),
      'regularity': regularity.round(),
      'regularityStatus': regularityStatus,
    };
  }
}
