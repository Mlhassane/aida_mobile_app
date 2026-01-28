import 'package:hive_flutter/hive_flutter.dart';
import '../services/hive_service.dart';

class HiveInit {
  static Future<void> initialize() async {
    // Initialiser Hive Flutter
    await Hive.initFlutter();

    // Initialiser les services Hive (ouvrir les boxes et enregistrer les adaptateurs)
    await HiveService.init();
  }
}
