import 'package:flutter/material.dart';
import 'colors.g.dart';
import 'spacing.dart';
import 'typography.dart';

const kFontFamily = 'IBMPlexSansArabic';

/// Token-driven theme. No Material 3 surface tints, no violet ripples, no card elevation.
ThemeData buildWexTheme() {
  final scheme = ColorScheme.light(
    primary: WexColors.teal600,
    onPrimary: WexColors.surface,
    secondary: WexColors.teal500,
    onSecondary: WexColors.surface,
    surface: WexColors.surface,
    onSurface: WexColors.ink900,
    error: WexColors.danger,
    onError: WexColors.surface,
    outline: WexColors.line,
    surfaceTint: Colors.transparent,
  );

  final base = ThemeData(
    useMaterial3: true,
    fontFamily: kFontFamily,
    colorScheme: scheme,
    scaffoldBackgroundColor: WexColors.paper,
    splashFactory: NoSplash.splashFactory,
    highlightColor: WexColors.sunken,
    splashColor: Colors.transparent,
    hoverColor: Colors.transparent,
  );

  RoundedRectangleBorder shape12() =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.control));

  return base.copyWith(
    textTheme: base.textTheme
        .copyWith(
          displayLarge: WexText.display,
          headlineSmall: WexText.titleL,
          titleLarge: WexText.titleL,
          titleMedium: WexText.titleM,
          bodyLarge: WexText.body,
          bodyMedium: WexText.body,
          bodySmall: WexText.bodyS,
          labelLarge: WexText.titleM.copyWith(fontSize: 15, height: 22 / 15),
          labelMedium: WexText.label,
        )
        .apply(fontFamily: kFontFamily, bodyColor: WexColors.ink900, displayColor: WexColors.ink900),
    appBarTheme: AppBarTheme(
      backgroundColor: WexColors.paper,
      surfaceTintColor: Colors.transparent,
      foregroundColor: WexColors.ink900,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: WexText.titleM,
    ),
    cardTheme: CardThemeData(
      color: WexColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.card),
        side: const BorderSide(color: WexColors.line),
      ),
    ),
    dividerTheme: const DividerThemeData(color: WexColors.line, thickness: 1, space: 1),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: WexColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheetTop))),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(shape12()),
        textStyle: WidgetStatePropertyAll(WexText.titleM.copyWith(fontSize: 16, height: 24 / 16)),
        foregroundColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.disabled) ? WexColors.disabled : WexColors.surface),
        backgroundColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.disabled)) return WexColors.sunken;
          if (s.contains(WidgetState.pressed)) return WexColors.teal700;
          return WexColors.teal600;
        }),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(shape12()),
        side: const WidgetStatePropertyAll(BorderSide(color: WexColors.line)),
        foregroundColor: const WidgetStatePropertyAll(WexColors.ink900),
        textStyle: WidgetStatePropertyAll(WexText.titleM.copyWith(fontSize: 15, height: 22 / 15)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(WexColors.teal600),
        shape: WidgetStatePropertyAll(shape12()),
        textStyle: WidgetStatePropertyAll(WexText.titleM.copyWith(fontSize: 15, height: 22 / 15)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: WexColors.surface,
      selectedColor: WexColors.ink900,
      side: const BorderSide(color: WexColors.line),
      labelStyle: WexText.body.copyWith(fontWeight: FontWeight.w500),
      shape: const StadiumBorder(),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WexColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: Sp.s16, vertical: 14),
      hintStyle: WexText.body.copyWith(color: WexColors.disabled),
      labelStyle: WexText.bodyS,
      errorStyle: WexText.label.copyWith(color: WexColors.danger),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.control),
          borderSide: const BorderSide(color: WexColors.line)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.control),
          borderSide: const BorderSide(color: WexColors.line)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.control),
          borderSide: const BorderSide(color: WexColors.teal500, width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.control),
          borderSide: const BorderSide(color: WexColors.danger)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.control),
          borderSide: const BorderSide(color: WexColors.danger, width: 2)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: WexColors.ink900,
      contentTextStyle: WexText.body.copyWith(color: WexColors.surface),
      shape: shape12(),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: WexColors.teal600),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? WexColors.teal600 : WexColors.surface),
      side: const BorderSide(color: WexColors.line, width: 1.5),
    ),
    radioTheme: const RadioThemeData(fillColor: WidgetStatePropertyAll(WexColors.teal600)),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: WexColors.teal600),
  );
}
