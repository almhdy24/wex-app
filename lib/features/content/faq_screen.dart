import 'package:flutter/material.dart';
import '../../core/strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/spacing.dart';

class FaqScreen extends ConsumerWidget {
  const FaqScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(faqProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Ar.faq)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
            child: Text(Ar.loadError,
                style: TextStyle(color: WexColors.textSecondary))),
        data: (items) => ListView(
          padding: const EdgeInsets.all(Sp.page),
          children: [
            for (final f in items)
              Card(
                margin: const EdgeInsets.only(bottom: Sp.x3),
                child: ExpansionTile(
                  shape: const Border(),
                  title: Text(f.question,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  childrenPadding:
                      const EdgeInsets.fromLTRB(Sp.x6, 0, Sp.x6, Sp.x6),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.answer,
                        style: const TextStyle(
                            height: 1.8, color: WexColors.textSecondary))
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
