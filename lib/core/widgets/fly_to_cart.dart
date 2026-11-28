import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/colors.dart';

/// Registry of mounted cart icons (the visible one is the animation target).
abstract final class CartTargets {
  static final List<GlobalKey> keys = [];

  /// Center of the first cart icon that is mounted AND on screen (tab not offstage).
  static Offset? visibleCenter() {
    for (final k in keys.reversed) {
      final ctx = k.currentContext;
      if (ctx == null) continue;
      if (!TickerMode.valuesOf(ctx).enabled) continue; // offstage tab in the IndexedStack
      final box = ctx.findRenderObject();
      if (box is RenderBox && box.attached && box.hasSize) {
        return box.localToGlobal(box.size.center(Offset.zero));
      }
    }
    return null;
  }
}

/// A small branded disc flies from [source] to the cart icon along a curved path,
/// then the badge bounces (CartButton animates its count change). Skipped when the
/// OS asks for reduced motion or no cart icon is visible.
void flyToCart(BuildContext source) {
  HapticFeedback.mediumImpact();
  if (MediaQuery.of(source).disableAnimations) return;
  final box = source.findRenderObject();
  final end = CartTargets.visibleCenter();
  if (box is! RenderBox || !box.attached || end == null) return;
  final start = box.localToGlobal(box.size.center(Offset.zero));
  final overlay = Overlay.maybeOf(source, rootOverlay: true);
  if (overlay == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _Fly(start: start, end: end, onDone: () => entry.remove()),
  );
  overlay.insert(entry);
}

class _Fly extends StatefulWidget {
  final Offset start, end;
  final VoidCallback onDone;
  const _Fly({required this.start, required this.end, required this.onDone});
  @override
  State<_Fly> createState() => _FlyState();
}

class _FlyState extends State<_Fly> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 650))
        ..addStatusListener((s) { if (s == AnimationStatus.completed) widget.onDone(); })
        ..forward();
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  Offset _bezier(double t) {
    final a = widget.start, b = widget.end;
    // Control point lifted above the straight line for a natural arc.
    final c = Offset((a.dx + b.dx) / 2, math.min(a.dy, b.dy) - 90);
    final u = 1 - t;
    return a * (u * u) + c * (2 * u * t) + b * (t * t);
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final t = Curves.easeInOutCubic.transform(_c.value);
            final p = _bezier(t);
            final size = 40 - 22 * t;
            return Stack(children: [
              Positioned(
                left: p.dx - size / 2, top: p.dy - size / 2,
                child: Opacity(
                  opacity: 1 - 0.35 * t,
                  child: Container(
                    width: size, height: size, alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      gradient: WexColors.gradBrand, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Color(0x553E4EE8), blurRadius: 10)]),
                    child: Icon(Icons.add_rounded, color: Colors.white, size: size * 0.6),
                  ),
                ),
              ),
            ]);
          },
        ),
      );
}
