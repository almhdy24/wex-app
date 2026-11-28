import 'package:flutter/painting.dart';
import '../core/design/colors.g.dart';

/// Cards have NO elevation (hairline border). This is the single floating shadow token,
/// used by the bottom nav, sticky bars and sheets.
abstract final class Elev {
  static const float = [
    BoxShadow(color: WexColors.shadowSoft, blurRadius: 24, offset: Offset(0, -8)),
  ];
}
