import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/spacing.dart';
import '../../core/design/typography.dart';
import '../../core/format/plural.dart';
import '../../data/repositories/product_repository.dart';
import '../../ui/app_scaffold.dart';
import '../../ui/app_sheet.dart';
import '../../ui/app_top_bar.dart';
import '../../ui/buttons.dart';
import '../../ui/cart_action.dart';
import '../../ui/gradients.dart';
import '../../ui/icons.dart';
import '../../ui/product_card.dart';
import '../../ui/skeleton.dart';
import '../../ui/states.dart';
import '../promotions/promo_inline.dart';
import 'catalog_controller.dart';

const _types = [
  (value: null, label: 'الكل'),
  (value: 'laptop', label: 'لابتوبات'),
  (value: 'phone', label: 'هواتف'),
  (value: 'accessory', label: 'ملحقات'),
];

const _sorts = [
  (value: 'newest', label: 'الأحدث'),
  (value: 'price_asc', label: 'السعر من الأقل'),
  (value: 'price_desc', label: 'السعر من الأعلى'),
];

const _conditions = [
  (value: null, label: 'الكل'),
  (value: 'new', label: 'جديد'),
  (value: 'used_imported', label: 'مستعمل مستورد'),
  (value: 'refurbished', label: 'مجدّد'),
];

class CatalogScreen extends ConsumerStatefulWidget {
  final String? initialType;
  final String? initialSearch;
  const CatalogScreen({super.key, this.initialType, this.initialSearch});
  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  late final ProductQuery _initial = ProductQuery(type: widget.initialType, search: widget.initialSearch);
  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = widget.initialSearch ?? '';
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 600) {
        ref.read(catalogControllerProvider(_initial).notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  int _activeFilters(ProductQuery q) =>
      [q.brand, q.condition, q.minPriceSdg, q.maxPriceSdg].where((e) => e != null).length;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogControllerProvider(_initial));
    final ctrl = ref.read(catalogControllerProvider(_initial).notifier);
    final q = state.query;
    final active = _activeFilters(q);

    return AppScaffold(
      appBar: const AppTopBar(title: 'المتجر', showBack: false, actions: [CartAction()]),
      body: Column(children: [
        // Sticky header: search, category chips, count + sort + filter.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SizedBox(
            height: 48,
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              onChanged: (v) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 400), () => ctrl.setSearch(v.trim()));
              },
              decoration: const InputDecoration(
                hintText: 'ابحث عن لابتوب أو ماركة',
                prefixIcon: Icon(LucideIcons.search, size: 20, color: WexColors.muted),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: EdgeFade(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _types.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final t = _types[i];
                final selected = q.type == t.value;
                return ChoiceChip(
                  label: Text(t.label),
                  selected: selected,
                  labelStyle: WexText.body.copyWith(
                      color: selected ? WexColors.surface : WexColors.ink900, fontWeight: FontWeight.w500),
                  onSelected: (_) => ctrl.setType(t.value),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(children: [
            Expanded(child: Text(state.loading ? ' ' : resultsLabel(state.total), style: WexText.bodyS)),
            SizedBox(
              height: 44,
              child: TextButton.icon(
                onPressed: () => _openSort(q.sort ?? 'newest', ctrl.setSort),
                icon: const Icon(LucideIcons.arrowUpDown, size: 18),
                label: const Text('ترتيب'),
              ),
            ),
            SizedBox(
              height: 44,
              child: TextButton.icon(
                onPressed: () => _openFilters(q, ctrl),
                icon: const Icon(LucideIcons.slidersHorizontal, size: 18),
                label: Text(active == 0 ? 'تصفية' : 'تصفية ($active)'),
              ),
            ),
          ]),
        ),
        const Divider(),
        Expanded(child: _results(state, ctrl)),
      ]),
    );
  }

  Widget _results(CatalogState state, CatalogController ctrl) {
    if (state.loading) {
      return SkeletonScope(
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: AppScaffold.listPadding(context, top: 12),
          children: [for (var i = 0; i < 3; i++) const _SkeletonRow()],
        ),
      );
    }
    if (state.error != null && state.items.isEmpty) {
      return ErrorState(onRetry: ctrl.refresh);
    }
    if (state.items.isEmpty) {
      return EmptyState(
        icon: LucideIcons.searchX,
        title: 'لا توجد نتائج مطابقة',
        body: 'جرّب كلمة أخرى أو أزل بعض عوامل التصفية.',
        actionLabel: _activeFilters(state.query) > 0 ? 'إزالة التصفية' : null,
        onAction: ctrl.clearFilters,
      );
    }
    final rows = productRows(
      state.items,
      (p) => ProductCard(product: p, onTap: () => context.push('/products/${p.slug}')),
    );
    // A promo card spans both columns after every 3rd row (every 6th slot).
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if ((i + 1) % 3 == 0) children.add(const PromoInline(placement: 'store_inline'));
    }
    return RefreshIndicator(
      color: WexColors.teal600,
      onRefresh: ctrl.refresh,
      child: ListView(
        controller: _scroll,
        padding: AppScaffold.listPadding(context, top: 12),
        children: [
          ...children,
          if (state.loadingMore) const SkeletonScope(child: _SkeletonRow()),
        ],
      ),
    );
  }

  void _openSort(String current, void Function(String?) onPick) {
    showAppSheet<void>(
      context,
      title: 'ترتيب النتائج',
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          for (final s in _sorts)
            ListTile(
              title: Text(s.label, style: WexText.body),
              trailing: s.value == current ? const Icon(LucideIcons.check, size: 20, color: WexColors.teal600) : null,
              onTap: () {
                Navigator.of(ctx).pop();
                onPick(s.value);
              },
            ),
        ],
      ),
    );
  }

  void _openFilters(ProductQuery q, CatalogController ctrl) {
    showAppSheet<void>(
      context,
      title: 'تصفية النتائج',
      builder: (ctx) => _FilterSheet(initial: q, onApply: (brand, cond, min, max) {
        Navigator.of(ctx).pop();
        ctrl.setFilters(brand: brand, condition: cond, minPriceSdg: min, maxPriceSdg: max);
      }),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: const [
          Expanded(child: _SkeletonCard()),
          SizedBox(width: 12),
          Expanded(child: _SkeletonCard()),
        ]),
      );
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: WexColors.surface,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: WexColors.line),
        ),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(aspectRatio: 4 / 3, child: SkeletonBox(height: double.infinity)),
          SizedBox(height: 12),
          SkeletonBox(height: 12, width: 60),
          SizedBox(height: 8),
          SkeletonBox(height: 16, width: 120),
          SizedBox(height: 16),
          SkeletonBox(height: 18, width: 90),
          SizedBox(height: 12),
          SkeletonBox(height: 40, width: 40),
        ]),
      );
}

class _FilterSheet extends ConsumerStatefulWidget {
  final ProductQuery initial;
  final void Function(String? brand, String? condition, int? min, int? max) onApply;
  const _FilterSheet({required this.initial, required this.onApply});
  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  String? _brand;
  String? _condition;
  late final _min = TextEditingController(text: widget.initial.minPriceSdg?.toString() ?? '');
  late final _max = TextEditingController(text: widget.initial.maxPriceSdg?.toString() ?? '');

  @override
  void initState() {
    super.initState();
    _brand = widget.initial.brand;
    _condition = widget.initial.condition;
  }

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  int? _num(TextEditingController c) {
    final digits = c.text.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? null : int.tryParse(digits);
  }

  @override
  Widget build(BuildContext context) {
    final brands = ref.watch(brandsProvider).valueOrNull ?? const [];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('الحالة', style: WexText.titleM),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in _conditions)
              ChoiceChip(
                label: Text(c.label),
                selected: _condition == c.value,
                labelStyle: WexText.body.copyWith(color: _condition == c.value ? WexColors.surface : WexColors.ink900),
                onSelected: (_) => setState(() => _condition = c.value),
              ),
          ]),
          if (brands.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('الماركة', style: WexText.titleM),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              ChoiceChip(
                label: const Text('الكل'),
                selected: _brand == null,
                labelStyle: WexText.body.copyWith(color: _brand == null ? WexColors.surface : WexColors.ink900),
                onSelected: (_) => setState(() => _brand = null),
              ),
              for (final b in brands)
                ChoiceChip(
                  label: Text(b.name, textDirection: TextDirection.ltr),
                  selected: _brand == b.slug,
                  labelStyle: WexText.body.copyWith(color: _brand == b.slug ? WexColors.surface : WexColors.ink900),
                  onSelected: (_) => setState(() => _brand = b.slug),
                ),
            ]),
          ],
          const SizedBox(height: 24),
          const Text('السعر (ج.س)', style: WexText.titleM),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _min,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(hintText: 'من'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _max,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(hintText: 'إلى'),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: SecondaryButton('إزالة الكل', onPressed: () => widget.onApply(null, null, null, null))),
            const SizedBox(width: 12),
            Expanded(
                flex: 2,
                child: PrimaryButton('عرض النتائج',
                    onPressed: () => widget.onApply(_brand, _condition, _num(_min), _num(_max)))),
          ]),
        ]),
      ),
    );
  }
}
