import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../application/active_property_provider.dart';
import '../application/owner_properties_controller.dart';
import 'widgets/property_switcher_sheet.dart';

/// The owner area's persistent chrome: one app bar and a four-tab bottom nav
/// wrapped around whichever branch is showing.
///
/// Tabs, rather than the dashboard-and-push stack this replaces, because the
/// owner side is heading for four distinct areas an owner moves between all day
/// — going back through a hub each time would be the wrong shape. Each branch
/// keeps its own navigator, so scroll position and half-filled forms survive a
/// tab switch.
///
/// Screens that deserve the full width — the property wizard, tenant
/// onboarding, enquiry detail — deliberately push onto the *root* navigator
/// instead, which slides them over this chrome.
class OwnerShell extends ConsumerWidget {
  const OwnerShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = <_OwnerTab>[
    _OwnerTab(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      title: 'My properties',
    ),
    _OwnerTab(
      label: 'Tenants',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      title: 'Tenants',
    ),
    _OwnerTab(
      label: 'Rent',
      icon: Icons.currency_rupee_outlined,
      selectedIcon: Icons.currency_rupee,
      title: 'Rent',
    ),
    _OwnerTab(
      label: 'More',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view,
      title: 'More',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = navigationShell.currentIndex;
    final tab = _tabs[index];
    final active = ref.watch(activePropertyProvider);
    final propertyCount = ref.watch(ownerPropertyCountProvider);

    // Home is the portfolio, so it keeps its own title. The other tabs are
    // scoped to one property and say which.
    final showsSwitcher = index != 0 && active != null;

    return Scaffold(
      appBar: AppBar(
        title: showsSwitcher
            ? _PropertySwitcher(
                name: active.name,
                // With a single property there is nothing to switch to, so the
                // control renders as a plain label.
                enabled: propertyCount > 1,
              )
            : Text(tab.title),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _notYet(context, 'Notifications'),
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppRoutes.profile),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: _onTap,
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.selectedIcon),
              label: t.label,
            ),
        ],
      ),
    );
  }

  void _onTap(int index) {
    // Tapping the tab you are already on pops that branch back to its root —
    // the behaviour every native tab bar has, and its absence is felt
    // immediately once branches have sub-routes.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _notYet(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what arrives in a later wave.')),
    );
  }
}

class _OwnerTab {
  const _OwnerTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.title,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  /// App-bar title when this tab is showing.
  final String title;
}

/// The active-property control in the app bar. Reads as a plain title when the
/// owner has only one property.
class _PropertySwitcher extends StatelessWidget {
  const _PropertySwitcher({required this.name, required this.enabled});

  final String name;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!enabled) {
      return Text(name, overflow: TextOverflow.ellipsis);
    }

    return InkWell(
      onTap: () => _openSwitcher(context),
      borderRadius: AppRadius.chip,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: theme.appBarTheme.titleTextStyle,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _openSwitcher(BuildContext context) => PropertySwitcherSheet.show(context);
}
