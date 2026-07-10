import 'package:flutter/material.dart';

/// جميع ألوان التطبيق في مكان واحد — لا تكتب Color(0x...) مباشرة في أي شاشة
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1E5C8A);
  static const Color primaryDark = Color(0xFF123B5C);
  static const Color secondary = Color(0xFFE8A33D);

  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1A1D1F);
  static const Color textSecondary = Color(0xFF6F767E);
  static const Color textHint = Color(0xFFB0B6BD);

  static const Color success = Color(0xFF3AA76D);
  static const Color warning = Color(0xFFE8A33D);
  static const Color error = Color(0xFFD64545);

  static const Color border = Color(0xFFE5E7EB);
  static const Color favoriteRed = Color(0xFFE84C4C);
  static const accent = Color(0xFFE7A94C); // warm gold — price, badges
  static const saleBadge = Color(0xFF0E6E5C);
  static const rentBadge = Color(0xFF3E6FE0);

  static const divider = Color(0xFFE7ECEA);

  static const shimmerBase = Color(0xFFE9EDEC);
  static const shimmerHighlight = Color(0xFFF6F8F7);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
}
