import 'package:flutter/material.dart';

/// Brand palette — ported 1:1 from the web design tokens (src/styles/tokens.css).
abstract final class WexColors {
  static const navy = Color(0xFF061A55);
  static const royal = Color(0xFF0B3FBF);
  static const vivid = Color(0xFF1E6BFF);
  static const cyan = Color(0xFF00B7FF);

  static const ice = Color(0xFFEAF3FF);
  static const iceLight = Color(0xFFF4F8FE);
  static const white = Color(0xFFFFFFFF);

  static const textPrimary = navy;
  static const textSecondary = Color(0xFF4B5B85);
  static const border = Color(0xFFD5E2F7);
  static const disabled = Color(0xFF9AA8C7);

  static const onDark = Color(0xFFFFFFFF);
  static const onDarkMuted = Color(0xFFC9D6F5);

  static const success = Color(0xFF12805C);
  static const successBg = Color(0xFFE8F5EE);
  static const warning = Color(0xFFB45309);
  static const warningBg = Color(0xFFFEF3E2);
  static const danger = Color(0xFFB42318);
  static const dangerBg = Color(0xFFFEE8E7);

  static const gradBrand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [royal, vivid, cyan],
  );
  static const gradNavy = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy, royal],
  );
}
