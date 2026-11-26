import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/widgets/price_text.dart';
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
      appBar: AppBar(title: const Text('السلة')),
      body: items.isEmpty
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.shopping_cart_outlined, size: 48, color: WexColors.disabled),
                const SizedBox(height: 12),
                const Text('السلة فارغة حاليًا', style: TextStyle(color: WexColors.textSecondary)),
                const SizedBox(height: 16),
                FilledButton(onPressed: () => context.go('/catalog'), child: const Text('تصفّح الأجهزة')),
              ]),
            )
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
                          ..showSnackBar(SnackBar(
                            content: const Text('تم حذف المنتج'),
                            action: SnackBarAction(label: 'تراجع', onPressed: () => cart.restore(removed, index)),
                          ));
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
    return Container(
      padding: const EdgeInsets.all(Sp.x5),
      decoration: BoxDecoration(
        color: WexColors.white,
        borderRadius: BorderRadius.circular(Radii.card),
        boxShadow: const [BoxShadow(color: Color(0x0F061A55), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.sm),
            child: SizedBox(
              width: 72, height: 72,
              child: item.thumbUrl.isEmpty
                  ? Container(color: WexColors.iceLight, child: const Icon(Icons.devices_other, color: WexColors.disabled))
                  : CachedNetworkImage(imageUrl: item.thumbUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: Sp.x5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 6),
                PriceText(item.lineTotal, size: 15),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: WexColors.danger, size: 20)),
              _Stepper(quantity: item.quantity, onInc: onInc, onDec: onDec),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onInc, onDec;
  const _Stepper({required this.quantity, required this.onInc, required this.onDec});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: WexColors.border),
          borderRadius: BorderRadius.circular(Radii.pill),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _sq(Icons.remove, quantity > 1 ? onDec : null),
          SizedBox(width: 28, child: Text('$quantity', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700))),
          _sq(Icons.add, onInc),
        ]),
      );
  Widget _sq(IconData i, VoidCallback? onTap) =>
      IconButton(iconSize: 16, visualDensity: VisualDensity.compact, onPressed: onTap, icon: Icon(i, color: WexColors.royal));
}

class _Summary extends StatelessWidget {
  final int subtotal, discount, discountPct, total;
  const _Summary({required this.subtotal, required this.discount, required this.discountPct, required this.total});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(Sp.page, Sp.x6, Sp.page, Sp.x6),
      decoration: const BoxDecoration(
        color: WexColors.white,
        boxShadow: [BoxShadow(color: Color(0x14061A55), blurRadius: 16, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _row('المجموع الفرعي', subtotal),
            if (discount > 0) _row('خصم التطبيق ($discountPct%)', -discount, color: WexColors.success),
            const Padding(padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('رسوم التوصيل: تُحسب في الخطوة التالية',
                    style: TextStyle(color: WexColors.textSecondary, fontSize: 12))),
            const SizedBox(height: 4),
            Row(children: [
              const Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const Spacer(),
              PriceText(total, size: 20),
            ]),
            const SizedBox(height: Sp.x5),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.push('/checkout'),
                child: const Text('متابعة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, int value, {Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Text(label, style: const TextStyle(color: WexColors.textSecondary)),
          const Spacer(),
          PriceText(value.abs(), size: 14, color: color ?? WexColors.navy, weight: FontWeight.w700),
        ]),
      );
}
