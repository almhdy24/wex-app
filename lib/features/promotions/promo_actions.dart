import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/utils/launchers.dart';
import '../../data/models/promotion.dart';

/// Runs the promo's action, then records the click (silent on failure).
Future<void> handlePromoTap(BuildContext context, WidgetRef ref, Promotion p) async {
  ref.read(promotionRepositoryProvider).event(p.id, 'click');
  final v = p.actionValue ?? '';
  switch (p.actionType) {
    case PromoAction.product:
      context.push('/products/$v');
    case PromoAction.category:
      // action_value is a category slug; map the known ones to the store's type filter.
      final type = switch (v) {
        'laptops' || 'laptop' => 'laptop',
        'phones' || 'phone' => 'phone',
        'accessories' || 'accessory' => 'accessory',
        _ => null,
      };
      context.go(type == null ? '/catalog' : '/catalog?type=$type');
    case PromoAction.filter:
      context.go('/catalog?search=${Uri.encodeQueryComponent(v)}');
    case PromoAction.url:
      await openUrl(v);
    case PromoAction.whatsapp:
      final shop = ref.read(shopProvider).valueOrNull;
      if (shop != null && shop.whatsapp.isNotEmpty) await openWhatsApp(shop.whatsapp, text: v);
    case PromoAction.none:
      break;
  }
}

final _viewed = <int>{};

/// One view event per session per promo.
void recordPromoView(WidgetRef ref, Promotion p) {
  if (_viewed.add(p.id)) ref.read(promotionRepositoryProvider).event(p.id, 'view');
}
