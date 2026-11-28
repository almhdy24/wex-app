import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/strings.dart';
import '../../core/utils/launchers.dart';
import '../../core/widgets/cart_button.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/shimmer.dart';
import '../../core/widgets/wex_kit.dart';
import '../../core/widgets/wex_widgets.dart';
import '../../data/models/content.dart';
import '../../data/models/shop.dart';
import '../../data/repositories/product_repository.dart';

final heroSlidesProvider = FutureProvider.autoDispose(
    (ref) => ref.read(contentRepositoryProvider).heroSlides());
final featuredProvider = FutureProvider.autoDispose((ref) => ref
    .read(productRepositoryProvider)
    .list(const ProductQuery(sort: 'newest', perPage: 8)));

const _categories = [
  (type: 'laptop', label: Ar.catLaptops, icon: Icons.laptop_mac_rounded),
  (type: 'phone', label: Ar.catPhones, icon: Icons.smartphone_rounded),
  (type: 'accessory', label: Ar.catAccessories, icon: Icons.headphones_rounded),
];

const _trust = [
  (icon: Icons.verified_rounded, text: Ar.trustImported),
  (icon: Icons.lock_clock_rounded, text: Ar.trustLock),
  (icon: Icons.store_rounded, text: Ar.trustPickup),
  (icon: Icons.local_shipping_rounded, text: Ar.trustDelivery),
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shop = ref.watch(shopProvider).valueOrNull;
    final slides =
        ref.watch(heroSlidesProvider).valueOrNull ?? const <HeroSlide>[];
    final featured = ref.watch(featuredProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(shopProvider);
          ref.invalidate(heroSlidesProvider);
          ref.invalidate(featuredProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Hero(slides: slides)),
            const SliverToBoxAdapter(child: _TrustRow()),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(Sp.page, Sp.x5, Sp.page, Sp.x6),
                child: Row(children: [
                  for (final c in _categories)
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _CategoryTile(
                          label: c.label,
                          icon: c.icon,
                          onTap: () => context.go('/catalog?type=${c.type}')),
                    )),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Sp.page, 0, Sp.page, Sp.x5),
                child: WexSectionHeader(Ar.sectionNewest,
                    onSeeAll: () => context.go('/catalog')),
              ),
            ),
            featured.when(
              loading: () => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: Sp.page),
                sliver: SliverGrid(
                  gridDelegate:
                      productGridDelegate(MediaQuery.of(context).size.width),
                  delegate: SliverChildBuilderDelegate(
                      (_, __) => const ProductCardSkeleton(),
                      childCount: 4),
                ),
              ),
              error: (_, __) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              data: (page) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: Sp.page),
                sliver: SliverGrid(
                  gridDelegate:
                      productGridDelegate(MediaQuery.of(context).size.width),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => FadeInUp(
                        index: i,
                        child: ProductCard(
                            product: page.items[i],
                            onTap: () => context
                                .push('/products/${page.items[i].slug}'))),
                    childCount: page.items.length,
                  ),
                ),
              ),
            ),
            // "Can't find it?" WhatsApp card (always useful; shown prominently when catalogue is small)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Sp.page, Sp.x6, Sp.page, 0),
                child: WexHelpCard(whatsapp: shop?.whatsapp ?? ''),
              ),
            ),
            SliverToBoxAdapter(child: _StoreInfo(shop: shop)),
            const SliverToBoxAdapter(child: SizedBox(height: Sp.x9)),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final List<HeroSlide> slides;
  const _Hero({required this.slides});
  @override
  Widget build(BuildContext context) {
    final title = slides.isNotEmpty && slides.first.title.isNotEmpty
        ? slides.first.title
        : Ar.heroTitle;
    final subtitle = slides.isNotEmpty && slides.first.subtitle.isNotEmpty
        ? slides.first.subtitle
        : Ar.heroSubtitle;
    final reduce = MediaQuery.of(context).disableAnimations;
    final top = MediaQuery.of(context).padding.top;
    Widget loop(Widget w, double dy, int ms) => reduce
        ? w
        : w
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: dy, duration: ms.ms, curve: Curves.easeInOut);
    const bottomRadius = BorderRadius.vertical(bottom: Radius.circular(32));
    return Column(children: [
      Stack(clipBehavior: Clip.none, children: [
        // Full-bleed gradient header: the one hero moment of the screen.
        ClipRRect(
          borderRadius: bottomRadius,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: WexColors.gradBrand),
            child: Stack(children: [
              PositionedDirectional(
                  top: -40,
                  end: -30,
                  child: loop(_Blob(const Color(0x14FFFFFF), 150), 14, 3200)),
              PositionedDirectional(
                  bottom: -50,
                  start: -30,
                  child: loop(_Blob(const Color(0x14FFFFFF), 170), -16, 3800)),
              PositionedDirectional(
                end: 20,
                bottom: 70,
                child: loop(
                    const Icon(Icons.laptop_mac_rounded,
                        size: 78, color: Color(0x26FFFFFF)),
                    -8,
                    2600),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(Sp.x8, top + Sp.x7, Sp.x8, 56),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text(Ar.appName,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800)),
                      Spacer(),
                      CartButton(color: Colors.white),
                    ]),
                    const SizedBox(height: Sp.x6),
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            height: 1.4)),
                    const SizedBox(height: 6),
                    Text(subtitle,
                        style: const TextStyle(
                            color: WexColors.onDarkMuted,
                            fontSize: 14,
                            height: 1.6)),
                  ],
                ),
              ),
            ]),
          ),
        ),
        // Search card overlapping the header's bottom edge.
        PositionedDirectional(
          start: Sp.page,
          end: Sp.page,
          bottom: -26,
          child: GestureDetector(
            onTap: () => context.go('/catalog'),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: Sp.x7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Radii.pill),
                boxShadow: const [
                  BoxShadow(
                      color: WexColors.shadowSoft,
                      blurRadius: 20,
                      offset: Offset(0, 8)),
                ],
              ),
              child: Row(children: const [
                Icon(Icons.search_rounded,
                    color: WexColors.textSecondary, size: 22),
                SizedBox(width: 10),
                Text(Ar.searchHint,
                    style: TextStyle(color: WexColors.textSecondary)),
              ]),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 26),
    ]);
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob(this.color, this.size);
  @override
  Widget build(BuildContext context) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

class _TrustRow extends StatelessWidget {
  const _TrustRow();
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding:
              const EdgeInsets.symmetric(horizontal: Sp.page, vertical: Sp.x5),
          children: [
            for (final t in _trust)
              Container(
                margin: const EdgeInsetsDirectional.only(end: Sp.x3),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                    color: WexColors.white,
                    borderRadius: BorderRadius.circular(Radii.pill),
                    border: Border.all(color: WexColors.border)),
                child: Row(children: [
                  Icon(t.icon, size: 15, color: WexColors.primary),
                  const SizedBox(width: 6),
                  Text(t.text,
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w600)),
                ]),
              ),
          ],
        ),
      );
}

class _CategoryTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _CategoryTile(
      {required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.inner + 4),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: Sp.x7),
          decoration: BoxDecoration(
              color: WexColors.white,
              borderRadius: BorderRadius.circular(Radii.inner + 4),
              border: Border.all(color: WexColors.border)),
          child: Column(children: [
            TintIcon(icon),
            const SizedBox(height: 8),
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
        ),
      );
}

class _StoreInfo extends StatelessWidget {
  final Shop? shop;
  const _StoreInfo({required this.shop});
  @override
  Widget build(BuildContext context) {
    final s = shop;
    if (s == null ||
        (s.address.isEmpty && s.whatsapp.isEmpty && s.phone.isEmpty)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.page, Sp.x6, Sp.page, 0),
      child: SurfaceCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(Ar.storeHeading,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          if (s.address.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.place_rounded,
                  size: 18, color: WexColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(s.address))
            ]),
          ],
          if (s.workingHours.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.schedule_rounded,
                  size: 18, color: WexColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(s.workingHours))
            ]),
          ],
          const SizedBox(height: Sp.x6),
          Row(children: [
            if (s.phone.isNotEmpty)
              Expanded(
                  child: _ActionBtn(Icons.call_rounded, Ar.callStore,
                      () => openDialer(s.phone))),
            if (s.phone.isNotEmpty && s.whatsapp.isNotEmpty)
              const SizedBox(width: 8),
            if (s.whatsapp.isNotEmpty)
              Expanded(
                  child: _ActionBtn(Icons.chat_rounded, Ar.whatsappLabel,
                      () => openWhatsApp(s.whatsapp))),
            if ((s.address.isNotEmpty || s.shopMapLink.isNotEmpty))
              const SizedBox(width: 8),
            if (s.address.isNotEmpty || s.shopMapLink.isNotEmpty)
              Expanded(
                  child: _ActionBtn(
                      Icons.map_rounded,
                      Ar.mapLabel,
                      () => s.shopMapLink.isNotEmpty
                          ? openUrl(s.shopMapLink)
                          : openMaps(s.address))),
          ]),
        ]),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn(this.icon, this.label, this.onTap);
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: WexColors.iceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WexColors.border)),
          child: Column(children: [
            Icon(icon, size: 20, color: WexColors.primary),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11.5, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}
