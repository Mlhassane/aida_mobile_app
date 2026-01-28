import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Helper to get TextTheme based on font family name
  static TextTheme _getTextTheme(
    String fontFamily, [
    TextTheme? baseTextTheme,
  ]) {
    final theme = baseTextTheme ?? const TextTheme();
    switch (fontFamily) {
      case 'Poppins':
        return GoogleFonts.poppinsTextTheme(theme);
      case 'Roboto':
        return GoogleFonts.robotoTextTheme(theme);
      case 'Open Sans':
        return GoogleFonts.openSansTextTheme(theme);
      case 'Montserrat':
        return GoogleFonts.montserratTextTheme(theme);
      case 'Instrument Serif':
        return GoogleFonts.instrumentSerifTextTheme(theme);
      case 'Lato':
        return GoogleFonts.latoTextTheme(theme);
      case 'Outfit':
        return GoogleFonts.outfitTextTheme(theme);
      case 'System':
      default:
        return theme;
    }
  }

  static ThemeData _buildTheme(
    Brightness brightness,
    Color seedColor,
    String fontFamily,
  ) {
    final isDark = brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF0F0F0F)
        : const Color(0xFFFDFDFD);
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final surfaceColor = isDark
        ? const Color(0xFF1A1A1A)
        : const Color(0xFFF5F5F5);
    final textColor = isDark ? Colors.white : const Color(0xFF121212);
    final secondaryTextColor = isDark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
    final borderColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFEEEEEE);

    final TextTheme baseTextTheme = TextTheme(
      bodyLarge: TextStyle(color: textColor, letterSpacing: -0.2),
      bodyMedium: TextStyle(color: textColor, letterSpacing: -0.2),
      bodySmall: TextStyle(color: secondaryTextColor, letterSpacing: -0.1),
      titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: seedColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        primary: seedColor,
        brightness: brightness,
        surface: cardColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      dividerTheme: DividerThemeData(color: borderColor, thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: seedColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      textTheme: _getTextTheme(fontFamily, baseTextTheme),
    );
  }

  static ThemeData lightTheme(Color seedColor, String fontFamily) {
    return _buildTheme(Brightness.light, seedColor, fontFamily);
  }

  static ThemeData darkTheme(Color seedColor, String fontFamily) {
    return _buildTheme(Brightness.dark, seedColor, fontFamily);
  }
}
