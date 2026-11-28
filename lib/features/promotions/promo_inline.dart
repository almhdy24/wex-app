import 'package:flutter/widgets.dart';

/// Placeholder until the promotions provider lands (renders nothing: no hole in the list).
class PromoInline extends StatelessWidget {
  final String placement;
  final bool compact;
  const PromoInline({super.key, required this.placement, this.compact = false});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
