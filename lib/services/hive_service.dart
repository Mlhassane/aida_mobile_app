import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/period_model.dart';
import '../models/symptom_model.dart';
import '../models/journal_model.dart';
import '../models/notification_model.dart';

class HiveService {
  static const String userBoxName = 'userBox';
  static const String settingsBoxName = 'settingsBox';
  static const String periodsBoxName = 'periodsBox';
  static const String symptomsBoxName = 'symptomsBox';
  static const String journalBoxName = 'journalBox';
  static const String chatBoxName = 'chatBox';
  static const String blogBoxName = 'blogBox';
  static const String notificationsBoxName = 'notificationsBox';

  // Initialiser Hive (appelé après l'initialisation de base)
  static Future<void> init() async {
    // Enregistrer les adaptateurs
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PeriodModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SymptomModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(JournalModelAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(NotificationModelAdapter());
    }

    // Ouvrir les boxes avec types spécifiques
    await Hive.openBox<UserModel>(userBoxName);
    await Hive.openBox(settingsBoxName);
    await Hive.openBox<PeriodModel>(periodsBoxName);
    await Hive.openBox<SymptomModel>(symptomsBoxName);
    await Hive.openBox<JournalModel>(journalBoxName);
    await Hive.openBox(chatBoxName);
    await Hive.openBox(blogBoxName);
    await Hive.openBox<NotificationModel>(notificationsBoxName);
  }

  // Obtenir la box utilisateur
  static Box<UserModel> get userBox => Hive.box<UserModel>(userBoxName);

  // Obtenir la box des paramètres
  static Box get settingsBox => Hive.box(settingsBoxName);

  // Obtenir la box des périodes (typée)
  static Box<PeriodModel> get periodsBox =>
      Hive.box<PeriodModel>(periodsBoxName);

  // Obtenir la box des symptômes (typée)
  static Box<SymptomModel> get symptomsBox =>
      Hive.box<SymptomModel>(symptomsBoxName);

  // Obtenir la box du journal (typée)
  static Box<JournalModel> get journalBox =>
      Hive.box<JournalModel>(journalBoxName);

  // Box pour l'historique du chat
  static Box get chatBox => Hive.box(chatBoxName);

  // Box pour le blog AIDA
  static Box get blogBox => Hive.box(blogBoxName);

  // Box pour les notifications
  static Box<NotificationModel> get notificationsBox =>
      Hive.box<NotificationModel>(notificationsBoxName);

  // Fermer toutes les boxes
  static Future<void> closeAll() async {
    await Hive.close();
  }
}
