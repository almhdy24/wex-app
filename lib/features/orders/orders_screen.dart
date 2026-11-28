import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/spacing.dart';
import '../../core/design/tones.dart';
import '../../core/design/typography.dart';
import '../../core/strings.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/launchers.dart';
import '../../core/widgets/illustrations.dart';
import '../../core/widgets/price_text.dart';
import '../../core/widgets/shimmer.dart';
import '../../core/widgets/wex_kit.dart';
import '../../core/widgets/wex_widgets.dart';
import '../../data/models/order.dart';

/// Order filter buckets shown as chips with live counts.
enum OrderFilter { all, pending, processing, completed, cancelled }

OrderFilter _bucketOf(OrderStatus s) => switch (s) {
      OrderStatus.pendingPayment => OrderFilter.pending,
      OrderStatus.paymentReview ||
      OrderStatus.confirmed ||
      OrderStatus.readyForPickup ||
      OrderStatus.outForDelivery =>
        OrderFilter.processing,
      OrderStatus.completed => OrderFilter.completed,
      OrderStatus.cancelled || OrderStatus.expired => OrderFilter.cancelled,
      _ => OrderFilter.all,
    };

String _filterLabel(OrderFilter f) => switch (f) {
      OrderFilter.all => Ar.ordersAll,
      OrderFilter.pending => Ar.stPending,
      OrderFilter.processing => Ar.ordersProcessing,
      OrderFilter.completed => Ar.stCompleted,
      OrderFilter.cancelled => Ar.stCancelled,
    };

/// Semantic tone for an order status (shared with the detail screen).
Tone statusTone(OrderStatus s) => switch (s) {
      OrderStatus.pendingPayment => Tone.warning,
      OrderStatus.paymentReview ||
      OrderStatus.confirmed ||
      OrderStatus.readyForPickup ||
      OrderStatus.outForDelivery =>
        Tone.brand,
      OrderStatus.completed => Tone.success,
      OrderStatus.cancelled || OrderStatus.expired => Tone.danger,
      _ => Tone.neutral,
    };

String statusText(OrderStatus s) => switch (s) {
      OrderStatus.pendingPayment => Ar.stPending,
      OrderStatus.paymentReview => Ar.stReview,
      OrderStatus.confirmed ||
      OrderStatus.readyForPickup ||
      OrderStatus.outForDelivery =>
        Ar.stConfirmed,
      OrderStatus.completed => Ar.stCompleted,
      OrderStatus.cancelled => Ar.stCancelled,
      OrderStatus.expired => Ar.stExpired,
      _ => '—',
    };

/// (label, bg, fg) — kept for older call sites.
(String, Color, Color) statusChip(OrderStatus s) {
  final t = statusTone(s);
  return (statusText(s), t.bg, t.fg);
}

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
    if (!authed) {
      return Scaffold(
        appBar: AppBar(title: const Text(Ar.navOrders)),
        body: IllustratedEmpty(
          kind: IllustrationKind.box,
          title: Ar.ordersSignedOut,
          ctaLabel: Ar.signIn,
          onCta: () => context.push('/login'),
        ),
      );
    }
    final orders = ref.watch(ordersListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Ar.navOrders)),
      body: orders.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(Sp.page),
          child: Column(children: [
            ShimmerBox(height: 96, radius: 24),
            SizedBox(height: 12),
            ShimmerBox(height: 140, radius: 24),
            SizedBox(height: 12),
            ShimmerBox(height: 140, radius: 24),
          ]),
        ),
        error: (_, __) => IllustratedEmpty(
          kind: IllustrationKind.search,
          title: Ar.ordersLoadError,
          ctaLabel: Ar.retry,
          onCta: () => ref.invalidate(ordersListProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return IllustratedEmpty(
              kind: IllustrationKind.box,
              title: Ar.ordersEmptyTitle,
              body: Ar.ordersEmptyBody,
              ctaLabel: Ar.browseStore,
              onCta: () => context.go('/catalog'),
            );
          }
          final counts = {for (final f in OrderFilter.values) f: 0};
          for (final o in list) {
            counts[OrderFilter.all] = counts[OrderFilter.all]! + 1;
            final b = _bucketOf(o.status);
            counts[b] = counts[b]! + 1;
          }
          final shown = _filter == OrderFilter.all
              ? list
              : list.where((o) => _bucketOf(o.status) == _filter).toList();
          final active =
              counts[OrderFilter.pending]! + counts[OrderFilter.processing]!;
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(ordersListProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Sp.page, Sp.x3, Sp.page, 120),
              children: [
                HeroCard(
                  child: Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(Radii.icon)),
                      child: const Icon(Icons.receipt_long_rounded,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(Ar.ordersActiveHero,
                                style: TextStyle(
                                    color: WexColors.onDarkMuted,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(Ar.ordersActiveCount(active),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800)),
                          ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: OrderFilter.values.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final f = OrderFilter.values[i];
                      return CountFilterChip(
                        label: _filterLabel(f),
                        count: counts[f],
                        selected: _filter == f,
                        onTap: () => setState(() => _filter = f),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                if (shown.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                        child: Text(Ar.ordersFilterEmpty,
                            style: TextStyle(color: WexColors.textSecondary))),
                  )
                else
                  for (var i = 0; i < shown.length; i++)
                    FadeInUp(
                      key: ValueKey(shown[i].orderNumber),
                      index: i,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _OrderCard(order: shown[i]),
                      ),
                    ),
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
      final o =
          await ref.read(orderRepositoryProvider).reorder(order.orderNumber);
      final n = (o['order_number'] ?? '').toString();
      ref.invalidate(ordersListProvider);
      if (n.isNotEmpty) {
        router.go('/orders/$n');
      }
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text(Ar.reorderFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tone = statusTone(order.status);
    final shop = ref.watch(shopProvider).valueOrNull;
    final isDelivery = order.deliveryType == 'delivery';

    Widget? cta;
    switch (order.status) {
      case OrderStatus.pendingPayment:
        final left = order.secondsRemaining > 0
            ? ' · ${Ar.lockLeft(formatRemaining(order.secondsRemaining))}'
            : '';
        cta = _CardCta(
            icon: Icons.account_balance_rounded,
            label: '${Ar.completeTransfer}$left',
            onTap: () => context.push('/orders/${order.orderNumber}'));
      case OrderStatus.confirmed ||
            OrderStatus.readyForPickup ||
            OrderStatus.outForDelivery ||
            OrderStatus.paymentReview:
        if (shop != null && shop.whatsapp.isNotEmpty) {
          cta = _CardCta(
              icon: Icons.chat_rounded,
              label: Ar.orderContactWa,
              tone: Tone.success,
              onTap: () => openWhatsApp(shop.whatsapp,
                  text: Ar.orderWaText(order.orderNumber)));
        }
      case OrderStatus.completed ||
            OrderStatus.cancelled ||
            OrderStatus.expired:
        cta = _CardCta(
            icon: Icons.refresh_rounded,
            label: Ar.orderAgain,
            tone: Tone.neutral,
            onTap: () => _reorder(context, ref));
      default:
    }

    return SurfaceCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push('/orders/${order.orderNumber}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.card24),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Status stripe at the start edge; grows in.
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 5),
              duration: MediaQuery.of(context).disableAnimations
                  ? Duration.zero
                  : const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              builder: (_, w, __) => Container(width: w, color: tone.fg),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        _Thumb(url: order.firstItemImage),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(order.firstItemName ?? order.orderNumber,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        height: 1.35)),
                                const SizedBox(height: 4),
                                LtrText(order.orderNumber,
                                    maxLines: 1, style: WexText.caption),
                              ]),
                        ),
                        const SizedBox(width: 8),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              StatusPill(
                                  order.statusLabel.isEmpty
                                      ? statusText(order.status)
                                      : order.statusLabel,
                                  tone: tone),
                              if (order.itemsCount > 1) ...[
                                const SizedBox(height: 6),
                                StatusPill(Ar.itemsChip(order.itemsCount),
                                    tone: Tone.neutral, dot: false),
                              ],
                            ]),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        const Icon(Icons.schedule_rounded,
                            size: 15, color: WexColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                              order.createdAt == null
                                  ? '—'
                                  : formatDateTimeAr(order.createdAt!),
                              style: WexText.caption,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Icon(
                            isDelivery
                                ? Icons.local_shipping_outlined
                                : Icons.storefront_outlined,
                            size: 16,
                            color: WexColors.textSecondary),
                        const SizedBox(width: 10),
                        PriceText(order.totalSdg, size: 16),
                      ]),
                      if (cta != null) ...[const SizedBox(height: 12), cta],
                    ]),
              ),
            ),
            const Padding(
              padding: EdgeInsetsDirectional.only(end: 6),
              child:
                  Icon(Icons.chevron_left_rounded, color: WexColors.disabled),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? url;
  const _Thumb({this.url});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(Radii.inner),
        child: Container(
          width: 56,
          height: 56,
          color: WexColors.iceLight,
          child: url == null
              ? const Icon(Icons.laptop_mac_rounded, color: WexColors.disabled)
              : Image.network(url!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.laptop_mac_rounded,
                      color: WexColors.disabled)),
        ),
      );
}

class _CardCta extends StatelessWidget {
  final IconData icon;
  final String label;
  final Tone tone;
  final VoidCallback onTap;
  const _CardCta(
      {required this.icon,
      required this.label,
      this.tone = Tone.brand,
      required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
        color: tone.bg,
        borderRadius: BorderRadius.circular(Radii.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.pill),
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 18, color: tone.fg),
              const SizedBox(width: 8),
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: tone.fg,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ),
            ]),
          ),
        ),
      );
}
