import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';

/// Token-rendered server-side ({{lock_duration}} etc.). We just render paragraphs.
class ContentPageScreen extends ConsumerWidget {
  final String slug;
  const ContentPageScreen({super.key, required this.slug});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pageProvider(slug));
    return Scaffold(
      appBar: AppBar(title: Text(async.valueOrNull?.title ?? 'صفحة المتجر')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('هذه الصفحة غير متوفرة حاليًا.', style: TextStyle(color: WexColors.textSecondary))),
        data: (page) {
          final paras = page.body.split(RegExp(r'\n\s*\n')).where((p) => p.trim().isNotEmpty).toList();
          return ListView(
            padding: const EdgeInsets.all(Sp.page),
            children: [
              for (final p in paras)
                Padding(
                  padding: const EdgeInsets.only(bottom: Sp.x6),
                  child: Text(p.trim(), style: const TextStyle(height: 1.9, fontSize: 15)),
                ),
            ],
          );
        },
      ),
    );
  }
}
