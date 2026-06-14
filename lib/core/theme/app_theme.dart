import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// App Color Palette — PadiGuard Green Agro Theme
class AppColors {
  // Primary Colors (Rice Green)
  static const Color primary = Color(0xFF2E7D32); // Forest Green
  static const Color primaryLight = Color(0xFF60AD5E); // Medium Green
  static const Color primaryDark = Color(0xFF005005); // Deep Forest Green

  // Accent Colors
  static const Color accent = Color(0xFFFF8F00); // Harvest Gold
  static const Color accentLight = Color(0xFFFFBF47); // Light Gold
  static const Color accentDark = Color(0xFFC56000); // Dark Gold

  // Secondary Colors
  static const Color secondary = Color(0xFF00897B); // Teal Green
  static const Color secondaryLight = Color(0xFF4EBAAA); // Light Teal
  static const Color secondaryDark = Color(0xFF005B4F); // Dark Teal

  // Status Colors
  static const Color success = Color(0xFF388E3C); // Green
  static const Color successLight = Color(0xFF81C784); // Light green
  static const Color warning = Color(0xFFF57F17); // Dark Amber
  static const Color warningLight = Color(0xFFFFCC02); // Yellow
  static const Color error = Color(0xFFC62828); // Deep Red
  static const Color errorLight = Color(0xFFEF5350); // Light Red
  static const Color info = Color(0xFF0277BD); // Blue

  // Risk Colors (for disease/harvest risk)
  static const Color riskLow = Color(0xFF388E3C); // Green
  static const Color riskMedium = Color(0xFFF57F17); // Amber
  static const Color riskHigh = Color(0xFFC62828); // Red

  // Background Colors
  static const Color background = Color(0xFFF1F8E9); // Very light green tint
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF9FBF5); // Off white greenish
  static const Color surfaceGreen = Color(0xFFE8F5E9); // Light green surface

  // Text Colors
  static const Color textPrimary = Color(0xFF1B2E1D); // Very dark green/black
  static const Color textSecondary = Color(0xFF4A6741); // Medium dark green
  static const Color textHint = Color(0xFF9DBE96); // Light muted green
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White

  // Border & Divider
  static const Color border = Color(0xFFDCEDC8); // Light green border
  static const Color divider = Color(0xFFEAF4DA); // Very light green divider

  // Gradient helpers
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF8F00), Color(0xFFE65100)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lushGradient = LinearGradient(
    colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Transparent
  static const Color transparent = Color(0x00000000);

  // Skeleton/Loading
  static const Color skeletonBase = Color(0xFFDCEDC8);
  static const Color skeletonHighlight = Color(0xFFF1F8E9);
}

/// App Theme Data
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceGreen,
      labelStyle: _bodySmall(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
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
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(double.infinity, 52),
        textStyle: _labelLarge().copyWith(color: AppColors.textOnPrimary),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(double.infinity, 52),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
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
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      surface: Color(0xFF121A10),
      error: AppColors.errorLight,
      onPrimary: AppColors.textPrimary,
      onSecondary: AppColors.textPrimary,
      onSurface: Color(0xFFE0EDD9),
      onError: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: const Color(0xFF0D1510),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFF1A2618),
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: Color(0xFFB8D4AE)),
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

  static TextStyle _titleLarge() => const TextStyle(
        fontSize: 20,
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

  static TextStyle _bodyLarge() => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle _bodyMedium() => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
        color: AppColors.textPrimary,
        height: 1.43,
      );

  static TextStyle _bodySmall() => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
        color: AppColors.textSecondary,
        height: 1.33,
      );

  static TextStyle _labelLarge() => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle _labelMedium() => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle _labelSmall() => const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );
}
