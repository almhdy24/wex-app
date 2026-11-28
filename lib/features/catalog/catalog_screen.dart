import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/cart_button.dart';
import '../../core/widgets/shimmer.dart';
import '../../core/widgets/wex_widgets.dart';
import '../../app/providers.dart';
import '../../data/repositories/product_repository.dart';
import 'catalog_controller.dart';

const _types = [
  (value: null, label: Ar.filterAll),
  (value: 'laptop', label: Ar.filterLaptops),
  (value: 'phone', label: Ar.filterPhones),
  (value: 'accessory', label: Ar.filterAccessories),
];

const _sorts = [
  (value: 'newest', label: Ar.sortNewest),
  (value: 'price_asc', label: Ar.sortPriceAsc),
  (value: 'price_desc', label: Ar.sortPriceDesc),
];

class CatalogScreen extends ConsumerStatefulWidget {
  final String? initialType;
  final String? initialSearch;
  const CatalogScreen({super.key, this.initialType, this.initialSearch});
  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

String _sortLabel(String? v) => _sorts
    .firstWhere((s) => s.value == (v ?? 'newest'), orElse: () => _sorts.first)
    .label;

void _openSortSheet(
    BuildContext context, String current, void Function(String) onPick) {
  showModalBottomSheet(
    context: context,
    backgroundColor: WexColors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (ctx) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: WexColors.border,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 8),
        const Padding(
            padding: EdgeInsets.all(Sp.x6),
            child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(Ar.sortBy,
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 16)))),
        for (final s in _sorts)
          ListTile(
            title: Text(s.label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: current == s.value
                ? const Icon(Icons.check_rounded, color: WexColors.primary)
                : null,
            onTap: () {
              onPick(s.value);
              Navigator.pop(ctx);
            },
          ),
        const SizedBox(height: 8),
      ]),
    ),
  );
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  late final ProductQuery _initial = ProductQuery(
      type: widget.initialType, search: widget.initialSearch, sort: 'newest');
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = widget.initialSearch ?? '';
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >
          _scrollCtrl.position.maxScrollExtent - 400) {
        ref.read(catalogControllerProvider(_initial).notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(
        const Duration(milliseconds: 300),
        () => ref
            .read(catalogControllerProvider(_initial).notifier)
            .setSearch(v.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogControllerProvider(_initial));
    final ctrl = ref.read(catalogControllerProvider(_initial).notifier);

    return Scaffold(
      appBar:
          AppBar(title: const Text(Ar.navStore), actions: const [CartButton()]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Sp.page, Sp.x3, Sp.page, 0),
            child: TextField(
              controller: _searchCtrl,
              textDirection: TextDirection.rtl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: Ar.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchCtrl.clear();
                          ctrl.setSearch('');
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: Sp.page, vertical: Sp.x3),
              children: [
                for (final t in _types)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: Sp.x3),
                    child: ChoiceChip(
                      label: Text(t.label),
                      selected: state.query.type == t.value,
                      onSelected: (_) => ctrl.setType(t.value),
                      selectedColor: WexColors.royal,
                      labelStyle: TextStyle(
                          color: state.query.type == t.value
                              ? Colors.white
                              : WexColors.navy,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Sp.page, Sp.x3, Sp.page, Sp.x3),
            child: Row(
              children: [
                if (!state.loading && state.total > 0)
                  Text(Ar.results(state.total),
                      style: const TextStyle(
                          color: WexColors.textSecondary, fontSize: 13)),
                const Spacer(),
                InkWell(
                  onTap: () => _openSortSheet(
                      context, state.query.sort ?? 'newest', ctrl.setSort),
                  borderRadius: BorderRadius.circular(Radii.pill),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                        color: WexColors.white,
                        borderRadius: BorderRadius.circular(Radii.pill),
                        border: Border.all(color: WexColors.border)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.sort_rounded,
                          size: 16, color: WexColors.primary),
                      const SizedBox(width: 6),
                      Text(_sortLabel(state.query.sort),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18, color: WexColors.textSecondary),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _body(state, ctrl)),
        ],
      ),
    );
  }

  Widget _body(CatalogState state, CatalogController ctrl) {
    if (state.loading) {
      return GridView.builder(
        padding: const EdgeInsets.all(Sp.page),
        gridDelegate: productGridDelegate(MediaQuery.of(context).size.width),
        itemCount: 6,
        itemBuilder: (_, __) => const ProductCardSkeleton(),
      );
    }
    if (state.error != null && state.items.isEmpty) {
      return _Message(
          icon: Icons.wifi_off, text: state.error!, onRetry: ctrl.refresh);
    }
    if (state.items.isEmpty) {
      return const _Message(icon: Icons.search_off, text: Ar.noResults);
    }
    final width = MediaQuery.of(context).size.width;
    final whatsapp = ref.watch(shopProvider).valueOrNull?.whatsapp ?? '';
    return RefreshIndicator(
      onRefresh: ctrl.refresh,
      child: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Sp.page, Sp.x3, Sp.page, 0),
            sliver: SliverGrid(
              gridDelegate: productGridDelegate(width),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final p = state.items[i];
                  return FadeInUp(
                    index: i,
                    child: ProductCard(product: p, onTap: () => context.push('/products/${p.slug}')),
                  );
                },
                childCount: state.items.length,
              ),
            ),
          ),
          if (state.hasMore)
            const SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
            ),
          // Few results must never look like a dead-empty screen.
          if (!state.hasMore && state.items.length <= 2)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Sp.page, Sp.x8, Sp.page, 0),
                child: WexHelpCard(whatsapp: whatsapp),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: Sp.x10)),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final Future<void> Function()? onRetry;
  const _Message({required this.icon, required this.text, this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: WexColors.disabled),
            const SizedBox(height: 12),
            Text(text, style: const TextStyle(color: WexColors.textSecondary)),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onRetry, child: const Text(Ar.retry)),
            ],
          ],
        ),
      );
}
