import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/design/typography.dart';
import '../../core/strings.dart';
import '../../core/utils/product_name.dart';
import '../../core/widgets/price_text.dart';
import '../../core/widgets/product_card.dart';
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

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text(Ar.cart)),
        body: WexEmptyState(
          icon: Icons.shopping_bag_outlined,
          title: Ar.cartEmpty,
          body: Ar.cartEmptyBody,
          ctaLabel: Ar.cartEmptyCta,
          onCta: () => context.go('/catalog'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text(Ar.cart)),
      body: Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(Sp.page),
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _dismissible(context, cart, items, i),
                const SizedBox(height: Sp.x5),
              ],
              // Compact summary card right under the items (no dead space).
              _SummaryCard(subtotal: subtotal, discount: discount, discountPct: discountPct),
              // "Complete your setup": real store accessories, only when the cart is small.
              if (items.length <= 2) _CompleteSetup(inCart: {for (final i in items) i.productId}),
              const SizedBox(height: Sp.x6),
            ],
          ),
        ),
        _CheckoutBar(total: total),
      ]),
    );
  }

  Widget _dismissible(BuildContext context, CartController cart, List<CartItem> items, int i) {
    void remove() {
      final removed = items[i];
      final index = i;
      cart.remove(removed.productId);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: const Text(Ar.removed),
          action: SnackBarAction(label: Ar.undo, onPressed: () => cart.restore(removed, index)),
        ));
    }

    return Dismissible(
      key: ValueKey('cart-${items[i].productId}'),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => remove(),
      background: const _SwipeBg(AlignmentDirectional.centerStart),
      secondaryBackground: const _SwipeBg(AlignmentDirectional.centerEnd),
      child: _CartLine(
        item: items[i],
        onInc: () => cart.setQuantity(items[i].productId, items[i].quantity + 1),
        onDec: () => cart.setQuantity(items[i].productId, items[i].quantity - 1),
        onDelete: remove,
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
    final t = normalizeProductName(item.name);
    return WexCard(
      padding: const EdgeInsets.all(Sp.x5),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 78, height: 78,
            child: item.thumbUrl.isEmpty
                ? const ColoredBox(color: WexColors.iceLight, child: Icon(Icons.laptop_mac_rounded, color: WexColors.disabled))
                : CachedNetworkImage(imageUrl: item.thumbUrl, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: Sp.x6),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (t.brand.isNotEmpty)
              Directionality(
                textDirection: TextDirection.ltr,
                child: Align(alignment: Alignment.centerRight, child: Text(t.brand, style: WexText.caption)),
              ),
            LtrText(t.model, maxLines: 2, style: WexText.itemTitle),
            const SizedBox(height: 6),
            PriceText(item.lineTotal, size: 16),
          ]),
        ),
        Column(children: [
          InkWell(
            onTap: onDelete, borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.delete_outline_rounded, color: WexColors.danger, size: 20),
            ),
          ),
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
        decoration: BoxDecoration(
          border: Border.all(color: WexColors.border), borderRadius: BorderRadius.circular(Radii.pill)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _sq(Icons.remove_rounded, quantity > 1 ? onDec : null),
          SizedBox(
            width: 28,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: Text('$quantity', key: ValueKey(quantity), textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          _sq(Icons.add_rounded, atMax ? null : onInc),
        ]),
      );
  Widget _sq(IconData i, VoidCallback? onTap) => IconButton(
        iconSize: 16, visualDensity: VisualDensity.compact, onPressed: onTap,
        icon: Icon(i, color: onTap == null ? WexColors.disabled : WexColors.primary),
      );
}

/// Subtotal / discount (+ savings chip inline) / delivery note — one compact card.
class _SummaryCard extends StatelessWidget {
  final int subtotal, discount, discountPct;
  const _SummaryCard({required this.subtotal, required this.discount, required this.discountPct});
  @override
  Widget build(BuildContext context) => WexCard(
        padding: const EdgeInsets.all(Sp.x6),
        child: Column(children: [
          _row(const Text(Ar.subtotal, style: WexText.body), PriceText(subtotal, size: 15, color: WexColors.textPrimary, weight: FontWeight.w700)),
          if (discount > 0) ...[
            const SizedBox(height: 10),
            _row(
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center, spacing: 8,
                children: [
                  Text(Ar.discountPercent(discountPct), style: WexText.body),
                  _SavingsChip(discount),
                ],
              ),
              PriceText(discount, size: 15, color: WexColors.success, weight: FontWeight.w800, negative: true),
            ),
          ],
          const SizedBox(height: 12),
          const Row(children: [
            Icon(Icons.local_shipping_outlined, size: 16, color: WexColors.textSecondary),
            SizedBox(width: 8),
            Expanded(child: Text(Ar.deliveryLater, style: WexText.caption)),
          ]),
        ]),
      );

  Widget _row(Widget l, Widget r) => Row(children: [Expanded(child: Align(alignment: AlignmentDirectional.centerStart, child: l)), r]);
}

class _SavingsChip extends StatelessWidget {
  final int amount;
  const _SavingsChip(this.amount);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: WexColors.successBg, borderRadius: BorderRadius.circular(Radii.pill)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('${Ar.youSave} ', style: TextStyle(color: WexColors.success, fontSize: 11.5, fontWeight: FontWeight.w600)),
          PriceText(amount, size: 11.5, color: WexColors.success, weight: FontWeight.w800),
        ]),
      );
}

class _CompleteSetup extends ConsumerWidget {
  final Set<int> inCart;
  const _CompleteSetup({required this.inCart});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(accessoriesProvider);
    return async.maybeWhen(
      data: (all) {
        final list = all.where((p) => !inCart.contains(p.id) && !p.isOutOfStock).toList();
        if (list.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: Sp.x8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(Ar.completeSetup, style: WexText.title),
            const SizedBox(height: Sp.x5),
            SizedBox(
              height: 296,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(width: Sp.x5),
                itemBuilder: (_, i) => SizedBox(
                  width: 164, height: 296,
                  child: ProductCard(product: list[i], onTap: () => context.push('/products/${list[i].slug}')),
                ),
              ),
            ),
          ]),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

/// Sticky: just the total + the CTA.
class _CheckoutBar extends StatelessWidget {
  final int total;
  const _CheckoutBar({required this.total});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(Sp.page, Sp.x5, Sp.page, Sp.x5),
        decoration: const BoxDecoration(
          color: WexColors.white,
          border: Border(top: BorderSide(color: WexColors.border)),
          boxShadow: [BoxShadow(color: WexColors.shadowSticky, blurRadius: 24, offset: Offset(0, -6))],
        ),
        child: SafeArea(
          top: false,
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              const Text(Ar.total, style: WexText.caption),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
                child: PriceText(total, key: ValueKey(total), size: 20),
              ),
            ]),
            const SizedBox(width: Sp.x7),
            Expanded(child: WexButton(Ar.continueLabel, onPressed: () => context.push('/checkout'))),
          ]),
        ),
      );
}

class _SwipeBg extends StatelessWidget {
  final AlignmentGeometry alignment;
  const _SwipeBg(this.alignment);
  @override
  Widget build(BuildContext context) => Container(
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(color: WexColors.dangerBg, borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.delete_outline_rounded, color: WexColors.danger),
      );
}
