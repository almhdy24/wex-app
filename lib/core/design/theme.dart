import 'package:flutter/material.dart';
import 'colors.dart';
import 'spacing.dart';

abstract final class WexShadows {
  static const sm = [BoxShadow(color: WexColors.shadowSoft, blurRadius: 10, offset: Offset(0, 3))];
  static const md = [BoxShadow(color: WexColors.shadowSoft, blurRadius: 24, offset: Offset(0, 10))];
  static const sticky = [BoxShadow(color: WexColors.shadowSticky, blurRadius: 24, offset: Offset(0, -6))];
}

ThemeData buildWexTheme() {
  const fontFamily = 'Tajawal';
  final scheme = ColorScheme.fromSeed(
    seedColor: WexColors.royal,
    primary: WexColors.royal,
    secondary: WexColors.vivid,
    surface: WexColors.white,
    error: WexColors.danger,
    brightness: Brightness.light,
  ).copyWith(surfaceTint: Colors.transparent);

  final base = ThemeData(useMaterial3: true, fontFamily: fontFamily, scaffoldBackgroundColor: WexColors.ice, colorScheme: scheme);
  const numeric = [FontFeature.tabularFigures()];

  return base.copyWith(
    splashFactory: InkSparkle.splashFactory,
    textTheme: base.textTheme.copyWith(
      headlineSmall: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.35, letterSpacing: -0.2),
      titleLarge: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, height: 1.4),
      titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.4),
      bodyLarge: const TextStyle(fontSize: 15.5, height: 1.75, fontFeatures: numeric),
      bodyMedium: const TextStyle(fontSize: 14.5, height: 1.7, fontFeatures: numeric),
      labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    ).apply(fontFamily: fontFamily, bodyColor: WexColors.textPrimary, displayColor: WexColors.textPrimary),
    appBarTheme: const AppBarTheme(
      backgroundColor: WexColors.ice,
      surfaceTintColor: Colors.transparent,
      foregroundColor: WexColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontFamily: fontFamily, fontSize: 17, fontWeight: FontWeight.w700, color: WexColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: WexColors.white, elevation: 0, margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.card),
        side: const BorderSide(color: WexColors.border),
      ),
    ),
    dividerTheme: const DividerThemeData(color: WexColors.border, thickness: 1, space: 24),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: WexColors.royal, foregroundColor: WexColors.white,
        minimumSize: const Size.fromHeight(54), elevation: 0,
        textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.control)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: WexColors.royal, minimumSize: const Size.fromHeight(50),
        side: const BorderSide(color: WexColors.border),
        textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.control)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: WexColors.white, selectedColor: WexColors.royal,
      side: const BorderSide(color: WexColors.border),
      labelStyle: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, color: WexColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.pill)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: WexColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: Sp.x6, vertical: Sp.x6),
      hintStyle: const TextStyle(color: WexColors.disabled),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.control), borderSide: const BorderSide(color: WexColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.control), borderSide: const BorderSide(color: WexColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.control), borderSide: const BorderSide(color: WexColors.royal, width: 1.6)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating, backgroundColor: WexColors.navy,
      contentTextStyle: const TextStyle(fontFamily: fontFamily, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.card)),
    ),
  );
}
