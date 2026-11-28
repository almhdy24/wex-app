import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/spacing.dart';
import '../../core/design/typography.dart';
import '../../core/strings.dart';
import '../../core/utils/launchers.dart';
import '../../core/utils/product_name.dart';
import '../../core/utils/spec_normalizer.dart';
import '../../core/widgets/cart_button.dart';
import '../../core/widgets/fly_to_cart.dart';
import '../../core/widgets/price_text.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/whatsapp_glyph.dart';
import '../../core/widgets/wex_widgets.dart';
import '../../data/models/product.dart';
import '../cart/cart_controller.dart';

final productDetailProvider =
    FutureProvider.autoDispose.family<ProductDetail, String>(
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
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _openViewer(List<ProductImage> images, int start) {
    Navigator.of(context, rootNavigator: true).push(PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => _FullScreenViewer(images: images, start: start),
      transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(productDetailProvider(widget.slug));
    return Scaffold(
      appBar: AppBar(title: const Text(Ar.deviceDetails), actions: const [CartButton()]),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => WexEmptyState(
          icon: Icons.error_outline_rounded,
          title: Ar.deviceLoadError,
          ctaLabel: Ar.retry,
          onCta: () => ref.invalidate(productDetailProvider(widget.slug)),
        ),
        data: (p) => _content(context, p),
      ),
    );
  }

  Widget _content(BuildContext context, ProductDetail p) {
    final images = p.images;
    final shop = ref.watch(shopProvider).valueOrNull;
    final rows = buildSpecRows(p.specs);
    final chips = specChips(p.specs);
    final title = p.title;
    final latin = isLatinTitle(title.full);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              // ---- Gallery: 4:3, cover, dots INSIDE the image ----
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const ColoredBox(color: WexColors.iceLight),
                    if (images.isEmpty)
                      const Center(child: Icon(Icons.laptop_mac_rounded, size: 76, color: WexColors.disabled))
                    else
                      PageView.builder(
                        controller: _page,
                        onPageChanged: (i) => setState(() => _index = i),
                        itemCount: images.length,
                        itemBuilder: (_, i) => GestureDetector(
                          onTap: () => _openViewer(images, i),
                          child: Hero(
                            tag: i == 0 ? 'product-${p.id}' : 'img-${p.id}-$i',
                            child: CachedNetworkImage(imageUrl: images[i].url, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    if (images.length > 1)
                      PositionedDirectional(
                        bottom: 12, start: 0, end: 0,
                        child: IgnorePointer(
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            for (var i = 0; i < images.length; i++)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: i == _index ? 22 : 7, height: 7,
                                decoration: BoxDecoration(
                                  color: i == _index ? Colors.white : const Color(0x99FFFFFF),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4)],
                                ),
                              ),
                          ]),
                        ),
                      ),
                    if (images.isNotEmpty)
                      PositionedDirectional(
                        top: 10, end: 10,
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(color: Color(0x99000000), shape: BoxShape.circle),
                            child: const Icon(Icons.zoom_out_map_rounded, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(Sp.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- Above the fold: title, price, key specs, availability ----
                    if (title.brand.isNotEmpty)
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(title.brand, style: WexText.caption.copyWith(letterSpacing: 0.5)),
                        ),
                      ),
                    Text(
                      title.model,
                      textDirection: latin ? TextDirection.ltr : TextDirection.rtl,
                      textAlign: latin ? TextAlign.right : TextAlign.start,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.35),
                    ),
                    const SizedBox(height: Sp.x5),
                    PriceText(p.priceSdg, size: 26),
                    const SizedBox(height: Sp.x5),
                    Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                      _AvailabilityChip(p),
                      _condChip(p),
                      for (final c in chips) WexChip(c),
                    ]),
                    const SizedBox(height: Sp.x5),
                    const Text(Ar.priceMayChange, style: WexText.caption),

                    // ---- Full spec grid: 2 columns, value large, label small ----
                    if (rows.isNotEmpty) ...[
                      const SizedBox(height: Sp.x9),
                      const Text(Ar.allSpecs, style: WexText.title),
                      const SizedBox(height: Sp.x6),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, mainAxisSpacing: Sp.x5, crossAxisSpacing: Sp.x5, mainAxisExtent: 100),
                        itemCount: rows.length,
                        itemBuilder: (_, i) => _SpecTile(rows[i]),
                      ),
                    ],

                    if ((p.description ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: Sp.x9),
                      const Text(Ar.description, style: WexText.title),
                      const SizedBox(height: Sp.x5),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        alignment: Alignment.topCenter,
                        child: Text(
                          p.description!,
                          maxLines: _descExpanded ? null : 4,
                          overflow: _descExpanded ? null : TextOverflow.ellipsis,
                          style: WexText.body.copyWith(height: 1.9, color: WexColors.textSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _descExpanded = !_descExpanded),
                        child: Text(_descExpanded ? Ar.showLess : Ar.showMore),
                      ),
                    ],

                    if (p.accessories.isNotEmpty) ...[
                      const SizedBox(height: Sp.x8),
                      const Text(Ar.compatible, style: WexText.title),
                      const SizedBox(height: Sp.x6),
                      SizedBox(
                        height: 300,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          itemCount: p.accessories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: Sp.x6),
                          itemBuilder: (_, i) => SizedBox(
                            width: 164, height: 300,
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
        _StickyBar(product: p, whatsapp: shop?.whatsapp ?? ''),
      ],
    );
  }

  Widget _condChip(ProductDetail p) {
    final isNew = p.condition == 'new';
    final label = isNew ? Ar.condNew : (p.condition == 'used_imported' ? Ar.condUsed : conditionLabel(p.condition));
    if (label.isEmpty) return const SizedBox.shrink();
    return WexBadge(label,
        bg: isNew ? WexColors.primary : WexColors.iceLight,
        fg: isNew ? Colors.white : WexColors.textPrimary);
  }
}

class _AvailabilityChip extends StatelessWidget {
  final ProductDetail p;
  const _AvailabilityChip(this.p);
  @override
  Widget build(BuildContext context) {
    switch (p.stockStatus) {
      case StockStatus.outOfStock:
        return const WexBadge(Ar.outOfStock, bg: WexColors.dangerBg, fg: WexColors.danger);
      case StockStatus.lowStock:
        final chip = const WexBadge(Ar.lowStock, bg: WexColors.warningBg, fg: WexColors.warning);
        if (MediaQuery.of(context).disableAnimations) return chip;
        return chip
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fade(begin: 0.65, end: 1, duration: 900.ms);
      default:
        return const WexBadge(Ar.inStock, bg: WexColors.successBg, fg: WexColors.success);
    }
  }
}

class _SpecTile extends StatelessWidget {
  final SpecRow row;
  const _SpecTile(this.row);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(Sp.x6),
        decoration: BoxDecoration(
          color: WexColors.white,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: WexColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Icon(row.icon, size: 15, color: WexColors.primary),
              const SizedBox(width: 6),
              Text(row.label, style: WexText.caption),
            ]),
            const SizedBox(height: 6),
            LtrText(row.value, maxLines: 2, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.3)),
          ],
        ),
      );
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
      decoration: const BoxDecoration(
        color: WexColors.white,
        border: Border(top: BorderSide(color: WexColors.border)),
        boxShadow: [BoxShadow(color: WexColors.shadowSticky, blurRadius: 24, offset: Offset(0, -6))],
      ),
      child: SafeArea(
        top: false,
        child: Row(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(Ar.priceLabel, style: WexText.caption),
              PriceText(product.priceSdg, size: 16),
            ],
          ),
          const SizedBox(width: Sp.x5),
          Expanded(
            child: Builder(
              builder: (btnContext) => WexButton(
                disabled ? Ar.outOfStock : Ar.addToCart,
                onPressed: disabled
                    ? null
                    : () {
                        ref.read(cartControllerProvider.notifier).addProduct(product);
                        flyToCart(btnContext);
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(SnackBar(
                            content: const Text(Ar.added),
                            action: SnackBarAction(label: Ar.viewCart, onPressed: () => context.push('/cart')),
                          ));
                      },
              ),
            ),
          ),
          if (whatsapp.isNotEmpty) ...[
            const SizedBox(width: 10),
            _WhatsAppBtn(onTap: () => openWhatsApp(whatsapp, text: Ar.waProductInquiry(product.title.full))),
          ],
        ]),
      ),
    );
  }
}

class _WhatsAppBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _WhatsAppBtn({required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF25D366),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            WhatsAppGlyph(size: 22, color: Colors.white),
            SizedBox(width: 6),
            Text(Ar.whatsappLabel, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        ),
      );
}

/// Full-screen image viewer: contain + pinch zoom, swipe between images.
class _FullScreenViewer extends StatefulWidget {
  final List<ProductImage> images;
  final int start;
  const _FullScreenViewer({required this.images, required this.start});
  @override
  State<_FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<_FullScreenViewer> {
  late final PageController _c = PageController(initialPage: widget.start);
  late int _i = widget.start;
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          PageView.builder(
            controller: _c,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _i = i),
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 1, maxScale: 5,
              child: Center(child: CachedNetworkImage(imageUrl: widget.images[i].url, fit: BoxFit.contain)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
                const Spacer(),
                if (widget.images.length > 1)
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text('${_i + 1} / ${widget.images.length}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                const SizedBox(width: 12),
              ]),
            ),
          ),
        ]),
      );
}
