import 'package:flutter/material.dart';
import '../core/design/colors.g.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';
import 'icons.dart';

/// Horizontal "− n +" stepper (36px visual, 44px hit targets). Always LTR so the minus is on the left.
class QtyStepper extends StatelessWidget {
  final int quantity;
  final int max;
  final VoidCallback onInc;
  final VoidCallback onDec;
  const QtyStepper({super.key, required this.quantity, required this.max, required this.onInc, required this.onDec});

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'الكمية $quantity',
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: WexColors.surface,
              borderRadius: BorderRadius.circular(Radii.control),
              border: Border.all(color: WexColors.line),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _btn(LucideIcons.minus, 'إنقاص الكمية', quantity > 1 ? onDec : null),
              SizedBox(
                width: 28,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 120),
                  child: Text('$quantity', key: ValueKey(quantity), textAlign: TextAlign.center, style: WexText.numeric),
                ),
              ),
              _btn(LucideIcons.plus, 'زيادة الكمية', quantity < max ? onInc : null),
            ]),
          ),
        ),
      );

  Widget _btn(IconData icon, String label, VoidCallback? onTap) => Semantics(
        button: true,
        label: label,
        child: InkResponse(
          onTap: onTap,
          radius: 22,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, size: 18, color: onTap == null ? WexColors.disabled : WexColors.ink900),
          ),
        ),
      );
}
