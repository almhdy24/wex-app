import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../design/colors.dart';
import '../../features/cart/cart_controller.dart';

/// AppBar cart action with a live item-count badge.
class CartButton extends ConsumerWidget {
  final Color? color;
  const CartButton({super.key, this.color});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartControllerProvider.notifier).totalItems;
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.shopping_cart_outlined, color: color),
          onPressed: () => context.push('/cart'),
        ),
        if (count > 0)
          PositionedDirectional(
            top: 6, end: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: const BoxDecoration(color: WexColors.danger, shape: BoxShape.circle),
              child: Text('$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ),
      ],
    );
  }
}
