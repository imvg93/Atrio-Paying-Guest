import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/state_views.dart';
import '../../meta/data/amenity.dart';
import '../../meta/data/amenity_repository.dart';
import '../../properties/data/models/property.dart';
import '../../properties/presentation/widgets/property_status_chip.dart';
import '../application/owner_properties_controller.dart';
import 'widgets/occupancy_ring.dart';
import 'widgets/property_card.dart';
import 'widgets/property_cover.dart';
import 'widgets/stat_tile.dart';

/// H2 — one property's overview, and the hub every other owner screen for that
/// property is reached from.
///
/// Answers "how is this PG doing" above the fold: the occupancy ring, free beds
/// and rent range, then the actions that change those numbers.
class PropertyOverviewScreen extends ConsumerWidget {
  const PropertyOverviewScreen({super.key, required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final property = ref.watch(ownerPropertyProvider(propertyId));

    return Scaffold(
      body: property.when(
        loading: () => const _OverviewLoading(),
        error: (error, _) => Scaffold(
          appBar: AppBar(),
          body: AppErrorView(
            error: error,
            onRetry: () => ref.invalidate(ownerPropertyProvider(propertyId)),
          ),
        ),
        data: (property) => _Overview(property: property),
      ),
    );
  }
}

class _Overview extends ConsumerWidget {
  const _Overview({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final occupancy = property.occupancy;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(ownerPropertyProvider(property.id));
        await ref.read(ownerPropertyProvider(property.id).future);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _CoverHeader(property: property),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Above the occupancy ring on purpose. For a draft the ring
                  // reads 0% and means nothing yet, while publishing is the one
                  // action that matters — burying it under a full screen of
                  // stats put the primary call to action below the fold on a
                  // small phone.
                  if (property.status == PropertyStatus.draft)
                    FadeSlideIn(child: _PublishPrompt(property: property)),

                  // --- the headline figure ---------------------------
                  FadeSlideIn(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: AppRadius.card,
                      ),
                      child: Column(
                        children: [
                          OccupancyRing(occupancy: occupancy),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            occupancy.hasNoBeds
                                ? 'No rooms added yet'
                                : occupancy.filledLabel,
                            style: theme.textTheme.titleMedium,
                          ),
                          if (!occupancy.hasNoBeds) ...[
                            const SizedBox(height: AppSpacing.md),
                            OccupancyLegend(occupancy: occupancy),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // --- the numbers underneath -------------------------
                  FadeSlideIn(
                    index: 1,
                    child: Row(
                      children: [
                        Expanded(
                          child: StatTile(
                            value: '${occupancy.availableBeds}',
                            label: 'Beds free',
                            icon: Icons.bed_outlined,
                            tint: context.statusColors.positive.content,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: StatTile(
                            value: property.hasRentRange
                                ? Money.range(
                                    property.minRentPaise,
                                    property.maxRentPaise,
                                  )
                                : '—',
                            label: 'Rent per bed',
                            icon: Icons.currency_rupee,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- actions ------------------------------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: QuickActionBar(
                actions: [
                  QuickAction(
                    icon: Icons.meeting_room_outlined,
                    label: 'Rooms',
                    onTap: () => _laterWave(context, 'Rooms and beds'),
                  ),
                  QuickAction(
                    icon: Icons.photo_library_outlined,
                    label: 'Photos',
                    onTap: () => _laterWave(context, 'Photo management'),
                  ),
                  QuickAction(
                    icon: Icons.mark_email_unread_outlined,
                    label: 'Enquiries',
                    onTap: () => _laterWave(context, 'The enquiry inbox'),
                  ),
                  QuickAction(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    onTap: () => context.push(
                      AppRoutes.ownerPropertyEditFor(property.id),
                    ),
                  ),
                  QuickAction(
                    icon: Icons.tune,
                    label: 'Settings',
                    onTap: () => context.push(
                      AppRoutes.ownerPropertySettingsFor(property.id),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- the rest -----------------------------------------------
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            sliver: SliverList.list(
              children: [
                if (property.description != null) ...[
                  const _SectionTitle('About'),
                  Text(
                    property.description!,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                const _SectionTitle('Address'),
                _AddressBlock(property: property),
                const SizedBox(height: AppSpacing.lg),
                _AmenitiesSection(property: property),
                if (property.rules != null && property.rules!.isNotEmpty) ...[
                  const _SectionTitle('House rules'),
                  _RulesBlock(rules: property.rules!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _laterWave(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what arrives in the next wave.')),
    );
  }
}

/// The collapsing photo header. Receives the Hero from the portfolio card, so
/// the cover grows into place rather than the screen cutting.
class _CoverHeader extends ConsumerWidget {
  const _CoverHeader({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      // The title only appears once the image has scrolled away, so it is never
      // competing with the name burned into the header.
      title: Text(property.name),
      actions: [
        IconButton(
          tooltip: 'Property settings',
          icon: const Icon(Icons.tune),
          onPressed: () => context.push(
            AppRoutes.ownerPropertySettingsFor(property.id),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: PropertyCard.heroTagFor(property.id),
              child: PropertyCover(
                propertyId: property.id,
                name: property.name,
                url: property.coverPhoto?.url,
                height: 220,
              ),
            ),
            // Keeps the white text and the back arrow legible over any photo.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent, Colors.black87],
                  stops: [0, 0.45, 1],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  PropertyStatusChip(status: property.status),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    property.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${property.shortAddress} · ${property.genderType.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
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

/// The one thing a draft property needs: a way to go live.
class _PublishPrompt extends ConsumerStatefulWidget {
  const _PublishPrompt({required this.property});

  final Property property;

  @override
  ConsumerState<_PublishPrompt> createState() => _PublishPromptState();
}

class _PublishPromptState extends ConsumerState<_PublishPrompt> {
  bool _busy = false;

  Future<void> _publish() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(ownerPropertiesProvider.notifier)
          .updateStatus(widget.property.id, PropertyStatus.published);
      ref.invalidate(ownerPropertyProvider(widget.property.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Published. Students can find it now.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppErrorView.messageFor(error))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = context.statusColors;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: status.warning.fill,
        borderRadius: AppRadius.card,
      ),
      // The button sits on its own line rather than beside the text. Sharing a
      // row left it fighting the copy for width on a narrow phone: the theme
      // stretches buttons to full width, so the message wrapped to three lines
      // and the label was squeezed to nothing.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.rocket_launch_outlined, color: status.warning.content),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This property is a draft',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: status.warning.content),
                    ),
                    Text(
                      'Publish it to start receiving enquiries.',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: status.warning.content),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              backgroundColor: status.warning.content,
              foregroundColor: status.warning.fill,
            ),
            onPressed: _busy ? null : _publish,
            icon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.publish, size: 18),
            label: Text(_busy ? 'Publishing...' : 'Publish now'),
          ),
        ],
      ),
    );
  }
}

class _AddressBlock extends StatelessWidget {
  const _AddressBlock({required this.property});

  final Property property;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.place_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.addressLine, style: theme.textTheme.bodyMedium),
                Text(
                  '${property.locality}, ${property.city}\n'
                  '${property.state} ${property.pincode}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  // Shown because the pin is the one field an owner cannot
                  // check by reading it back — seeing the coordinates at least
                  // reveals a pin left in the wrong city.
                  '${property.latitude.toStringAsFixed(5)}, '
                  '${property.longitude.toStringAsFixed(5)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Amenities, labelled from the server catalogue rather than from raw keys.
///
/// Falls back to the key itself while the catalogue is loading or if it fails:
/// "wifi" is a worse label than "Wi-Fi" but far better than an empty section.
class _AmenitiesSection extends ConsumerWidget {
  const _AmenitiesSection({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = property.activeAmenities;
    if (active.isEmpty) return const SizedBox.shrink();

    final catalogue = ref.watch(amenityCatalogueProvider).value;
    final labels = <String, String>{
      for (final amenity in catalogue ?? const <Amenity>[])
        amenity.key: amenity.label,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Amenities'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final key in active)
              Chip(
                label: Text(labels[key] ?? key),
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _RulesBlock extends StatelessWidget {
  const _RulesBlock({required this.rules});

  final Map<String, dynamic> rules;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        children: [
          for (final entry in rules.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      // Rules are open-ended JSONB, so keys arrive in whatever
                      // shape they were written in. Humanised rather than shown
                      // raw, since there is no catalogue to look them up in.
                      _humanise(entry.key),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    _describe(entry.value),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _humanise(String key) {
    final spaced = key
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .replaceAll('_', ' ');
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  static String _describe(Object? value) => switch (value) {
        true => 'Yes',
        false => 'No',
        null => '—',
        _ => value.toString(),
      };
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _OverviewLoading extends StatelessWidget {
  const _OverviewLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
