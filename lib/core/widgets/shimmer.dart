import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/spacing.dart';

/// Lightweight shimmer (no package): a moving gradient over a base color.
class Shimmer extends StatefulWidget {
  final Widget child;
  const Shimmer({super.key, required this.child});
  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) => ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final dx = bounds.width * (_c.value * 2 - 1);
            return LinearGradient(
              begin: Alignment.centerLeft, end: Alignment.centerRight,
              colors: const [Color(0xFFE6EEFB), Color(0xFFF4F8FE), Color(0xFFE6EEFB)],
              stops: const [0.3, 0.5, 0.7],
              transform: _SlideGradient(dx),
            ).createShader(bounds);
          },
          child: child,
        ),
        child: widget.child,
      );
}

class _SlideGradient extends GradientTransform {
  final double dx;
  const _SlideGradient(this.dx);
  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) => Matrix4.translationValues(dx, 0, 0);
}

class _Block extends StatelessWidget {
  final double? width, height;
  final double radius;
  const _Block({this.width, this.height, this.radius = 6});
  @override
  Widget build(BuildContext context) => Container(
        width: width, height: height,
        decoration: BoxDecoration(color: const Color(0xFFE6EEFB), borderRadius: BorderRadius.circular(radius)),
      );
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});
  @override
  Widget build(BuildContext context) => Shimmer(
        child: Container(
          decoration: BoxDecoration(color: WexColors.white, borderRadius: BorderRadius.circular(Radii.card)),
          clipBehavior: Clip.antiAlias,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: const [
            AspectRatio(aspectRatio: 4 / 3, child: _Block(radius: 0)),
            Padding(
              padding: EdgeInsets.all(Sp.x6),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Block(height: 12, width: 120), SizedBox(height: 8),
                _Block(height: 12, width: 80), SizedBox(height: 10),
                _Block(height: 16, width: 90),
              ]),
            ),
          ]),
        ),
      );
}

/// Staggered fade + slide-up entrance for list/grid items.
class FadeInUp extends StatelessWidget {
  final int index;
  final Widget child;
  const FadeInUp({super.key, required this.index, required this.child});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 300 + (index.clamp(0, 8) * 40)),
        curve: const Cubic(0.16, 1, 0.3, 1),
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, (1 - t) * 16), child: child),
        ),
        child: child,
      );
}
