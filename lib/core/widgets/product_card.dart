import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../design/colors.dart';
import '../design/spacing.dart';
import 'price_text.dart';

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
    final product = widget.product;
    final cond = conditionLabel(product.condition);
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
        decoration: BoxDecoration(
          color: WexColors.white,
          borderRadius: BorderRadius.circular(Radii.card),
          boxShadow: const [BoxShadow(color: Color(0x0F061A55), blurRadius: 6, offset: Offset(0, 2))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'product-${product.id}',
                    child: product.thumbUrl.isEmpty
                        ? Container(color: WexColors.iceLight, child: const Icon(Icons.devices_other, color: WexColors.disabled, size: 40))
                        : CachedNetworkImage(
                            imageUrl: product.thumbUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: WexColors.iceLight),
                            errorWidget: (_, __, ___) => Container(
                                color: WexColors.iceLight,
                                child: const Icon(Icons.devices_other, color: WexColors.disabled, size: 40)),
                          ),
                  ),
                  if (cond.isNotEmpty)
                    PositionedDirectional(
                      top: 8, start: 8,
                      child: _Badge(text: cond, color: product.condition == 'new' ? WexColors.royal : WexColors.navy),
                    ),
                  if (product.isOutOfStock)
                    PositionedDirectional(
                      top: 8, end: 8,
                      child: _Badge(text: 'نفذ', color: WexColors.danger),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Sp.x6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.4)),
                  const SizedBox(height: 6),
                  PriceText(product.priceSdg, size: 16),
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

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(Radii.sm)),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}
