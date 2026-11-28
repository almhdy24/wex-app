import 'package:flutter/material.dart';
import '../core/design/colors.g.dart';
import 'elevation.dart';

/// Every screen goes through this. It owns the bottom inset (safe area + breathing room)
/// so the last item of any scroll view is never hidden behind the nav / sticky bar.
class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;

  /// Sticky bottom bar (e.g. total + CTA). Gets the floating shadow and the safe-area inset.
  final Widget? bottomBar;
  const AppScaffold({super.key, this.appBar, required this.body, this.bottomBar});

  /// Padding for ListView / CustomScrollView / SingleChildScrollView inside [body].
  static EdgeInsets listPadding(BuildContext context,
          {double top = 0, double horizontal = 16, double extra = 24}) =>
      EdgeInsets.fromLTRB(horizontal, top, horizontal, extra + MediaQuery.of(context).padding.bottom);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: WexColors.paper,
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomBar == null
            ? null
            : DecoratedBox(
                decoration: const BoxDecoration(color: WexColors.surface, boxShadow: Elev.float),
                child: SafeArea(
                  top: false,
                  child: Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), child: bottomBar),
                ),
              ),
      );
}
