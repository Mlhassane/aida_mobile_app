import 'package:flutter/material.dart';
import 'hive_service.dart';

enum AppThemeMode { light, dark, system }

// Couleurs de thème disponibles
const List<Color> aidaThemeColors = [
  Color(0xFFE91E63), // Pink principal
  Color(0xFF9C27B0), // Purple
  Color(0xFF2196F3), // Blue
  Color(0xFF4CAF50), // Green
  Color(0xFFFF5722), // Deep Orange
  Color(0xFF3F51B5), // Indigo
  Color(0xFF009688), // Teal
  Color(0xFF795548), // Brown
  Color(0xFF607D8B), // Blue Grey
  Color(0xFFFFC107), // Amber
];

class ThemeService extends ChangeNotifier {
  static const String themeKey = 'themeMode';
  static const String seedColorKey = 'seedColor';
  static const String fontFamilyKey = 'fontFamily';

  AppThemeMode _themeMode = AppThemeMode.system;
  Color _seedColor = aidaThemeColors[0]; // Pink par défaut
  String _fontFamily =
      'Outfit'; // 'Outfit' par défaut pour une esthétique premium

  ThemeService() {
    _loadTheme();
  }

  AppThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;
  String get fontFamily => _fontFamily;

  void _loadTheme() {
    final box = HiveService.settingsBox;
    final savedTheme = box.get(themeKey);
    final savedColor = box.get(seedColorKey);
    final savedFont = box.get(fontFamilyKey);

    if (savedTheme != null) {
      _themeMode = AppThemeMode.values[savedTheme];
    }

    if (savedColor != null) {
      _seedColor = Color(savedColor);
    }

    if (savedFont != null) {
      _fontFamily = savedFont;
    }

    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    final box = HiveService.settingsBox;
    await box.put(themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    final box = HiveService.settingsBox;
    await box.put(seedColorKey, color.value);
    notifyListeners();
  }

  Future<void> setFontFamily(String family) async {
    _fontFamily = family;
    final box = HiveService.settingsBox;
    await box.put(fontFamilyKey, family);
    notifyListeners();
  }

  ThemeMode getEffectiveThemeMode(BuildContext? context) {
    if (_themeMode == AppThemeMode.system && context != null) {
      final brightness = MediaQuery.platformBrightnessOf(context);
      return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
    return _themeMode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light;
  }

  bool isDarkMode(BuildContext? context) {
    return getEffectiveThemeMode(context) == ThemeMode.dark;
  }

  String get themeModeLabel {
    switch (_themeMode) {
      case AppThemeMode.light:
        return 'Clair';
      case AppThemeMode.dark:
        return 'Sombre';
      case AppThemeMode.system:
        return 'Système';
    }
  }
}
