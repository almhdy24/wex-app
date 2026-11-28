import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../design/colors.dart';
import '../../features/cart/cart_controller.dart';

/// AppBar cart action with a live item-count badge that bounces when the count changes.
class CartButton extends ConsumerWidget {
  final Color? color;
  const CartButton({super.key, this.color});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref
        .watch(cartControllerProvider)
        .fold<int>(0, (s, i) => s + i.quantity);
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'السلة',
          icon: Icon(Icons.shopping_bag_outlined, color: color),
          onPressed: () => context.push('/cart'),
        ),
        PositionedDirectional(
          top: -1,
          end: -3,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.elasticOut,
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: count == 0
                ? const SizedBox.shrink(key: ValueKey('empty'))
                : Container(
                    key: ValueKey(count),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    constraints:
                        const BoxConstraints(minWidth: 18, minHeight: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: WexColors.danger,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: Colors.white, width: 1.5)),
                    child: Text('$count',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800)),
                  ),
          ),
        ),
      ],
    );
  }
}
