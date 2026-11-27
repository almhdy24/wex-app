import 'package:flutter/material.dart';

/// Modern, premium palette for an imported-electronics store. One confident
/// indigo→violet accent (signature gradient), deep-midnight ink, cool near-white
/// surfaces. Calm, not flat; distinctive, not neon.
abstract final class WexColors {
  // Accent (actions, selected states, signature gradient)
  static const primary = Color(0xFF3E4EE8);
  static const primaryDeep = Color(0xFF2E3BC4);
  static const violet = Color(0xFF6A5CF0);
  static const royal = primary;  // aliases kept for existing refs
  static const vivid = violet;
  static const cyan = primary;

  // Ink / text
  static const navy = Color(0xFF0E1430);        // deep midnight (dark headers)
  static const textPrimary = Color(0xFF111833);
  static const textSecondary = Color(0xFF6A7187);
  static const border = Color(0xFFE9EBF2);
  static const disabled = Color(0xFFADB2C2);

  // Surfaces / background
  static const ice = Color(0xFFF6F7FB);         // app background (cool near-white)
  static const iceLight = Color(0xFFF1F3F9);
  static const white = Color(0xFFFFFFFF);

  static const onDark = Color(0xFFFFFFFF);
  static const onDarkMuted = Color(0xFFC4CAE4);

  // Status
  static const success = Color(0xFF0E9F6E);
  static const successBg = Color(0xFFE6F6EF);
  static const warning = Color(0xFFB4690E);
  static const warningBg = Color(0xFFFBF0E2);
  static const danger = Color(0xFFDC4A46);
  static const dangerBg = Color(0xFFFCEBEA);

  // Soft neutral shadows
  static const shadowSoft = Color(0x0F131A3A);
  static const shadowSticky = Color(0x14131A3A);

  // Signature gradient — hero, primary CTA, lock card
  static const gradBrand = LinearGradient(
    begin: Alignment.topRight, end: Alignment.bottomLeft,
    colors: [Color(0xFF3E4EE8), Color(0xFF6A5CF0)],
  );
  static const gradNavy = LinearGradient(
    begin: Alignment.topRight, end: Alignment.bottomLeft,
    colors: [Color(0xFF151C3C), Color(0xFF2A2E73)],
  );
}
