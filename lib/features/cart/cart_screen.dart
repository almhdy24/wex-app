import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/strings.dart';
import '../../core/widgets/price_text.dart';
import '../../core/widgets/wex_widgets.dart';
import '../../data/models/cart_item.dart';
import 'cart_controller.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartControllerProvider);
    final cart = ref.read(cartControllerProvider.notifier);
    final shop = ref.watch(shopProvider).valueOrNull;
    final discountPct = shop?.appDiscountPercent ?? 3;
    final subtotal = items.fold<int>(0, (s, i) => s + i.lineTotal);
    final discount = (subtotal * discountPct / 100).round();
    final total = subtotal - discount;

    return Scaffold(
      appBar: AppBar(title: const Text(Ar.cart)),
      body: items.isEmpty
          ? WexEmptyState(
              icon: Icons.shopping_bag_outlined, title: Ar.cartEmpty,
              body: 'أضف أجهزة إلى سلتك وتابع الطلب بسهولة.',
              ctaLabel: Ar.cartEmptyCta, onCta: () => context.go('/catalog'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(Sp.page),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: Sp.x6),
                    itemBuilder: (_, i) => _CartLine(
                      item: items[i],
                      onInc: () => cart.setQuantity(items[i].productId, items[i].quantity + 1),
                      onDec: () => cart.setQuantity(items[i].productId, items[i].quantity - 1),
                      onDelete: () {
                        final removed = items[i];
                        final index = i;
                        cart.remove(removed.productId);
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(SnackBar(content: const Text(Ar.removed),
                              action: SnackBarAction(label: Ar.undo, onPressed: () => cart.restore(removed, index))));
                      },
                    ),
                  ),
                ),
                _Summary(subtotal: subtotal, discount: discount, discountPct: discountPct, total: total),
              ],
            ),
    );
  }
}

class _CartLine extends StatelessWidget {
  final CartItem item;
  final VoidCallback onInc, onDec, onDelete;
  const _CartLine({required this.item, required this.onInc, required this.onDec, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    return WexCard(
      padding: const EdgeInsets.all(Sp.x5),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 74, height: 74, color: WexColors.iceLight, padding: const EdgeInsets.all(6),
            child: item.thumbUrl.isEmpty
                ? const Icon(Icons.laptop_mac_rounded, color: WexColors.disabled)
                : CachedNetworkImage(imageUrl: item.thumbUrl, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(width: Sp.x6),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          LtrText(item.name, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.3)),
          const SizedBox(height: 8),
          PriceText(item.lineTotal, size: 15),
        ])),
        Column(children: [
          InkWell(onTap: onDelete, borderRadius: BorderRadius.circular(8),
              child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.delete_outline_rounded, color: WexColors.danger, size: 20))),
          const SizedBox(height: 4),
          _Stepper(quantity: item.quantity, atMax: item.quantity >= item.maxQty, onInc: onInc, onDec: onDec),
        ]),
      ]),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int quantity;
  final bool atMax;
  final VoidCallback onInc, onDec;
  const _Stepper({required this.quantity, required this.atMax, required this.onInc, required this.onDec});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(border: Border.all(color: WexColors.border), borderRadius: BorderRadius.circular(Radii.pill)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _sq(Icons.remove_rounded, quantity > 1 ? onDec : null),
          SizedBox(width: 30, child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Text('$quantity', key: ValueKey(quantity), textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          )),
          _sq(Icons.add_rounded, atMax ? null : onInc),
        ]),
      );
  Widget _sq(IconData i, VoidCallback? onTap) =>
      IconButton(iconSize: 16, visualDensity: VisualDensity.compact, onPressed: onTap,
          icon: Icon(i, color: onTap == null ? WexColors.disabled : WexColors.primary));
}

class _Summary extends StatelessWidget {
  final int subtotal, discount, discountPct, total;
  const _Summary({required this.subtotal, required this.discount, required this.discountPct, required this.total});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(Sp.page, Sp.x6, Sp.page, Sp.x6),
      decoration: const BoxDecoration(color: WexColors.white,
          boxShadow: [BoxShadow(color: WexColors.shadowSticky, blurRadius: 24, offset: Offset(0, -6))]),
      child: SafeArea(top: false, child: Column(children: [
        _row(Ar.subtotal, subtotal),
        if (discount > 0) Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            Text('${Ar.discountLine} · $discountPct٪', style: const TextStyle(color: WexColors.textSecondary)),
            const Spacer(),
            Row(children: [
              const Text('−', style: TextStyle(color: WexColors.success, fontWeight: FontWeight.w800)),
              PriceText(discount, size: 14, color: WexColors.success, weight: FontWeight.w800),
            ]),
          ]),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [Icon(Icons.local_shipping_outlined, size: 15, color: WexColors.textSecondary), SizedBox(width: 6),
              Expanded(child: Text(Ar.deliveryLater, style: TextStyle(color: WexColors.textSecondary, fontSize: 12)))])),
        const Divider(),
        Row(children: [
          const Text(Ar.total, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const Spacer(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (c, a) => FadeTransition(opacity: a,
                child: SizeTransition(sizeFactor: a, axis: Axis.horizontal, child: c)),
            child: PriceText(total, key: ValueKey(total), size: 20),
          ),
        ]),
        if (discount > 0) Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: WexColors.successBg, borderRadius: BorderRadius.circular(Radii.pill)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('${Ar.youSave} ', style: TextStyle(color: WexColors.success, fontSize: 12, fontWeight: FontWeight.w700)),
              PriceText(discount, size: 12, color: WexColors.success, weight: FontWeight.w800),
            ]),
          ),
        ),
        const SizedBox(height: Sp.x5),
        WexButton(Ar.continueLabel, onPressed: () => context.push('/checkout')),
      ])),
    );
  }

  Widget _row(String label, int value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Text(label, style: const TextStyle(color: WexColors.textSecondary)),
          const Spacer(),
          PriceText(value, size: 14, color: WexColors.navy, weight: FontWeight.w700),
        ]),
      );
}
