import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 6)
class NotificationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  bool isRead;

  @HiveField(5)
  final String type; // 'reminder', 'motivation', 'system'

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.isRead = false,
    this.type = 'system',
  });
}
