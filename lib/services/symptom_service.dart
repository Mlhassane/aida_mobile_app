import 'package:hive_flutter/hive_flutter.dart';
import '../models/symptom_model.dart';
import 'hive_service.dart';

class SymptomService {
  // Enregistrer ou mettre à jour un symptôme pour une date
  static Future<void> saveSymptom(SymptomModel symptom) async {
    final box = HiveService.symptomsBox;

    // Chercher si un symptôme existe déjà pour cette date
    final existingKey = box.keys.firstWhere((key) {
      final s = box.get(key) as SymptomModel?;
      return s != null &&
          s.date.year == symptom.date.year &&
          s.date.month == symptom.date.month &&
          s.date.day == symptom.date.day;
    }, orElse: () => null);

    if (existingKey != null) {
      // Mettre à jour
      await box.put(existingKey, symptom);
    } else {
      // Ajouter
      await box.add(symptom);
    }
  }

  // Obtenir tous les symptômes
  static List<SymptomModel> getAllSymptoms() {
    final box = HiveService.symptomsBox;
    final symptoms = box.values.toList();
    symptoms.sort((a, b) => b.date.compareTo(a.date)); // Plus récent en premier
    return symptoms;
  }

  // Obtenir les symptômes pour une date spécifique
  static SymptomModel? getSymptomForDate(DateTime date) {
    final allSymptoms = getAllSymptoms();
    try {
      return allSymptoms.firstWhere(
        (s) =>
            s.date.year == date.year &&
            s.date.month == date.month &&
            s.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  // Obtenir les symptômes dans une plage de dates
  static List<SymptomModel> getSymptomsInRange(DateTime start, DateTime end) {
    final allSymptoms = getAllSymptoms();
    return allSymptoms.where((symptom) {
      return symptom.date.isAfter(start.subtract(const Duration(days: 1))) &&
          symptom.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Supprimer un symptôme
  static Future<void> deleteSymptom(String symptomId) async {
    final box = HiveService.symptomsBox;
    final key = box.keys.firstWhere(
      (k) => (box.get(k) as SymptomModel).id == symptomId,
      orElse: () => null,
    );

    if (key != null) {
      await box.delete(key);
    }
  }

  // Stream pour écouter les changements
  static Stream<BoxEvent> watchSymptoms() {
    return HiveService.symptomsBox.watch();
  }

  // Obtenir les statistiques des symptômes
  static Map<String, dynamic> getSymptomStatistics() {
    final symptoms = getAllSymptoms();
    if (symptoms.isEmpty) {
      return {
        'totalEntries': 0,
        'mostCommonSymptom': null,
        'averagePainLevel': 0,
        'mostCommonMood': null,
      };
    }

    // Symptôme le plus fréquent
    final symptomCounts = <String, int>{};
    for (var symptom in symptoms) {
      for (var s in symptom.symptoms) {
        symptomCounts[s] = (symptomCounts[s] ?? 0) + 1;
      }
    }
    final mostCommonSymptom = symptomCounts.isEmpty
        ? null
        : symptomCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Niveau de douleur moyen
    final painLevels = symptoms
        .where((s) => s.painLevel != null)
        .map((s) => s.painLevel!)
        .toList();
    final averagePainLevel = painLevels.isEmpty
        ? 0.0
        : painLevels.reduce((a, b) => a + b) / painLevels.length;

    // Humeur la plus fréquente
    final moodCounts = <String, int>{};
    for (var symptom in symptoms) {
      if (symptom.mood != null) {
        moodCounts[symptom.mood!] = (moodCounts[symptom.mood!] ?? 0) + 1;
      }
    }
    final mostCommonMood = moodCounts.isEmpty
        ? null
        : moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return {
      'totalEntries': symptoms.length,
      'mostCommonSymptom': mostCommonSymptom,
      'averagePainLevel': averagePainLevel.round(),
      'mostCommonMood': mostCommonMood,
      'symptomCounts': symptomCounts,
      'moodCounts': moodCounts,
    };
  }
}
