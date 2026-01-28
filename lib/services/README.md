# Services

## HiveService

Service centralisé pour gérer Hive et les boxes de données.

### Boxes disponibles

- **userBox** : Box pour stocker les données utilisateur (`UserModel`)
- **settingsBox** : Box pour les paramètres généraux de l'application
- **periodsBox** : Box pour stocker l'historique des périodes

### Utilisation

```dart
// Obtenir la box utilisateur
final userBox = HiveService.userBox;

// Obtenir la box des paramètres
final settingsBox = HiveService.settingsBox;

// Obtenir la box des périodes
final periodsBox = HiveService.periodsBox;
```

## UserService

Service pour gérer les données utilisateur de manière simplifiée.

### Méthodes principales

- `saveUser(UserModel user)` : Sauvegarder une utilisatrice
- `getUser()` : Obtenir l'utilisatrice actuelle
- `hasUser()` : Vérifier si une utilisatrice existe
- `updateUser(UserModel user)` : Mettre à jour l'utilisatrice
- `deleteUser()` : Supprimer l'utilisatrice
- `watchUser()` : Écouter les changements de l'utilisatrice (Stream)

### Méthodes de mise à jour spécifiques

- `updateLastPeriodDate(DateTime date)` : Mettre à jour la date des dernières règles
- `updateAverageCycleLength(int days)` : Mettre à jour la durée moyenne du cycle
- `updateAveragePeriodLength(int days)` : Mettre à jour la durée moyenne des règles

### Exemple d'utilisation

```dart
// Créer une nouvelle utilisatrice
final user = UserModel(
  id: 'unique-id',
  name: 'Marie',
  averageCycleLength: 28,
  averagePeriodLength: 5,
  createdAt: DateTime.now(),
);

await UserService.saveUser(user);

// Récupérer l'utilisatrice
final currentUser = UserService.getUser();

// Écouter les changements
UserService.watchUser().listen((user) {
  print('Utilisatrice mise à jour: ${user?.name}');
});
```


## HiveService

Service centralisé pour gérer Hive et les boxes de données.

### Boxes disponibles

- **userBox** : Box pour stocker les données utilisateur (`UserModel`)
- **settingsBox** : Box pour les paramètres généraux de l'application
- **periodsBox** : Box pour stocker l'historique des périodes

### Utilisation

```dart
// Obtenir la box utilisateur
final userBox = HiveService.userBox;

// Obtenir la box des paramètres
final settingsBox = HiveService.settingsBox;

// Obtenir la box des périodes
final periodsBox = HiveService.periodsBox;
```

## UserService

Service pour gérer les données utilisateur de manière simplifiée.

### Méthodes principales

- `saveUser(UserModel user)` : Sauvegarder une utilisatrice
- `getUser()` : Obtenir l'utilisatrice actuelle
- `hasUser()` : Vérifier si une utilisatrice existe
- `updateUser(UserModel user)` : Mettre à jour l'utilisatrice
- `deleteUser()` : Supprimer l'utilisatrice
- `watchUser()` : Écouter les changements de l'utilisatrice (Stream)

### Méthodes de mise à jour spécifiques

- `updateLastPeriodDate(DateTime date)` : Mettre à jour la date des dernières règles
- `updateAverageCycleLength(int days)` : Mettre à jour la durée moyenne du cycle
- `updateAveragePeriodLength(int days)` : Mettre à jour la durée moyenne des règles

### Exemple d'utilisation

```dart
// Créer une nouvelle utilisatrice
final user = UserModel(
  id: 'unique-id',
  name: 'Marie',
  averageCycleLength: 28,
  averagePeriodLength: 5,
  createdAt: DateTime.now(),
);

await UserService.saveUser(user);

// Récupérer l'utilisatrice
final currentUser = UserService.getUser();

// Écouter les changements
UserService.watchUser().listen((user) {
  print('Utilisatrice mise à jour: ${user?.name}');
});
```


## HiveService

Service centralisé pour gérer Hive et les boxes de données.

### Boxes disponibles

- **userBox** : Box pour stocker les données utilisateur (`UserModel`)
- **settingsBox** : Box pour les paramètres généraux de l'application
- **periodsBox** : Box pour stocker l'historique des périodes

### Utilisation

```dart
// Obtenir la box utilisateur
final userBox = HiveService.userBox;

// Obtenir la box des paramètres
final settingsBox = HiveService.settingsBox;

// Obtenir la box des périodes
final periodsBox = HiveService.periodsBox;
```

## UserService

Service pour gérer les données utilisateur de manière simplifiée.

### Méthodes principales

- `saveUser(UserModel user)` : Sauvegarder une utilisatrice
- `getUser()` : Obtenir l'utilisatrice actuelle
- `hasUser()` : Vérifier si une utilisatrice existe
- `updateUser(UserModel user)` : Mettre à jour l'utilisatrice
- `deleteUser()` : Supprimer l'utilisatrice
- `watchUser()` : Écouter les changements de l'utilisatrice (Stream)

### Méthodes de mise à jour spécifiques

- `updateLastPeriodDate(DateTime date)` : Mettre à jour la date des dernières règles
- `updateAverageCycleLength(int days)` : Mettre à jour la durée moyenne du cycle
- `updateAveragePeriodLength(int days)` : Mettre à jour la durée moyenne des règles

### Exemple d'utilisation

```dart
// Créer une nouvelle utilisatrice
final user = UserModel(
  id: 'unique-id',
  name: 'Marie',
  averageCycleLength: 28,
  averagePeriodLength: 5,
  createdAt: DateTime.now(),
);

await UserService.saveUser(user);

// Récupérer l'utilisatrice
final currentUser = UserService.getUser();

// Écouter les changements
UserService.watchUser().listen((user) {
  print('Utilisatrice mise à jour: ${user?.name}');
});
```






































