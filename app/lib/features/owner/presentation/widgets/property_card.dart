import 'package:flutter/material.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../properties/data/models/property.dart';
import '../../../properties/presentation/widgets/property_status_chip.dart';
import 'occupancy_ring.dart';
import 'property_cover.dart';

/// One property in the portfolio list (H1).
///
/// Reads top to bottom in the order an owner actually asks: what is it, is it
/// live, how full is it, what does it earn. The occupancy bar sits directly
/// under the name because "how full am I" is the question that brings them back
/// to this screen daily.
class PropertyCard extends StatelessWidget {
  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  final PropertySummary property;
  final VoidCallback onTap;

  /// Shared with the overview screen's header, so tapping a card grows its
  /// cover into the next screen instead of cutting to it.
  static String heroTagFor(String id) => 'property-cover-$id';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final occupancy = property.occupancy;

    return PressableScale(
      onTap: onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: heroTagFor(property.id),
                  child: PropertyCover(
                    propertyId: property.id,
                    name: property.name,
                    url: property.coverPhotoUrl,
                    height: 132,
                  ),
                ),
                // Status sits on the image, where the eye already is, rather
                // than competing with the name below it.
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: PropertyStatusChip(status: property.status),
                ),
                if (property.photoCount == 0)
                  Positioned(
                    bottom: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: const _GlassBadge(
                      icon: Icons.add_a_photo_outlined,
                      label: 'Add photos',
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          property.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          property.shortAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      const _Dot(),
                      Text(
                        property.genderType.label,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),
                  OccupancyBar(occupancy: occupancy),
                  const SizedBox(height: AppSpacing.sm),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          // "No rooms yet" is a nudge towards the next action,
                          // where "0/0 beds filled" would just look broken.
                          occupancy.hasNoBeds
                              ? 'No rooms added yet'
                              : occupancy.filledLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (property.hasRent)
                        Text(
                          Money.range(
                            property.minRentPaise,
                            property.maxRentPaise,
                          ),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A frosted pill that stays legible over any photo.
class _GlassBadge extends StatelessWidget {
  const _GlassBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        // Solid-ish black rather than a blur: a BackdropFilter here would cost a
        // saveLayer on every card in a scrolling list.
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: AppRadius.chip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
