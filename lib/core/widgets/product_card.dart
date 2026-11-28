import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product.dart';
import '../../features/cart/cart_controller.dart';
import '../design/colors.dart';
import '../design/typography.dart';
import '../strings.dart';
import '../utils/product_name.dart';
import '../utils/spec_normalizer.dart';
import 'fly_to_cart.dart';
import 'price_text.dart';
import 'wex_widgets.dart';

/// Grid delegate sized to the card: square image + fixed text block, so cells never
/// overflow or leave dead gaps.
SliverGridDelegate productGridDelegate(double screenWidth, {double padding = 16, double gap = 12}) {
  final cell = (screenWidth - padding * 2 - gap) / 2;
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2, mainAxisSpacing: gap, crossAxisSpacing: gap,
    mainAxisExtent: (cell - 16) + 8 + 134,
  );
}

/// Product card (Round 2): 1:1 cover image (no side bars), badge inside the image,
/// brand caption, 2-line model title, spec line, price, quick-add (+) with fly-to-cart.
class ProductCard extends ConsumerStatefulWidget {
  final ProductListItem product;
  final VoidCallback onTap;
  const ProductCard({super.key, required this.product, required this.onTap});
  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool _pressed = false;
  bool _added = false;

  void _quickAdd(BuildContext btnContext) {
    ref.read(cartControllerProvider.notifier).addListItem(widget.product);
    flyToCart(btnContext);
    setState(() => _added = true);
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _added = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final t = p.title;
    final isNew = p.condition == 'new';
    final cond = isNew ? Ar.condNew : (p.condition == 'used_imported' ? Ar.condUsed : conditionLabel(p.condition));
    final specs = specLine(p.specs);
    final latin = isLatinTitle(t.model);
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: WexColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: WexColors.border),
            boxShadow: const [BoxShadow(color: WexColors.shadowSoft, blurRadius: 14, offset: Offset(0, 6))],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const ColoredBox(color: WexColors.iceLight),
                          if (p.thumbUrl.isNotEmpty)
                            Hero(
                              tag: 'product-${p.id}',
                              child: CachedNetworkImage(
                                imageUrl: p.thumbUrl, fit: BoxFit.cover,
                                placeholder: (_, __) => const _Placeholder(),
                                errorWidget: (_, __, ___) => const _Placeholder(),
                              ),
                            )
                          else
                            const _Placeholder(),
                          if (cond.isNotEmpty)
                            PositionedDirectional(
                              top: 8, start: 8,
                              child: WexBadge(cond,
                                  bg: isNew ? WexColors.primary : Colors.white,
                                  fg: isNew ? Colors.white : WexColors.textPrimary),
                            ),
                          if (p.isOutOfStock)
                            Positioned.fill(
                              child: ColoredBox(
                                color: const Color(0x99FFFFFF),
                                child: Center(child: WexBadge(Ar.outOfStock, bg: WexColors.danger)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 10, 4, 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (t.brand.isNotEmpty)
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(t.brand, style: WexText.caption.copyWith(letterSpacing: 0.4)),
                              ),
                            ),
                          Text(
                            t.model,
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                            textDirection: latin ? TextDirection.ltr : TextDirection.rtl,
                            textAlign: latin ? TextAlign.right : TextAlign.start,
                            style: WexText.itemTitle,
                          ),
                          if (specs.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(specs, maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: WexText.caption),
                              ),
                            ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 44),
                            child: PriceText(p.priceSdg, size: 17),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (!p.isOutOfStock)
                PositionedDirectional(
                  bottom: 0, end: 0,
                  child: Builder(
                    builder: (btnContext) => _QuickAdd(added: _added, onTap: () => _quickAdd(btnContext)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAdd extends StatelessWidget {
  final bool added;
  final VoidCallback onTap;
  const _QuickAdd({required this.added, required this.onTap});
  @override
  Widget build(BuildContext context) => Semantics(
        button: true, label: Ar.addToCart,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: added ? WexColors.success : WexColors.primary,
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(color: Color(0x333E4EE8), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                child: Icon(added ? Icons.check_rounded : Icons.add_rounded,
                    key: ValueKey(added), color: Colors.white, size: 22),
              ),
            ),
          ),
        ),
      );
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();
  @override
  Widget build(BuildContext context) => const Center(
      child: Icon(Icons.laptop_mac_rounded, color: WexColors.disabled, size: 36));
}
