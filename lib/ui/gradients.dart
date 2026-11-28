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
        shaderCallback: (r) => LinearGradient(
          colors: [WexColors.surface.withValues(alpha: 0), WexColors.surface, WexColors.surface, WexColors.surface.withValues(alpha: 0)],
          stops: const [0, 0.03, 0.97, 1],
        ).createShader(r),
        child: child,
      );
}
