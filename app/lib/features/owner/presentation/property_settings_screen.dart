import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../properties/data/models/property.dart';
import '../../properties/presentation/widgets/property_status_chip.dart';
import '../application/owner_properties_controller.dart';

/// H11 — listing status, notice period, and deleting the property.
///
/// The three settings that change what the outside world sees, kept away from
/// the wizard so that publishing is never something an owner does by accident
/// while editing an address.
class PropertySettingsScreen extends ConsumerWidget {
  const PropertySettingsScreen({super.key, required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ownerPropertyProvider(propertyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Property settings')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorView(
          error: error,
          onRetry: () => ref.invalidate(ownerPropertyProvider(propertyId)),
        ),
        data: (property) => _Settings(property: property),
      ),
    );
  }
}

class _Settings extends ConsumerStatefulWidget {
  const _Settings({required this.property});

  final Property property;

  @override
  ConsumerState<_Settings> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<_Settings> {
  bool _busy = false;

  Property get _property => widget.property;

  Future<void> _setStatus(PropertyStatus status) async {
    if (status == _property.status || _busy) return;

    // Unlisting is the one that has an effect the owner cannot see from here —
    // the listing disappears from search — so it asks first.
    if (status == PropertyStatus.unlisted) {
      final confirmed = await _confirm(
        title: 'Unlist this property?',
        body: 'It disappears from student search straight away. Your rooms, '
            'tenants and records are untouched, and you can publish it again '
            'at any time.',
        confirmLabel: 'Unlist',
      );
      if (!confirmed) return;
    }

    setState(() => _busy = true);
    try {
      await ref
          .read(ownerPropertiesProvider.notifier)
          .updateStatus(_property.id, status);
      ref.invalidate(ownerPropertyProvider(_property.id));
      HapticFeedback.lightImpact();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppErrorView.messageFor(error))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await _confirm(
      title: 'Delete ${_property.name}?',
      body: _property.occupancy.occupiedBeds > 0
          ? 'This property still has ${_property.occupancy.occupiedBeds} '
              'occupied bed(s). Deleting it removes the listing; tenant and '
              'payment history is kept.'
          : 'The listing is removed. Its history is kept, so nothing is lost '
              'permanently.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return;

    setState(() => _busy = true);
    try {
      await ref.read(ownerPropertiesProvider.notifier).delete(_property.id);
      if (!mounted) return;
      // Back to the portfolio, not to the overview of a property that is gone.
      context.go(AppRoutes.ownerHome);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_property.name} was deleted.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppErrorView.messageFor(error))),
      );
    }
  }

  Future<bool> _confirm({
    required String title,
    required String body,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final theme = Theme.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        FadeSlideIn(
          child: Row(
            children: [
              Expanded(
                child: Text(_property.name, style: theme.textTheme.titleMedium),
              ),
              PropertyStatusChip(status: _property.status),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        FadeSlideIn(
          index: 1,
          child: Text('Listing status', style: theme.textTheme.titleSmall),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final (index, status) in PropertyStatus.values.indexed)
          FadeSlideIn(
            index: 2 + index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _StatusOption(
                status: status,
                selected: _property.status == status,
                enabled: !_busy,
                onTap: () => _setStatus(status),
              ),
            ),
          ),

        const SizedBox(height: AppSpacing.lg),
        FadeSlideIn(
          index: 5,
          child: _NoticePeriodRow(
            days: _property.noticePeriodDays,
            onEdit: () =>
                context.push(AppRoutes.ownerPropertyEditFor(_property.id)),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
        FadeSlideIn(
          index: 6,
          child: _DangerZone(
            busy: _busy,
            onDelete: _delete,
          ),
        ),
      ],
    );
  }
}

/// One status choice, with what it actually means underneath it.
class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.status,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final PropertyStatus status;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = status.tone.resolve(context);

    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.6,
      duration: AppMotion.fast,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: AppRadius.card,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.standard,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected
                ? palette.fill
                : theme.colorScheme.surfaceContainerLow,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: selected ? palette.content : theme.colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                status.icon,
                color: selected ? palette.content : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: selected ? palette.content : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      status.explanation,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: selected ? palette.content : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.check_circle, color: palette.content),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NoticePeriodRow extends StatelessWidget {
  const _NoticePeriodRow({required this.days, required this.onEdit});

  final int days;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          Icon(Icons.event_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notice period', style: theme.textTheme.titleSmall),
                Text(
                  '$days days before a tenant leaves',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(onPressed: onEdit, child: const Text('Change')),
        ],
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone({required this.busy, required this.onDelete});

  final bool busy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final danger = context.statusColors.danger;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: AppRadius.card,
        border: Border.all(color: danger.content.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delete property',
            style: theme.textTheme.titleSmall?.copyWith(color: danger.content),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Removes the listing. Occupancy and payment history is kept, so '
            'this is reversible by support if you change your mind.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: busy ? null : onDelete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete this property'),
            style: OutlinedButton.styleFrom(
              foregroundColor: danger.content,
              side: BorderSide(color: danger.content.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}
