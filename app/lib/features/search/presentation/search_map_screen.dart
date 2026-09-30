import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_scaffold.dart';

/// Screen 6 — map view of the same result set.
///
/// Needs a maps SDK and API key, neither chosen yet, plus the backend's
/// distance-sort strategy (MIGRATION_PLAN.md 8.9 — PostGIS is not installed).
class SearchMapScreen extends StatelessWidget {
  const SearchMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScaffold(
      title: 'Map',
      description:
          'The same search results plotted on a map, with a toggle back to '
          'the list.',
      dependsOn: [
        'GET /properties/search?lat=&lng=&radius_km=',
        'a maps SDK + key (not yet chosen)',
      ],
    );
  }
}
