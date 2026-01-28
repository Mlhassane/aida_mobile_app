# AIDA - Assistant IA Flutter

Une application Flutter complète d'assistant IA avec des fonctionnalités avancées, incluant un chat intelligent, un calendrier, des analytics et des paramètres personnalisables.

## 🚀 Fonctionnalités

### 🤖 Chat IA
- Intégration avec Gemini AI pour des conversations intelligentes
- Support du markdown pour les réponses formatées
- Historique des conversations sauvegardé localement
- Interface utilisateur moderne avec animations

### 📅 Calendrier
- Gestion complète des événements avec `table_calendar`
- Ajout, modification et suppression d'événements
- Sélection de couleurs personnalisées
- Vue mensuelle, hebdomadaire et journalière

### 📊 Analytics
- Graphiques interactifs avec `fl_chart`
- Statistiques d'utilisation du chat
- Distribution des événements par mois
- Activité des 7 derniers jours

### ⚙️ Paramètres
- Basculement entre mode clair et sombre
- Gestion des données (export/import)
- Personnalisation des couleurs
- Informations sur l'application

## 🛠️ Technologies utilisées

- **Flutter** - Framework de développement
- **Provider** - Gestion d'état
- **flutter_gemini** - Intégration IA
- **table_calendar** - Calendrier interactif
- **fl_chart** - Graphiques et visualisations
- **flutter_animate** - Animations fluides
- **shared_preferences** - Stockage local
- **iconly** - Icônes modernes
- **intl** - Internationalisation
- **flutter_markdown_plus** - Rendu markdown
- **percent_indicator** - Indicateurs de progression
- **logging** - Journalisation

## 📱 Captures d'écran

L'application comprend 5 écrans principaux :

1. **Accueil** - Vue d'ensemble avec statistiques et actions rapides
2. **Chat** - Interface de conversation avec l'IA
3. **Analytics** - Graphiques et statistiques détaillées
4. **Calendrier** - Gestion des événements
5. **Paramètres** - Configuration de l'application

## 🚀 Installation

1. Clonez le repository :
```bash
git clone https://github.com/votre-username/aida-flutter.git
cd aida-flutter
```

2. Installez les dépendances :
```bash
flutter pub get
```

3. Configurez Gemini AI (optionnel) :
   - Obtenez une clé API sur [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Ajoutez la clé dans votre configuration

4. Lancez l'application :
```bash
flutter run
```

## 📁 Structure du projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── providers/               # Gestionnaires d'état
│   ├── theme_provider.dart
│   ├── chat_provider.dart
│   └── calendar_provider.dart
└── screens/                 # Écrans de l'application
    ├── home_screen.dart
    ├── chat_screen.dart
    ├── analytics_screen.dart
    ├── calendar_screen.dart
    └── settings_screen.dart
```

## 🔧 Configuration

### Dépendances principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.5
  flutter_gemini: ^3.0.0
  table_calendar: ^3.2.0
  fl_chart: ^1.0.0
  flutter_animate: ^4.5.2
  shared_preferences: ^2.5.3
  iconly: ^1.0.1
  intl: ^0.20.2
  flutter_markdown_plus: ^1.0.3
  percent_indicator: ^4.2.5
  logging: ^1.3.0
```

## 🎨 Design

L'application utilise Material Design 3 avec :
- Thème adaptatif (clair/sombre)
- Animations fluides et modernes
- Interface utilisateur intuitive
- Navigation par onglets
- Composants personnalisés

## 📊 Fonctionnalités avancées

### Gestion d'état
- Utilisation de Provider pour une gestion d'état efficace
- Séparation claire entre la logique métier et l'interface

### Persistance des données
- Stockage local avec SharedPreferences
- Sauvegarde automatique des conversations
- Persistance des événements du calendrier

### Animations
- Transitions fluides entre les écrans
- Animations d'entrée pour les éléments
- Effets visuels modernes

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Forkez le projet
2. Créez une branche pour votre fonctionnalité
3. Committez vos changements
4. Poussez vers la branche
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🆘 Support

Si vous rencontrez des problèmes ou avez des questions :

- Ouvrez une issue sur GitHub
- Consultez la documentation
- Contactez l'équipe de développement

## 🔮 Roadmap

Fonctionnalités prévues pour les prochaines versions :

- [ ] Synchronisation cloud
- [ ] Notifications push
- [ ] Support multi-langues
- [ ] Widgets pour l'écran d'accueil
- [ ] Export PDF des conversations
- [ ] Intégration avec d'autres services IA

---

**AIDA** - Votre assistant IA personnel intelligent et moderne ! 🤖✨
