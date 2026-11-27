import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../design/colors.dart';

/// Modern bottom nav: a soft floating bar with an animated indicator pill behind
/// the active tab, filled/outlined icon swap, RTL-aware.
class WexScaffoldShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const WexScaffoldShell({super.key, required this.shell});

  static const _tabs = [
    (icon: Icons.home_outlined, active: Icons.home_rounded, label: 'الرئيسية'),
    (icon: Icons.grid_view_outlined, active: Icons.grid_view_rounded, label: 'المتجر'),
    (icon: Icons.receipt_long_outlined, active: Icons.receipt_long_rounded, label: 'طلباتي'),
    (icon: Icons.person_outline_rounded, active: Icons.person_rounded, label: 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    final current = shell.currentIndex;
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: WexColors.white,
          border: Border(top: BorderSide(color: WexColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: _Tab(
                      data: _tabs[i],
                      selected: current == i,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        shell.goBranch(i, initialLocation: i == current);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final ({IconData icon, IconData active, String label}) data;
  final bool selected;
  final VoidCallback onTap;
  const _Tab({required this.data, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 48,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
            decoration: BoxDecoration(
              color: selected ? WexColors.primary.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(selected ? data.active : data.icon,
                color: selected ? WexColors.primary : WexColors.textSecondary, size: 24),
          ),
          const SizedBox(height: 3),
          Text(data.label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? WexColors.primary : WexColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              )),
        ],
      ),
    );
  }
}
