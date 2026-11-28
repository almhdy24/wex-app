import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/design/colors.g.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';
import '../core/format/money.dart';
import '../core/utils/spec_normalizer.dart';
import '../core/widgets/fly_to_cart.dart';
import '../data/models/product.dart';
import '../features/cart/cart_controller.dart';
import 'icons.dart';
import 'money_text.dart';
import 'product_image.dart';
import 'qty_stepper.dart';
import 'tag.dart';

/// Product card: image tile (contain, 4:3), condition tag top-start, brand / model / spec line,
/// price block and the add button (becomes an inline stepper once in the cart).
class ProductCard extends ConsumerStatefulWidget {
  final ProductListItem product;
  final VoidCallback onTap;
  const ProductCard({super.key, required this.product, required this.onTap});
  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool _justAdded = false;
  final _btnKey = GlobalKey();

  void _add() {
    final p = widget.product;
    ref.read(cartControllerProvider.notifier).addListItem(p);
    HapticFeedback.lightImpact();
    flyToCart(_btnKey.currentContext ?? context);
    setState(() => _justAdded = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _justAdded = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final t = p.title;
    final cond = conditionLabel(p.condition);
    final chips = p.specChips.isNotEmpty ? p.specChips : specChips(p.specs);
    final inCart = ref.watch(cartControllerProvider).where((e) => e.productId == p.id).firstOrNull;
    final cart = ref.read(cartControllerProvider.notifier);

    return Semantics(
      button: true,
      label: '${t.full}، ${formatMoney(p.priceSdg)}',
      child: Material(
        color: WexColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
          side: const BorderSide(color: WexColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Stack(children: [
                ProductPhoto(url: p.thumbUrl, heroTag: 'product-${p.id}', memWidth: 420),
                if (cond.isNotEmpty) PositionedDirectional(top: 8, start: 8, child: AppTag(cond, dense: true)),
              ]),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (t.brand.isNotEmpty)
                    Text(t.brand, textDirection: TextDirection.ltr, style: WexText.label),
                  Text(t.model,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: _isLatin(t.model) ? TextDirection.ltr : TextDirection.rtl,
                      textAlign: TextAlign.start,
                      style: WexText.body.copyWith(fontWeight: FontWeight.w600)),
                  if (chips.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(chips.join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.start,
                        style: WexText.label.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                  ],
                  const SizedBox(height: 12),
                  if (p.isDeal)
                    MoneyText(p.compareAtSdg!, style: WexText.label, strike: true)
                  else
                    const SizedBox(height: 0),
                  MoneyText(p.priceSdg),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: p.isOutOfStock
                        ? const Align(alignment: AlignmentDirectional.centerStart, child: AppTag('نفد من المخزون', kind: TagKind.danger))
                        : inCart != null
                            ? Directionality(
                                textDirection: TextDirection.ltr,
                                child: Row(children: [
                                  Expanded(
                                    child: QtyStepper(
                                      quantity: inCart.quantity,
                                      max: inCart.maxQty,
                                      onInc: () => cart.setQuantity(p.id, inCart.quantity + 1),
                                      onDec: () => cart.setQuantity(p.id, inCart.quantity - 1),
                                    ),
                                  ),
                                ]),
                              )
                            : Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: Semantics(
                                  button: true,
                                  label: 'أضف إلى السلة',
                                  child: Material(
                                    key: _btnKey,
                                    color: WexColors.teal600,
                                    borderRadius: BorderRadius.circular(Radii.control),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(Radii.control),
                                      onTap: _add,
                                      child: SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: AnimatedSwitcher(
                                          duration: Motion.fast,
                                          child: Icon(_justAdded ? LucideIcons.check : LucideIcons.plus,
                                              key: ValueKey(_justAdded), size: 20, color: WexColors.surface),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  static bool _isLatin(String s) => RegExp(r'^[\x00-\x7F\s]+$').hasMatch(s.trim());
}

/// Two-column rows with equal card heights (content-driven; no fixed child aspect ratio).
List<Widget> productRows(List<ProductListItem> items, Widget Function(ProductListItem) card, {double gap = 12}) {
  final rows = <Widget>[];
  for (var i = 0; i < items.length; i += 2) {
    final a = items[i];
    final b = i + 1 < items.length ? items[i + 1] : null;
    rows.add(Padding(
      padding: EdgeInsets.only(bottom: gap),
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: card(a)),
          SizedBox(width: gap),
          Expanded(child: b == null ? const SizedBox.shrink() : card(b)),
        ]),
      ),
    ));
  }
  return rows;
}
