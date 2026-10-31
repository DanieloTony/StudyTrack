import 'package:flutter/material.dart';

/// Central colour palette for StudyTrack.
/// Keep all app colours in this file for easy maintenance.
abstract final class AppColors {
  // Sage green
  static const Color primary = Color(0xFF6B8F71);
  static const Color primaryPressed = Color(0xFF55765B);

  // Cream backgrounds
  static const Color background = Color(0xFFF7F5EC);
  static const Color secondaryBackground = Color(0xFFF0F0E5);
  static const Color surface = Color(0xFFFFFDF8);
  static const Color softSage = Color(0xFFE7EFE4);

  // Text
  static const Color textPrimary = Color(0xFF28352D);
  static const Color textSecondary = Color(0xFF737C70);
  static const Color textSecondaryStrong = Color(0xFF5D665C);

  // Status colours
  static const Color accent = Color(0xFFD6A756);
  static const Color success = Color(0xFF4F7A58);
  static const Color warning = Color(0xFFB7791F);
  static const Color error = Color(0xFFB94A48);

  // Borders
  static const Color border = Color(0xFFE3E6DA);

  // Dark mode
  static const Color darkBackground = Color(0xFF0C0D0F);
  static const Color darkSurface = Color(0xFF15171A);
  static const Color darkRaised = Color(0xFF222529);
  static const Color darkBorder = Color(0xFF30343A);
  static const Color darkText = Color(0xFFF4F5F7);
  static const Color darkTextSecondary = Color(0xFFB4B4B4);
  static const Color darkMeta = Color(0xFF949494);
  static const Color darkPrimary = Color(0xFF4CB3F0);
  static const Color darkSuccess = Color(0xFF10B981);
  static const Color darkWarning = Color(0xFFF2B33D);
  static const Color darkError = Color(0xFFF16C72);
  static const Color darkSoftSage = Color(0xFF20272C);
}
