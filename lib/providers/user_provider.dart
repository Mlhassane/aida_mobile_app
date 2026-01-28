import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

/// Provider pour gérer l'utilisateur de manière centralisée
class UserProvider extends ChangeNotifier {
  UserModel? _user;
  StreamSubscription<UserModel?>? _subscription;

  UserProvider() {
    _loadUser();
    _subscription = UserService.watchUser().listen((_) {
      _loadUser();
      notifyListeners();
    });
  }

  /// Utilisateur actuel
  UserModel? get user => _user;

  /// Vérifier si un utilisateur existe
  bool get hasUser => _user != null;

  /// Charger l'utilisateur depuis Hive
  void _loadUser() {
    _user = UserService.getUser();
  }

  /// Sauvegarder un nouvel utilisateur
  Future<void> saveUser(UserModel user) async {
    await UserService.saveUser(user);
    // Le stream notifiera automatiquement
  }

  /// Mettre à jour l'utilisateur
  Future<void> updateUser(UserModel user) async {
    await UserService.updateUser(user);
    // Le stream notifiera automatiquement
  }

  /// Mettre à jour la dernière date de règles
  Future<void> updateLastPeriodDate(DateTime date) async {
    await UserService.updateLastPeriodDate(date);
    // Le stream notifiera automatiquement
  }

  /// Mettre à jour la durée moyenne du cycle
  Future<void> updateAverageCycleLength(int days) async {
    await UserService.updateAverageCycleLength(days);
    // Le stream notifiera automatiquement
  }

  /// Mettre à jour la durée moyenne des règles
  Future<void> updateAveragePeriodLength(int days) async {
    await UserService.updateAveragePeriodLength(days);
    // Le stream notifiera automatiquement
  }

  /// Supprimer l'utilisateur
  Future<void> deleteUser() async {
    await UserService.deleteUser();
    // Le stream notifiera automatiquement
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
