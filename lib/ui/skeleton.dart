import 'package:flutter/material.dart';
import '../core/design/colors.g.dart';
import '../core/design/spacing.dart';

/// One shared pulse (sunken <-> paper, 1200ms) for every skeleton block on screen.
class SkeletonScope extends StatefulWidget {
  final Widget child;
  const SkeletonScope({super.key, required this.child});
  static Animation<Color?>? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<_Pulse>()?.color;
  @override
  State<SkeletonScope> createState() => _SkeletonScopeState();
}

class _SkeletonScopeState extends State<SkeletonScope> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
  late final Animation<Color?> _color =
      ColorTween(begin: WexColors.sunken, end: WexColors.paper).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started && !MediaQuery.of(context).disableAnimations) {
      _started = true;
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Pulse(color: _color, child: widget.child);
}

class _Pulse extends InheritedWidget {
  final Animation<Color?> color;
  const _Pulse({required this.color, required super.child});
  @override
  bool updateShouldNotify(_Pulse old) => false;
}

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const SkeletonBox({super.key, this.width, required this.height, this.radius = Radii.control});
  @override
  Widget build(BuildContext context) {
    final anim = SkeletonScope.of(context);
    if (anim == null) {
      return Container(width: width, height: height, decoration: BoxDecoration(color: WexColors.sunken, borderRadius: BorderRadius.circular(radius)));
    }
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: anim.value ?? WexColors.sunken, borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }
}
