import 'package:flutter/material.dart';
import '../../core/strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../data/models/app_notification.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(Ar.notifications),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllRead();
              ref.invalidate(notificationsProvider);
              ref.invalidate(unreadCountProvider);
            },
            child: const Text(Ar.markAllRead),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
            child: OutlinedButton(
                onPressed: () => ref.invalidate(notificationsProvider),
                child: const Text(Ar.retry))),
        data: (list) => list.isEmpty
            ? const Center(
                child: Text(Ar.notifEmpty,
                    style: TextStyle(color: WexColors.textSecondary)))
            : ListView.separated(
                padding: const EdgeInsets.all(Sp.page),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: Sp.x3),
                itemBuilder: (_, i) => _NotifTile(
                    n: list[i],
                    onTap: () async {
                      await ref
                          .read(notificationRepositoryProvider)
                          .markRead(list[i].id);
                      ref.invalidate(unreadCountProvider);
                      final n = list[i];
                      if (n.orderNumber != null && context.mounted) {
                        context.push('/orders/${n.orderNumber}');
                      }
                    }),
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
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.card),
        child: Container(
          padding: const EdgeInsets.all(Sp.x6),
          decoration: BoxDecoration(
            color: n.isRead ? WexColors.white : WexColors.ice,
            borderRadius: BorderRadius.circular(Radii.card),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0F061A55), blurRadius: 6, offset: Offset(0, 2))
            ],
          ),
          child: Row(children: [
            if (!n.isRead)
              Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsetsDirectional.only(end: 10),
                  decoration: const BoxDecoration(
                      color: WexColors.royal, shape: BoxShape.circle)),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(n.title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (n.body.isNotEmpty)
                    Text(n.body,
                        style: const TextStyle(
                            color: WexColors.textSecondary, fontSize: 13)),
                ])),
          ]),
        ),
      );
}
