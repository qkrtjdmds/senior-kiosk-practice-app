import 'package:flutter/material.dart';

ThemeData buildAppTheme({bool highContrast = false}) {
  final primary = highContrast
      ? const Color(0xFF064E3B)
      : const Color(0xFF286A5B);
  final background = highContrast
      ? const Color(0xFFFFFFFF)
      : const Color(0xFFF7F8F2);
  final baseScheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.light,
    surface: background,
    surfaceContainerLowest: Colors.white,
    surfaceContainerHighest: highContrast
        ? const Color(0xFFE3E8E6)
        : const Color(0xFFE7EEF0),
  );
  final colorScheme = highContrast
      ? baseScheme.copyWith(
          primary: const Color(0xFF064E3B),
          onPrimary: Colors.white,
          onSurface: const Color(0xFF101413),
          outline: const Color(0xFF25332F),
          outlineVariant: const Color(0xFF596963),
        )
      : baseScheme;

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: highContrast
          ? const Color(0xFF101413)
          : const Color(0xFF173D36),
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        color: highContrast ? const Color(0xFF101413) : const Color(0xFF173D36),
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      titleLarge: TextStyle(
        color: highContrast ? const Color(0xFF101413) : const Color(0xFF173D36),
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      bodyLarge: TextStyle(
        color: highContrast ? const Color(0xFF101413) : const Color(0xFF36544D),
        fontSize: 20,
        height: 1.5,
      ),
      labelLarge: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
    ),
  );
}
