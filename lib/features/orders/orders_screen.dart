import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/widgets/price_text.dart';
import '../../data/models/order.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authed = ref.watch(authControllerProvider).isAuthenticated;
    if (!authed) {
      return Scaffold(
        appBar: AppBar(title: const Text('طلباتي')),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.receipt_long, size: 48, color: WexColors.disabled),
            const SizedBox(height: 12),
            const Text('سجّل الدخول لعرض طلباتك', style: TextStyle(color: WexColors.textSecondary)),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => context.push('/login'), child: const Text('تسجيل الدخول')),
          ]),
        ),
      );
    }
    final orders = ref.watch(ordersListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي')),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('تعذّر تحميل الطلبات', style: TextStyle(color: WexColors.textSecondary)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => ref.invalidate(ordersListProvider), child: const Text('إعادة المحاولة')),
          ]),
        ),
        data: (list) => list.isEmpty
            ? const Center(child: Text('لا توجد طلبات بعد', style: TextStyle(color: WexColors.textSecondary)))
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(ordersListProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(Sp.page),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Sp.x5),
                  itemBuilder: (_, i) => _OrderCard(order: list[i]),
                ),
              ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderListItem order;
  const _OrderCard({required this.order});
  @override
  Widget build(BuildContext context) {
    final chip = statusChip(order.status);
    return InkWell(
      onTap: () => context.push('/orders/${order.orderNumber}'),
      borderRadius: BorderRadius.circular(Radii.card),
      child: Container(
        padding: const EdgeInsets.all(Sp.x6),
        decoration: BoxDecoration(
          color: WexColors.white,
          borderRadius: BorderRadius.circular(Radii.card),
          boxShadow: const [BoxShadow(color: Color(0x0F061A55), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Directionality(textDirection: TextDirection.ltr, child: Text(order.orderNumber,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontFeatures: [FontFeature.tabularFigures()]))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: chip.$2, borderRadius: BorderRadius.circular(Radii.pill)),
                child: Text(order.statusLabel.isEmpty ? chip.$1 : order.statusLabel,
                    style: TextStyle(color: chip.$3, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              PriceText(order.totalSdg, size: 16),
              const Spacer(),
              if (order.status == OrderStatus.pendingPayment)
                const Text('رفع إشعار التحويل', style: TextStyle(color: WexColors.royal, fontWeight: FontWeight.w700, fontSize: 13)),
            ]),
          ],
        ),
      ),
    );
  }
}

/// (label, bg, fg) per status.
(String, Color, Color) statusChip(OrderStatus s) => switch (s) {
      OrderStatus.pendingPayment => ('بانتظار الدفع', WexColors.warningBg, WexColors.warning),
      OrderStatus.paymentReview => ('مراجعة التحويل', WexColors.ice, WexColors.royal),
      OrderStatus.confirmed || OrderStatus.readyForPickup || OrderStatus.outForDelivery => ('مؤكد', WexColors.ice, WexColors.royal),
      OrderStatus.completed => ('مكتمل', WexColors.successBg, WexColors.success),
      OrderStatus.cancelled => ('ملغي', WexColors.dangerBg, WexColors.danger),
      OrderStatus.expired => ('منتهي', WexColors.dangerBg, WexColors.danger),
      _ => ('—', WexColors.ice, WexColors.textSecondary),
    };
