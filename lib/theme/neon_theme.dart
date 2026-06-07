import 'package:flutter/material.dart';

class NeonColors {
  static const Color background = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF131A26);
  static const Color cyan = Color(0xFF00FFFF);
  static const Color cyanGlow = Color(0x6600FFFF);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF8B9BB4);
  static const Color borderGlow = Color(0x3300FFFF);
  static const Color danger = Color(0xFFFF0055);
}

class NeonTheme {
  static ThemeData get theme => ThemeData(
        fontFamily: 'Inter', // Assuming Inter or system font
        scaffoldBackgroundColor: NeonColors.background,
        brightness: Brightness.dark,
        primaryColor: NeonColors.cyan,
        colorScheme: const ColorScheme.dark(
          primary: NeonColors.cyan,
          secondary: NeonColors.cyan,
          surface: NeonColors.surface,
          error: NeonColors.danger,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: NeonColors.textLight,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: NeonColors.textLight),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: NeonColors.cyan,
          foregroundColor: NeonColors.background,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: NeonColors.cyan,
          selectionColor: NeonColors.cyanGlow,
          selectionHandleColor: NeonColors.cyan,
        ),
      );
}
