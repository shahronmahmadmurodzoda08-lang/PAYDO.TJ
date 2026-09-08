import 'package:flutter/material.dart';

/// Палитаи рангии ягонаи PAYDO.TJ.
/// Ранги асосӣ — сабзи PAYDO (боварӣ, савдо, амният).
class AppColors {
  AppColors._();

  // Brand
  static const primary = Color(0xFF12B76A); // PAYDO green
  static const primaryDark = Color(0xFF0A8F52);
  static const primaryLight = Color(0xFFD1FADF);
  static const secondary = Color(0xFF2563EB); // trust blue (accents/links)

  // Neutral (Light)
  static const backgroundLight = Color(0xFFF9FAFB);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textPrimaryLight = Color(0xFF101828);
  static const textSecondaryLight = Color(0xFF667085);
  static const borderLight = Color(0xFFE4E7EC);

  // Neutral (Dark)
  static const backgroundDark = Color(0xFF0F1115);
  static const surfaceDark = Color(0xFF1A1D23);
  static const textPrimaryDark = Color(0xFFF2F4F7);
  static const textSecondaryDark = Color(0xFF98A2B3);
  static const borderDark = Color(0xFF2A2E37);

  // Semantic
  static const success = Color(0xFF12B76A);
  static const warning = Color(0xFFF79009);
  static const error = Color(0xFFF04438);
  static const info = Color(0xFF2563EB);
}
