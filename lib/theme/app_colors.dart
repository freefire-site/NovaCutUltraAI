import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0B0B0F);
  static const Color surface = Color(0xFF17171C);

  static const Color primary = Color(0xFF7B61FF);
  static const Color secondary = Color(0xFF00C2FF);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB3B3C2);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF7B61FF),
      Color(0xFF00C2FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
