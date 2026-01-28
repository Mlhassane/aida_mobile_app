import 'package:flutter/material.dart';

class ThemeColors {
  static const List<Color> aidaSeedColors = [
    Color(0xFFFF85A1), // Pink (Default)
    Color(0xFF8B5CF6), // Purple
    Color(0xFF3B82F6), // Blue
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFF6366F1), // Indigo
    Color(0xFFF43F5E), // Rose
  ];

  // Couleur primaire du thème (seed color)
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  // deriveColor creates variants of the primary color to keep themes uniform
  static Color _deriveColor(
    BuildContext context,
    double strength, [
    Color fallback = Colors.grey,
  ]) {
    final primary = getPrimaryColor(context);
    return Color.lerp(primary, fallback, strength) ?? primary;
  }

  // Cycle Phase Colors (Derived from primary for uniformity)
  static Color getPeriodColor(BuildContext context) => getPrimaryColor(context);
  static Color getFertilityColor(BuildContext context) =>
      _deriveColor(context, 0.3, Colors.white);
  static Color getOvulationColor(BuildContext context) =>
      _deriveColor(context, 0.4, Colors.black);
  static Color getNormalDayColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Colors.grey.shade800
      : Colors.grey.shade300;

  // Simplified Gradients for Premium Design
  static LinearGradient getPhaseGradient(BuildContext context, String phase) {
    final primary = getPrimaryColor(context);
    return LinearGradient(
      colors: [primary.withOpacity(0.12), primary.withOpacity(0.02)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Shadow Colors
  static Color getShadowColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Colors.black.withOpacity(0.4)
      : getPrimaryColor(context).withOpacity(0.08);

  static Color getShadowLight(BuildContext context) =>
      getPrimaryColor(context).withOpacity(0.05);

  static Color getShadowDark(BuildContext context) =>
      Colors.black.withOpacity(0.2);

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.color ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : const Color(0xFF1A1A1A));
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.color ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade400
            : Colors.grey.shade600);
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFF0F0F0);
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1A1A1A)
        : const Color(0xFFFAFAFA);
  }

  // Couleur d'erreur
  static Color getErrorColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  // Couleur pour les actions rapides
  static Color getActionColor(BuildContext context, {int index = 0}) {
    final primary = getPrimaryColor(context);
    final List<Color> variants = [
      primary,
      _deriveColor(context, 0.2, Colors.black),
      _deriveColor(context, 0.2, Colors.white),
    ];
    return variants[index % variants.length];
  }

  static Color getStatsColor(BuildContext context) => getPrimaryColor(context);

  static Color getSecondaryActionColor(BuildContext context) =>
      _deriveColor(context, 0.4, Colors.grey);

  static const List<String> availableFonts = [
    'System',
    'Poppins',
    'Roboto',
    'Open Sans',
    'Montserrat',
    'Instrument Serif',
    'Lato',
  ];
}
