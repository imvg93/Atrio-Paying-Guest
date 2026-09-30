import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';

/// **More tab root** — screen M1 of the owner screen plan.
///
/// A real hub, not a placeholder: it is only a menu, so it can be finished now
/// and simply gains live destinations as each wave lands. Entries that are not
/// built yet say when they arrive rather than failing silently, which is the
/// difference between "not yet" and "broken".
class OwnerMoreScreen extends StatelessWidget {
  const OwnerMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: [
        const _SectionHeader('Running the PG'),
        _MoreTile(
          icon: Icons.build_outlined,
          title: 'Complaints',
          subtitle: 'Maintenance requests from your tenants',
          comingInWave: 4,
        ),
        _MoreTile(
          icon: Icons.insights_outlined,
          title: 'Reports',
          subtitle: 'Occupancy, revenue and collection rate',
          comingInWave: 6,
        ),
        _MoreTile(
          icon: Icons.receipt_long_outlined,
          title: 'Expenses',
          subtitle: 'What the property costs you',
          comingInWave: 6,
        ),
        const Divider(height: AppSpacing.lg),
        const _SectionHeader('Account'),
        _MoreTile(
          icon: Icons.badge_outlined,
          title: 'KYC verification',
          subtitle: 'Verify your identity to publish listings',
          comingInWave: 7,
        ),
        _MoreTile(
          icon: Icons.group_add_outlined,
          title: 'Managers & staff',
          subtitle: 'Give someone access to run a property',
          comingInWave: 7,
        ),
        _MoreTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'What you get told about, and how',
          comingInWave: 7,
        ),
        _MoreTile(
          icon: Icons.person_outline,
          title: 'Profile & settings',
          subtitle: 'Your name, email and sign-out',
          onTap: (context) => context.push(AppRoutes.profile),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.comingInWave,
  }) : assert(onTap != null || comingInWave != null,
            'a tile must either navigate somewhere or say when it will');

  final IconData icon;
  final String title;
  final String subtitle;
  final void Function(BuildContext context)? onTap;

  /// Set instead of [onTap] while the destination does not exist yet.
  final int? comingInWave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pending = onTap == null;

    return ListTile(
      leading: Icon(
        icon,
        color: pending ? theme.colorScheme.outline : theme.colorScheme.primary,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: pending
          ? Chip(
              label: Text('Wave $comingInWave'),
              labelStyle: theme.textTheme.labelSmall,
              visualDensity: VisualDensity.compact,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            )
          : const Icon(Icons.chevron_right),
      onTap: () {
        if (onTap != null) {
          onTap!(context);
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title arrives in wave $comingInWave.')),
        );
      },
    );
  }
}
