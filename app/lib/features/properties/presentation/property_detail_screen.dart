import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_scaffold.dart';

/// Screen 7 — photo carousel, rooms and pricing, amenities, rules, map
/// preview, and the "Request a visit" call to action.
class PropertyDetailScreen extends StatelessWidget {
  const PropertyDetailScreen({super.key, required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context) {
    return ComingSoonScaffold(
      title: 'Property',
      description:
          'Full detail for property $propertyId: photos, rooms grouped by '
          'sharing type with rent and availability, amenities and rules.',
      dependsOn: const ['GET /properties/:id'],
    );
  }
}
