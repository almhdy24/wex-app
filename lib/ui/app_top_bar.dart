import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/design/colors.g.dart';
import '../core/design/typography.dart';
import 'icons.dart';

/// 56px top bar: title at the reading start, optional back, trailing actions.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBack;
  final List<Widget> actions;
  const AppTopBar({super.key, this.title, this.showBack = true, this.actions = const []});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Material(
      color: WexColors.paper,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Row(children: [
            if (showBack)
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  tooltip: 'رجوع',
                  icon: Icon(rtl ? LucideIcons.arrowRight : LucideIcons.arrowLeft, size: 24, color: WexColors.ink900),
                  onPressed: () => context.canPop() ? context.pop() : context.go('/'),
                ),
              )
            else
              const SizedBox(width: 16),
            Expanded(
              child: title == null
                  ? const SizedBox.shrink()
                  : Text(title!, maxLines: 1, overflow: TextOverflow.ellipsis, style: WexText.titleM),
            ),
            ...actions,
            const SizedBox(width: 4),
          ]),
        ),
      ),
    );
  }
}
