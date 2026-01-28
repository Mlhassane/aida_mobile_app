# Modèles de données

## UserModel

Le modèle `UserModel` représente les données de l'utilisatrice dans l'application de suivi menstruel.

### Champs principaux

- **id** : Identifiant unique de l'utilisatrice
- **name** : Nom de l'utilisatrice
- **dateOfBirth** : Date de naissance (optionnel)
- **lastPeriodDate** : Date des dernières règles
- **averageCycleLength** : Durée moyenne du cycle en jours (défaut: 28)
- **averagePeriodLength** : Durée moyenne des règles en jours (défaut: 5)
- **weight** : Poids en kg (optionnel)
- **height** : Taille en cm (optionnel)
- **notificationsEnabled** : Activation des notifications (défaut: true)
- **profileImagePath** : Chemin vers l'image de profil (optionnel)

### Méthodes utiles

- `age` : Calcule l'âge à partir de la date de naissance
- `nextPeriodDate` : Calcule la date de la prochaine période prévue
- `daysUntilNextPeriod` : Nombre de jours jusqu'à la prochaine période
- `isCurrentlyOnPeriod` : Vérifie si l'utilisatrice est actuellement en période

### Génération des adaptateurs Hive

Pour générer les adaptateurs Hive après modification du modèle, exécutez :

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```


## UserModel

Le modèle `UserModel` représente les données de l'utilisatrice dans l'application de suivi menstruel.

### Champs principaux

- **id** : Identifiant unique de l'utilisatrice
- **name** : Nom de l'utilisatrice
- **dateOfBirth** : Date de naissance (optionnel)
- **lastPeriodDate** : Date des dernières règles
- **averageCycleLength** : Durée moyenne du cycle en jours (défaut: 28)
- **averagePeriodLength** : Durée moyenne des règles en jours (défaut: 5)
- **weight** : Poids en kg (optionnel)
- **height** : Taille en cm (optionnel)
- **notificationsEnabled** : Activation des notifications (défaut: true)
- **profileImagePath** : Chemin vers l'image de profil (optionnel)

### Méthodes utiles

- `age` : Calcule l'âge à partir de la date de naissance
- `nextPeriodDate` : Calcule la date de la prochaine période prévue
- `daysUntilNextPeriod` : Nombre de jours jusqu'à la prochaine période
- `isCurrentlyOnPeriod` : Vérifie si l'utilisatrice est actuellement en période

### Génération des adaptateurs Hive

Pour générer les adaptateurs Hive après modification du modèle, exécutez :

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```


## UserModel

Le modèle `UserModel` représente les données de l'utilisatrice dans l'application de suivi menstruel.

### Champs principaux

- **id** : Identifiant unique de l'utilisatrice
- **name** : Nom de l'utilisatrice
- **dateOfBirth** : Date de naissance (optionnel)
- **lastPeriodDate** : Date des dernières règles
- **averageCycleLength** : Durée moyenne du cycle en jours (défaut: 28)
- **averagePeriodLength** : Durée moyenne des règles en jours (défaut: 5)
- **weight** : Poids en kg (optionnel)
- **height** : Taille en cm (optionnel)
- **notificationsEnabled** : Activation des notifications (défaut: true)
- **profileImagePath** : Chemin vers l'image de profil (optionnel)

### Méthodes utiles

- `age` : Calcule l'âge à partir de la date de naissance
- `nextPeriodDate` : Calcule la date de la prochaine période prévue
- `daysUntilNextPeriod` : Nombre de jours jusqu'à la prochaine période
- `isCurrentlyOnPeriod` : Vérifie si l'utilisatrice est actuellement en période

### Génération des adaptateurs Hive

Pour générer les adaptateurs Hive après modification du modèle, exécutez :

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

























