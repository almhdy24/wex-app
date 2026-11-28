import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/spacing.dart';
import '../../core/design/typography.dart';
import '../../data/models/app_notification.dart';
import '../../ui/app_scaffold.dart';
import '../../ui/app_top_bar.dart';
import '../../ui/icons.dart';
import '../../ui/skeleton.dart';
import '../../ui/states.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsProvider);
    return AppScaffold(
      appBar: AppTopBar(title: 'الإشعارات', actions: [
        TextButton(
          onPressed: () async {
            await ref.read(notificationRepositoryProvider).markAllRead();
            ref.invalidate(notificationsProvider);
            ref.invalidate(unreadCountProvider);
          },
          child: const Text('تعليم الكل كمقروء'),
        ),
      ]),
      body: async.when(
        loading: () => SkeletonScope(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: AppScaffold.listPadding(context),
            children: [for (var i = 0; i < 4; i++) ...const [SkeletonBox(height: 72, radius: Radii.card), SizedBox(height: 8)]],
          ),
        ),
        error: (_, __) => ErrorState(onRetry: () => ref.invalidate(notificationsProvider)),
        data: (list) => list.isEmpty
            ? const EmptyState(icon: LucideIcons.bell, title: 'لا توجد إشعارات', body: 'سنخبرك هنا بكل تحديث على طلباتك.')
            : ListView.separated(
                padding: AppScaffold.listPadding(context, top: 4),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _NotifTile(
                  n: list[i],
                  onTap: () async {
                    await ref.read(notificationRepositoryProvider).markRead(list[i].id);
                    ref.invalidate(unreadCountProvider);
                    final n = list[i];
                    if (n.orderNumber != null && context.mounted) context.push('/orders/${n.orderNumber}');
                  },
                ),
              ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final AppNotification n;
  final VoidCallback onTap;
  const _NotifTile({required this.n, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
        color: WexColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.card), side: const BorderSide(color: WexColors.line)),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (!n.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsetsDirectional.only(end: 12, top: 8),
                  decoration: const BoxDecoration(color: WexColors.teal600, shape: BoxShape.circle),
                ),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(n.title, style: WexText.body.copyWith(fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w600)),
                  if (n.body.isNotEmpty) Text(n.body, style: WexText.bodyS),
                ]),
              ),
            ]),
          ),
        ),
      );
}
