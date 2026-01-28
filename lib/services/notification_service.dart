import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import 'user_service.dart';
import 'hive_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  // Initialiser les notifications
  static Future<void> initialize() async {
    // Calculer les notifications non lues au démarrage
    _updateUnreadCount();
    // Initialiser les timezones
    tzdata.initializeTimeZones();

    // Définir la timezone locale (utilise la timezone système)
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Paris'));
    } catch (e) {
      // Si la timezone n'existe pas, utiliser UTC
      tz.setLocalLocation(tz.UTC);
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Gérer le clic sur la notification
      },
    );

    // Demander les permissions Android 13+
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    _initialized = true;
  }

  // Planifier une notification pour les prochaines règles
  static Future<void> schedulePeriodReminder(UserModel user) async {
    if (!user.notificationsEnabled || user.nextPeriodDate == null) {
      return;
    }

    final nextPeriodDate = user.nextPeriodDate!;
    final now = DateTime.now();

    // Notification 3 jours avant
    final reminderDate3Days = nextPeriodDate.subtract(const Duration(days: 3));
    if (reminderDate3Days.isAfter(now)) {
      await _scheduleNotification(
        id: 1,
        title: 'Rappel AIDA',
        body:
            'Vos règles sont prévues dans 3 jours (${_formatDate(nextPeriodDate)})',
        scheduledDate: reminderDate3Days,
      );
    }

    // Notification 1 jour avant
    final reminderDate1Day = nextPeriodDate.subtract(const Duration(days: 1));
    if (reminderDate1Day.isAfter(now)) {
      await _scheduleNotification(
        id: 2,
        title: 'Rappel AIDA',
        body: 'Vos règles sont prévues demain (${_formatDate(nextPeriodDate)})',
        scheduledDate: reminderDate1Day,
      );
    }

    // Notification le jour J
    if (nextPeriodDate.isAfter(now)) {
      await _scheduleNotification(
        id: 3,
        title: 'AIDA - Vos règles',
        body:
            'Vos règles sont prévues aujourd\'hui. N\'oubliez pas de les enregistrer !',
        scheduledDate: nextPeriodDate,
      );
    }
  }

  // Planifier une notification
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // S'assurer que l'initialisation est terminée
    if (!_initialized) {
      await initialize();
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'period_reminders',
          'Rappels de règles',
          channelDescription: 'Notifications pour les rappels de règles',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // Enregistrer dans l'historique
    await _saveToHistory(
      id: id.toString(),
      title: title,
      body: body,
      date: scheduledDate,
      type: 'reminder',
    );
  }

  static Future<void> _saveToHistory({
    required String id,
    required String title,
    required String body,
    required DateTime date,
    required String type,
  }) async {
    final notification = NotificationModel(
      id: id,
      title: title,
      body: body,
      date: date,
      type: type,
    );
    await HiveService.notificationsBox.put(id, notification);
    _updateUnreadCount();
  }

  static void _updateUnreadCount() {
    unreadCount.value = HiveService.notificationsBox.values
        .where((n) => !n.isRead && n.date.isBefore(DateTime.now()))
        .length;
  }

  static Future<void> markAsRead(String id) async {
    final notification = HiveService.notificationsBox.get(id);
    if (notification != null) {
      notification.isRead = true;
      await notification.save();
      _updateUnreadCount();
    }
  }

  static Future<void> markAllAsRead() async {
    for (var notification in HiveService.notificationsBox.values) {
      if (!notification.isRead) {
        notification.isRead = true;
        await notification.save();
      }
    }
    _updateUnreadCount();
  }

  static List<NotificationModel> getAllNotifications() {
    final list = HiveService.notificationsBox.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  static Future<void> deleteNotification(String id) async {
    await HiveService.notificationsBox.delete(id);
    _updateUnreadCount();
  }

  // Annuler toutes les notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Annuler une notification spécifique
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Formater une date pour l'affichage
  static String _formatDate(DateTime date) {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  // Mettre à jour les notifications quand les données utilisateur changent
  static Future<void> updateNotifications() async {
    await cancelAllNotifications();
    final user = UserService.getUser();
    if (user != null) {
      await schedulePeriodReminder(user);
      await scheduleDailyCheckIns(user);
    }
  }

  // Planifier des notifications quotidiennes de prise de nouvelles
  static Future<void> scheduleDailyCheckIns(UserModel user) async {
    if (!user.notificationsEnabled) return;

    // Matin (9h00)
    await _scheduleDailyNotification(
      id: 10,
      title: 'Bonjour !',
      body: 'Comment allez-vous ce matin ? Prenez un moment pour vous.',
      hour: 9,
      minute: 0,
    );

    // Après-midi (14h00)
    await _scheduleDailyNotification(
      id: 11,
      title: 'Coucou !',
      body:
          'Comment se passe votre après-midi ? N\'oubliez pas de vous hydrater.',
      hour: 14,
      minute: 0,
    );

    // Soir (21h00)
    await _scheduleDailyNotification(
      id: 12,
      title: 'C\'est l\'heure du bilan ! 🌙',
      body:
          'Quoi de neuf aujourd\'hui ? Raconte-moi tout dans ton journal pour libérer ton esprit avant de dormir.',
      hour: 21,
      minute: 0,
    );
  }

  static Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await initialize();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_checkins',
          'Rappels quotidiens',
          channelDescription: 'Notifications de prise de nouvelles quotidienne',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/launcher_icon',
          largeIcon: const DrawableResourceAndroidBitmap(
            '@mipmap/launcher_icon',
          ),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Pour les checkins quotidiens, on n'enregistre pas forcément dans l'historique
    // car ils sont répétitifs et pourraient polluer la liste.
    // Mais on pourrait le faire si l'utilisateur le souhaite.
  }

  // Tester une notification immédiate
  static Future<void> showTestNotification({
    String title = 'Test AIDA',
    String body = 'Ceci est une notification de test',
  }) async {
    if (!_initialized) {
      await initialize();
    }

    await _notifications.show(
      999,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Notifications de test',
          channelDescription: 'Canal pour les notifications de test',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    await _saveToHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      date: DateTime.now(),
      type: 'motivation',
    );
  }

  // Planifier une notification de test dans X secondes
  static Future<void> scheduleTestNotification({
    int seconds = 5,
    String title = 'Test AIDA',
    String body = 'Ceci est une notification de test programmée',
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final scheduledDate = DateTime.now().add(Duration(seconds: seconds));

    await _notifications.zonedSchedule(
      998,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Notifications de test',
          channelDescription: 'Canal pour les notifications de test',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          largeIcon: const DrawableResourceAndroidBitmap(
            '@mipmap/launcher_icon',
          ),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Obtenir les notifications planifiées (Android uniquement)
  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
