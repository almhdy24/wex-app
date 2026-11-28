import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/spacing.dart';
import '../../core/design/typography.dart';
import '../../core/format/money.dart';
import '../../core/network/api_exception.dart';
import '../../core/strings.dart';
import '../../core/utils/arabic_duration.dart';
import '../../core/utils/ascii_digits.dart';
import '../../core/utils/product_name.dart';
import '../../core/utils/sudan_phone.dart';
import '../../data/models/catalog_meta.dart';
import '../../ui/app_scaffold.dart';
import '../../ui/app_top_bar.dart';
import '../../ui/buttons.dart';
import '../../ui/icons.dart';
import '../../ui/money_text.dart';
import '../../ui/states.dart';
import '../../ui/tag.dart';
import '../cart/cart_controller.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _type = 'pickup';
  ShippingZone? _zone;
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();
  bool _busy = false;
  String? _error;
  bool _summaryOpen = false;

  @override
  void dispose() {
    _phone.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!ref.read(authControllerProvider).isAuthenticated) {
      await context.push('/login');
      if (!ref.read(authControllerProvider).isAuthenticated) return;
    }
    final phone = normalizeSudanPhone(_phone.text);
    if (!isValidSudanPhone(phone)) {
      setState(() => _error = Ar.invalidPhone);
      return;
    }
    if (_type == 'delivery') {
      if (_zone == null) {
        setState(() => _error = Ar.pickZone);
        return;
      }
      if (_address.text.trim().length < 5) {
        setState(() => _error = Ar.addressNeeded);
        return;
      }
    }
    final items = ref
        .read(cartControllerProvider)
        .map((e) => (productId: e.productId, quantity: e.quantity))
        .toList();
    if (items.isEmpty) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final order = await ref.read(orderRepositoryProvider).create(
          orderType: _type,
          items: items,
          contactPhone: phone,
          shippingZoneId: _zone?.id,
          deliveryAddress: _type == 'delivery' ? _address.text.trim() : null,
          customerNotes: _notes.text.trim());
      ref.read(cartControllerProvider.notifier).clear();
      final number = (order['order_number'] ?? '').toString();
      if (mounted) context.go('/orders/$number', extra: {'justCreated': true});
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = Ar.orderFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = ref.watch(shopProvider).valueOrNull;
    final zones = ref.watch(zonesProvider);
    final cart = ref.watch(cartControllerProvider);
    final pct = shop?.appDiscountPercent ?? 0;
    final lockHours = shop?.lockHours ?? 4;
    final subtotal = cart.fold<int>(0, (s, i) => s + i.lineTotal);
    final discount = (subtotal * pct / 100).round();
    final fee = _type == 'delivery' ? (_zone?.feeSdg ?? 0) : 0;
    final total = subtotal - discount + fee;

    if (shop != null && !shop.ordersEnabled) {
      return AppScaffold(
        appBar: const AppTopBar(title: 'إتمام الطلب'),
        body: EmptyState(
          icon: LucideIcons.circlePause,
          title: 'استقبال الطلبات متوقف مؤقتًا',
          body: shop.ordersDisabledMessage.isEmpty ? 'نعود إليك قريبًا.' : shop.ordersDisabledMessage,
        ),
      );
    }

    return AppScaffold(
      appBar: const AppTopBar(title: 'إتمام الطلب'),
      bottomBar: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          const Text('الإجمالي', style: WexText.bodyS),
          const Spacer(),
          MoneyText.large(total),
        ]),
        const SizedBox(height: 12),
        PrimaryButton(
          _type == 'delivery' ? 'تأكيد الطلب والتوصيل' : 'تأكيد الطلب',
          icon: LucideIcons.check,
          loading: _busy,
          onPressed: _busy ? null : _placeOrder,
        ),
      ]),
      body: ListView(
        padding: AppScaffold.listPadding(context, top: 4),
        children: [
          _Title(1, 'طريقة الاستلام'),
          const SizedBox(height: 12),
          _Choice(selected: _type == 'pickup', icon: LucideIcons.store, title: 'استلام من المحل', note: 'مجانًا', onTap: () => setState(() => _type = 'pickup')),
          const SizedBox(height: 8),
          _Choice(selected: _type == 'delivery', icon: LucideIcons.truck, title: 'توصيل', note: 'حسب المنطقة', onTap: () => setState(() => _type = 'delivery')),
          AnimatedSize(
            duration: Motion.base,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _type == 'delivery'
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(children: [
                      zones.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const Text('تعذّر تحميل المناطق.', style: WexText.bodyS),
                        data: (list) => InputDecorator(
                          decoration: const InputDecoration(labelText: 'منطقة التوصيل'),
                          child: DropdownButton<ShippingZone>(
                            value: _zone,
                            isExpanded: true,
                            underline: const SizedBox.shrink(),
                            hint: const Text('اختر المنطقة'),
                            items: [
                              for (final z in list)
                                DropdownMenuItem(value: z, child: Text('${z.name} — ${z.feeSdg == 0 ? 'مجانًا' : formatMoney(z.feeSdg)}')),
                            ],
                            onChanged: (z) => setState(() => _zone = z),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(controller: _address, maxLines: 2, decoration: const InputDecoration(labelText: 'عنوان التوصيل')),
                    ]),
                  )
                : (shop != null && shop.address.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Icon(LucideIcons.mapPin, size: 20, color: WexColors.muted),
                          const SizedBox(width: 8),
                          Expanded(child: Text(shop.address, style: WexText.body)),
                        ]),
                      )
                    : const SizedBox(width: double.infinity)),
          ),
          const SizedBox(height: 24),
          _Title(2, 'وسيلة الدفع'),
          const SizedBox(height: 12),
          // Bank transfer is the only payment method the shop supports.
          _Choice(
            selected: true,
            icon: LucideIcons.landmark,
            title: 'تحويل بنكي',
            note: 'ارفع إشعار التحويل بعد تأكيد الطلب',
            badge: 'تثبيت السعر ${formatHoursAr(lockHours)}',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _Title(3, 'التواصل'),
          const SizedBox(height: 16),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹\s-]'))],
            onChanged: (v) {
              final a = toAsciiDigits(v);
              if (a != v) _phone.value = TextEditingValue(text: a, selection: TextSelection.collapsed(offset: a.length));
            },
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف (واتساب)',
              hintText: '09XXXXXXXX',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: Icon(LucideIcons.phone, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          TextField(controller: _notes, decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)')),
          if (_error != null)
            Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: WexText.body.copyWith(color: WexColors.danger))),
          const SizedBox(height: 24),
          // Collapsible order summary
          InkWell(
            onTap: () => setState(() => _summaryOpen = !_summaryOpen),
            child: SizedBox(
              height: 48,
              child: Row(children: [
                Expanded(child: Text('ملخص الطلب · ${cart.fold<int>(0, (s, i) => s + i.quantity)} منتجات', style: WexText.titleM)),
                AnimatedRotation(turns: _summaryOpen ? 0.5 : 0, duration: Motion.base, child: const Icon(LucideIcons.chevronDown, size: 22)),
              ]),
            ),
          ),
          AnimatedSize(
            duration: Motion.base,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !_summaryOpen
                ? const SizedBox(width: double.infinity)
                : Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: WexColors.surface, borderRadius: BorderRadius.circular(Radii.card), border: Border.all(color: WexColors.line)),
                    child: Column(children: [
                      for (final i in cart)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(children: [
                            Expanded(child: Text('${normalizeProductName(i.name).full} × ${i.quantity}', maxLines: 1, overflow: TextOverflow.ellipsis, style: WexText.bodyS)),
                            MoneyText(i.lineTotal, style: WexText.bodyS.copyWith(color: WexColors.ink900, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      const Divider(height: 20),
                      _line('المجموع الفرعي', MoneyText(subtotal, style: WexText.bodyS.copyWith(color: WexColors.ink900, fontWeight: FontWeight.w600))),
                      if (discount > 0)
                        _line('خصم التطبيق ${isolate('$pct%')}', MoneyText(-discount, style: WexText.bodyS.copyWith(fontWeight: FontWeight.w600), color: WexColors.success)),
                      if (_type == 'delivery') _line('رسوم التوصيل', MoneyText(fee, style: WexText.bodyS.copyWith(color: WexColors.ink900, fontWeight: FontWeight.w600))),
                    ]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _line(String l, Widget v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [Expanded(child: Text(l, style: WexText.bodyS)), v]),
      );
}

class _Title extends StatelessWidget {
  final int n;
  final String text;
  const _Title(this.n, this.text);
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: WexColors.ink900)),
          child: Text('$n', style: WexText.numeric.copyWith(fontSize: 12)),
        ),
        const SizedBox(width: 12),
        Text(text, style: WexText.titleM),
      ]);
}

class _Choice extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String note;
  final String? badge;
  final VoidCallback onTap;
  const _Choice({required this.selected, required this.icon, required this.title, required this.note, this.badge, required this.onTap});
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: title,
        child: AnimatedContainer(
          duration: Motion.base,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: selected ? WexColors.teal50 : WexColors.surface,
            borderRadius: BorderRadius.circular(Radii.card),
            border: Border.all(color: selected ? WexColors.teal600 : WexColors.line, width: selected ? 2 : 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(Radii.card),
              onTap: () {
                HapticFeedback.selectionClick();
                onTap();
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Icon(icon, size: 24, color: WexColors.ink900),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(title, style: WexText.body.copyWith(fontWeight: FontWeight.w600)),
                      Text(note, style: WexText.bodyS),
                      if (badge != null) ...[const SizedBox(height: 8), AppTag(badge!, kind: TagKind.success)],
                    ]),
                  ),
                  Icon(selected ? LucideIcons.circleCheck : LucideIcons.circle, size: 22, color: selected ? WexColors.teal600 : WexColors.disabled),
                ]),
              ),
            ),
          ),
        ),
      );
}
