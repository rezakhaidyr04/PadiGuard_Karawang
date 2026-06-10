import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// App Color Palette
class AppColors {
  // Primary Colors (Green theme - Agriculture)
  static const Color primary = Color(0xFF2E7D32); // Deep green
  static const Color primaryLight = Color(0xFF66BB6A); // Light green
  static const Color primaryDark = Color(0xFF1B5E20); // Very dark green

  // Secondary Colors
  static const Color secondary = Color(0xFFF57C00); // Orange (harvest/warning)
  static const Color secondaryLight = Color(0xFFFFB74D); // Light orange
  static const Color secondaryDark = Color(0xFFE65100); // Dark orange

  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color successLight = Color(0xFF81C784); // Light green
  static const Color warning = Color(0xFFFFC107); // Amber
  static const Color error = Color(0xFFF44336); // Red
  static const Color info = Color(0xFF2196F3); // Blue

  // Risk Colors (for disease/harvest risk)
  static const Color riskLow = Color(0xFF4CAF50); // Green
  static const Color riskMedium = Color(0xFFFFC107); // Amber
  static const Color riskHigh = Color(0xFFF44336); // Red

  // Background Colors
  static const Color background = Color(0xFFFAFAFA); // Light gray
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Very light gray

  // Text Colors
  static const Color textPrimary = Color(0xFF212121); // Dark gray
  static const Color textSecondary = Color(0xFF757575); // Medium gray
  static const Color textHint = Color(0xFFBDBDBD); // Light gray
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White

  // Border & Divider
  static const Color border = Color(0xFFE0E0E0); // Light gray
  static const Color divider = Color(0xFFEEEEEE); // Very light gray

  // Transparent
  static const Color transparent = Color(0x00000000);

  // Skeleton/Loading
  static const Color skeletonBase = Color(0xFFE0E0E0);
  static const Color skeletonHighlight = Color(0xFFF5F5F5);
}

/// App Theme Data
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.textOnPrimary,
      onSecondary: AppColors.textOnPrimary,
      onSurface: AppColors.textPrimary,
      onError: AppColors.textOnPrimary,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: _titleLarge(),
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      hintStyle: _bodyMedium().copyWith(color: AppColors.textHint),
      labelStyle: _bodyMedium().copyWith(color: AppColors.textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 48),
        textStyle: _labelLarge().copyWith(color: AppColors.textOnPrimary),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: _displayLarge(),
      displayMedium: _displayMedium(),
      displaySmall: _displaySmall(),
      headlineLarge: _headlineLarge(),
      headlineMedium: _headlineMedium(),
      headlineSmall: _headlineSmall(),
      titleLarge: _titleLarge(),
      titleMedium: _titleMedium(),
      titleSmall: _titleSmall(),
      bodyLarge: _bodyLarge(),
      bodyMedium: _bodyMedium(),
      bodySmall: _bodySmall(),
      labelLarge: _labelLarge(),
      labelMedium: _labelMedium(),
      labelSmall: _labelSmall(),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      surface: Color(0xFF121212),
      error: Color(0xFFCF6679),
      onPrimary: AppColors.textPrimary,
      onSecondary: AppColors.textPrimary,
      onSurface: Color(0xFFE0E0E0),
      onError: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: const Color(0xFF1E1E1E),
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Color(0xFFE0E0E0)),
      titleTextStyle: _titleLarge(),
    ),
  );

  // Text Styles - Display
  static TextStyle _displayLarge() => const TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        fontFamily: 'Poppins',
        color: AppColors.textPrimary,
        letterSpacing: -0.25,
      );

  static TextStyle _displayMedium() => const TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        fontFamily: 'Poppins',
        color: AppColors.textPrimary,
      );

  static TextStyle _displaySmall() => const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        fontFamily: 'Poppins',
        color: AppColors.textPrimary,
      );

  // Text Styles - Headline
  static TextStyle _headlineLarge() => const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        fontFamily: 'Poppins',
        color: AppColors.textPrimary,
      );

  static TextStyle _headlineMedium() => const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        fontFamily: 'Poppins',
        color: AppColors.textPrimary,
      );

  static TextStyle _headlineSmall() => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        fontFamily: 'Poppins',
        color: AppColors.textPrimary,
      );

  // Text Styles - Title
  static TextStyle _titleLarge() => const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
        color: AppColors.textPrimary,
      );

  static TextStyle _titleMedium() => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
        color: AppColors.textPrimary,
      );

  static TextStyle _titleSmall() => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
        color: AppColors.textPrimary,
      );

  // Text Styles - Body
  static TextStyle _bodyLarge() => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontFamily: 'InterTight',
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle _bodyMedium() => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'InterTight',
        color: AppColors.textPrimary,
        height: 1.43,
      );

  static TextStyle _bodySmall() => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: 'InterTight',
        color: AppColors.textSecondary,
        height: 1.33,
      );

  // Text Styles - Label
  static TextStyle _labelLarge() => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'InterTight',
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle _labelMedium() => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: 'InterTight',
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle _labelSmall() => const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        fontFamily: 'InterTight',
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );
}
