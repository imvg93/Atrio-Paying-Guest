import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_scaffold.dart';

/// Screen 8a — date, slot and an optional message.
class VisitRequestFormScreen extends StatelessWidget {
  const VisitRequestFormScreen({super.key, required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context) {
    return ComingSoonScaffold(
      title: 'Request a visit',
      description:
          'Pick a preferred date and slot (morning / afternoon / evening) '
          'and optionally add a message for the owner.',
      dependsOn: const ['POST /visit-requests'],
    );
  }
}
