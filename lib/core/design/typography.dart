import 'package:flutter/material.dart';
import 'colors.dart';

/// Tajawal scale (Round 2). Hierarchy comes from size + weight contrast,
/// not from bolding everything:
///   Display 28/800 · Title 20/700 · Body 15/500 · Caption 12/500 muted.
abstract final class WexText {
  static const display = TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.3, letterSpacing: -0.3);
  static const title = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.4);
  static const body = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.6);
  static const caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.5, color: WexColors.textSecondary);
  /// Card/list item title: between body and title.
  static const itemTitle = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.35);
  /// Prices.
  static const price = TextStyle(fontSize: 17, fontWeight: FontWeight.w800, height: 1.2);
}
