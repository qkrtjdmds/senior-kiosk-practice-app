import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const primary = Color(0xFF286A5B);
  const background = Color(0xFFF7F8F2);

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: background,
      surfaceContainerLowest: Colors.white,
      surfaceContainerHighest: Color(0xFFE7EEF0),
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: Color(0xFF173D36),
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: Color(0xFF173D36),
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      titleLarge: TextStyle(
        color: Color(0xFF173D36),
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      bodyLarge: TextStyle(color: Color(0xFF36544D), fontSize: 20, height: 1.5),
      labelLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
    ),
  );
}
