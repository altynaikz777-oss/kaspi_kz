import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/kaspi_catalog.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _qrScannerRoute = '/qr/scan';

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _openQrScanner(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location == _qrScannerRoute) {
      return;
    }
    context.push(_qrScannerRoute);
  }

  @override
  Widget build(BuildContext context) {
    final current = navigationShell.currentIndex;
    final location = GoRouterState.of(context).uri.path;
    final qrFlowActive = location.startsWith('/qr');
    return Scaffold(
      backgroundColor: Colors.white,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE8EAED))),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                _NavItem(
                  label: 'Главная',
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  selected: current == 0 && !qrFlowActive,
                  onTap: () => _goBranch(0),
                ),
                _NavItem(
                  label: 'Kaspi QR',
                  icon: Icons.qr_code_2_outlined,
                  selectedIcon: Icons.qr_code_2_rounded,
                  selected: qrFlowActive,
                  onTap: () => _openQrScanner(context),
                ),
                _NavItem(
                  label: 'Сообщения',
                  icon: Icons.chat_bubble_outline_rounded,
                  selectedIcon: Icons.chat_bubble_rounded,
                  selected: current == 2 && !qrFlowActive,
                  onTap: () => _goBranch(2),
                ),
                _NavItem(
                  label: 'Сервисы',
                  icon: Icons.menu_rounded,
                  selectedIcon: Icons.menu_rounded,
                  selected: current == 3 && !qrFlowActive,
                  onTap: () => _goBranch(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? kaspiPrimary : const Color(0xFF9AA0A6);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, color: color, size: 26),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
