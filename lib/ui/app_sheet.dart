import 'package:flutter/material.dart';
import '../core/design/colors.g.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';
import 'elevation.dart';
import 'icons.dart';

/// Bottom sheet scaffold: handle, title + close, scrollable content, bottom inset.
Future<T?> showAppSheet<T>(BuildContext context, {required String title, required WidgetBuilder builder, double maxHeightFactor = 0.9}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: WexColors.surface,
      barrierColor: WexColors.ink900.withValues(alpha: 0.4),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * maxHeightFactor),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheetTop))),
      builder: (ctx) => DecoratedBox(
        decoration: const BoxDecoration(
          color: WexColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheetTop)),
          boxShadow: Elev.float,
        ),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: WexColors.line, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(children: [
                Expanded(child: Text(title, style: WexText.titleM)),
                IconButton(tooltip: 'إغلاق', onPressed: () => Navigator.of(ctx).pop(), icon: const Icon(LucideIcons.x, size: 22)),
              ]),
            ),
            Flexible(child: builder(ctx)),
          ]),
        ),
      ),
    );
