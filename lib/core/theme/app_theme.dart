import 'package:flutter/material.dart';

/// PosterPro dark/gold theme.
///
/// Headings use the platform serif family (Noto Serif on Android) to match
/// the reference design's serif display font, without pulling in a
/// network-fetched font package.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF120E0A);
  static const Color surface = Color(0xFF1C1611);
  static const Color surfaceAlt = Color(0xFF241C15);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF1D98B);
  static const Color textPrimary = Color(0xFFF5EFE3);
  static const Color textSecondary = Color(0xFFB8AA92);
  static const Color textMuted = Color(0xFF8A7D68);
  static const Color danger = Color(0xFFE05C5C);
  static const Color border = Color(0xFF352A1E);
}

class AppTheme {
  AppTheme._();

  static const String serifFontFamily = 'serif';

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    final textTheme = base.textTheme
        .apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        )
        .copyWith(
          headlineLarge: const TextStyle(
            fontFamily: serifFontFamily,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          headlineMedium: const TextStyle(
            fontFamily: serifFontFamily,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          headlineSmall: const TextStyle(
            fontFamily: serifFontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titleLarge: const TextStyle(
            fontFamily: serifFontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.gold,
        secondary: AppColors.goldLight,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: const Color(0xFF1A1206),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      dividerColor: AppColors.border,
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surfaceAlt,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
      ),
    );
  }
}

/// Gold gradient used for primary CTAs like "Generate Poster".
const LinearGradient goldGradient = LinearGradient(
  colors: [AppColors.gold, AppColors.goldLight],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);
