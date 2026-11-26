import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/widgets/price_text.dart';
import '../../data/models/order.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderNumber;
  const OrderDetailScreen({super.key, required this.orderNumber});
  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _uploading = false;

  Future<void> _upload() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1600);
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      // Compress client-side (the web omits this; we do it right).
      final out = '${picked.path}_c.jpg';
      final compressed = await FlutterImageCompress.compressAndGetFile(
          picked.path, out, quality: 80, minWidth: 1600, minHeight: 1600);
      await ref.read(orderRepositoryProvider)
          .uploadProof(widget.orderNumber, compressed?.path ?? picked.path);
      ref.invalidate(orderDetailProvider(widget.orderNumber));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفع إشعار التحويل')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذّر رفع الإشعار')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _reorder() async {
    try {
      final o = await ref.read(orderRepositoryProvider).reorder(widget.orderNumber);
      final n = (o['order_number'] ?? '').toString();
      if (mounted && n.isNotEmpty) context.go('/orders/$n');
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذّر إعادة الطلب')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(orderDetailProvider(widget.orderNumber));
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الطلب')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('تعذّر تحميل الطلب', style: TextStyle(color: WexColors.textSecondary)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => ref.invalidate(orderDetailProvider(widget.orderNumber)), child: const Text('إعادة المحاولة')),
          ]),
        ),
        data: (o) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(orderDetailProvider(widget.orderNumber)),
          child: ListView(
            padding: const EdgeInsets.all(Sp.page),
            children: [
              if (o.isPending && o.secondsRemaining > 0)
                _LockCard(order: o, serverSeconds: o.secondsRemaining, lockExpiresAt: o.lockExpiresAt),
              if (o.isExpired) _ExpiredCard(onReorder: _reorder),
              const SizedBox(height: Sp.x6),
              _Totals(order: o),
              if (o.payment.canUpload) ...[
                const SizedBox(height: Sp.x6),
                _AccountsCard(order: o),
                const SizedBox(height: Sp.x6),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _uploading ? null : _upload,
                    icon: _uploading
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.upload_file),
                    label: Text(o.payment.state == PaymentState.rejected ? 'إعادة رفع الإشعار' : 'رفع إشعار التحويل'),
                  ),
                ),
              ],
              if (o.payment.state == PaymentState.underReview)
                const Padding(
                  padding: EdgeInsets.only(top: Sp.x6),
                  child: _Note(icon: Icons.hourglass_top, text: 'إشعارك قيد المراجعة، سنؤكد الطلب بعد التحقق.'),
                ),
              if (o.payment.state == PaymentState.approved || o.status == OrderStatus.completed)
                const Padding(
                  padding: EdgeInsets.only(top: Sp.x6),
                  child: _Note(icon: Icons.verified, text: 'تم تأكيد طلبك.', color: WexColors.success),
                ),
              const SizedBox(height: Sp.x8),
              _Timeline(order: o),
            ],
          ),
        ),
      ),
    );
  }
}

/// Price-lock countdown driven by the server clock (not the device).
class _LockCard extends ConsumerStatefulWidget {
  final OrderDetail order;
  final int serverSeconds;
  final DateTime? lockExpiresAt;
  const _LockCard({required this.order, required this.serverSeconds, this.lockExpiresAt});
  @override
  ConsumerState<_LockCard> createState() => _LockCardState();
}

class _LockCardState extends ConsumerState<_LockCard> {
  late int _remaining = widget.serverSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final st = ref.read(serverTimeApiProvider).serverTime;
      final next = widget.lockExpiresAt != null ? st.secondsUntil(widget.lockExpiresAt!) : _remaining - 1;
      if (!mounted) return;
      setState(() => _remaining = next < 0 ? 0 : next);
      if (_remaining == 0) _timer?.cancel();
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  String get _formatted {
    final h = _remaining ~/ 3600;
    final m = (_remaining % 3600) ~/ 60;
    final s = _remaining % 60;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(h)}:${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sp.x8),
      decoration: BoxDecoration(gradient: WexColors.gradNavy, borderRadius: BorderRadius.circular(Radii.panel)),
      child: Column(
        children: [
          const Text('السعر مثبّت — أكمل التحويل خلال', style: TextStyle(color: WexColors.onDarkMuted)),
          const SizedBox(height: 10),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(_formatted, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, fontFeatures: [FontFeature.tabularFigures()])),
          ),
          const SizedBox(height: 12),
          PriceText(widget.order.totalSdg, size: 24, color: Colors.white),
        ],
      ),
    );
  }
}

class _ExpiredCard extends StatelessWidget {
  final VoidCallback onReorder;
  const _ExpiredCard({required this.onReorder});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(Sp.x7),
        decoration: BoxDecoration(color: WexColors.dangerBg, borderRadius: BorderRadius.circular(Radii.panel)),
        child: Column(children: [
          const Text('انتهت مهلة تثبيت السعر لهذا الطلب.', style: TextStyle(color: WexColors.danger, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          FilledButton(onPressed: onReorder, child: const Text('أعد الطلب بالسعر الحالي')),
        ]),
      );
}

class _Totals extends StatelessWidget {
  final OrderDetail order;
  const _Totals({required this.order});
  @override
  Widget build(BuildContext context) => _card(Column(children: [
        _row('المجموع الفرعي', order.subtotalSdg),
        if (order.discountSdg > 0) _row('الخصم', -order.discountSdg, color: WexColors.success),
        if (order.deliveryType == 'delivery') _row('رسوم التوصيل', order.deliveryFeeSdg),
        const Divider(),
        Row(children: [
          const Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.w800)),
          const Spacer(),
          PriceText(order.totalSdg, size: 18),
        ]),
      ]));

  Widget _row(String l, int v, {Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Text(l, style: const TextStyle(color: WexColors.textSecondary)),
          const Spacer(),
          PriceText(v.abs(), size: 14, color: color ?? WexColors.navy, weight: FontWeight.w700),
        ]),
      );
}

class _AccountsCard extends StatelessWidget {
  final OrderDetail order;
  const _AccountsCard({required this.order});
  @override
  Widget build(BuildContext context) {
    if (order.paymentAccounts.isEmpty) return const SizedBox.shrink();
    return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('حساب التحويل', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      const SizedBox(height: 10),
      for (final a in order.paymentAccounts) ...[
        Text(a.bankName, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(a.accountName, style: const TextStyle(color: WexColors.textSecondary, fontSize: 13)),
        Row(children: [
          Directionality(textDirection: TextDirection.ltr, child: Text(a.accountNumber,
              style: const TextStyle(fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()]))),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: a.accountNumber));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ رقم الحساب')));
            },
          ),
        ]),
        const SizedBox(height: 8),
      ],
    ]));
  }
}

class _Timeline extends StatelessWidget {
  final OrderDetail order;
  const _Timeline({required this.order});
  @override
  Widget build(BuildContext context) {
    if (order.timeline.isEmpty) return const SizedBox.shrink();
    return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('مسار الطلب', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      const SizedBox(height: 12),
      for (final e in order.timeline) Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(padding: EdgeInsets.only(top: 3), child: Icon(Icons.check_circle, size: 18, color: WexColors.royal)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.statusText, style: const TextStyle(fontWeight: FontWeight.w700)),
            if ((e.note ?? '').isNotEmpty) Text(e.note!, style: const TextStyle(color: WexColors.textSecondary, fontSize: 13)),
          ])),
        ]),
      ),
    ]));
  }
}

class _Note extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _Note({required this.icon, required this.text, this.color = WexColors.royal});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(Sp.x6),
        decoration: BoxDecoration(color: WexColors.ice, borderRadius: BorderRadius.circular(Radii.card)),
        child: Row(children: [
          Icon(icon, color: color), const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(height: 1.6))),
        ]),
      );
}

Widget _card(Widget child) => Container(
      padding: const EdgeInsets.all(Sp.x7),
      decoration: BoxDecoration(
        color: WexColors.white,
        borderRadius: BorderRadius.circular(Radii.card),
        boxShadow: const [BoxShadow(color: Color(0x0F061A55), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: child,
    );
