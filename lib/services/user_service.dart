import '../models/user_model.dart';
import 'hive_service.dart';
import 'notification_service.dart';

class UserService {
  static const String userKey = 'currentUser';

  // Sauvegarder l'utilisatrice
  static Future<void> saveUser(UserModel user) async {
    final box = HiveService.userBox;
    await box.put(userKey, user);
  }

  // Obtenir l'utilisatrice actuelle
  static UserModel? getUser() {
    final box = HiveService.userBox;
    return box.get(userKey);
  }

  // Vérifier si une utilisatrice existe
  static bool hasUser() {
    return getUser() != null;
  }

  // Mettre à jour l'utilisatrice
  static Future<void> updateUser(UserModel user) async {
    final updatedUser = user.copyWith(updatedAt: DateTime.now());
    await saveUser(updatedUser);

    // Mettre à jour les notifications
    try {
      await NotificationService.updateNotifications();
    } catch (e) {
      // Ignorer les erreurs de notif pour ne pas bloquer l'app
      print('Erreur notification: $e');
    }
  }

  // Supprimer l'utilisatrice
  static Future<void> deleteUser() async {
    final box = HiveService.userBox;
    await box.delete(userKey);
  }

  // Écouter les changements de l'utilisatrice
  static Stream<UserModel?> watchUser() {
    final box = HiveService.userBox;
    return box.watch(key: userKey).map((event) => event.value as UserModel?);
  }

  // Mettre à jour la dernière période
  static Future<void> updateLastPeriodDate(DateTime date) async {
    final user = getUser();
    if (user != null) {
      final updatedUser = user.copyWith(lastPeriodDate: date);
      await updateUser(updatedUser);
    }
  }

  // Mettre à jour la durée moyenne du cycle
  static Future<void> updateAverageCycleLength(int days) async {
    final user = getUser();
    if (user != null) {
      final updatedUser = user.copyWith(averageCycleLength: days);
      await updateUser(updatedUser);
    }
  }

  // Mettre à jour la durée moyenne des règles
  static Future<void> updateAveragePeriodLength(int days) async {
    final user = getUser();
    if (user != null) {
      final updatedUser = user.copyWith(averagePeriodLength: days);
      await updateUser(updatedUser);
    }
  }
}
