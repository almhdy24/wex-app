import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/network/api_exception.dart';
import '../../core/strings.dart';
import '../../core/utils/arabic_duration.dart';
import '../../core/utils/ascii_digits.dart';
import '../../core/utils/sudan_phone.dart';
import '../../core/widgets/price_text.dart';
import '../../core/widgets/wex_widgets.dart';
import '../../data/models/catalog_meta.dart';
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

  Future<void> _placeOrder() async {
    if (!ref.read(authControllerProvider).isAuthenticated) {
      await context.push('/login');
      if (!ref.read(authControllerProvider).isAuthenticated) return;
    }
    final phone = normalizeSudanPhone(_phone.text);
    if (!isValidSudanPhone(phone)) { setState(() => _error = 'أدخل رقم هاتف سوداني صحيح (مثال: 09XXXXXXXX)'); return; }
    if (_type == 'delivery') {
      if (_zone == null) { setState(() => _error = 'اختر منطقة التوصيل'); return; }
      if (_address.text.trim().length < 5) { setState(() => _error = 'أدخل عنوان التوصيل بالتفصيل'); return; }
    }
    final items = ref.read(cartControllerProvider).map((e) => (productId: e.productId, quantity: e.quantity)).toList();
    if (items.isEmpty) return;

    setState(() { _busy = true; _error = null; });
    try {
      final order = await ref.read(orderRepositoryProvider).create(
        orderType: _type, items: items, contactPhone: phone,
        shippingZoneId: _zone?.id,
        deliveryAddress: _type == 'delivery' ? _address.text.trim() : null,
        customerNotes: _notes.text.trim());
      ref.read(cartControllerProvider.notifier).clear();
      final number = (order['order_number'] ?? '').toString();
      if (mounted) context.go('/orders/$number');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'تعذّر إنشاء الطلب. حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = ref.watch(shopProvider).valueOrNull;
    final zones = ref.watch(zonesProvider);
    final cart = ref.watch(cartControllerProvider);
    final discountPct = shop?.appDiscountPercent ?? 3;
    final lockHours = shop?.lockHours ?? 4;
    final subtotal = cart.fold<int>(0, (s, i) => s + i.lineTotal);
    final discount = (subtotal * discountPct / 100).round();
    final shippingFee = _type == 'delivery' ? (_zone?.feeSdg ?? 0) : 0;
    final total = subtotal - discount + shippingFee;

    if (shop != null && !shop.ordersEnabled) {
      return Scaffold(
        appBar: AppBar(title: const Text(Ar.checkout)),
        body: WexEmptyState(icon: Icons.pause_circle_outline_rounded,
            title: 'الطلبات متوقفة مؤقتًا',
            body: shop.ordersDisabledMessage.isEmpty ? Ar.ordersClosed : shop.ordersDisabledMessage),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text(Ar.checkout)),
      body: Column(children: [
        const _StepBar(step: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(Sp.page),
            children: [
              const Text(Ar.receiveMethod, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: Sp.x5),
              _choice('pickup', Ar.pickup, Ar.pickupFree, Icons.store_rounded),
              const SizedBox(height: Sp.x3),
              _choice('delivery', Ar.delivery, Ar.deliveryByArea, Icons.local_shipping_rounded),
              AnimatedSize(
                duration: const Duration(milliseconds: 260), curve: Curves.easeOut,
                child: _type == 'delivery'
                    ? Padding(
                        padding: const EdgeInsets.only(top: Sp.x6),
                        child: Column(children: [
                          zones.when(
                            loading: () => const LinearProgressIndicator(),
                            error: (_, __) => const Text('تعذّر تحميل مناطق التوصيل'),
                            data: (list) => InputDecorator(
                              decoration: const InputDecoration(labelText: Ar.deliveryArea),
                              child: DropdownButton<ShippingZone>(
                                value: _zone, isExpanded: true, underline: const SizedBox.shrink(),
                                hint: const Text(Ar.chooseArea),
                                items: [for (final z in list) DropdownMenuItem(value: z,
                                    child: Text('${z.name} — ${z.feeSdg == 0 ? Ar.pickupFree : '${z.feeSdg} ج.س'}'))],
                                onChanged: (z) => setState(() => _zone = z),
                              ),
                            ),
                          ),
                          const SizedBox(height: Sp.x5),
                          TextField(controller: _address, maxLines: 2,
                              decoration: const InputDecoration(labelText: Ar.deliveryAddress)),
                        ]),
                      )
                    : (shop != null && shop.address.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: Sp.x6),
                            child: WexCard(padding: const EdgeInsets.all(Sp.x6), child: Row(children: [
                              const Icon(Icons.place_rounded, color: WexColors.primary, size: 20), const SizedBox(width: 10),
                              Expanded(child: Text(shop.address, style: const TextStyle(fontWeight: FontWeight.w600))),
                            ])),
                          )
                        : const SizedBox.shrink()),
              ),
              const SizedBox(height: Sp.x8),
              const Text('التواصل', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: Sp.x5),
              TextField(
                controller: _phone, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹\s-]'))],
                onChanged: (v) { final a = toAsciiDigits(v); if (a != v) _phone.value = TextEditingValue(text: a, selection: TextSelection.collapsed(offset: a.length)); },
                decoration: const InputDecoration(labelText: Ar.phoneLabel, hintText: Ar.phoneHint, prefixIcon: Icon(Icons.phone_rounded)),
              ),
              const SizedBox(height: Sp.x5),
              TextField(controller: _notes, decoration: const InputDecoration(labelText: Ar.notesOptional)),
              if (_error != null) Padding(padding: const EdgeInsets.only(top: Sp.x5),
                  child: Text(_error!, style: const TextStyle(color: WexColors.danger))),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(Sp.page, Sp.x6, Sp.page, Sp.x6),
          decoration: const BoxDecoration(color: WexColors.white,
              boxShadow: [BoxShadow(color: WexColors.shadowSticky, blurRadius: 24, offset: Offset(0, -6))]),
          child: SafeArea(top: false, child: Column(children: [
            Row(children: [const Text(Ar.total, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), const Spacer(),
                PriceText(total, size: 20)]),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.lock_clock_rounded, size: 14, color: WexColors.textSecondary), const SizedBox(width: 5),
              Flexible(child: Text('بعد التأكيد نثبّت لك السعر ${formatHoursAr(lockHours)} لتكمل التحويل',
                  textAlign: TextAlign.center, style: const TextStyle(color: WexColors.textSecondary, fontSize: 12))),
            ]),
            const SizedBox(height: Sp.x5),
            WexButton(Ar.confirmOrder, loading: _busy, onPressed: _busy ? null : _placeOrder),
          ])),
        ),
      ]),
    );
  }

  Widget _choice(String value, String title, String note, IconData icon) {
    final selected = _type == value;
    return InkWell(
      onTap: () { HapticFeedback.selectionClick(); setState(() => _type = value); },
      borderRadius: BorderRadius.circular(Radii.card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(Sp.x6),
        decoration: BoxDecoration(
          color: selected ? WexColors.primary.withValues(alpha: 0.06) : WexColors.white,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: selected ? WexColors.primary : WexColors.border, width: selected ? 1.6 : 1)),
        child: Row(children: [
          Icon(icon, color: selected ? WexColors.primary : WexColors.textSecondary),
          const SizedBox(width: Sp.x5),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
          Text(note, style: const TextStyle(color: WexColors.textSecondary, fontSize: 13)),
          const SizedBox(width: 8),
          Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: selected ? WexColors.primary : WexColors.disabled, size: 20),
        ]),
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  final int step; // 0=cart,1=checkout,2=done
  const _StepBar({required this.step});
  @override
  Widget build(BuildContext context) {
    const labels = [Ar.stepCart, Ar.stepCheckout, Ar.stepDone];
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.page, Sp.x5, Sp.page, 0),
      child: Row(children: [
        for (var i = 0; i < 3; i++) ...[
          Column(children: [
            Container(
              width: 28, height: 28, alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i <= step ? WexColors.primary : WexColors.iceLight, shape: BoxShape.circle,
                border: Border.all(color: i <= step ? WexColors.primary : WexColors.border)),
              child: i < step
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                  : Text('${i + 1}', style: TextStyle(color: i <= step ? Colors.white : WexColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 4),
            Text(labels[i], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: i <= step ? WexColors.primary : WexColors.textSecondary)),
          ]),
          if (i < 2) Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 18, left: 4, right: 4),
              color: i < step ? WexColors.primary : WexColors.border)),
        ],
      ]),
    );
  }
}
