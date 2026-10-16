import 'package:flutter/material.dart';

/// Color tokens from the approved prototype (ui-ux-pro-max: dark OLED, terminal green).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.raised,
    required this.line,
    required this.fg,
    required this.fg2,
    required this.accent,
    required this.onAccent,
    required this.info,
    required this.danger,
  });

  final Color bg, surface, raised, line, fg, fg2, accent, onAccent, info, danger;

  static const dark = AppColors(
    bg: Color(0xFF0B1222),
    surface: Color(0xFF141C2E),
    raised: Color(0xFF1B2438),
    line: Color(0xFF2A3650),
    fg: Color(0xFFEEF2F8),
    fg2: Color(0xFF93A0B8),
    accent: Color(0xFF22C55E),
    onAccent: Color(0xFF06210F),
    info: Color(0xFF38BDF8),
    danger: Color(0xFFF87171),
  );

  static const light = AppColors(
    bg: Color(0xFFF3F6FA),
    surface: Color(0xFFFFFFFF),
    raised: Color(0xFFEEF2F7),
    line: Color(0xFFD5DDE8),
    fg: Color(0xFF0E1626),
    fg2: Color(0xFF56647C),
    accent: Color(0xFF15803D),
    onAccent: Color(0xFFFFFFFF),
    info: Color(0xFF0369A1),
    danger: Color(0xFFB91C1C),
  );

  static const excel = Color(0xFF1D6F42);
  static const telegram = Color(0xFF2AABEE);

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) =>
      other is AppColors && t > .5 ? other : this;
}

const kMono = 'JetBrainsMono';
const kSans = 'IBMPlexSans';
const kMonoFallback = [kSans];

extension AppColorsX on BuildContext {
  AppColors get c => Theme.of(this).extension<AppColors>()!;
}

ThemeData buildTheme(bool dark) {
  final c = dark ? AppColors.dark : AppColors.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: c.accent,
    brightness: dark ? Brightness.dark : Brightness.light,
  ).copyWith(
    primary: c.accent,
    onPrimary: c.onAccent,
    surface: c.surface,
    onSurface: c.fg,
    error: c.danger,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    fontFamily: kSans,
    extensions: [c],
    dividerColor: c.line,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.fg,
      contentTextStyle: TextStyle(color: c.bg, fontFamily: kSans),
      behavior: SnackBarBehavior.floating,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.raised,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.line)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.line)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.info, width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.danger)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.danger, width: 2)),
      errorStyle: TextStyle(color: c.danger, fontSize: 13),
    ),
  );
}
