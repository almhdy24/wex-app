import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/spacing.dart';
import '../../data/models/promotion.dart';
import '../../ui/promo_card.dart';
import '../../ui/skeleton.dart';
import 'promo_actions.dart';

/// home_hero carousel: viewportFraction .92 (next banner peeks), 5s autoplay that pauses on touch
/// and when the app is backgrounded, segmented indicator. Nothing renders when there are no promos.
class PromoCarousel extends ConsumerStatefulWidget {
  final String placement;
  const PromoCarousel({super.key, this.placement = 'home_hero'});
  @override
  ConsumerState<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends ConsumerState<PromoCarousel> with WidgetsBindingObserver {
  final _ctrl = PageController(viewportFraction: 0.92);
  Timer? _auto;
  Timer? _viewTimer;
  int _index = 0;
  bool _touching = false;
  bool _foreground = true;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _auto = Timer.periodic(const Duration(seconds: 5), (_) => _next());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _auto?.cancel();
    _viewTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => _foreground = state == AppLifecycleState.resumed;

  void _next() {
    if (!mounted || _touching || !_foreground || _count < 2 || !_ctrl.hasClients) return;
    if (MediaQuery.of(context).disableAnimations) return;
    final n = (_index + 1) % _count;
    _ctrl.animateToPage(n, duration: Motion.slow, curve: Curves.easeOutCubic);
  }

  void _scheduleView(Promotion p) {
    _viewTimer?.cancel();
    _viewTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) recordPromoView(ref, p);
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(promotionsProvider(widget.placement));
    return async.when(
      loading: () => const SkeletonScope(
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: SkeletonBox(height: 172, radius: Radii.card)),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        _count = list.length;
        if (_index == 0) _scheduleView(list.first);
        if (list.length == 1) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PromoCard(promo: list.first, onTap: () => handlePromoTap(context, ref, list.first)),
          );
        }
        return Column(children: [
          RepaintBoundary(
            child: SizedBox(
              height: promoHeight(context),
              child: Listener(
                onPointerDown: (_) => _touching = true,
                onPointerUp: (_) => _touching = false,
                onPointerCancel: (_) => _touching = false,
                child: PageView.builder(
                  controller: _ctrl,
                  itemCount: list.length,
                  onPageChanged: (i) {
                    setState(() => _index = i);
                    _scheduleView(list[i]);
                  },
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: PromoCard(promo: list[i], onTap: () => handlePromoTap(context, ref, list[i])),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < list.length; i++)
              AnimatedContainer(
                duration: Motion.base,
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 3,
                width: i == _index ? 20 : 6,
                decoration: BoxDecoration(color: i == _index ? WexColors.ink900 : WexColors.line, borderRadius: BorderRadius.circular(2)),
              ),
          ]),
        ]);
      },
    );
  }
}
