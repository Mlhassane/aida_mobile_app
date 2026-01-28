import 'package:hive_flutter/hive_flutter.dart';
import '../models/period_model.dart';
import '../models/symptom_model.dart';
import '../models/journal_model.dart';
import '../core/logger.dart';

/// Service pour migrer les anciennes données JSON vers des objets Hive natifs
class MigrationService {
  static const String _migrationKey = 'migration_version';
  static const int _currentVersion = 1;

  /// Effectuer toutes les migrations nécessaires
  static Future<void> migrate() async {
    final settingsBox = Hive.box('settingsBox');
    final lastVersion = settingsBox.get(_migrationKey, defaultValue: 0) as int;

    if (lastVersion < _currentVersion) {
      logger.info('Migration de v$lastVersion vers v$_currentVersion');

      if (lastVersion < 1) {
        await _migrateToV1();
      }

      await settingsBox.put(_migrationKey, _currentVersion);
      logger.info('Migration terminée');
    }
  }

  /// Migration v0 -> v1: Convertir JSON en objets Hive natifs
  static Future<void> _migrateToV1() async {
    logger.info('Migration v1: Conversion JSON -> objets typés');

    await _migratePeriods();
    await _migrateSymptoms();
    await _migrateJournals();
  }

  /// Migrer les périodes de JSON vers objets Hive
  static Future<void> _migratePeriods() async {
    try {
      final typedBox = Hive.box<PeriodModel>('periodsBox');

      // Vérifier s'il y a des données au format JSON
      // Note: oldData sera null ou un objet PeriodModel si déjà migré
      // On doit accéder directement via la box non typée pour lire l'ancien format
      final box = Hive.box('periodsBox');
      final oldData = box.get('periodsList');

      if (oldData != null && oldData is List) {
        logger.info('Migration de ${oldData.length} périodes');

        for (var item in oldData) {
          if (item is Map) {
            try {
              final json = Map<String, dynamic>.from(item);
              final period = PeriodModel.fromJson(json);
              await typedBox.add(period);
            } catch (e) {
              logger.warning('Impossible de migrer une période: $e');
            }
          }
        }

        // Supprimer l'ancien format
        await box.delete('periodsList');
        logger.info('Migration des périodes terminée');
      } else {
        logger.info('Aucune période à migrer');
      }
    } catch (e) {
      logger.severe('Erreur lors de la migration des périodes: $e');
    }
  }

  /// Migrer les symptômes de JSON vers objets Hive
  static Future<void> _migrateSymptoms() async {
    try {
      final typedBox = Hive.box<SymptomModel>('symptomsBox');
      final box = Hive.box('symptomsBox');
      final oldData = box.get('symptomsList');

      if (oldData != null && oldData is List) {
        logger.info('Migration de ${oldData.length} symptômes');

        for (var item in oldData) {
          if (item is Map) {
            try {
              final json = Map<String, dynamic>.from(item);
              final symptom = SymptomModel.fromJson(json);
              await typedBox.add(symptom);
            } catch (e) {
              logger.warning('Impossible de migrer un symptôme: $e');
            }
          }
        }

        await box.delete('symptomsList');
        logger.info('Migration des symptômes terminée');
      } else {
        logger.info('Aucun symptôme à migrer');
      }
    } catch (e) {
      logger.severe('Erreur lors de la migration des symptômes: $e');
    }
  }

  /// Migrer les entrées de journal de JSON vers objets Hive
  static Future<void> _migrateJournals() async {
    try {
      final typedBox = Hive.box<JournalModel>('journalBox');
      final box = Hive.box('journalBox');
      final oldData = box.get('journalsList');

      if (oldData != null && oldData is List) {
        logger.info('Migration de ${oldData.length} entrées de journal');

        for (var item in oldData) {
          if (item is Map) {
            try {
              final json = Map<String, dynamic>.from(item);
              final journal = JournalModel.fromJson(json);
              await typedBox.add(journal);
            } catch (e) {
              logger.warning('Impossible de migrer une entrée de journal: $e');
            }
          }
        }

        await box.delete('journalsList');
        logger.info('Migration des entrées de journal terminée');
      } else {
        logger.info('Aucune entrée de journal à migrer');
      }
    } catch (e) {
      logger.severe('Erreur lors de la migration des journaux: $e');
    }
  }
}
