import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../data/models/promotion.dart';
import '../../ui/promo_card.dart';
import 'promo_actions.dart';

/// A single in-list promo (store_inline spans both columns; cart_promo is the compact row).
/// Renders nothing while loading or when there is no active promo (no hole).
class PromoInline extends ConsumerStatefulWidget {
  final String placement;
  final bool compact;
  const PromoInline({super.key, required this.placement, this.compact = false});
  @override
  ConsumerState<PromoInline> createState() => _PromoInlineState();
}

class _PromoInlineState extends ConsumerState<PromoInline> {
  Timer? _viewTimer;

  @override
  void dispose() {
    _viewTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(promotionsProvider(widget.placement)).valueOrNull ?? const <Promotion>[];
    if (list.isEmpty) return const SizedBox.shrink();
    final p = list.first;
    _viewTimer ??= Timer(const Duration(seconds: 1), () {
      if (mounted) recordPromoView(ref, p);
    });
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: widget.compact
          ? PromoCompact(promo: p, onTap: () => handlePromoTap(context, ref, p))
          : PromoCard(promo: p, onTap: () => handlePromoTap(context, ref, p)),
    );
  }
}
