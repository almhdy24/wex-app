import '../../ui/gradients.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/strings.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/spacing.dart';
import '../../core/design/tones.dart';
import '../../core/design/typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/illustrations.dart';
import '../../core/widgets/wex_kit.dart';
import 'orders_screen.dart' show statusTone, statusText;
import '../../core/utils/launchers.dart';
import '../../core/widgets/price_text.dart';
import '../../core/widgets/wex_widgets.dart';
import '../../data/models/order.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderNumber;
  final bool justCreated;
  const OrderDetailScreen(
      {super.key, required this.orderNumber, this.justCreated = false});
  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _uploading = false;

  Future<void> _upload() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85, maxWidth: 1600);
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      // Compress client-side (the web omits this; we do it right).
      final out = '${picked.path}_c.jpg';
      final compressed = await FlutterImageCompress.compressAndGetFile(
          picked.path, out,
          quality: 80, minWidth: 1600, minHeight: 1600);
      await ref
          .read(orderRepositoryProvider)
          .uploadProof(widget.orderNumber, compressed?.path ?? picked.path);
      ref.invalidate(orderDetailProvider(widget.orderNumber));
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(Ar.proofUploaded)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(Ar.uploadFailed)));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _reorder() async {
    try {
      final o =
          await ref.read(orderRepositoryProvider).reorder(widget.orderNumber);
      final n = (o['order_number'] ?? '').toString();
      if (mounted && n.isNotEmpty) context.go('/orders/$n');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(Ar.reorderFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(orderDetailProvider(widget.orderNumber));
    return Scaffold(
      appBar: AppBar(title: const Text(Ar.orderDetails)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(Ar.orderLoadError,
                style: TextStyle(color: WexColors.textSecondary)),
            const SizedBox(height: 12),
            OutlinedButton(
                onPressed: () =>
                    ref.invalidate(orderDetailProvider(widget.orderNumber)),
                child: const Text(Ar.retry)),
          ]),
        ),
        data: (o) => RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(orderDetailProvider(widget.orderNumber)),
          child: ListView(
            padding: const EdgeInsets.all(Sp.page),
            children: [
              if (widget.justCreated) ...[
                _SuccessHeader(orderNumber: o.orderNumber),
                const SizedBox(height: Sp.x6),
              ],
              _StatusHeader(order: o),
              const SizedBox(height: Sp.x6),
              if (o.isPending && o.secondsRemaining > 0)
                _LockCard(
                    order: o,
                    serverSeconds: o.secondsRemaining,
                    lockExpiresAt: o.lockExpiresAt),
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
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.upload_file),
                    label: Text(o.payment.state == PaymentState.rejected
                        ? Ar.reupload
                        : Ar.uploadProof),
                  ),
                ),
              ],
              if (o.payment.state == PaymentState.underReview)
                const Padding(
                  padding: EdgeInsets.only(top: Sp.x6),
                  child: _Note(icon: Icons.hourglass_top, text: Ar.underReview),
                ),
              if (o.payment.state == PaymentState.approved ||
                  o.status == OrderStatus.completed)
                const Padding(
                  padding: EdgeInsets.only(top: Sp.x6),
                  child: _Note(
                      icon: Icons.verified,
                      text: Ar.confirmed,
                      color: WexColors.success),
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
  const _LockCard(
      {required this.order, required this.serverSeconds, this.lockExpiresAt});
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
      final next = widget.lockExpiresAt != null
          ? st.secondsUntil(widget.lockExpiresAt!)
          : _remaining - 1;
      if (!mounted) return;
      setState(() => _remaining = next < 0 ? 0 : next);
      if (_remaining == 0) _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
      decoration: BoxDecoration(
          gradient: Gradients.hero,
          borderRadius: BorderRadius.circular(Radii.panel)),
      child: Column(
        children: [
          const Text(Ar.lockHeading,
              style: TextStyle(color: WexColors.onDarkMuted)),
          const SizedBox(height: 10),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(_formatted,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()])),
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
        decoration: BoxDecoration(
            color: WexColors.dangerBg,
            borderRadius: BorderRadius.circular(Radii.panel)),
        child: Column(children: [
          const Text(Ar.lockExpired,
              style: TextStyle(
                  color: WexColors.danger, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          FilledButton(onPressed: onReorder, child: const Text(Ar.reorder)),
        ]),
      );
}

class _Totals extends StatelessWidget {
  final OrderDetail order;
  const _Totals({required this.order});
  @override
  Widget build(BuildContext context) => _card(Column(children: [
        _row(Ar.subtotal, order.subtotalSdg),
        if (order.discountSdg > 0)
          _row(Ar.discount, -order.discountSdg, color: WexColors.success),
        if (order.deliveryType == 'delivery')
          _row(Ar.deliveryFee, order.deliveryFeeSdg),
        const Divider(),
        Row(children: [
          const Text(Ar.total, style: TextStyle(fontWeight: FontWeight.w800)),
          const Spacer(),
          PriceText(order.totalSdg, size: 18),
        ]),
      ]));

  Widget _row(String l, int v, {Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Text(l, style: const TextStyle(color: WexColors.textSecondary)),
          const Spacer(),
          PriceText(v.abs(),
              size: 14,
              color: color ?? WexColors.navy,
              weight: FontWeight.w700),
        ]),
      );
}

class _AccountsCard extends StatelessWidget {
  final OrderDetail order;
  const _AccountsCard({required this.order});
  @override
  Widget build(BuildContext context) {
    if (order.paymentAccounts.isEmpty) return const SizedBox.shrink();
    return _card(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(Ar.transferAccount,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      const SizedBox(height: 10),
      for (final a in order.paymentAccounts) ...[
        Text(a.bankName, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(a.accountName,
            style:
                const TextStyle(color: WexColors.textSecondary, fontSize: 13)),
        Row(children: [
          Directionality(
              textDirection: TextDirection.ltr,
              child: Text(a.accountNumber,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()]))),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: a.accountNumber));
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(Ar.accountCopied)));
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
    final events = order.timeline;
    final dead = order.status == OrderStatus.cancelled ||
        order.status == OrderStatus.expired;
    return _card(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(Ar.orderPath,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      const SizedBox(height: 14),
      for (var i = 0; i < events.length; i++)
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              width: 32,
              child: Column(children: [
                // Coloured circle (done = success tint, current = brand, dead end = danger).
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: (i == events.length - 1
                            ? (dead ? Tone.danger : Tone.brand)
                            : Tone.success)
                        .bg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    i == events.length - 1
                        ? (dead ? Icons.close_rounded : Icons.circle)
                        : Icons.check_rounded,
                    size: i == events.length - 1 && !dead ? 10 : 16,
                    color: (i == events.length - 1
                            ? (dead ? Tone.danger : Tone.brand)
                            : Tone.success)
                        .fg,
                  ),
                ),
                if (i != events.length - 1)
                  Expanded(child: Container(width: 2, color: WexColors.border)),
              ]),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(events[i].statusText,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, height: 1.3)),
                      if (events[i].createdAt != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(formatDateTimeAr(events[i].createdAt!),
                              style: WexText.caption),
                        ),
                      if ((events[i].note ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(events[i].note!, style: WexText.caption),
                        ),
                    ]),
              ),
            ),
          ]),
        ),
    ]));
  }
}

class _Note extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _Note(
      {required this.icon, required this.text, this.color = WexColors.royal});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(Sp.x6),
        decoration: BoxDecoration(
            color: WexColors.ice,
            borderRadius: BorderRadius.circular(Radii.card)),
        child: Row(children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(height: 1.6))),
        ]),
      );
}

Widget _card(Widget child) => SurfaceCard(child: child);

/// Animated confirmation shown right after checkout.
class _SuccessHeader extends StatelessWidget {
  final String orderNumber;
  const _SuccessHeader({required this.orderNumber});
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      soft: true,
      child: Column(children: [
        const AnimatedCheck(size: 84),
        const SizedBox(height: Sp.x6),
        const Text(Ar.orderCreated,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))
            .animate(delay: 150.ms)
            .fadeIn()
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('${Ar.orderNumberLabel}: ',
              style: TextStyle(color: WexColors.textSecondary)),
          Directionality(
              textDirection: TextDirection.ltr,
              child: Text(orderNumber,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontFeatures: [FontFeature.tabularFigures()]))),
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            icon: const Icon(Icons.copy_rounded),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: orderNumber));
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text(Ar.copied)));
            },
          ),
        ]).animate(delay: 250.ms).fadeIn(),
        const SizedBox(height: 4),
        const Text(Ar.orderConfirmHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: WexColors.textSecondary, height: 1.6))
            .animate(delay: 350.ms)
            .fadeIn(),
        const SizedBox(height: Sp.x6),
        WexButton(Ar.shareWhatsapp,
            secondary: true,
            icon: const Icon(Icons.share_rounded,
                color: WexColors.primary, size: 20),
            onPressed: () => shareViaWhatsApp(Ar.shareOrderText(orderNumber))),
      ]),
    );
  }
}

/// Status summary: tinted icon square, status pill and the order number.
class _StatusHeader extends StatelessWidget {
  final OrderDetail order;
  const _StatusHeader({required this.order});
  @override
  Widget build(BuildContext context) {
    final tone = statusTone(order.status);
    return SurfaceCard(
      child: Row(children: [
        TintIcon(
            order.status == OrderStatus.completed
                ? Icons.verified_rounded
                : (tone == Tone.danger
                    ? Icons.cancel_rounded
                    : Icons.receipt_long_rounded),
            tone: tone),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(Ar.orderNumberLabel, style: WexText.caption),
            LtrText(order.orderNumber,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ]),
        ),
        StatusPill(
            order.statusLabel.isEmpty
                ? statusText(order.status)
                : order.statusLabel,
            tone: tone),
      ]),
    );
  }
}
