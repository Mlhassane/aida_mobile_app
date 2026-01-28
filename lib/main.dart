import 'package:aida/app/aida.dart';
import 'package:aida/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/ai_service.dart';
import 'services/notification_service.dart';
import 'core/logger.dart';
import 'services/hive_service.dart';
import 'services/migration_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init logging
  initLogging();

  // Init Hive Flutter and open boxes
  await Hive.initFlutter();
  await HiveService.init();

  // Migrer les anciennes données JSON vers objets typés
  await MigrationService.migrate();

  runApp(const AidaApp());

  // Post-startup initializations
  _initServicesAsync();
}

Future<void> _initServicesAsync() async {
  // Init AI Service
  AIService.init();

  // Init notifications (timezones, permissions)
  await NotificationService.initialize();

  // Update scheduled notifications if user exists
  final user = UserService.getUser();
  if (user != null) {
    await NotificationService.updateNotifications();
  }
}
