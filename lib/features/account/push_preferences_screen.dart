import 'package:flutter/material.dart';
import '../../core/strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/spacing.dart';

final pushPrefsProvider = FutureProvider.autoDispose(
    (ref) => ref.read(pushRepositoryProvider).preferences());

class PushPreferencesScreen extends ConsumerWidget {
  const PushPreferencesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pushPrefsProvider);
    final repo = ref.read(pushRepositoryProvider);
    Future<void> toggle(String key, bool v) async {
      await repo.updatePreferences({key: v});
      ref.invalidate(pushPrefsProvider);
    }

    return Scaffold(
      appBar: AppBar(title: const Text(Ar.pushTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
            child: Text(Ar.loadError,
                style: TextStyle(color: WexColors.textSecondary))),
        data: (p) => ListView(
          padding: const EdgeInsets.all(Sp.page),
          children: [
            _row(Ar.prefOrders, p.orderUpdates,
                (v) => toggle('order_updates', v)),
            _row(Ar.prefPayments, p.paymentUpdates,
                (v) => toggle('payment_updates', v)),
            _row(
                Ar.prefPrices, p.priceAlerts, (v) => toggle('price_alerts', v)),
            _row(Ar.prefOffers, p.announcements,
                (v) => toggle('announcements', v)),
            const SizedBox(height: Sp.x6),
            OutlinedButton.icon(
              onPressed: () async {
                await repo.sendTest();
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text(Ar.testSent)));
                }
              },
              icon: const Icon(Icons.send),
              label: const Text(Ar.sendTest),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, bool value, ValueChanged<bool> onChanged) =>
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        value: value,
        activeThumbColor: WexColors.royal,
        onChanged: onChanged,
      );
}
