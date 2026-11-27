import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../design/colors.dart';
import '../design/spacing.dart';
import 'price_text.dart';

/// Modern product card: large rounded image, hairline border, quiet shadow,
/// condition pill, press-scale. Robust against overflow (no AspectRatio in a
/// fixed grid cell — image takes the flexible space).
class ProductCard extends StatefulWidget {
  final ProductListItem product;
  final VoidCallback onTap;
  const ProductCard({super.key, required this.product, required this.onTap});
  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final cond = conditionLabel(p.condition);
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
            boxShadow: const [BoxShadow(color: WexColors.shadowSoft, blurRadius: 18, offset: Offset(0, 8))],
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
                      child: Hero(
                        tag: 'product-${p.id}',
                        child: p.thumbUrl.isEmpty
                            ? const Icon(Icons.laptop_mac_rounded, color: WexColors.disabled, size: 38)
                            : CachedNetworkImage(
                                imageUrl: p.thumbUrl, fit: BoxFit.cover,
                                placeholder: (_, __) => const ColoredBox(color: WexColors.iceLight),
                                errorWidget: (_, __, ___) => const Icon(Icons.laptop_mac_rounded, color: WexColors.disabled, size: 38),
                              ),
                      ),
                    ),
                    if (cond.isNotEmpty)
                      PositionedDirectional(
                        top: 10, start: 10,
                        child: _Pill(text: cond, filled: p.condition == 'new'),
                      ),
                    if (p.isOutOfStock)
                      Positioned.fill(
                        child: ColoredBox(
                          color: const Color(0x66FFFFFF),
                          child: Center(child: _Pill(text: 'نفذ', filled: true, danger: true)),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(Sp.x6, Sp.x5, Sp.x6, Sp.x6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(p.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, height: 1.3)),
                    const SizedBox(height: 6),
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

class _Pill extends StatelessWidget {
  final String text;
  final bool filled;
  final bool danger;
  const _Pill({required this.text, this.filled = false, this.danger = false});
  @override
  Widget build(BuildContext context) {
    final bg = danger ? WexColors.danger : filled ? WexColors.primary : Colors.white;
    final fg = (danger || filled) ? Colors.white : WexColors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(Radii.pill),
        border: filled || danger ? null : Border.all(color: WexColors.border),
      ),
      child: Text(text, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
