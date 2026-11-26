import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/cart_button.dart';
import '../../data/repositories/product_repository.dart';
import 'catalog_controller.dart';

const _types = [
  (value: null, label: 'الكل'),
  (value: 'laptop', label: 'لابتوبات'),
  (value: 'phone', label: 'هواتف'),
  (value: 'accessory', label: 'ملحقات'),
];

const _sorts = [
  (value: 'newest', label: 'الأحدث'),
  (value: 'price_asc', label: 'الأقل سعرًا'),
  (value: 'price_desc', label: 'الأعلى سعرًا'),
];

class CatalogScreen extends ConsumerStatefulWidget {
  final String? initialType;
  final String? initialSearch;
  const CatalogScreen({super.key, this.initialType, this.initialSearch});
  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  late final ProductQuery _initial =
      ProductQuery(type: widget.initialType, search: widget.initialSearch, sort: 'newest');
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = widget.initialSearch ?? '';
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels > _scrollCtrl.position.maxScrollExtent - 400) {
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
    _debounce = Timer(const Duration(milliseconds: 300),
        () => ref.read(catalogControllerProvider(_initial).notifier).setSearch(v.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogControllerProvider(_initial));
    final ctrl = ref.read(catalogControllerProvider(_initial).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('المتجر'), actions: const [CartButton()]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Sp.page, Sp.x3, Sp.page, 0),
            child: TextField(
              controller: _searchCtrl,
              textDirection: TextDirection.rtl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'ابحث عن جهاز أو ماركة',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () { _searchCtrl.clear(); ctrl.setSearch(''); setState(() {}); },
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Sp.page, vertical: Sp.x3),
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
                          color: state.query.type == t.value ? Colors.white : WexColors.navy,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              const SizedBox(width: Sp.page),
              const Icon(Icons.sort, size: 18, color: WexColors.textSecondary),
              const SizedBox(width: 6),
              DropdownButton<String>(
                value: state.query.sort ?? 'newest',
                underline: const SizedBox.shrink(),
                items: [for (final s in _sorts) DropdownMenuItem(value: s.value, child: Text(s.label))],
                onChanged: (v) => ctrl.setSort(v),
              ),
              const Spacer(),
            ],
          ),
          Expanded(child: _body(state, ctrl)),
        ],
      ),
    );
  }

  Widget _body(CatalogState state, CatalogController ctrl) {
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      return _Message(icon: Icons.wifi_off, text: state.error!, onRetry: ctrl.refresh);
    }
    if (state.items.isEmpty) {
      return const _Message(icon: Icons.search_off, text: 'لا توجد نتائج مطابقة');
    }
    return RefreshIndicator(
      onRefresh: ctrl.refresh,
      child: GridView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.all(Sp.page),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: Sp.x6, crossAxisSpacing: Sp.x6, childAspectRatio: 0.66),
        itemCount: state.items.length + (state.hasMore ? 2 : 0),
        itemBuilder: (context, i) {
          if (i >= state.items.length) {
            return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
          }
          final p = state.items[i];
          return ProductCard(product: p, onTap: () => context.push('/products/${p.slug}'));
        },
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
              OutlinedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
            ],
          ],
        ),
      );
}
