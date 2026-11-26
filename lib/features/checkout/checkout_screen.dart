import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/arabic_duration.dart';
import '../../core/utils/sudan_phone.dart';
import '../../core/widgets/price_text.dart';
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
    final auth = ref.read(authControllerProvider);
    if (!auth.isAuthenticated) {
      final ok = await context.push<bool>('/login');
      if (ok != true && !ref.read(authControllerProvider).isAuthenticated) return;
    }
    final phone = normalizeSudanPhone(_phone.text);
    if (!isValidSudanPhone(phone)) { setState(() => _error = 'أدخل رقم هاتف سوداني صحيح'); return; }
    if (_type == 'delivery') {
      if (_zone == null) { setState(() => _error = 'اختر منطقة التوصيل'); return; }
      if (_address.text.trim().length < 5) { setState(() => _error = 'أدخل عنوان التوصيل بالتفصيل'); return; }
    }
    final items = ref.read(cartControllerProvider)
        .map((e) => (productId: e.productId, quantity: e.quantity)).toList();
    if (items.isEmpty) return;

    setState(() { _busy = true; _error = null; });
    try {
      final order = await ref.read(orderRepositoryProvider).create(
        orderType: _type,
        items: items,
        contactPhone: phone,
        shippingZoneId: _zone?.id,
        deliveryAddress: _type == 'delivery' ? _address.text.trim() : null,
        customerNotes: _notes.text.trim(),
      );
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
        appBar: AppBar(title: const Text('إتمام الطلب')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              shop.ordersDisabledMessage.isEmpty ? 'استقبال الطلبات متوقف مؤقتًا.' : shop.ordersDisabledMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: WexColors.textSecondary, height: 1.8)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(Sp.page),
              children: [
                const Text('طريقة الاستلام', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: Sp.x5),
                _choice('pickup', 'الاستلام من المحل', 'مجانًا', Icons.store),
                const SizedBox(height: Sp.x3),
                _choice('delivery', 'التوصيل', 'حسب المنطقة', Icons.local_shipping),
                if (_type == 'delivery') ...[
                  const SizedBox(height: Sp.x6),
                  zones.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('تعذّر تحميل مناطق التوصيل'),
                    data: (list) => InputDecorator(
                      decoration: const InputDecoration(labelText: 'منطقة التوصيل'),
                      child: DropdownButton<ShippingZone>(
                        value: _zone,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        hint: const Text('اختر المنطقة'),
                        items: [
                          for (final z in list)
                            DropdownMenuItem(value: z, child: Text('${z.name} — ${z.feeSdg == 0 ? 'مجانًا' : '${z.feeSdg} ج.س'}')),
                        ],
                        onChanged: (z) => setState(() => _zone = z),
                      ),
                    ),
                  ),
                  const SizedBox(height: Sp.x5),
                  TextField(
                    controller: _address,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'عنوان التوصيل بالتفصيل'),
                  ),
                ],
                const SizedBox(height: Sp.x8),
                const Text('التواصل', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: Sp.x5),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف', hintText: '09XXXXXXXX'),
                ),
                const SizedBox(height: Sp.x5),
                TextField(
                  controller: _notes,
                  decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)'),
                ),
                if (_error != null) Padding(
                  padding: const EdgeInsets.only(top: Sp.x5),
                  child: Text(_error!, style: const TextStyle(color: WexColors.danger)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(Sp.page, Sp.x6, Sp.page, Sp.x6),
            decoration: const BoxDecoration(
              color: WexColors.white,
              boxShadow: [BoxShadow(color: Color(0x14061A55), blurRadius: 16, offset: Offset(0, -4))],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(children: [
                    const Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const Spacer(),
                    PriceText(total, size: 20),
                  ]),
                  const SizedBox(height: 6),
                  Text('بعد التأكيد يُثبَّت السعر لمدة ${formatHoursAr(lockHours)} لتتمكّن من التحويل.',
                      style: const TextStyle(color: WexColors.textSecondary, fontSize: 12), textAlign: TextAlign.center),
                  const SizedBox(height: Sp.x5),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy ? null : _placeOrder,
                      child: _busy
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('تأكيد الطلب'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _choice(String value, String title, String note, IconData icon) {
    final selected = _type == value;
    return InkWell(
      onTap: () => setState(() => _type = value),
      borderRadius: BorderRadius.circular(Radii.card),
      child: Container(
        padding: const EdgeInsets.all(Sp.x6),
        decoration: BoxDecoration(
          color: selected ? WexColors.ice : WexColors.white,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: selected ? WexColors.royal : WexColors.border, width: selected ? 2 : 1),
        ),
        child: Row(children: [
          Icon(icon, color: selected ? WexColors.royal : WexColors.textSecondary),
          const SizedBox(width: Sp.x5),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
          Text(note, style: const TextStyle(color: WexColors.textSecondary, fontSize: 13)),
        ]),
      ),
    );
  }
}
