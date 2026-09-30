import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../properties/data/models/property.dart';
import '../../application/active_property_provider.dart';
import '../../application/owner_properties_controller.dart';
import 'property_cover.dart';

/// The sheet behind the app-bar property switcher.
///
/// Only reachable when the owner has more than one property — with one there is
/// nothing to switch to and the app bar renders a plain title instead.
///
/// Shows the loaded page rather than fetching its own list: the portfolio is
/// already in memory, and a second request here would make opening the switcher
/// slower than the screen it switches away from.
class PropertySwitcherSheet extends ConsumerWidget {
  const PropertySwitcherSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const PropertySwitcherSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(ownerPropertiesProvider);
    final active = ref.watch(activePropertyProvider);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Text('Switch property', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  if (state.hasValue)
                    Text(
                      '${state.value!.total} total',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            Flexible(
              child: state.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: AppErrorView(
                    error: error,
                    onRetry: () =>
                        ref.read(ownerPropertiesProvider.notifier).refresh(),
                  ),
                ),
                data: (page) => ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.lg,
                  ),
                  itemCount: page.items.length,
                  itemBuilder: (context, index) {
                    final property = page.items[index];
                    final isActive = active?.id == property.id;

                    return FadeSlideIn(
                      index: index,
                      offset: 8,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: InkWell(
                          borderRadius: AppRadius.card,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ref
                                .read(activePropertyProvider.notifier)
                                .select(ActivePropertySelection(
                                  id: property.id,
                                  name: property.name,
                                ));
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? theme.colorScheme.secondaryContainer
                                  : Colors.transparent,
                              borderRadius: AppRadius.card,
                            ),
                            child: Row(
                              children: [
                                PropertyCoverThumb(property: property),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        property.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleSmall,
                                      ),
                                      Text(
                                        property.occupancy.hasNoBeds
                                            ? property.shortAddress
                                            : property.occupancy.filledLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isActive)
                                  Icon(
                                    Icons.check_circle,
                                    color: theme.colorScheme.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Square cover thumbnail, sized for a list row.
class PropertyCoverThumb extends StatelessWidget {
  const PropertyCoverThumb({super.key, required this.property});

  final PropertySummary property;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: PropertyCover(
        propertyId: property.id,
        name: property.name,
        url: property.coverPhotoUrl,
        height: 48,
        borderRadius: AppRadius.chip,
      ),
    );
  }
}
