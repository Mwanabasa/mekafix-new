import 'package:flutter/material.dart';

class MekaTheme {
  static const seed = Color(0xFF0B6E4F);
  static const amber = Color(0xFFF4A261);
  static const ink = Color(0xFF10231C);

  static ThemeData light(TextTheme textTheme) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
    return ThemeData(
      colorScheme: scheme.copyWith(secondary: amber),
      textTheme: textTheme.apply(bodyColor: ink, displayColor: ink),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF3F7F5),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
