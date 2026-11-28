import 'package:flutter/material.dart';
import '../core/design/colors.g.dart';
import '../core/design/typography.dart';
import '../core/format/money.dart';

/// Price with the amount in [style] (ink) and "ج.س" smaller and muted. Digits and sign are isolated.
class MoneyText extends StatelessWidget {
  final int value;
  final TextStyle style;
  final bool strike;
  final Color? color;
  const MoneyText(this.value, {super.key, this.style = WexText.priceM, this.strike = false, this.color});

  /// Large price (26/32).
  const MoneyText.large(this.value, {super.key, this.strike = false, this.color}) : style = WexText.priceL;

  @override
  Widget build(BuildContext context) {
    final amount = style.copyWith(
      color: color ?? style.color,
      decoration: strike ? TextDecoration.lineThrough : null,
      decorationColor: WexColors.muted,
    );
    final unit = amount.copyWith(
      fontSize: (style.fontSize ?? 16) * 0.75,
      fontWeight: FontWeight.w500,
      color: color ?? WexColors.muted,
      fontFeatures: const [],
    );
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: isolate('${value < 0 ? '−' : ''}${formatAmount(value)}'), style: amount),
        TextSpan(text: ' $currencyUnit', style: unit),
      ]),
      softWrap: false,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
