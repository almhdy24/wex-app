import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/widgets/product_card.dart';
import '../../data/models/content.dart';
import '../../data/repositories/product_repository.dart';

final heroSlidesProvider = FutureProvider((ref) => ref.read(contentRepositoryProvider).heroSlides());
final featuredProvider = FutureProvider((ref) =>
    ref.read(productRepositoryProvider).list(const ProductQuery(sort: 'newest', perPage: 8)));

const _categories = [
  (type: 'laptop', label: 'الحواسيب', icon: Icons.laptop_mac),
  (type: 'phone', label: 'الهواتف', icon: Icons.smartphone),
  (type: 'accessory', label: 'الملحقات', icon: Icons.headphones),
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shop = ref.watch(shopProvider);
    final slides = ref.watch(heroSlidesProvider);
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
            SliverToBoxAdapter(child: _Hero(slides: slides.valueOrNull ?? const [])),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(Sp.page),
                child: Row(
                  children: [
                    for (final c in _categories)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _CategoryTile(
                            label: c.label, icon: c.icon,
                            onTap: () => context.go('/catalog?type=${c.type}'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Sp.page, 0, Sp.page, Sp.x5),
                child: Row(
                  children: [
                    const Text('أحدث الأجهزة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    TextButton(onPressed: () => context.go('/catalog'), child: const Text('عرض الكل')),
                  ],
                ),
              ),
            ),
            featured.when(
              loading: () => const SliverToBoxAdapter(
                  child: SizedBox(height: 240, child: Center(child: CircularProgressIndicator()))),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              data: (page) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: Sp.page),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: Sp.x6, crossAxisSpacing: Sp.x6, childAspectRatio: 0.66),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final p = page.items[i];
                      return ProductCard(product: p, onTap: () => context.push('/products/${p.slug}'));
                    },
                    childCount: page.items.length,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _StoreInfo(shopAddress: shop.valueOrNull?.address ?? '', hours: shop.valueOrNull?.workingHours ?? '')),
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
    final title = slides.isNotEmpty ? slides.first.title : 'أجهزة لابتوب لأعمالك ودراستك';
    final subtitle = slides.isNotEmpty ? slides.first.subtitle : 'أجهزة مستوردة بأسعار واضحة';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(Sp.page, 48, Sp.page, Sp.x10),
      decoration: const BoxDecoration(gradient: WexColors.gradNavy),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('مرحبًا بك', style: TextStyle(color: WexColors.onDarkMuted, fontSize: 14)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, height: 1.4)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: WexColors.onDarkMuted, fontSize: 14, height: 1.6)),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _CategoryTile({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.card),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: Sp.x8),
          decoration: BoxDecoration(
            color: WexColors.white,
            borderRadius: BorderRadius.circular(Radii.card),
            boxShadow: const [BoxShadow(color: Color(0x0F061A55), blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(children: [
            Icon(icon, color: WexColors.royal, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}

class _StoreInfo extends StatelessWidget {
  final String shopAddress;
  final String hours;
  const _StoreInfo({required this.shopAddress, required this.hours});
  @override
  Widget build(BuildContext context) {
    if (shopAddress.isEmpty && hours.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.all(Sp.page),
      padding: const EdgeInsets.all(Sp.x8),
      decoration: BoxDecoration(
        color: WexColors.white,
        borderRadius: BorderRadius.circular(Radii.panel),
        boxShadow: const [BoxShadow(color: Color(0x0F061A55), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('المتجر', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        if (shopAddress.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(children: [const Icon(Icons.place, size: 18, color: WexColors.royal), const SizedBox(width: 8), Expanded(child: Text(shopAddress))]),
        ],
        if (hours.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.schedule, size: 18, color: WexColors.royal), const SizedBox(width: 8), Expanded(child: Text(hours))]),
        ],
      ]),
    );
  }
}
