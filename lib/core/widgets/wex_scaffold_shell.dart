import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../design/colors.dart';

/// Bottom-tab shell: home / catalog / orders / account (RTL, animated active pill).
class WexScaffoldShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const WexScaffoldShell({super.key, required this.shell});

  static const _tabs = [
    (icon: Icons.home_rounded, label: 'الرئيسية'),
    (icon: Icons.storefront_rounded, label: 'المتجر'),
    (icon: Icons.receipt_long_rounded, label: 'طلباتي'),
    (icon: Icons.person_rounded, label: 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: WexColors.white,
          boxShadow: [BoxShadow(color: Color(0x14061A55), blurRadius: 16, offset: Offset(0, -4))],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: _TabButton(
                      icon: _tabs[i].icon,
                      label: _tabs[i].label,
                      selected: shell.currentIndex == i,
                      onTap: () => shell.goBranch(i, initialLocation: i == shell.currentIndex),
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

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? WexColors.royal : WexColors.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: selected ? 1.1 : 1.0,
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }
}
