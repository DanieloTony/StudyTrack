import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => _buildTheme(
    brightness: Brightness.light,
    background: AppColors.background,
    surface: AppColors.surface,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.accent,
    onSecondary: AppColors.espresso,
    text: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    border: AppColors.border,
    inputFill: AppColors.surface,
    navigationIndicator: AppColors.caramel.withValues(alpha: 0.18),
    error: AppColors.error,
  );

  static ThemeData get dark => _buildTheme(
    brightness: Brightness.dark,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkText,
    secondary: AppColors.caramel,
    onSecondary: AppColors.espresso,
    text: AppColors.darkText,
    textSecondary: AppColors.darkTextSecondary,
    border: AppColors.darkBorder,
    inputFill: AppColors.darkRaised,
    navigationIndicator: AppColors.caramel.withValues(alpha: 0.25),
    error: AppColors.darkError,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color onSecondary,
    required Color text,
    required Color textSecondary,
    required Color border,
    required Color inputFill,
    required Color navigationIndicator,
    required Color error,
  }) {
    final isDark = brightness == Brightness.dark;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.card),
      side: BorderSide(color: border),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.control),
      borderSide: BorderSide(color: border),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: onSecondary,
        surface: surface,
        onSurface: text,
        onSurfaceVariant: textSecondary,
        error: error,
        onError: isDark ? AppColors.darkBackground : Colors.white,
        outline: border,
        outlineVariant: border,
      ),
      textTheme: _textTheme(text, textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.35,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: shape,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: BorderSide(color: primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: BorderSide(color: error, width: 1.6),
        ),
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: primary,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface.withValues(alpha: isDark ? 0.96 : 0.92),
        indicatorColor: navigationIndicator,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);

          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? primary : textSecondary,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
      ),
      dividerColor: border,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.darkRaised : AppColors.textPrimary,
        contentTextStyle: TextStyle(
          color: isDark ? AppColors.darkText : Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color text, Color textSecondary) {
    final base = Typography.material2021().black;

    TextStyle? style(TextStyle? source, {FontWeight? weight}) {
      return source?.copyWith(
        color: text,
        fontWeight: weight,
        letterSpacing: -0.2,
      );
    }

    return base.copyWith(
      displayLarge: style(base.displayLarge, weight: FontWeight.w700),
      displayMedium: style(base.displayMedium, weight: FontWeight.w700),
      displaySmall: style(base.displaySmall, weight: FontWeight.w700),
      headlineLarge: style(base.headlineLarge, weight: FontWeight.w700),
      headlineMedium: style(base.headlineMedium, weight: FontWeight.w700),
      headlineSmall: style(base.headlineSmall, weight: FontWeight.w700),
      titleLarge: style(base.titleLarge, weight: FontWeight.w700),
      titleMedium: style(base.titleMedium, weight: FontWeight.w600),
      titleSmall: style(base.titleSmall, weight: FontWeight.w600),
      bodyLarge: style(
        base.bodyLarge,
        weight: FontWeight.w400,
      )?.copyWith(color: text),
      bodyMedium: style(
        base.bodyMedium,
        weight: FontWeight.w400,
      )?.copyWith(color: text),
      bodySmall: style(
        base.bodySmall,
        weight: FontWeight.w400,
      )?.copyWith(color: textSecondary),
      labelLarge: style(base.labelLarge, weight: FontWeight.w600),
      labelMedium: style(base.labelMedium, weight: FontWeight.w500),
      labelSmall: style(base.labelSmall, weight: FontWeight.w500),
    );
  }
}

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class AppRadii {
  static const double control = 12;
  static const double compact = 16;
  static const double card = 20;
  static const double panel = 24;
  static const double pill = 999;
}

abstract final class AppShadows {
  static const List<BoxShadow> glass = [
    BoxShadow(
      color: Color(0x0D1A120E),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x1A1A120E),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];
}
