import 'package:flutter/material.dart';
import 'colors.g.dart';

/// IBM Plex Sans Arabic scale. Font family comes from the theme (never hardcoded here).
/// display 28/36 bold | titleL 22/30 semibold | titleM 17/26 semibold | body 15/24 |
/// bodyS 13/20 | label 12/16 medium | priceL 26/32 bold | priceM 16/22 bold.
abstract final class WexText {
  static const _tab = [FontFeature.tabularFigures()];
  static const display = TextStyle(fontSize: 28, height: 36 / 28, fontWeight: FontWeight.w700, color: WexColors.ink900);
  static const titleL = TextStyle(fontSize: 22, height: 30 / 22, fontWeight: FontWeight.w600, color: WexColors.ink900);
  static const titleM = TextStyle(fontSize: 17, height: 26 / 17, fontWeight: FontWeight.w600, color: WexColors.ink900);
  static const body = TextStyle(fontSize: 15, height: 24 / 15, fontWeight: FontWeight.w400, color: WexColors.ink900);
  static const bodyS = TextStyle(fontSize: 13, height: 20 / 13, fontWeight: FontWeight.w400, color: WexColors.muted);
  static const label = TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: WexColors.muted);
  static const priceL = TextStyle(fontSize: 26, height: 32 / 26, fontWeight: FontWeight.w700, color: WexColors.ink900, fontFeatures: _tab);
  static const priceM = TextStyle(fontSize: 16, height: 22 / 16, fontWeight: FontWeight.w700, color: WexColors.ink900, fontFeatures: _tab);
  /// Numbers, counts, order numbers, timers.
  static const numeric = TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: WexColors.ink900, fontFeatures: _tab);

  // Legacy names.
  static const title = titleL;
  static const caption = bodyS;
  static const itemTitle = titleM;
  static const price = priceM;
}
