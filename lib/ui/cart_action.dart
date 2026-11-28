import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/design/colors.g.dart';
import '../core/design/typography.dart';
import '../core/widgets/fly_to_cart.dart';
import '../features/cart/cart_controller.dart';
import 'icons.dart';

/// Cart icon with the count badge anchored INSIDE the 48px icon box (never clipped by the screen
/// edge). The count bounces for 200ms when it changes. Registers as a fly-to-cart target.
class CartAction extends ConsumerStatefulWidget {
  const CartAction({super.key});
  @override
  ConsumerState<CartAction> createState() => _CartActionState();
}

class _CartActionState extends ConsumerState<CartAction> with SingleTickerProviderStateMixin {
  final _iconKey = GlobalKey();
  late final AnimationController _bounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  int _last = 0;

  @override
  void initState() {
    super.initState();
    CartTargets.keys.add(_iconKey);
  }

  @override
  void dispose() {
    CartTargets.keys.remove(_iconKey);
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(cartControllerProvider).fold<int>(0, (s, i) => s + i.quantity);
    if (count != _last) {
      _last = count;
      if (!MediaQuery.of(context).disableAnimations) _bounce.forward(from: 0);
    }
    return Semantics(
      button: true,
      label: count == 0 ? 'السلة' : 'السلة، $count منتجات',
      child: SizedBox(
        width: 48,
        height: 48,
        child: InkResponse(
          onTap: () => context.push('/cart'),
          radius: 24,
          child: Stack(alignment: Alignment.center, children: [
            Icon(LucideIcons.shoppingBag, key: _iconKey, size: 24, color: WexColors.ink900),
            if (count > 0)
              PositionedDirectional(
                top: 4,
                end: 2,
                child: ScaleTransition(
                  scale: Tween(begin: 1.0, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_bounce).drive(
                      TweenSequence([
                        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 1),
                        TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 1),
                      ])),
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: WexColors.teal600, borderRadius: BorderRadius.all(Radius.circular(9))),
                    child: Text('$count', style: WexText.label.copyWith(color: WexColors.surface, fontSize: 11, height: 1.2, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
