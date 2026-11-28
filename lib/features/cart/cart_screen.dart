import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/spacing.dart';
import '../../core/design/typography.dart';
import '../../core/format/money.dart';
import '../../core/utils/product_name.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/product.dart' show conditionLabel;
import '../../ui/app_scaffold.dart';
import '../../ui/app_top_bar.dart';
import '../../ui/buttons.dart';
import '../../ui/icons.dart';
import '../../ui/money_text.dart';
import '../../ui/product_card.dart';
import '../../ui/product_image.dart';
import '../../ui/qty_stepper.dart';
import '../../ui/section_header.dart';
import '../../ui/states.dart';
import '../../ui/tag.dart';
import '../promotions/promo_inline.dart';
import 'cart_controller.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartControllerProvider);
    final cart = ref.read(cartControllerProvider.notifier);
    final shop = ref.watch(shopProvider).valueOrNull;
    final pct = shop?.appDiscountPercent ?? 0;
    final subtotal = items.fold<int>(0, (s, i) => s + i.lineTotal);
    final discount = (subtotal * pct / 100).round();
    final total = subtotal - discount;

    if (items.isEmpty) {
      return AppScaffold(
        appBar: const AppTopBar(title: 'السلة'),
        body: EmptyState(
          icon: LucideIcons.shoppingBag,
          title: 'سلتك فاضية',
          body: 'اختار جهازًا من المتجر وأضفه هنا.',
          actionLabel: 'تصفّح المتجر',
          onAction: () => context.go('/catalog'),
        ),
      );
    }

    return AppScaffold(
      appBar: const AppTopBar(title: 'السلة'),
      bottomBar: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          const Text('الإجمالي', style: WexText.bodyS),
          const Spacer(),
          _CountUpMoney(total),
        ]),
        const SizedBox(height: 12),
        PrimaryButton('متابعة الطلب', icon: LucideIcons.arrowLeft, onPressed: () => context.push('/checkout')),
      ]),
      body: ListView(
        padding: AppScaffold.listPadding(context, top: 4),
        children: [
          const PromoInline(placement: 'cart_promo', compact: true),
          for (var i = 0; i < items.length; i++) ...[
            _Line(
              item: items[i],
              onInc: () => cart.setQuantity(items[i].productId, items[i].quantity + 1),
              onDec: () => cart.setQuantity(items[i].productId, items[i].quantity - 1),
              onRemove: () => _remove(context, cart, items, i),
            ),
            const SizedBox(height: 12),
          ],
          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: WexColors.surface,
              borderRadius: BorderRadius.circular(Radii.card),
              border: Border.all(color: WexColors.line),
            ),
            child: Column(children: [
              _SumRow('المجموع الفرعي', MoneyText(subtotal, style: WexText.body.copyWith(fontWeight: FontWeight.w600))),
              if (discount > 0)
                _SumRow(
                  'خصم التطبيق ${isolate('$pct%')}',
                  MoneyText(-discount, style: WexText.body.copyWith(fontWeight: FontWeight.w600), color: WexColors.success),
                ),
              const _SumRow('التوصيل', Text('تُحسب في الخطوة التالية', style: WexText.bodyS)),
              const Divider(height: 24),
              Row(children: [
                const Text('الإجمالي', style: WexText.titleM),
                const Spacer(),
                _CountUpMoney(total, large: true),
              ]),
            ]),
          ),
          if (items.length <= 2) _CompleteSetup(inCart: {for (final i in items) i.productId}),
        ],
      ),
    );
  }

  void _remove(BuildContext context, CartController cart, List<CartItem> items, int i) {
    final removed = items[i];
    cart.remove(removed.productId);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: const Text('تم حذف المنتج'),
        action: SnackBarAction(label: 'تراجع', textColor: WexColors.sun500, onPressed: () => cart.restore(removed, i)),
      ));
  }
}

class _SumRow extends StatelessWidget {
  final String label;
  final Widget value;
  const _SumRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(child: Text(label, style: WexText.body)),
          const SizedBox(width: 12),
          value,
        ]),
      );
}

class _Line extends StatelessWidget {
  final CartItem item;
  final VoidCallback onInc, onDec, onRemove;
  const _Line({required this.item, required this.onInc, required this.onDec, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final t = normalizeProductName(item.name);
    final cond = conditionLabel(item.condition);
    return Dismissible(
      key: ValueKey('cart-${item.productId}'),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => onRemove(),
      background: const _SwipeBg(AlignmentDirectional.centerStart),
      secondaryBackground: const _SwipeBg(AlignmentDirectional.centerEnd),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: WexColors.surface,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: WexColors.line),
        ),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 72, child: ProductPhoto(url: item.thumbUrl, aspectRatio: 1, padding: 6, memWidth: 200)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text([t.brand, t.model].where((e) => e.isNotEmpty).join(' '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: RegExp(r'^[\x00-\x7F\s]+$').hasMatch(t.model.trim()) ? TextDirection.ltr : TextDirection.rtl,
                    textAlign: TextAlign.start,
                    style: WexText.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                if (cond.isNotEmpty) AppTag(cond, dense: true),
                const SizedBox(height: 4),
                Row(children: [
                  Text('سعر الوحدة ', style: WexText.bodyS),
                  MoneyText(item.priceSdg, style: WexText.bodyS.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                ]),
              ]),
            ),
            SizedBox(
              width: 44,
              height: 44,
              child: IconButton(
                tooltip: 'حذف المنتج',
                onPressed: onRemove,
                icon: const Icon(LucideIcons.trash2, size: 20, color: WexColors.muted),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            QtyStepper(quantity: item.quantity, max: item.maxQty, onInc: onInc, onDec: onDec),
            const Spacer(),
            MoneyText(item.lineTotal),
          ]),
        ]),
      ),
    );
  }
}

class _SwipeBg extends StatelessWidget {
  final AlignmentGeometry alignment;
  const _SwipeBg(this.alignment);
  @override
  Widget build(BuildContext context) => Container(
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(color: WexColors.dangerBg, borderRadius: BorderRadius.circular(Radii.card)),
        child: const Icon(LucideIcons.trash2, color: WexColors.danger),
      );
}

/// Total that tweens (250ms) to the new value; instant with reduce-motion.
class _CountUpMoney extends StatefulWidget {
  final int value;
  final bool large;
  const _CountUpMoney(this.value, {this.large = false});
  @override
  State<_CountUpMoney> createState() => _CountUpMoneyState();
}

class _CountUpMoneyState extends State<_CountUpMoney> {
  late int _from = widget.value;
  @override
  void didUpdateWidget(_CountUpMoney old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _from = old.value;
  }

  @override
  Widget build(BuildContext context) {
    Widget money(int v) => widget.large ? MoneyText.large(v) : MoneyText(v, style: WexText.priceM);
    if (MediaQuery.of(context).disableAnimations) return money(widget.value);
    return TweenAnimationBuilder<double>(
      key: ValueKey(widget.value),
      tween: Tween(begin: _from.toDouble(), end: widget.value.toDouble()),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => money(v.round()),
    );
  }
}

class _CompleteSetup extends ConsumerWidget {
  final Set<int> inCart;
  const _CompleteSetup({required this.inCart});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = (ref.watch(accessoriesProvider).valueOrNull ?? const [])
        .where((p) => !inCart.contains(p.id) && !p.isOutOfStock)
        .take(6)
        .toList();
    if (list.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader('أكمل جهازك'),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (final p in list) ...[
                SizedBox(width: 168, child: ProductCard(product: p, onTap: () => context.push('/products/${p.slug}'))),
                const SizedBox(width: 12),
              ],
            ]),
          ),
        ),
      ]),
    );
  }
}
