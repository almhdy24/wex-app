import 'package:flutter/widgets.dart';
import '../core/design/colors.g.dart';

/// The ONLY gradient in the product (promo "ink" theme, login hero).
abstract final class Gradients {
  static const hero = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [WexColors.heroFrom, WexColors.heroTo],
  );
}

/// Horizontal scroller edge fade (so clipped chips read as "scrollable", not as a bug).
class EdgeFade extends StatelessWidget {
  final Widget child;
  const EdgeFade({super.key, required this.child});
  @override
  Widget build(BuildContext context) => ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (r) => const LinearGradient(
          colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF), Color(0xFFFFFFFF), Color(0x00FFFFFF)],
          stops: [0, 0.04, 0.96, 1],
        ).createShader(r),
        child: child,
      );
}
