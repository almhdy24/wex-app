import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/spacing.dart';
import '../../core/network/api_exception.dart';
import '../../core/strings.dart';
import '../../core/utils/arabic_duration.dart';
import '../../core/utils/ascii_digits.dart';
import '../../core/utils/sudan_phone.dart';
import '../../core/widgets/price_text.dart';
import '../../core/design/typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/product_name.dart';
import '../../data/models/cart_item.dart';
import '../../core/widgets/wex_kit.dart';
import '../../core/widgets/wex_widgets.dart';
import '../../core/design/tones.dart';
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
    final discountPct = shop?.appDiscountPercent ?? 3;
    final lockHours = shop?.lockHours ?? 4;
    final subtotal = cart.fold<int>(0, (s, i) => s + i.lineTotal);
    final discount = (subtotal * discountPct / 100).round();
    final shippingFee = _type == 'delivery' ? (_zone?.feeSdg ?? 0) : 0;
    final total = subtotal - discount + shippingFee;

    if (shop != null && !shop.ordersEnabled) {
      return Scaffold(
        appBar: AppBar(title: const Text(Ar.checkout)),
        body: WexEmptyState(
            icon: Icons.pause_circle_outline_rounded,
            title: Ar.ordersPausedTitle,
            body: shop.ordersDisabledMessage.isEmpty
                ? Ar.ordersClosed
                : shop.ordersDisabledMessage),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        // Tap outside the sheet to dismiss.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.pop(),
          ),
        ),
        NotificationListener<DraggableScrollableNotification>(
          onNotification: (n) {
            if (n.extent <= n.minExtent + 0.01 && !_closing) {
              _closing = true;
              context.pop();
            }
            return false;
          },
          child: DraggableScrollableSheet(
            initialChildSize: 0.94,
            minChildSize: 0.5,
            maxChildSize: 0.94,
            snap: true,
            snapSizes: const [0.94],
            builder: (context, scroll) => Container(
              decoration: const BoxDecoration(
                color: WexColors.ice,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(children: [
                _SheetHeader(onClose: () => context.pop()),
                Expanded(
                  child: ListView(
                    controller: scroll,
                    padding: const EdgeInsets.fromLTRB(
                        Sp.page, Sp.x3, Sp.page, Sp.page),
                    children: [
                      _SectionTitle(1, Ar.receiveMethod),
                      const SizedBox(height: Sp.x5),
                      _choice('pickup', Ar.pickup, Ar.pickupFree,
                          Icons.store_rounded,
                          badge: Ar.pickupFree),
                      const SizedBox(height: Sp.x3),
                      _choice('delivery', Ar.delivery, Ar.deliveryByArea,
                          Icons.local_shipping_rounded),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOut,
                        child: _type == 'delivery'
                            ? Padding(
                                padding: const EdgeInsets.only(top: Sp.x6),
                                child: Column(children: [
                                  zones.when(
                                    loading: () =>
                                        const LinearProgressIndicator(),
                                    error: (_, __) =>
                                        const Text(Ar.zonesLoadError),
                                    data: (list) => InputDecorator(
                                      decoration: const InputDecoration(
                                          labelText: Ar.deliveryArea),
                                      child: DropdownButton<ShippingZone>(
                                        value: _zone,
                                        isExpanded: true,
                                        underline: const SizedBox.shrink(),
                                        hint: const Text(Ar.chooseArea),
                                        items: [
                                          for (final z in list)
                                            DropdownMenuItem(
                                                value: z,
                                                child: Text(
                                                    '${z.name} — ${z.feeSdg == 0 ? Ar.pickupFree : formatSdg(z.feeSdg)}'))
                                        ],
                                        onChanged: (z) =>
                                            setState(() => _zone = z),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: Sp.x5),
                                  TextField(
                                      controller: _address,
                                      maxLines: 2,
                                      decoration: const InputDecoration(
                                          labelText: Ar.deliveryAddress)),
                                ]),
                              )
                            : (shop != null && shop.address.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(top: Sp.x6),
                                    child: SurfaceCard(
                                        padding: const EdgeInsets.all(Sp.x6),
                                        child: Row(children: [
                                          const TintIcon(Icons.place_rounded,
                                              size: 36),
                                          const SizedBox(width: 10),
                                          Expanded(
                                              child: Text(shop.address,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600))),
                                        ])),
                                  )
                                : const SizedBox.shrink()),
                      ),
                      const SizedBox(height: Sp.x9),
                      _SectionTitle(2, Ar.payMethod),
                      const SizedBox(height: Sp.x5),
                      // Bank transfer is the only payment method the shop supports.
                      _payCard(Ar.bankTransfer, Ar.bankTransferNote,
                          Ar.priceLockBadge(formatHoursAr(lockHours))),
                      const SizedBox(height: Sp.x9),
                      _SectionTitle(3, Ar.contactHeading),
                      const SizedBox(height: Sp.x8),
                      TextField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9٠-٩۰-۹\s-]'))
                        ],
                        onChanged: (v) {
                          final a = toAsciiDigits(v);
                          if (a != v) {
                            _phone.value = TextEditingValue(
                                text: a,
                                selection:
                                    TextSelection.collapsed(offset: a.length));
                          }
                        },
                        decoration: const InputDecoration(
                            labelText: Ar.phoneLabel,
                            hintText: Ar.phoneHint,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixIcon: Icon(Icons.phone_rounded)),
                      ),
                      const SizedBox(height: Sp.x5),
                      TextField(
                          controller: _notes,
                          decoration: const InputDecoration(
                              labelText: Ar.notesOptional)),
                      if (_error != null)
                        Padding(
                            padding: const EdgeInsets.only(top: Sp.x5),
                            child: Text(_error!,
                                style:
                                    const TextStyle(color: WexColors.danger))),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.fromLTRB(Sp.page, Sp.x6, Sp.page, Sp.x6),
                  decoration: const BoxDecoration(
                      color: WexColors.white,
                      boxShadow: [
                        BoxShadow(
                            color: WexColors.shadowSticky,
                            blurRadius: 24,
                            offset: Offset(0, -6))
                      ]),
                  child: SafeArea(
                      top: false,
                      child: Column(children: [
                        _OrderSummary(
                          items: cart,
                          subtotal: subtotal,
                          discount: discount,
                          discountPct: discountPct,
                          shippingFee: shippingFee,
                          delivery: _type == 'delivery',
                        ),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Text(Ar.total,
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16)),
                          const Spacer(),
                          PriceText(total, size: 20)
                        ]),
                        const SizedBox(height: Sp.x5),
                        // CTA label and icon follow the selection.
                        WexButton(
                            _type == 'delivery'
                                ? Ar.confirmDeliveryBank
                                : Ar.confirmPickupBank,
                            icon: const Icon(Icons.account_balance_rounded,
                                color: Colors.white, size: 20),
                            loading: _busy,
                            onPressed: _busy ? null : _placeOrder),
                      ])),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  bool _closing = false;

  /// The single, always-selected payment method card.
  Widget _payCard(String title, String note, String badge) => Container(
        padding: const EdgeInsets.all(Sp.x6),
        decoration: BoxDecoration(
            color: WexColors.primaryTint,
            borderRadius: BorderRadius.circular(Radii.inner + 4),
            border: Border.all(color: WexColors.primary, width: 1.6)),
        child: Row(children: [
          const TintIcon(Icons.account_balance_rounded, size: 44),
          const SizedBox(width: Sp.x5),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 2),
              Text(note, style: WexText.caption),
              const SizedBox(height: 8),
              StatusPill(badge, tone: Tone.success, dot: false),
            ]),
          ),
          const Icon(Icons.radio_button_checked_rounded,
              color: WexColors.primary, size: 22),
        ]),
      );

  Widget _choice(String value, String title, String note, IconData icon,
      {String? badge}) {
    final selected = _type == value;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _type = value);
      },
      borderRadius: BorderRadius.circular(Radii.inner + 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(Sp.x6),
        decoration: BoxDecoration(
            color: selected ? WexColors.primaryTint : WexColors.white,
            borderRadius: BorderRadius.circular(Radii.inner + 4),
            border: Border.all(
                color: selected ? WexColors.primary : WexColors.border,
                width: selected ? 1.6 : 1)),
        child: Row(children: [
          TintIcon(icon, tone: selected ? Tone.brand : Tone.neutral),
          const SizedBox(width: Sp.x5),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 2),
              Text(note, style: WexText.caption),
              if (badge != null) ...[
                const SizedBox(height: 8),
                StatusPill(badge, tone: Tone.success, dot: false),
              ],
            ]),
          ),
          Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? WexColors.primary : WexColors.disabled,
              size: 22),
        ]),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final VoidCallback onClose;
  const _SheetHeader({required this.onClose});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(Sp.page, 10, 8, 4),
        child: Column(children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: WexColors.border,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 6),
          Row(children: [
            const Expanded(
                child: Text(Ar.orderSummary,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
            IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
                tooltip: Ar.close),
          ]),
        ]),
      );
}

/// Numbered section heading: brand circle with the number + title.
class _SectionTitle extends StatelessWidget {
  final int n;
  final String title;
  const _SectionTitle(this.n, this.title);
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              color: WexColors.primary, shape: BoxShape.circle),
          child: Text('$n',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      ]);
}

/// Collapsible order summary above the CTA: items + subtotal / discount / delivery.
class _OrderSummary extends StatefulWidget {
  final List<CartItem> items;
  final int subtotal, discount, discountPct, shippingFee;
  final bool delivery;
  const _OrderSummary({
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.discountPct,
    required this.shippingFee,
    required this.delivery,
  });
  @override
  State<_OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<_OrderSummary> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    final count = widget.items.fold<int>(0, (s, i) => s + i.quantity);
    return Column(children: [
      InkWell(
        onTap: () => setState(() => _open = !_open),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            const Icon(Icons.receipt_long_rounded,
                size: 18, color: WexColors.primary),
            const SizedBox(width: 8),
            Text('${Ar.orderSummary} · $count ${Ar.itemsWord}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            AnimatedRotation(
              turns: _open ? 0.5 : 0,
              duration: const Duration(milliseconds: 220),
              child: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: WexColors.textSecondary),
            ),
          ]),
        ),
      ),
      AnimatedSize(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: _open
            ? ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: SingleChildScrollView(
                  child: Column(children: [
                    for (final i in widget.items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(children: [
                          Expanded(
                            child: Text(
                                '${normalizeProductName(i.name).full} × ${i.quantity}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: WexText.caption),
                          ),
                          PriceText(i.lineTotal,
                              size: 13,
                              color: WexColors.textPrimary,
                              weight: FontWeight.w700),
                        ]),
                      ),
                    const Divider(height: 14),
                    _line(
                        Ar.subtotal,
                        PriceText(widget.subtotal,
                            size: 13,
                            color: WexColors.textPrimary,
                            weight: FontWeight.w700)),
                    if (widget.discount > 0)
                      _line(
                          Ar.discountPercent(widget.discountPct),
                          PriceText(widget.discount,
                              size: 13,
                              color: WexColors.success,
                              weight: FontWeight.w800,
                              negative: true)),
                    if (widget.delivery)
                      _line(
                          Ar.deliveryFee,
                          PriceText(widget.shippingFee,
                              size: 13,
                              color: WexColors.textPrimary,
                              weight: FontWeight.w700)),
                    const SizedBox(height: 6),
                  ]),
                ),
              )
            : const SizedBox(width: double.infinity),
      ),
    ]);
  }

  Widget _line(String label, Widget value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Text(label, style: WexText.caption),
          const Spacer(),
          value
        ]),
      );
}
