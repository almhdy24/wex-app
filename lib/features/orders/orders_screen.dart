import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/spacing.dart';
import '../../core/design/typography.dart';
import '../../core/format/dates.dart';
import '../../core/format/money.dart';
import '../../core/format/plural.dart';
import '../../data/models/order.dart';
import '../../ui/app_scaffold.dart';
import '../../ui/app_top_bar.dart';
import '../../ui/buttons.dart';
import '../../ui/gradients.dart';
import '../../ui/icons.dart';
import '../../ui/money_text.dart';
import '../../ui/product_image.dart';
import '../../ui/skeleton.dart';
import '../../ui/states.dart';
import '../../ui/tag.dart';

/// Filter buckets (chips with live counts).
enum OrderFilter { all, pending, processing, done, cancelled }

OrderFilter bucketOf(OrderStatus s) => switch (s) {
      OrderStatus.pendingPayment => OrderFilter.pending,
      OrderStatus.paymentReview ||
      OrderStatus.confirmed ||
      OrderStatus.readyForPickup ||
      OrderStatus.outForDelivery =>
        OrderFilter.processing,
      OrderStatus.completed => OrderFilter.done,
      OrderStatus.cancelled || OrderStatus.expired => OrderFilter.cancelled,
      _ => OrderFilter.all,
    };

String _filterLabel(OrderFilter f) => switch (f) {
      OrderFilter.all => 'الكل',
      OrderFilter.pending => 'بانتظار الدفع',
      OrderFilter.processing => 'قيد التجهيز',
      OrderFilter.done => 'مكتمل',
      OrderFilter.cancelled => 'ملغي',
    };

StatusKind statusKind(OrderStatus s) => switch (s) {
      OrderStatus.pendingPayment => StatusKind.pending,
      OrderStatus.paymentReview => StatusKind.review,
      OrderStatus.confirmed || OrderStatus.readyForPickup || OrderStatus.outForDelivery => StatusKind.confirmed,
      OrderStatus.completed => StatusKind.done,
      OrderStatus.cancelled || OrderStatus.expired => StatusKind.bad,
      _ => StatusKind.neutral,
    };

String statusText(OrderStatus s) => switch (s) {
      OrderStatus.pendingPayment => 'بانتظار الدفع',
      OrderStatus.paymentReview => 'قيد مراجعة التحويل',
      OrderStatus.confirmed => 'مؤكد',
      OrderStatus.readyForPickup => 'جاهز للاستلام',
      OrderStatus.outForDelivery => 'خرج للتوصيل',
      OrderStatus.completed => 'مكتمل',
      OrderStatus.cancelled => 'ملغي',
      OrderStatus.expired => 'انتهت المهلة',
      _ => '—',
    };

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});
  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  OrderFilter _filter = OrderFilter.all;

  @override
  Widget build(BuildContext context) {
    final authed = ref.watch(authControllerProvider).isAuthenticated;
    const bar = AppTopBar(title: 'طلباتي', showBack: false);
    if (!authed) {
      return AppScaffold(
        appBar: bar,
        body: EmptyState(
          icon: LucideIcons.receipt,
          title: 'سجّل الدخول لعرض طلباتك',
          actionLabel: 'تسجيل الدخول',
          onAction: () => context.push('/login'),
        ),
      );
    }
    final orders = ref.watch(ordersListProvider);
    return AppScaffold(
      appBar: bar,
      body: orders.when(
        loading: () => SkeletonScope(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: AppScaffold.listPadding(context),
            children: [for (var i = 0; i < 3; i++) ...const [SkeletonBox(height: 150, radius: Radii.card), SizedBox(height: 12)]],
          ),
        ),
        error: (_, __) => ErrorState(onRetry: () => ref.invalidate(ordersListProvider)),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: LucideIcons.receipt,
              title: 'لا توجد طلبات بعد',
              body: 'اختار جهازك الأول وسنتابع معك بقية الخطوات.',
              actionLabel: 'تصفّح المتجر',
              onAction: () => context.go('/catalog'),
            );
          }
          final counts = {for (final f in OrderFilter.values) f: 0};
          for (final o in list) {
            counts[OrderFilter.all] = counts[OrderFilter.all]! + 1;
            final b = bucketOf(o.status);
            counts[b] = counts[b]! + 1;
          }
          final shown = _filter == OrderFilter.all ? list : list.where((o) => bucketOf(o.status) == _filter).toList();
          final active = shown.where((o) => o.status == OrderStatus.pendingPayment || o.status == OrderStatus.paymentReview).toList();
          final rest = _filter == OrderFilter.all ? shown.where((o) => !active.contains(o)).toList() : shown;
          final showActiveSection = _filter == OrderFilter.all && active.isNotEmpty;
          return RefreshIndicator(
            color: WexColors.teal600,
            onRefresh: () async => ref.invalidate(ordersListProvider),
            child: ListView(
              padding: AppScaffold.listPadding(context, top: 4),
              children: [
                SizedBox(
                  height: 44,
                  child: EdgeFade(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      itemCount: OrderFilter.values.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final f = OrderFilter.values[i];
                        final sel = _filter == f;
                        return ChoiceChip(
                          label: Text('${_filterLabel(f)} ${isolate('${counts[f]}')}'),
                          selected: sel,
                          labelStyle: WexText.body.copyWith(color: sel ? WexColors.surface : WexColors.ink900, fontWeight: FontWeight.w500),
                          onSelected: (_) => setState(() => _filter = f),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (shown.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: Text('لا توجد طلبات في هذا التصنيف', style: WexText.bodyS)),
                  ),
                if (showActiveSection) ...[
                  const Text('طلبات نشطة', style: WexText.titleM),
                  const SizedBox(height: 12),
                  for (final o in active) _OrderCard(order: o),
                  if (rest.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('الطلبات السابقة', style: WexText.titleM),
                    const SizedBox(height: 12),
                  ],
                ],
                for (final o in rest) _OrderCard(order: o),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderListItem order;
  const _OrderCard({required this.order});

  Future<void> _reorder(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final o = await ref.read(orderRepositoryProvider).reorder(order.orderNumber);
      final n = (o['order_number'] ?? '').toString();
      ref.invalidate(ordersListProvider);
      if (n.isNotEmpty) router.go('/orders/$n');
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('تعذّر إعادة الطلب')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = order.linesCount > 0 ? order.linesCount : order.itemsCount;
    final others = lines - 1;
    final label = order.statusLabel.isEmpty ? statusText(order.status) : order.statusLabel;
    final expired = order.status == OrderStatus.expired || order.status == OrderStatus.cancelled;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: WexColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.card), side: const BorderSide(color: WexColors.line)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/orders/${order.orderNumber}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(order.orderNumber, maxLines: 1, softWrap: false, style: WexText.numeric),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                StatusPill(label, kind: statusKind(order.status)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                SizedBox(width: 48, child: ProductPhoto(url: order.firstItemImage ?? '', aspectRatio: 1, padding: 4, memWidth: 140)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(order.firstItemName ?? 'طلب ${order.orderNumber}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: WexText.body.copyWith(fontWeight: FontWeight.w600)),
                    if (others > 0) Text('+ ${otherDevicesLabel(others)}', style: WexText.bodyS),
                  ]),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                MoneyText(order.totalSdg),
                const Spacer(),
                if (order.createdAt != null) Text(formatDateTimeAr(order.createdAt!), style: WexText.bodyS),
              ]),
              if (order.status == OrderStatus.pendingPayment) ...[
                const SizedBox(height: 12),
                PrimaryButton('ارفع إشعار التحويل', onPressed: () => context.push('/orders/${order.orderNumber}')),
              ] else if (expired) ...[
                const SizedBox(height: 12),
                SecondaryButton('اطلب مجددًا', onPressed: () => _reorder(context, ref)),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}
