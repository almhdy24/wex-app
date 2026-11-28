import 'package:flutter/painting.dart';
import '../core/design/colors.g.dart';

/// The ONLY gradient in the product (promo "ink" theme, login hero).
abstract final class Gradients {
  static const hero = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [WexColors.heroFrom, WexColors.heroTo],
  );
}
