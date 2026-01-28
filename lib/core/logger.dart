import 'package:logging/logging.dart';

final Logger logger = Logger('aida');

void initLogging({Level level = Level.INFO}) {
  Logger.root.level = level;
  Logger.root.onRecord.listen((record) {
    // Simple console output for development. Can be replaced by a file or remote logger.
    // Using print here intentionally for visibility in CI/dev consoles.
    // ignore: avoid_print
    print('${record.time.toIso8601String()} ${record.level.name} ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      // ignore: avoid_print
      print(record.error);
    }
    if (record.stackTrace != null) {
      // ignore: avoid_print
      print(record.stackTrace);
    }
  });
}
