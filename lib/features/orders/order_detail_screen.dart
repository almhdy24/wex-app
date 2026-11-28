import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/spacing.dart';
import '../../core/design/typography.dart';
import '../../core/format/dates.dart';
import '../../data/models/order.dart';
import '../../ui/app_scaffold.dart';
import '../../ui/app_top_bar.dart';
import '../../ui/buttons.dart';
import '../../ui/icons.dart';
import '../../ui/money_text.dart';
import '../../ui/skeleton.dart';
import '../../ui/states.dart';
import '../../ui/tag.dart';
import 'orders_screen.dart' show statusKind, statusText;

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderNumber;
  final bool justCreated;
  const OrderDetailScreen({super.key, required this.orderNumber, this.justCreated = false});
  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _uploading = false;

  void _toast(String m) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(m)));

  Future<void> _upload() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1600);
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      final out = '${picked.path}_c.jpg';
      final compressed = await FlutterImageCompress.compressAndGetFile(picked.path, out, quality: 80, minWidth: 1600, minHeight: 1600);
      await ref.read(orderRepositoryProvider).uploadProof(widget.orderNumber, compressed?.path ?? picked.path);
      ref.invalidate(orderDetailProvider(widget.orderNumber));
      if (mounted) _toast('تم رفع إشعار التحويل');
    } catch (_) {
      if (mounted) _toast('تعذّر رفع الإشعار');
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
      if (mounted) _toast('تعذّر إعادة الطلب');
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(orderDetailProvider(widget.orderNumber));
    return AppScaffold(
      appBar: const AppTopBar(title: 'تفاصيل الطلب'),
      body: async.when(
        loading: () => SkeletonScope(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: AppScaffold.listPadding(context),
            children: const [
              SkeletonBox(height: 88, radius: Radii.card),
              SizedBox(height: 12),
              SkeletonBox(height: 140, radius: Radii.card),
              SizedBox(height: 12),
              SkeletonBox(height: 120, radius: Radii.card),
            ],
          ),
        ),
        error: (_, __) => ErrorState(message: 'تعذّر تحميل الطلب.', onRetry: () => ref.invalidate(orderDetailProvider(widget.orderNumber))),
        data: (o) => RefreshIndicator(
          color: WexColors.teal600,
          onRefresh: () async => ref.invalidate(orderDetailProvider(widget.orderNumber)),
          child: ListView(
            padding: AppScaffold.listPadding(context, top: 4),
            children: [
              _Header(order: o, justCreated: widget.justCreated),
              const SizedBox(height: 12),
              if (o.isPending && o.secondsRemaining > 0) ...[
                _LockCard(order: o),
                const SizedBox(height: 12),
              ],
              if (o.isExpired) ...[
                _ExpiredBanner(onReorder: _reorder),
                const SizedBox(height: 12),
              ],
              if (o.payment.canUpload) ...[
                _Accounts(order: o),
                PrimaryButton(
                  o.payment.state == PaymentState.rejected ? 'إعادة رفع الإشعار' : 'ارفع إشعار التحويل',
                  icon: LucideIcons.upload,
                  loading: _uploading,
                  onPressed: _upload,
                ),
                const SizedBox(height: 12),
              ],
              if (o.payment.state == PaymentState.underReview)
                const _Note('إشعارك قيد المراجعة، نؤكد الطلب بعد التحقق.'),
              if (o.payment.state == PaymentState.approved || o.status == OrderStatus.completed)
                const _Note('تم تأكيد طلبك.', good: true),
              _Summary(order: o),
              const SizedBox(height: 12),
              _Timeline(order: o),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WexColors.surface,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: WexColors.line),
        ),
        child: child,
      );
}

class _Header extends StatelessWidget {
  final OrderDetail order;
  final bool justCreated;
  const _Header({required this.order, required this.justCreated});
  @override
  Widget build(BuildContext context) {
    final date = order.timeline.isNotEmpty ? order.timeline.first.createdAt : null;
    return _Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (justCreated) ...[
          Row(children: const [
            Icon(LucideIcons.circleCheck, size: 20, color: WexColors.success),
            SizedBox(width: 8),
            Text('تم إنشاء طلبك', style: WexText.body),
          ]),
          const SizedBox(height: 12),
        ],
        Row(children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(order.orderNumber, maxLines: 1, softWrap: false, style: WexText.titleM.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              tooltip: 'نسخ رقم الطلب',
              icon: const Icon(LucideIcons.copy, size: 20),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: order.orderNumber));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ رقم الطلب')));
              },
            ),
          ),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          StatusPill(order.statusLabel.isEmpty ? statusText(order.status) : order.statusLabel, kind: statusKind(order.status)),
          const SizedBox(width: 12),
          if (date != null) Flexible(child: Text(formatDateTimeAr(date), style: WexText.bodyS)),
        ]),
      ]),
    );
  }
}

/// Price-lock countdown driven by the server clock (not the device).
class _LockCard extends ConsumerStatefulWidget {
  final OrderDetail order;
  const _LockCard({required this.order});
  @override
  ConsumerState<_LockCard> createState() => _LockCardState();
}

class _LockCardState extends ConsumerState<_LockCard> {
  late int _remaining = widget.order.secondsRemaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final st = ref.read(serverTimeApiProvider).serverTime;
      final exp = widget.order.lockExpiresAt;
      final next = exp != null ? st.secondsUntil(exp) : _remaining - 1;
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

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WexColors.sun50,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: WexColors.sun100),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('السعر مثبّت — أكمل التحويل خلال', style: WexText.bodyS),
          const SizedBox(height: 4),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(formatCountdown(Duration(seconds: _remaining), alwaysHours: true),
                style: WexText.display.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
          ),
          const SizedBox(height: 4),
          Row(children: [
            const Text('المبلغ المطلوب ', style: WexText.bodyS),
            MoneyText(widget.order.totalSdg),
          ]),
        ]),
      );
}

class _ExpiredBanner extends StatelessWidget {
  final VoidCallback onReorder;
  const _ExpiredBanner({required this.onReorder});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: WexColors.dangerBg, borderRadius: BorderRadius.circular(Radii.card)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('انتهت مهلة تثبيت السعر لهذا الطلب.', style: WexText.body.copyWith(color: WexColors.dangerText, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SecondaryButton('أعد الطلب بالسعر الحالي', onPressed: onReorder),
        ]),
      );
}

class _Note extends StatelessWidget {
  final String text;
  final bool good;
  const _Note(this.text, {this.good = false});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: good ? WexColors.successBg : WexColors.teal50,
            borderRadius: BorderRadius.circular(Radii.card),
          ),
          child: Text(text, style: WexText.body.copyWith(color: good ? WexColors.successText : WexColors.teal700)),
        ),
      );
}

class _Accounts extends StatelessWidget {
  final OrderDetail order;
  const _Accounts({required this.order});
  @override
  Widget build(BuildContext context) {
    if (order.paymentAccounts.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _Card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('حساب التحويل', style: WexText.titleM),
          for (final a in order.paymentAccounts) ...[
            const SizedBox(height: 12),
            Text(a.bankName, style: WexText.body.copyWith(fontWeight: FontWeight.w600)),
            Text(a.accountName, style: WexText.bodyS),
            Row(children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(a.accountNumber, style: WexText.numeric.copyWith(fontSize: 16)),
                  ),
                ),
              ),
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton(
                  tooltip: 'نسخ رقم الحساب',
                  icon: const Icon(LucideIcons.copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: a.accountNumber));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ رقم الحساب')));
                  },
                ),
              ),
            ]),
          ],
        ]),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final OrderDetail order;
  const _Summary({required this.order});
  Widget _row(String l, Widget v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [Expanded(child: Text(l, style: WexText.body)), v]),
      );
  @override
  Widget build(BuildContext context) => _Card(
        child: Column(children: [
          _row('المجموع الفرعي', MoneyText(order.subtotalSdg, style: WexText.body.copyWith(fontWeight: FontWeight.w600))),
          if (order.discountSdg > 0)
            _row('الخصم', MoneyText(-order.discountSdg, style: WexText.body.copyWith(fontWeight: FontWeight.w600), color: WexColors.success)),
          if (order.deliveryType == 'delivery')
            _row('رسوم التوصيل', MoneyText(order.deliveryFeeSdg, style: WexText.body.copyWith(fontWeight: FontWeight.w600))),
          const Divider(height: 24),
          Row(children: [
            const Expanded(child: Text('الإجمالي', style: WexText.titleM)),
            MoneyText.large(order.totalSdg),
          ]),
        ]),
      );
}

enum _Node { done, current, bad }

bool _isBadText(String s) => RegExp(r'رفض|مرفوض|ملغ|انتهت|منتهي|منتهية').hasMatch(s);

class _Timeline extends StatelessWidget {
  final OrderDetail order;
  const _Timeline({required this.order});

  /// Merge consecutive identical statuses; keep the latest one (with its date and note).
  List<TimelineEvent> _merged() {
    final out = <TimelineEvent>[];
    for (final e in order.timeline) {
      if (out.isNotEmpty && out.last.statusText.trim() == e.statusText.trim()) {
        out[out.length - 1] = e;
      } else {
        out.add(e);
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final events = _merged();
    if (events.isEmpty) return const SizedBox.shrink();
    final dead = order.status == OrderStatus.cancelled || order.status == OrderStatus.expired;
    return _Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('مسار الطلب', style: WexText.titleM),
        const SizedBox(height: 16),
        for (var i = 0; i < events.length; i++)
          _Step(
            event: events[i],
            node: _isBadText(events[i].statusText) || (dead && i == events.length - 1)
                ? _Node.bad
                : (i == events.length - 1 ? _Node.current : _Node.done),
            last: i == events.length - 1,
          ),
      ]),
    );
  }
}

class _Step extends StatelessWidget {
  final TimelineEvent event;
  final _Node node;
  final bool last;
  const _Step({required this.event, required this.node, required this.last});

  @override
  Widget build(BuildContext context) {
    final Widget dot = switch (node) {
      _Node.done => Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(color: WexColors.teal600, shape: BoxShape.circle),
          child: const Icon(LucideIcons.check, size: 14, color: WexColors.surface)),
      _Node.current => Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: WexColors.teal600, width: 2)),
          child: Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: WexColors.teal600, shape: BoxShape.circle)))),
      _Node.bad => Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(color: WexColors.danger, shape: BoxShape.circle),
          child: const Icon(LucideIcons.x, size: 14, color: WexColors.surface)),
    };
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          width: 24,
          child: Column(children: [dot, if (!last) const Expanded(child: VerticalDivider(width: 2, thickness: 2))]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: last ? 0 : 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(event.statusText, style: WexText.body.copyWith(fontWeight: FontWeight.w600, color: node == _Node.bad ? WexColors.danger : WexColors.ink900)),
              if (event.createdAt != null) Text(formatDateTimeAr(event.createdAt!), style: WexText.bodyS),
              if ((event.note ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 2), child: Text(event.note!, style: WexText.bodyS)),
            ]),
          ),
        ),
      ]),
    );
  }
}
