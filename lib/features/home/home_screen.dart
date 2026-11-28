import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/spacing.dart';
import '../../core/design/typography.dart';
import '../../core/format/store_status.dart';
import '../../core/utils/arabic_duration.dart';
import '../../core/utils/launchers.dart';
import '../../data/models/product.dart';
import '../../data/models/shop.dart';
import '../../data/repositories/product_repository.dart';
import '../../ui/app_scaffold.dart';
import '../../ui/brand_logo.dart';
import '../../ui/buttons.dart';
import '../../ui/cart_action.dart';
import '../../ui/icons.dart';
import '../../ui/product_card.dart';
import '../../ui/section_header.dart';
import '../../ui/skeleton.dart';
import '../../ui/states.dart';
import '../../ui/tag.dart';
import '../promotions/promo_carousel.dart';
import '../promotions/promo_actions.dart';

final featuredProvider = FutureProvider.autoDispose(
    (ref) => ref.read(productRepositoryProvider).list(const ProductQuery(sort: 'newest', perPage: 8)));

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shop = ref.watch(shopProvider).valueOrNull;
    final featured = ref.watch(featuredProvider);
    final deals = ref.watch(dealsProvider).valueOrNull ?? const <ProductListItem>[];

    return AppScaffold(
      body: RefreshIndicator(
        color: WexColors.teal600,
        onRefresh: () async {
          ref.invalidate(shopProvider);
          ref.invalidate(featuredProvider);
          ref.invalidate(dealsProvider);
          ref.invalidate(promotionsProvider('home_hero'));
          ref.invalidate(promotionsProvider('home_strip'));
        },
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: AppScaffold.listPadding(context, horizontal: 0, extra: 32),
            children: [
              // Top bar
              const SizedBox(
                height: 56,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: 16, end: 4),
                  child: Row(children: [Expanded(child: Align(alignment: AlignmentDirectional.centerStart, child: BrandLockup())), CartAction()]),
                ),
              ),
              // Search
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Hero(
                  tag: 'search-field',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(Radii.control),
                      onTap: () => context.go('/catalog?focus=1'),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: WexColors.surface,
                          borderRadius: BorderRadius.circular(Radii.control),
                          border: Border.all(color: WexColors.line),
                        ),
                        child: const Row(children: [
                          Icon(LucideIcons.search, size: 20, color: WexColors.muted),
                          SizedBox(width: 12),
                          Expanded(child: Text('ابحث عن لابتوب أو ماركة', maxLines: 1, overflow: TextOverflow.ellipsis, style: WexText.body)),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
              const _Strip(),
              const PromoCarousel(),
              const SizedBox(height: 24),
              // Categories
              const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('تسوّق حسب الفئة', style: WexText.titleM)),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  _CategoryCell(LucideIcons.laptop, 'حواسيب', () => context.go('/catalog?type=laptop')),
                  const SizedBox(width: 12),
                  _CategoryCell(LucideIcons.smartphone, 'هواتف', () => context.go('/catalog?type=phone')),
                  const SizedBox(width: 12),
                  _CategoryCell(LucideIcons.headphones, 'ملحقات', () => context.go('/catalog?type=accessory')),
                ]),
              ),
              const SizedBox(height: 24),
              _TrustRow(lockHours: shop?.lockHours ?? 4),
              const SizedBox(height: 24),
              // Latest
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader('أحدث الأجهزة', onSeeAll: () => context.go('/catalog')),
              ),
              const SizedBox(height: 4),
              featured.when(
                loading: () => const SkeletonScope(child: _RailSkeleton()),
                error: (_, __) => ErrorState(message: 'تعذّر تحميل الأجهزة.', onRetry: () => ref.invalidate(featuredProvider)),
                data: (page) => page.items.isEmpty
                    ? const EmptyState(icon: LucideIcons.packageOpen, title: 'لا توجد أجهزة معروضة الآن', body: 'تابعنا قريبًا، نضيف أجهزة جديدة باستمرار.')
                    : _Rail(items: page.items),
              ),
              if (deals.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: SectionHeader('عروض مميزة')),
                const SizedBox(height: 4),
                _Rail(items: deals),
              ],
              const SizedBox(height: 24),
              if (shop != null && shop.whatsapp.isNotEmpty) _HelpRow(whatsapp: shop.whatsapp),
              if (shop != null) ...[const SizedBox(height: 24), _StoreCard(shop: shop)],
            ],
          ),
        ),
      ),
    );
  }
}

/// home_strip announcement (36px). Hidden when no active promo.
class _Strip extends ConsumerWidget {
  const _Strip();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(promotionsProvider('home_strip')).valueOrNull ?? const [];
    if (list.isEmpty) return const SizedBox.shrink();
    final p = list.first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Material(
        color: WexColors.sun50,
        borderRadius: BorderRadius.circular(Radii.control),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.control),
          onTap: () => handlePromoTap(context, ref, p),
          child: SizedBox(
            height: 36,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                Expanded(child: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: WexText.bodyS.copyWith(color: WexColors.sun700, fontWeight: FontWeight.w500))),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _CategoryCell(this.icon, this.label, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Semantics(
          button: true,
          label: label,
          child: Material(
            color: WexColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.card), side: const BorderSide(color: WexColors.line)),
            child: InkWell(
              borderRadius: BorderRadius.circular(Radii.card),
              onTap: onTap,
              child: Container(
                constraints: const BoxConstraints(minHeight: 88),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(icon, size: 28, color: WexColors.ink900),
                  const SizedBox(height: 8),
                  Text(label, style: WexText.body.copyWith(fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ),
        ),
      );
}

class _TrustRow extends StatelessWidget {
  final int lockHours;
  const _TrustRow({required this.lockHours});
  @override
  Widget build(BuildContext context) {
    final cells = [
      (LucideIcons.badgeCheck, 'أجهزة مستوردة'),
      (LucideIcons.lock, 'تثبيت السعر ${formatHoursAr(lockHours)}'),
      (LucideIcons.truck, 'استلام من المحل أو توصيل حسب المنطقة'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: WexColors.surface,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: WexColors.line),
        ),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (var i = 0; i < cells.length; i++) ...[
              if (i > 0) const VerticalDivider(width: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(cells[i].$1, size: 22, color: WexColors.teal600),
                    const SizedBox(height: 8),
                    Text(cells[i].$2, textAlign: TextAlign.center, style: WexText.label.copyWith(color: WexColors.ink900)),
                  ]),
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

/// Horizontal rail: 168px cards, snap scrolling, equal heights.
class _Rail extends StatelessWidget {
  final List<ProductListItem> items;
  const _Rail({required this.items});
  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6);
    final w = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 340 * scale,
      child: PageView.builder(
        padEnds: false,
        controller: PageController(viewportFraction: (168 + 12) / w),
        itemCount: items.length,
        itemBuilder: (context, i) => Padding(
          padding: EdgeInsetsDirectional.only(start: i == 0 ? 16 : 0, end: 12, top: 8, bottom: 8),
          child: ProductCard(product: items[i], onTap: () => context.push('/products/${items[i].slug}')),
        ),
      ),
    );
  }
}

class _RailSkeleton extends StatelessWidget {
  const _RailSkeleton();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(children: [
          Expanded(child: SkeletonBox(height: 300, radius: Radii.card)),
          SizedBox(width: 12),
          Expanded(child: SkeletonBox(height: 300, radius: Radii.card)),
        ]),
      );
}

class _HelpRow extends StatelessWidget {
  final String whatsapp;
  const _HelpRow({required this.whatsapp});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Material(
          color: WexColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.card), side: const BorderSide(color: WexColors.line)),
          child: InkWell(
            borderRadius: BorderRadius.circular(Radii.card),
            onTap: () => openWhatsApp(whatsapp, text: 'مرحبًا، أبحث عن جهاز.'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                const Icon(LucideIcons.messageCircle, size: 28, color: WexColors.whatsapp),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('ما لقيت اللي تبحث عنه؟', style: WexText.body.copyWith(fontWeight: FontWeight.w600)),
                    const Text('كلّمنا على واتساب ونساعدك نلقى الجهاز المناسب.', style: WexText.bodyS),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      );
}

class _StoreCard extends StatelessWidget {
  final Shop shop;
  const _StoreCard({required this.shop});
  @override
  Widget build(BuildContext context) {
    final hours = shop.storeHours;
    final status = hours == null ? null : storeStatus(DateTime.now().toUtc(), hours);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WexColors.surface,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: WexColors.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('المتجر', style: WexText.titleM),
          if (shop.address.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(LucideIcons.mapPin, size: 20, color: WexColors.muted),
              const SizedBox(width: 8),
              Expanded(child: Text(shop.address, style: WexText.body)),
            ]),
          ],
          if (shop.workingHours.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(LucideIcons.clock, size: 20, color: WexColors.muted),
              const SizedBox(width: 8),
              Expanded(child: Text(shop.workingHours, style: WexText.body)),
            ]),
          ],
          if (status != null) ...[
            const SizedBox(height: 12),
            AppTag(status.text, kind: status.isOpen ? TagKind.success : TagKind.neutral),
          ],
          const SizedBox(height: 16),
          Row(children: [
            if (shop.phone.isNotEmpty) Expanded(child: SecondaryButton('اتصل', icon: LucideIcons.phone, compact: true, onPressed: () => openDialer(shop.phone))),
            if (shop.phone.isNotEmpty && shop.whatsapp.isNotEmpty) const SizedBox(width: 8),
            if (shop.whatsapp.isNotEmpty) Expanded(child: SecondaryButton('واتساب', icon: LucideIcons.messageCircle, compact: true, onPressed: () => openWhatsApp(shop.whatsapp))),
            if (shop.address.isNotEmpty || shop.shopMapLink.isNotEmpty) const SizedBox(width: 8),
            if (shop.address.isNotEmpty || shop.shopMapLink.isNotEmpty)
              Expanded(
                child: SecondaryButton('الخريطة', icon: LucideIcons.map, compact: true,
                    onPressed: () => shop.shopMapLink.isNotEmpty ? openUrl(shop.shopMapLink) : openMaps(shop.address)),
              ),
          ]),
        ]),
      ),
    );
  }
}
