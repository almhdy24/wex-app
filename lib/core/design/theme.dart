import 'package:flutter/material.dart';
import 'colors.dart';
import 'spacing.dart';

/// Blue-tinted shadows (navy rgba 6,26,85) matching the web.
abstract final class WexShadows {
  static const sm = [BoxShadow(color: Color(0x0F061A55), blurRadius: 6, offset: Offset(0, 2))];
  static const md = [BoxShadow(color: Color(0x17061A55), blurRadius: 20, offset: Offset(0, 8))];
  static const lg = [BoxShadow(color: Color(0x1F061A55), blurRadius: 32, offset: Offset(0, 16))];
  static const sticky = [BoxShadow(color: Color(0x14061A55), blurRadius: 16, offset: Offset(0, -4))];
}

ThemeData buildWexTheme() {
  const fontFamily = 'Tajawal';
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: WexColors.ice,
    colorScheme: ColorScheme.fromSeed(
      seedColor: WexColors.royal,
      primary: WexColors.royal,
      secondary: WexColors.vivid,
      surface: WexColors.white,
      error: WexColors.danger,
      brightness: Brightness.light,
    ),
  );

  const numeric = [FontFeature.tabularFigures()];
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: WexColors.textPrimary,
      displayColor: WexColors.textPrimary,
      fontFamily: fontFamily,
    ).copyWith(
      bodyMedium: const TextStyle(fontSize: 15, height: 1.7, fontFeatures: numeric),
      titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.35),
      titleMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.35),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: WexColors.white,
      foregroundColor: WexColors.navy,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w800, color: WexColors.navy),
    ),
    cardTheme: CardThemeData(
      color: WexColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.card)),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: WexColors.royal,
        foregroundColor: WexColors.white,
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.control)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WexColors.iceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.control),
        borderSide: const BorderSide(color: WexColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.control),
        borderSide: const BorderSide(color: WexColors.border),
      ),
    ),
  );
}
