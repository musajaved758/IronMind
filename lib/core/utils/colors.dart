import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF0F172A);
  static const secondary = Color(0xFF1E293B);
  static const brightPrimary = Color(0xFF3B82F6);
  static const cardBackground = Color(0xFF1E293B);
  static const border = Color(0xFF334155);
  static const selectedBorder = Color(0xFF60A5FA);
  static const glowingGreen = Color(
    0xFF60A5FA,
  ); // Renamed internally but keeping name for compatibility if used elsewhere
  static const iconSelected = Color(0xFF60A5FA);
  static const iconPrimary = Color(0xFF94A3B8);
  static const textPrimaryWhite = Color(0xFFF8FAFC);
  static const textColorGrey = Color(0xFF94A3B8);
  static const white = Color.fromRGBO(255, 255, 255, 0.1);
  static const cardBgUpColor = Color(0xFF334155);
  static const textPrimaryBlack = Color(0xFF0F172A);

  static const lowPriorityColor = Color(0xFF10B981); // Emerald
  static const mediumPriorityColor = Color(0xFFF59E0B); // Amber
  static const highPriorityColor = Color(0xFFEF4444); // Red
}

class AppGradient {
  static const cardGradient = LinearGradient(
    colors: [AppColors.white, AppColors.cardBackground, AppColors.glowingGreen],
    stops: [1, 2, 3],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

/// Theme-aware color scheme that adapts to light/dark mode.
/// Usage: `final colors = Theme.of(context).appColors;`
class AppColorScheme {
  final Color bg;
  final Color surface;
  final Color cardBg;
  final Color primary;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color navBar;
  final Color navBarBorder;
  final Color iconActive;
  final Color iconInactive;
  final Color divider;
  final Color calendarDayBg;
  final Color calendarDayText;
  final Color calendarSelectedBg;
  final Color calendarSelectedText;
  final Color calendarTodayBorder;
  final Color progressBarBg;
  final Color dialogBg;
  final Color chipBg;
  final Color chipBorder;

  const AppColorScheme({
    required this.bg,
    required this.surface,
    required this.cardBg,
    required this.primary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.navBar,
    required this.navBarBorder,
    required this.iconActive,
    required this.iconInactive,
    required this.divider,
    required this.calendarDayBg,
    required this.calendarDayText,
    required this.calendarSelectedBg,
    required this.calendarSelectedText,
    required this.calendarTodayBorder,
    required this.progressBarBg,
    required this.dialogBg,
    required this.chipBg,
    required this.chipBorder,
  });

  // ── Dark Theme (current blueish) ──
  static const dark = AppColorScheme(
    bg: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    cardBg: Color(0xFF1E293B),
    primary: Color(0xFF2563EB),
    accent: Color(0xFF3B82F6),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    border: Color(0xFF334155),
    navBar: Color(0xFF1E293B),
    navBarBorder: Color(0xFF334155),
    iconActive: Color(0xFF2563EB),
    iconInactive: Color(0xFF64748B),
    divider: Color(0xFF334155),
    calendarDayBg: Color(0xFF1E293B),
    calendarDayText: Color(0xFFCBD5E1),
    calendarSelectedBg: Color(0xFF2563EB),
    calendarSelectedText: Color(0xFFFFFFFF),
    calendarTodayBorder: Color(0xFF2563EB),
    progressBarBg: Color(0xFF334155),
    dialogBg: Color(0xFF1E293B),
    chipBg: Color(0xFF334155),
    chipBorder: Color(0xFF475569),
  );

  // ── Light Theme (white + blue from Figma) ──
  static const light = AppColorScheme(
    bg: Color(0xFFF0F4FF), // soft blue-white
    surface: Color(0xFFFFFFFF), // white cards
    cardBg: Color(0xFFFFFFFF),
    primary: Color(0xFF4F46E5), // indigo
    accent: Color(0xFF6366F1), // lighter indigo
    textPrimary: Color(0xFF1E293B), // dark navy
    textSecondary: Color(0xFF64748B), // slate grey
    textMuted: Color(0xFF94A3B8), // lighter grey
    border: Color(0xFFE2E8F0), // light grey border
    navBar: Color(0xFFFFFFFF),
    navBarBorder: Color(0xFFE2E8F0),
    iconActive: Color(0xFF4F46E5),
    iconInactive: Color(0xFF94A3B8),
    divider: Color(0xFFE2E8F0),
    calendarDayBg: Color(0xFFEEF2FF), // very light indigo
    calendarDayText: Color(0xFF475569),
    calendarSelectedBg: Color(0xFF4F46E5),
    calendarSelectedText: Color(0xFFFFFFFF),
    calendarTodayBorder: Color(0xFF4F46E5),
    progressBarBg: Color(0xFFE2E8F0),
    dialogBg: Color(0xFFFFFFFF),
    chipBg: Color(0xFFEEF2FF),
    chipBorder: Color(0xFFCBD5E1),
  );
}

/// Extension to access AppColorScheme from ThemeData
extension AppColorSchemeExtension on ThemeData {
  AppColorScheme get appColors => brightness == Brightness.dark
      ? AppColorScheme.dark
      : AppColorScheme.light;
}
