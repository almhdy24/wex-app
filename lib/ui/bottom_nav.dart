import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/design/colors.g.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';
import 'elevation.dart';
import 'icons.dart';

class NavItem {
  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

const navItems = [
  NavItem(LucideIcons.house, 'الرئيسية'),
  NavItem(LucideIcons.store, 'المتجر'),
  NavItem(LucideIcons.receipt, 'طلباتي'),
  NavItem(LucideIcons.user, 'حسابي'),
];

/// Custom bottom nav: 64px + safe inset, floating shadow, 3px teal bar on the top edge of the
/// active item (animated width), labels always visible. No Material NavigationBar, no pill.
class AppBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const AppBottomNav({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(color: WexColors.surface, boxShadow: Elev.float),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(children: [
              for (var i = 0; i < navItems.length; i++)
                Expanded(
                  child: _NavCell(
                    item: navItems[i],
                    active: i == index,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTap(i);
                    },
                  ),
                ),
            ]),
          ),
        ),
      );
}

class _NavCell extends StatelessWidget {
  final NavItem item;
  final bool active;
  final VoidCallback onTap;
  const _NavCell({required this.item, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? WexColors.ink900 : WexColors.muted;
    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      child: InkResponse(
        onTap: onTap,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        child: Stack(alignment: Alignment.topCenter, children: [
          AnimatedContainer(
            duration: Motion.base,
            curve: Curves.easeOutCubic,
            height: 3,
            width: active ? 32 : 0,
            decoration: const BoxDecoration(
              color: WexColors.teal600,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(3)),
            ),
          ),
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(item.icon, size: 24, color: color),
              const SizedBox(height: 2),
              Text(item.label,
                  maxLines: 1,
                  style: WexText.label.copyWith(fontSize: 12, color: color, fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
            ]),
          ),
        ]),
      ),
    );
  }
}
