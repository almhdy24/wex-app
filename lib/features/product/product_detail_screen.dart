import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/widgets/price_text.dart';
import '../../core/widgets/product_card.dart';
import '../../data/models/product.dart';

final productDetailProvider = FutureProvider.autoDispose.family<ProductDetail, String>(
  (ref, slug) => ref.read(productRepositoryProvider).detail(slug),
);

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String slug;
  const ProductDetailScreen({super.key, required this.slug});
  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _imageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(productDetailProvider(widget.slug));
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الجهاز')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 40, color: WexColors.disabled),
            const SizedBox(height: 12),
            const Text('تعذّر تحميل الجهاز', style: TextStyle(color: WexColors.textSecondary)),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => ref.invalidate(productDetailProvider(widget.slug)),
              child: const Text('إعادة المحاولة')),
          ]),
        ),
        data: (p) => _content(context, p),
      ),
    );
  }

  Widget _content(BuildContext context, ProductDetail p) {
    final images = p.images.isNotEmpty ? p.images : <ProductImage>[];
    final cond = conditionLabel(p.condition);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Gallery
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: WexColors.iceLight,
                  child: images.isEmpty
                      ? const Icon(Icons.devices_other, size: 72, color: WexColors.disabled)
                      : Hero(
                          tag: 'product-${p.id}',
                          child: CachedNetworkImage(
                            imageUrl: images[_imageIndex].url, fit: BoxFit.contain),
                        ),
                ),
              ),
              if (images.length > 1)
                SizedBox(
                  height: 70,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(Sp.x5),
                    itemCount: images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: Sp.x3),
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => setState(() => _imageIndex = i),
                      child: Container(
                        width: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Radii.sm),
                          border: Border.all(
                              color: i == _imageIndex ? WexColors.royal : WexColors.border, width: 2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CachedNetworkImage(imageUrl: images[i].thumbUrl, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(Sp.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cond.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: WexColors.ice, borderRadius: BorderRadius.circular(Radii.pill)),
                        child: Text(cond, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: WexColors.navy)),
                      ),
                    const SizedBox(height: Sp.x5),
                    Text(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.4)),
                    const SizedBox(height: Sp.x5),
                    PriceText(p.priceSdg, size: 26),
                    if (p.stockStatus == StockStatus.lowStock) ...[
                      const SizedBox(height: 8),
                      const Text('الكمية محدودة', style: TextStyle(color: WexColors.warning, fontWeight: FontWeight.w700)),
                    ],
                    if ((p.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: Sp.x8),
                      Text(p.description!, style: const TextStyle(height: 1.8, color: WexColors.textSecondary)),
                    ],
                    if (p.specs.isNotEmpty) ...[
                      const SizedBox(height: Sp.x9),
                      const Text('المواصفات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: Sp.x5),
                      ...p.specs.entries.map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    width: 120,
                                    child: Text(e.key,
                                        style: const TextStyle(color: WexColors.textSecondary))),
                                Expanded(
                                    child: Text(e.value,
                                        style: const TextStyle(fontWeight: FontWeight.w600))),
                              ],
                            ),
                          )),
                    ],
                    if (p.accessories.isNotEmpty) ...[
                      const SizedBox(height: Sp.x9),
                      const Text('ملحقات متوافقة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: Sp.x5),
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: p.accessories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: Sp.x6),
                          itemBuilder: (_, i) => SizedBox(
                            width: 150,
                            child: ProductCard(
                              product: p.accessories[i],
                              onTap: () => context.push('/products/${p.accessories[i].slug}'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        _StickyBar(product: p),
      ],
    );
  }
}

class _StickyBar extends StatelessWidget {
  final ProductDetail product;
  const _StickyBar({required this.product});
  @override
  Widget build(BuildContext context) {
    final disabled = product.isOutOfStock;
    return Container(
      padding: const EdgeInsets.fromLTRB(Sp.page, Sp.x5, Sp.page, Sp.x5),
      decoration: const BoxDecoration(
        color: WexColors.white,
        boxShadow: [BoxShadow(color: Color(0x14061A55), blurRadius: 16, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            PriceText(product.priceSdg, size: 20),
            const Spacer(),
            FilledButton.icon(
              onPressed: disabled
                  ? null
                  : () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('السلة قادمة في التحديث القادم'))),
              icon: const Icon(Icons.add_shopping_cart),
              label: Text(disabled ? 'غير متوفر' : 'أضف إلى السلة'),
              style: FilledButton.styleFrom(minimumSize: const Size(160, 48)),
            ),
          ],
        ),
      ),
    );
  }
}
