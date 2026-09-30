import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/widgets/coming_soon_scaffold.dart';

/// Screen 5 — student home. Search bar, filter sheet, result cards.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComingSoonScaffold(
      title: 'Find a PG',
      showBack: false,
      description:
          'Search by locality, budget, sharing type and amenities, with '
          'results as cards showing photo, rent and distance.',
      dependsOn: const [
        'GET /properties/search',
        'GET /meta/amenities',
      ],
      actions: [
        IconButton(
          tooltip: 'Map view',
          icon: const Icon(Icons.map_outlined),
          onPressed: () => context.push(AppRoutes.searchMap),
        ),
        IconButton(
          tooltip: 'My visits',
          icon: const Icon(Icons.event_outlined),
          onPressed: () => context.push(AppRoutes.myVisits),
        ),
        IconButton(
          tooltip: 'Profile',
          icon: const Icon(Icons.person_outline),
          onPressed: () => context.push(AppRoutes.profile),
        ),
      ],
    );
  }
}
