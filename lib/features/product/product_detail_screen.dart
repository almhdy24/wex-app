import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/env.dart';
import '../../app/providers.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/spacing.dart';
import '../../core/design/typography.dart';
import '../../core/format/money.dart';
import '../../core/utils/arabic_duration.dart';
import '../../core/utils/launchers.dart';
import '../../core/utils/spec_normalizer.dart';
import '../../data/models/product.dart';
import '../../ui/app_scaffold.dart';
import '../../ui/app_top_bar.dart';
import '../../ui/buttons.dart';
import '../../ui/cart_action.dart';
import '../../ui/icons.dart';
import '../../ui/image_viewer.dart';
import '../../ui/money_text.dart';
import '../../ui/product_image.dart';
import '../../ui/skeleton.dart';
import '../../ui/states.dart';
import '../../ui/tag.dart';
import '../../core/widgets/fly_to_cart.dart';
import '../cart/cart_controller.dart';

final productDetailProvider = FutureProvider.autoDispose.family<ProductDetail, String>(
  (ref, slug) => ref.read(productRepositoryProvider).detail(slug),
);

const _keyLabels = ['المعالج', 'الرام', 'التخزين', 'الشاشة', 'كرت الشاشة', 'البطارية'];

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String slug;
  const ProductDetailScreen({super.key, required this.slug});
  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final _page = PageController();
  int _index = 0;
  bool _allSpecs = false;
  final _addKey = GlobalKey();

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(productDetailProvider(widget.slug));
    return async.when(
      loading: () => const AppScaffold(
        appBar: AppTopBar(actions: [CartAction()]),
        body: SkeletonScope(child: _DetailSkeleton()),
      ),
      error: (_, __) => AppScaffold(
        appBar: const AppTopBar(actions: [CartAction()]),
        body: ErrorState(onRetry: () => ref.invalidate(productDetailProvider(widget.slug))),
      ),
      data: (p) => _content(p),
    );
  }

  Widget _content(ProductDetail p) {
    final shop = ref.watch(shopProvider).valueOrNull;
    final t = p.title;
    final urls = [for (final i in p.images) i.url];
    final thumbs = [for (final i in p.images) i.thumbUrl];
    final rows = buildSpecRows(p.specs);
    final byLabel = {for (final r in rows) r.label: r.value};
    final keySpecs = [for (final l in _keyLabels) if (byLabel[l] != null) (l, byLabel[l]!)];
    final cond = conditionLabel(p.condition);
    final inCart = ref.watch(cartControllerProvider).any((e) => e.productId == p.id);
    final lockText = formatHoursAr(shop?.lockHours ?? 4);

    return AppScaffold(
      appBar: const AppTopBar(actions: [CartAction()]),
      bottomBar: Row(children: [
        Expanded(
          child: KeyedSubtree(
            key: _addKey,
            child: PrimaryButton(
              p.isOutOfStock ? 'غير متوفر حاليًا' : (inCart ? 'تمت الإضافة · عرض السلة' : 'أضف إلى السلة'),
              icon: p.isOutOfStock ? null : (inCart ? LucideIcons.arrowLeft : LucideIcons.shoppingBag),
              onPressed: p.isOutOfStock
                  ? null
                  : () {
                      if (inCart) {
                        context.push('/cart');
                      } else {
                        ref.read(cartControllerProvider.notifier).addProduct(p);
                        flyToCart(_addKey.currentContext ?? context);
                      }
                    },
            ),
          ),
        ),
        if (shop != null && shop.whatsapp.isNotEmpty) ...[
          const SizedBox(width: 12),
          IconSquareButton(
            icon: LucideIcons.messageCircle,
            semanticLabel: 'اطلب عبر واتساب',
            size: 52,
            iconColor: WexColors.whatsapp,
            onPressed: () => openWhatsApp(shop.whatsapp,
                text: 'مرحبًا، أسأل عن: ${t.full}\n${Env.origin}/products/${p.slug}'),
          ),
        ],
      ]),
      body: ListView(
        padding: AppScaffold.listPadding(context, extra: 24),
        children: [
          // Gallery
          if (urls.isEmpty)
            const ProductPhoto(url: '')
          else
            Column(children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: PageView.builder(
                  controller: _page,
                  itemCount: urls.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => openImageViewer(context, urls, i),
                    child: ProductPhoto(url: urls[i], heroTag: i == 0 ? 'product-${p.id}' : null, memWidth: 900, padding: 16),
                  ),
                ),
              ),
              if (urls.length > 1) ...[
                const SizedBox(height: 12),
                _Segments(count: urls.length, index: _index),
                const SizedBox(height: 12),
                SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: thumbs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _page.animateToPage(i, duration: Motion.base, curve: Curves.easeOutCubic),
                      child: Container(
                        width: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Radii.control),
                          border: Border.all(color: i == _index ? WexColors.ink900 : WexColors.line, width: i == _index ? 2 : 1),
                        ),
                        child: ProductPhoto(url: thumbs[i], aspectRatio: 1, padding: 4, memWidth: 160),
                      ),
                    ),
                  ),
                ),
              ],
            ]),
          const SizedBox(height: 24),
          // Info
          if (t.brand.isNotEmpty) Text(t.brand, textDirection: TextDirection.ltr, style: WexText.bodyS),
          Text(t.model,
              textDirection: RegExp(r'^[\x00-\x7F\s]+$').hasMatch(t.model.trim()) ? TextDirection.ltr : TextDirection.rtl,
              textAlign: TextAlign.start,
              style: WexText.titleL),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            MoneyText.large(p.priceSdg),
            if (p.isDeal) MoneyText(p.compareAtSdg!, style: WexText.bodyS, strike: true),
            if (p.isDeal) AppTag('وفّر ${formatMoney(p.compareAtSdg! - p.priceSdg)}', kind: TagKind.sun),
          ]),
          const SizedBox(height: 4),
          const Text('السعر قابل للتغيير حتى تأكيد الطلب.', style: WexText.bodyS),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (cond.isNotEmpty) AppTag(cond),
            if (p.stockStatus == StockStatus.lowStock) const AppTag('كمية محدودة', kind: TagKind.sun),
            if (p.isOutOfStock) const AppTag('نفد من المخزون', kind: TagKind.danger),
          ]),
          // Key specs
          if (keySpecs.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('المواصفات الأساسية', style: WexText.titleM),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, c) {
              final w = (c.maxWidth - 12) / 2;
              return Wrap(spacing: 12, runSpacing: 16, children: [
                for (final s in keySpecs) SizedBox(width: w, child: _SpecCell(label: s.$1, value: s.$2)),
              ]);
            }),
          ],
          // All specs
          if (rows.length > 1) ...[
            const SizedBox(height: 16),
            InkWell(
              onTap: () => setState(() => _allSpecs = !_allSpecs),
              child: SizedBox(
                height: 48,
                child: Row(children: [
                  const Expanded(child: Text('كل المواصفات', style: WexText.titleM)),
                  AnimatedRotation(
                    turns: _allSpecs ? 0.5 : 0,
                    duration: Motion.base,
                    child: const Icon(LucideIcons.chevronDown, size: 22),
                  ),
                ]),
              ),
            ),
            AnimatedSize(
              duration: Motion.base,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: !_allSpecs
                  ? const SizedBox(width: double.infinity)
                  : Container(
                      decoration: BoxDecoration(
                        color: WexColors.surface,
                        borderRadius: BorderRadius.circular(Radii.card),
                        border: Border.all(color: WexColors.line),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(children: [
                        for (var i = 0; i < rows.length; i++) ...[
                          if (i > 0) const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Expanded(child: Text(rows[i].label, style: WexText.bodyS)),
                              const SizedBox(width: 12),
                              Flexible(child: _value(rows[i].value, align: TextAlign.end)),
                            ]),
                          ),
                        ],
                      ]),
                    ),
            ),
          ],
          // How ordering works
          const SizedBox(height: 24),
          const Text('كيف يتم الطلب', style: WexText.titleM),
          const SizedBox(height: 12),
          _Step(1, 'أضف الجهاز إلى السلة وأكمل بيانات الطلب.'),
          _Step(2, 'نثبّت لك السعر $lockText بعد الطلب.'),
          _Step(3, 'حوّل المبلغ وارفع إشعار التحويل، ثم نراجعه ونؤكد طلبك.', last: true),
        ],
      ),
    );
  }
}

Widget _value(String v, {TextAlign align = TextAlign.start}) {
  final latin = RegExp(r'^[\x00-\x7F\s]+$').hasMatch(v.trim());
  return Text(v,
      textDirection: latin ? TextDirection.ltr : TextDirection.rtl,
      textAlign: align,
      style: WexText.body.copyWith(fontWeight: FontWeight.w600));
}

class _SpecCell extends StatelessWidget {
  final String label;
  final String value;
  const _SpecCell({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: WexText.label),
        const SizedBox(height: 2),
        _value(value),
      ]);
}

class _Segments extends StatelessWidget {
  final int count;
  final int index;
  const _Segments({required this.count, required this.index});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: Motion.base,
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 3,
            width: i == index ? 20 : 6,
            decoration: BoxDecoration(
              color: i == index ? WexColors.ink900 : WexColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ]);
}

class _Step extends StatelessWidget {
  final int n;
  final String text;
  final bool last;
  const _Step(this.n, this.text, {this.last = false});
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(
            width: 28,
            child: Column(children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: WexColors.ink900)),
                child: Text('$n', style: WexText.numeric.copyWith(fontSize: 13)),
              ),
              if (!last) const Expanded(child: VerticalDivider(width: 1)),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2, bottom: last ? 0 : 16),
              child: Text(text, style: WexText.body),
            ),
          ),
        ]),
      );
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();
  @override
  Widget build(BuildContext context) => ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: const [
          AspectRatio(aspectRatio: 4 / 3, child: SkeletonBox(height: double.infinity)),
          SizedBox(height: 24),
          SkeletonBox(height: 14, width: 60),
          SizedBox(height: 8),
          SkeletonBox(height: 24, width: 220),
          SizedBox(height: 16),
          SkeletonBox(height: 30, width: 160),
          SizedBox(height: 24),
          SkeletonBox(height: 60),
        ],
      );
}
