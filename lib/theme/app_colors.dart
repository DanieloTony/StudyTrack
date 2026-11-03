import 'package:flutter/material.dart';

/// Earth & Espresso palette and semantic colors for StudyTrack.
abstract final class AppColors {
  // Core Earth & Espresso tokens
  static const Color espresso = Color(0xFF1A120E);
  static const Color darkCocoa = Color(0xFF3A2418);
  static const Color walnut = Color(0xFF6B4A2E);
  static const Color caramel = Color(0xFFA88462);
  static const Color warmSand = Color(0xFFD5C4AE);
  static const Color charcoal = Color(0xFF4A4A46);

  // Light Theme Surfaces & Backgrounds
  static const Color background = Color(0xFFFAF7F2); // Warm off-white
  static const Color secondaryBackground = Color(0xFFF4ECE3);
  static const Color surface = Color(0xFFFFFFFF); // Clean white card
  static const Color softSage = warmSand;
  static const Color border = Color(0xFFEADBCE); // Subtle warm card outline

  // Light Theme Typography & Actions
  static const Color textPrimary = espresso;
  static const Color textSecondary = charcoal;
  static const Color textSecondaryStrong = Color(0xFF2E2E2C);
  static const Color primary = walnut;
  static const Color primaryPressed = Color(0xFF533923);
  static const Color accent = caramel;

  // Dark Theme Surfaces & Backgrounds
  static const Color darkBackground = espresso; // #1A120E
  static const Color darkSurface = darkCocoa; // #3A2418
  static const Color darkRaised = Color(0xFF4A3123);
  static const Color darkBorder = Color(0xFF4E3322);
  static const Color darkSoftSage = Color(0xFF332015);

  // Dark Theme Typography & Actions
  static const Color darkText = warmSand; // #D5C4AE
  static const Color darkTextSecondary = caramel; // #A88462
  static const Color darkMeta = Color(0xFF8C6E52);
  static const Color darkPrimary = walnut; // #6B4A2E

  // Status Cues (Harmonized with earthy palette)
  static const Color success = Color(0xFF2E6B4A);
  static const Color darkSuccess = Color(0xFF5DB883);
  static const Color warning = Color(0xFFBD722B);
  static const Color darkWarning = Color(0xFFE5974C);
  static const Color error = Color(0xFFA6392D);
  static const Color darkError = Color(0xFFE26859);

  // Border & Glass Highlights
  static const Color glassLightBorder = Color(0x336B4A2E);
  static const Color glassDarkBorder = Color(0x33D5C4AE);
}
