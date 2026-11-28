import 'package:flutter/material.dart';
import 'colors.g.dart';

/// Semantic tone: a foreground colour with a ~10–12% tint background.
/// Used for every status pill, amount accent, badge and icon square so the
/// whole app speaks one colour language.
enum Tone {
  brand(WexColors.primary, WexColors.primaryTint),
  success(WexColors.success, WexColors.successBg),
  warning(WexColors.warning, WexColors.warningBg),
  danger(WexColors.danger, WexColors.dangerBg),
  neutral(WexColors.neutral, WexColors.neutralBg);

  final Color fg;
  final Color bg;
  const Tone(this.fg, this.bg);
}
