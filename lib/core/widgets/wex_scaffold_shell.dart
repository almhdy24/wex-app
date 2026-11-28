import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/bottom_nav.dart';

/// Tab shell: IndexedStack branches + the custom bottom nav. Switching tabs is a 200ms fade-through.
class WexScaffoldShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const WexScaffoldShell({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    final current = shell.currentIndex;
    return Scaffold(
      body: _TabFade(index: current, child: shell),
      bottomNavigationBar: AppBottomNav(
        index: current,
        onTap: (i) => shell.goBranch(i, initialLocation: i == current),
      ),
    );
  }
}

class _TabFade extends StatefulWidget {
  final int index;
  final Widget child;
  const _TabFade({required this.index, required this.child});
  @override
  State<_TabFade> createState() => _TabFadeState();
}

class _TabFadeState extends State<_TabFade> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 200), value: 1);

  @override
  void didUpdateWidget(covariant _TabFade old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index && !MediaQuery.of(context).disableAnimations) {
      _c.forward(from: 0.3);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: CurvedAnimation(parent: _c, curve: Curves.easeOutCubic), child: widget.child);
}
