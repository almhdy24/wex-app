import 'package:flutter/widgets.dart';

/// Placeholder until the promotions provider lands (renders nothing: no hole in the list).
class PromoInline extends StatelessWidget {
  final String placement;
  const PromoInline({super.key, required this.placement});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
