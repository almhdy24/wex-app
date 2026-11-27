import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/strings.dart';
import '../../core/utils/launchers.dart';
import '../../core/utils/spec_normalizer.dart';
import '../../core/widgets/cart_button.dart';
import '../../core/widgets/price_text.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/wex_widgets.dart';
import '../../data/models/product.dart';
import '../cart/cart_controller.dart';

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
  final _page = PageController();
  int _index = 0;
  bool _descExpanded = false;

  @override
  void dispose() { _page.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(productDetailProvider(widget.slug));
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الجهاز'), actions: const [CartButton()]),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => WexEmptyState(
          icon: Icons.error_outline_rounded, title: 'تعذّر تحميل الجهاز',
          ctaLabel: Ar.retry, onCta: () => ref.invalidate(productDetailProvider(widget.slug))),
        data: (p) => _content(context, p),
      ),
    );
  }

  Widget _content(BuildContext context, ProductDetail p) {
    final images = p.images;
    final shop = ref.watch(shopProvider).valueOrNull;
    final rows = buildSpecRows(p.specs);
    final h = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Gallery (~40% height)
              SizedBox(
                height: h * 0.40,
                child: Stack(
                  children: [
                    Container(
                      color: WexColors.iceLight,
                      child: images.isEmpty
                          ? const Center(child: Icon(Icons.laptop_mac_rounded, size: 76, color: WexColors.disabled))
                          : PageView.builder(
                              controller: _page,
                              onPageChanged: (i) => setState(() => _index = i),
                              itemCount: images.length,
                              itemBuilder: (_, i) => InteractiveViewer(
                                maxScale: 4,
                                child: Hero(
                                  tag: i == 0 ? 'product-${p.id}' : 'img-$i',
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: CachedNetworkImage(imageUrl: images[i].url, fit: BoxFit.contain),
                                  ),
                                ),
                              ),
                            ),
                    ),
                    if (images.length > 1)
                      PositionedDirectional(
                        bottom: 14, start: 0, end: 0,
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          for (var i = 0; i < images.length; i++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _index ? 22 : 7, height: 7,
                              decoration: BoxDecoration(
                                color: i == _index ? WexColors.primary : WexColors.disabled,
                                borderRadius: BorderRadius.circular(4)),
                            ),
                        ]),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Sp.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      _condBadge(p),
                      const SizedBox(width: 8),
                      if (p.stockStatus == StockStatus.lowStock) const _PulseBadge(),
                    ]),
                    const SizedBox(height: Sp.x6),
                    LtrText(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.35)),
                    const SizedBox(height: Sp.x5),
                    PriceText(p.priceSdg, size: 26),
                    const SizedBox(height: 8),
                    const Text(Ar.priceMayChange, style: TextStyle(color: WexColors.textSecondary, fontSize: 13)),

                    // Specs grid
                    if (rows.isNotEmpty) ...[
                      const SizedBox(height: Sp.x9),
                      const Text(Ar.specs, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: Sp.x6),
                      GridView.builder(
                        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, mainAxisSpacing: Sp.x5, crossAxisSpacing: Sp.x5, childAspectRatio: 2.5),
                        itemCount: rows.length,
                        itemBuilder: (_, i) => _SpecTile(rows[i]),
                      ),
                    ],

                    // Description (expandable)
                    if ((p.description ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: Sp.x9),
                      const Text('الوصف', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: Sp.x5),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        alignment: Alignment.topCenter,
                        child: Text(p.description!,
                            maxLines: _descExpanded ? null : 4,
                            overflow: _descExpanded ? null : TextOverflow.ellipsis,
                            style: const TextStyle(height: 1.9, color: WexColors.textSecondary)),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _descExpanded = !_descExpanded),
                        child: Text(_descExpanded ? 'عرض أقل' : 'عرض المزيد'),
                      ),
                    ],

                    // Accessories / similar
                    if (p.accessories.isNotEmpty) ...[
                      const SizedBox(height: Sp.x8),
                      const Text(Ar.compatible, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: Sp.x6),
                      SizedBox(
                        height: 236,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: p.accessories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: Sp.x6),
                          itemBuilder: (_, i) => SizedBox(width: 150,
                              child: ProductCard(product: p.accessories[i], onTap: () => context.push('/products/${p.accessories[i].slug}'))),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        _StickyBar(product: p, whatsapp: shop?.whatsapp ?? ''),
      ],
    );
  }

  Widget _condBadge(ProductDetail p) {
    final isNew = p.condition == 'new';
    final label = isNew ? Ar.condNew : (p.condition == 'used_imported' ? Ar.condUsed : conditionLabel(p.condition));
    if (label.isEmpty) return const SizedBox.shrink();
    return WexBadge(label, bg: isNew ? WexColors.primary : WexColors.iceLight, fg: isNew ? Colors.white : WexColors.textPrimary);
  }
}

class _SpecTile extends StatelessWidget {
  final SpecRow row;
  const _SpecTile(this.row);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(Sp.x5),
        decoration: BoxDecoration(
          color: WexColors.white, borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: WexColors.border)),
        child: Row(children: [
          Container(
            width: 34, height: 34, alignment: Alignment.center,
            decoration: BoxDecoration(color: WexColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(9)),
            child: Icon(row.icon, size: 18, color: WexColors.primary)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(row.label, style: const TextStyle(fontSize: 11, color: WexColors.textSecondary)),
            LtrText(row.value, maxLines: 1, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          ])),
        ]),
      );
}

class _PulseBadge extends StatelessWidget {
  const _PulseBadge();
  @override
  Widget build(BuildContext context) => const WexBadge(Ar.lowStock, bg: WexColors.warningBg, fg: WexColors.warning)
      .animate(onPlay: (c) => c.repeat(reverse: true))
      .fadeIn(duration: 900.ms)
      .then()
      .scaleXY(begin: 1, end: 1.04, duration: 900.ms, curve: Curves.easeInOut);
}

class _StickyBar extends ConsumerWidget {
  final ProductDetail product;
  final String whatsapp;
  const _StickyBar({required this.product, required this.whatsapp});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disabled = product.isOutOfStock;
    return Container(
      padding: const EdgeInsets.fromLTRB(Sp.page, Sp.x5, Sp.page, Sp.x5),
      decoration: const BoxDecoration(color: WexColors.white,
          boxShadow: [BoxShadow(color: WexColors.shadowSticky, blurRadius: 24, offset: Offset(0, -6))]),
      child: SafeArea(
        top: false,
        child: Row(children: [
          if (whatsapp.isNotEmpty)
            _IconBtn(Icons.chat_rounded, () => openWhatsApp(whatsapp,
                text: 'مرحبًا، أسأل عن: ${product.name}')),
          if (whatsapp.isNotEmpty) const SizedBox(width: 10),
          Expanded(
            child: WexButton(
              disabled ? Ar.outOfStock : Ar.addToCart,
              icon: disabled ? null : const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 20),
              onPressed: disabled ? null : () {
                HapticFeedback.mediumImpact();
                ref.read(cartControllerProvider.notifier).addProduct(product);
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(SnackBar(content: const Text(Ar.added),
                      action: SnackBarAction(label: Ar.viewCart, onPressed: () => context.push('/cart'))));
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 54, height: 54, alignment: Alignment.center,
          decoration: BoxDecoration(color: WexColors.successBg, borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.chat_rounded, color: WexColors.success, size: 24)),
      );
}
