import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../design/colors.dart';
import '../strings.dart';
import '../../features/cart/cart_controller.dart';
import 'fly_to_cart.dart';

/// AppBar cart action. Registers itself as a fly-to-cart target; the count badge
/// sits at the corner (outside the glyph) and bounces whenever the count changes.
class CartButton extends ConsumerStatefulWidget {
  final Color? color;
  const CartButton({super.key, this.color});
  @override
  ConsumerState<CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends ConsumerState<CartButton> {
  final _iconKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    CartTargets.keys.add(_iconKey);
  }
  @override
  void dispose() {
    CartTargets.keys.remove(_iconKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(cartControllerProvider).fold<int>(0, (s, i) => s + i.quantity);
    return SizedBox(
      width: 48, height: 48,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          IconButton(
            tooltip: Ar.cart,
            icon: Icon(Icons.shopping_bag_outlined, key: _iconKey, color: widget.color),
            onPressed: () => context.push('/cart'),
          ),
          PositionedDirectional(
            top: 2, end: -2,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: Curves.elasticOut,
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: count == 0
                  ? const SizedBox.shrink(key: ValueKey('empty'))
                  : Container(
                      key: ValueKey(count),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: WexColors.danger, borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: Colors.white, width: 1.5)),
                      child: Text('$count',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
