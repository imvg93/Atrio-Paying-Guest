import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_scaffold.dart';

/// Screen 11 — rooms list, add/edit room (which auto-creates beds), and the
/// bed status grid.
class PropertyManageScreen extends StatelessWidget {
  const PropertyManageScreen({super.key, required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context) {
    return ComingSoonScaffold(
      title: 'Rooms & beds',
      description:
          'Manage rooms for property $propertyId. Creating a room '
          'auto-creates its beds from the sharing type; tap a bed to toggle '
          'available / maintenance.',
      dependsOn: const [
        'POST /owner/properties/:id/rooms',
        'PATCH /owner/rooms/:id',
        'DELETE /owner/rooms/:id',
        'PATCH /owner/beds/:id',
      ],
    );
  }
}
