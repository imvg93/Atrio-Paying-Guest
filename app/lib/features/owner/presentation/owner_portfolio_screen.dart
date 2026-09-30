import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/paginated.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/state_views.dart';
import '../../properties/data/models/property.dart';
import '../application/owner_properties_controller.dart';
import 'widgets/property_card.dart';

/// H1 — the owner's portfolio, and the Home tab's root.
///
/// Every property, newest first, with the two figures an owner opens the app
/// for: how full each one is and what it earns. Filter chips narrow by listing
/// status; the list pages in as it is scrolled.
class OwnerPortfolioScreen extends ConsumerStatefulWidget {
  const OwnerPortfolioScreen({super.key});

  @override
  ConsumerState<OwnerPortfolioScreen> createState() =>
      _OwnerPortfolioScreenState();
}

class _OwnerPortfolioScreenState extends ConsumerState<OwnerPortfolioScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Fetches the next page while there is still a screenful left to scroll, so
  /// the list never actually reaches its bottom while more exists.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      ref.read(ownerPropertiesProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ownerPropertiesProvider);
    final controller = ref.read(ownerPropertiesProvider.notifier);

    return Scaffold(
      // Extended over the list, because a bare + on a screen whose whole point
      // is "you have no properties yet" reads as a puzzle.
      floatingActionButton: state.value?.isEmpty ?? true
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.ownerPropertyNew),
              icon: const Icon(Icons.add),
              label: const Text('Add property'),
            ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: state.when(
          // A spinner only on the very first load. A refresh or a filter change
          // keeps the list on screen and lets the indicator carry the news —
          // replacing content the user is looking at with a spinner is the
          // single most common way a good list screen feels cheap.
          loading: () => state.hasValue
              ? _list(context, state.value!, isStale: true)
              : const _PortfolioSkeleton(),
          error: (error, _) => ListView(
            // Must scroll, or RefreshIndicator has nothing to pull on.
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
              AppErrorView(error: error, onRetry: controller.refresh),
            ],
          ),
          data: (page) => _list(context, page),
        ),
      ),
    );
  }

  Widget _list(
    BuildContext context,
    Paginated<PropertySummary> page, {
    bool isStale = false,
  }) {
    final filter = ref.read(ownerPropertiesProvider.notifier).statusFilter;

    // Nothing at all, and no filter hiding it: this is a new owner, so the
    // screen becomes an invitation rather than an empty list.
    if (page.isEmpty && filter == null) {
      return const _EmptyPortfolio();
    }

    return AnimatedOpacity(
      opacity: isStale ? 0.6 : 1,
      duration: AppMotion.fast,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _StatusFilterBar(
              selected: filter,
              onChanged: (value) => ref
                  .read(ownerPropertiesProvider.notifier)
                  .setStatusFilter(value),
            ),
          ),

          if (page.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppEmptyView(
                icon: Icons.filter_alt_off_outlined,
                title: 'Nothing matches this filter',
                message: 'No ${filter!.label.toLowerCase()} properties yet.',
                action: TextButton(
                  onPressed: () => ref
                      .read(ownerPropertiesProvider.notifier)
                      .setStatusFilter(null),
                  child: const Text('Show all'),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                // Clears the extended FAB, which would otherwise sit on the
                // last card's rent figure.
                96,
              ),
              sliver: SliverList.separated(
                itemCount: page.items.length + (page.hasMore ? 1 : 0),
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  if (index >= page.items.length) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final property = page.items[index];
                  return FadeSlideIn(
                    // Keyed by id so a refresh reuses the state rather than
                    // replaying the entrance for cards that never left.
                    key: ValueKey(property.id),
                    index: index,
                    child: PropertyCard(
                      property: property,
                      onTap: () => context.push(
                        AppRoutes.ownerPropertyOverviewFor(property.id),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Status filter chips. Horizontal because a fourth option (archived) is
/// plausible and a wrapping row would reflow the whole bar when it lands.
class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({required this.selected, required this.onChanged});

  final PropertyStatus? selected;
  final ValueChanged<PropertyStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          _chip(context, label: 'All', value: null),
          for (final status in PropertyStatus.values)
            _chip(context, label: status.label, value: status),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required PropertyStatus? value,
  }) {
    final isSelected = selected == value;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Center(
        child: FilterChip(
          label: Text(label),
          selected: isSelected,
          // Tapping the active chip clears it, which is what everyone tries.
          onSelected: (_) => onChanged(isSelected ? null : value),
          showCheckmark: false,
          avatar: isSelected
              ? Icon(
                  Icons.check,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                )
              : null,
        ),
      ),
    );
  }
}

/// First-run state. The only screen an owner sees before they have anything,
/// so it carries the pitch and the single next action.
class _EmptyPortfolio extends StatelessWidget {
  const _EmptyPortfolio();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.06),
        Center(
          child: FadeSlideIn(
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondaryContainer,
              ),
              child: Icon(
                Icons.apartment_rounded,
                size: 52,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FadeSlideIn(
          index: 1,
          child: Text(
            'List your first PG',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FadeSlideIn(
          index: 2,
          child: Text(
            'Add the building once, then rooms and beds. '
            'Students find you as soon as you publish.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        for (final (index, step) in const [
          (Icons.edit_location_alt_outlined, 'Add the building and its address'),
          (Icons.meeting_room_outlined, 'Set up rooms and beds'),
          (Icons.rocket_launch_outlined, 'Publish and start getting enquiries'),
        ].indexed)
          FadeSlideIn(
            index: 3 + index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: Icon(step.$1, size: 17),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(step.$2, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        FadeSlideIn(
          index: 6,
          child: FilledButton.icon(
            onPressed: () => context.push(AppRoutes.ownerPropertyNew),
            icon: const Icon(Icons.add),
            label: const Text('Add your first property'),
          ),
        ),
      ],
    );
  }
}

/// Shaped placeholders during the first load.
///
/// Cards rather than a centred spinner: the layout that is about to arrive is
/// already implied, so nothing jumps when the data lands.
class _PortfolioSkeleton extends StatelessWidget {
  const _PortfolioSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, index) => _ShimmerCard(index: index),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard({required this.index});

  final int index;

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Offset per card so the three do not pulse in lockstep, which reads as
        // a broken screen rather than a loading one.
        final t = (_controller.value + widget.index * 0.18) % 1;
        final color = Color.lerp(base, base.withValues(alpha: 0.45), t)!;

        Widget bar(double width, double height) => Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: AppRadius.chip,
              ),
            );

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 132, color: color),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bar(160, 16),
                    const SizedBox(height: AppSpacing.sm),
                    bar(110, 12),
                    const SizedBox(height: AppSpacing.md),
                    bar(double.infinity, 6),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
