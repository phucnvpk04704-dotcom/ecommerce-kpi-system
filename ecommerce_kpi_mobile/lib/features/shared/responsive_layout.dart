import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponsiveLayout extends ConsumerWidget {
  final Widget child;
  final String title;

  const ResponsiveLayout({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isWebPreview = width >= 600;
    final theme = Theme.of(context);
    final String location = GoRouterState.of(context).uri.toString();

    // The exactly 5 core navigation tabs
    final displayItems = [
      const _NavigationItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard', route: '/dashboard'),
      const _NavigationItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Employees', route: '/employees'),
      const _NavigationItem(icon: Icons.assessment_outlined, activeIcon: Icons.assessment, label: 'KPI', route: '/kpi'),
      const _NavigationItem(icon: Icons.emoji_events_outlined, activeIcon: Icons.emoji_events, label: 'Rewards', route: '/rewards'),
      const _NavigationItem(icon: Icons.more_horiz_outlined, activeIcon: Icons.more_horiz, label: 'More', route: '/more'),
    ];

    // Determine active tab index
    int getSelectedIndex() {
      for (int i = 0; i < displayItems.length; i++) {
        if (location == displayItems[i].route || location.startsWith('${displayItems[i].route}/')) {
          return i;
        }
      }
      return -1; // Not in the main tabs (sub-page)
    }

    final int selectedIndex = getSelectedIndex();
    final bool isSubPage = selectedIndex == -1;

    Widget mainScaffold = Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        leading: isSubPage
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    // Fallback to more page or dashboard if context can't pop
                    if (location.startsWith('/employees/')) {
                      context.go('/employees');
                    } else {
                      context.go('/more');
                    }
                  }
                },
              )
            : null,
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: !isSubPage
          ? Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF330C14)
                        : const Color(0xFFF3E6E8),
                    width: 1,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: selectedIndex >= 0 ? selectedIndex : 0,
                onTap: (index) {
                  if (index != selectedIndex) {
                    context.go(displayItems[index].route);
                  }
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: theme.brightness == Brightness.dark
                    ? const Color(0xFF1D0308)
                    : Colors.white,
                selectedItemColor: theme.colorScheme.primary,
                unselectedItemColor: theme.brightness == Brightness.dark
                    ? const Color(0xFF8C7174)
                    : const Color(0xFFBCA2A5),
                selectedLabelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
                elevation: 0,
                items: displayItems.map((item) {
                  final bool isSelected = selectedIndex == displayItems.indexOf(item);
                  return BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Icon(isSelected ? item.activeIcon : item.icon),
                    ),
                    label: item.label,
                  );
                }).toList(),
              ),
            )
          : null,
    );

    if (isWebPreview) {
      // Center the layout and limit width to 480px on desktop web browsers
      return Scaffold(
        backgroundColor: theme.brightness == Brightness.dark
            ? const Color(0xFF0F0003)
            : const Color(0xFFF0E5E7),
        body: Center(
          child: Container(
            width: 480,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.5 : 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isWebPreview ? 24 : 0),
              child: mainScaffold,
            ),
          ),
        ),
      );
    }

    return mainScaffold;
  }
}

class _NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
