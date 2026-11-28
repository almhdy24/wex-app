import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../design/colors.dart';
import '../design/spacing.dart';
import '../strings.dart';
import 'price_text.dart';
import 'wex_widgets.dart';

/// Product card: branded image/placeholder, condition badge, brand+model name
/// (2-line ellipsis, LTR for English), spec chips, price. Press-scale.
class ProductCard extends StatefulWidget {
  final ProductListItem product;
  final VoidCallback onTap;
  final List<String> chips; // optional short spec chips
  const ProductCard(
      {super.key,
      required this.product,
      required this.onTap,
      this.chips = const []});
  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final isNew = p.condition == 'new';
    final cond = isNew
        ? Ar.condNew
        : (p.condition == 'used_imported'
            ? Ar.condUsed
            : conditionLabel(p.condition));
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
          decoration: BoxDecoration(
            color: WexColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: WexColors.border),
            boxShadow: const [
              BoxShadow(
                  color: WexColors.shadowSoft,
                  blurRadius: 18,
                  offset: Offset(0, 8))
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: WexColors.iceLight,
                      padding: const EdgeInsets.all(8),
                      child: p.thumbUrl.isEmpty
                          ? const _Placeholder()
                          : Hero(
                              tag: 'product-${p.id}',
                              child: CachedNetworkImage(
                                imageUrl: p.thumbUrl,
                                fit: BoxFit.contain,
                                placeholder: (_, __) => const _Placeholder(),
                                errorWidget: (_, __, ___) =>
                                    const _Placeholder(),
                              ),
                            ),
                    ),
                    if (cond.isNotEmpty)
                      PositionedDirectional(
                          top: 10,
                          start: 10,
                          child: WexBadge(cond,
                              bg: isNew ? WexColors.primary : Colors.white,
                              fg: isNew
                                  ? Colors.white
                                  : WexColors.textPrimary)),
                    if (p.isOutOfStock)
                      Positioned.fill(
                          child: ColoredBox(
                              color: const Color(0x80FFFFFF),
                              child: Center(
                                  child: WexBadge(Ar.outOfStock,
                                      bg: WexColors.danger)))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(Sp.x6, Sp.x5, Sp.x6, Sp.x6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LtrText(p.name,
                        maxLines: 2,
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            height: 1.3)),
                    if (widget.chips.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Wrap(spacing: 5, runSpacing: 5, children: [
                        for (final c in widget.chips.take(3)) WexChip(c)
                      ]),
                    ],
                    const SizedBox(height: 8),
                    PriceText(p.priceSdg, size: 15.5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();
  @override
  Widget build(BuildContext context) => const Center(
      child:
          Icon(Icons.laptop_mac_rounded, color: WexColors.disabled, size: 36));
}
