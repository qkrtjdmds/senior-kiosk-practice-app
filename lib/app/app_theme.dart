import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFF7F3EA);
  static const surface = Color(0xFFFFFDF8);
  static const primary = Color(0xFF21324A);
  static const primaryContainer = Color(0xFFDDE5F0);
  static const sage = Color(0xFF71866F);
  static const sageContainer = Color(0xFFE5ECE2);
  static const cream = Color(0xFFF2E8D8);
  static const textPrimary = Color(0xFF202A35);
  static const textSecondary = Color(0xFF58616B);
  static const divider = Color(0xFFDDD8CF);
  static const warning = Color(0xFF87662F);
  static const error = Color(0xFF8A3F3B);
}

abstract final class AppSpacing {
  static const xxs = 4.0, xs = 8.0, sm = 12.0, md = 16.0;
  static const lg = 20.0, xl = 24.0, xxl = 32.0;
}

abstract final class AppRadius {
  static const small = 12.0, medium = 16.0, large = 24.0;
}

abstract final class AppSizes {
  static const touchTarget = 48.0;
  static const buttonHeight = 56.0;
  static const choiceHeight = 72.0;
  static const appBarHeight = 68.0;
}

ThemeData buildAppTheme({bool highContrast = false}) {
  final primary = highContrast ? const Color(0xFF14243A) : AppColors.primary;
  final background = highContrast ? Colors.white : AppColors.background;
  final baseScheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.light,
    surface: highContrast ? Colors.white : AppColors.surface,
    surfaceContainerLowest: highContrast ? Colors.white : AppColors.surface,
    surfaceContainerHighest: highContrast
        ? const Color(0xFFE3E8E6)
        : const Color(0xFFE7EEF0),
  );
  final colorScheme = highContrast
      ? baseScheme.copyWith(
          primary: const Color(0xFF14243A),
          onPrimary: Colors.white,
          onSurface: const Color(0xFF101413),
          outline: const Color(0xFF303840),
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
          : AppColors.primary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: AppSizes.appBarHeight,
    ),
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        color: highContrast ? const Color(0xFF101413) : AppColors.textPrimary,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      titleLarge: TextStyle(
        color: highContrast ? const Color(0xFF101413) : AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      bodyLarge: TextStyle(
        color: highContrast ? const Color(0xFF101413) : AppColors.textPrimary,
        fontSize: 20,
        height: 1.5,
      ),
      labelLarge: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: highContrast ? Colors.white : AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorScheme.secondaryContainer,
      contentTextStyle: TextStyle(
        color: colorScheme.onSecondaryContainer,
        fontSize: 18,
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
