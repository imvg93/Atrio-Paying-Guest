import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_scaffold.dart';

/// Screen 12 — the owner's inbox: accept, decline, or mark completed.
class OwnerVisitRequestsScreen extends StatelessWidget {
  const OwnerVisitRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScaffold(
      title: 'Visit requests',
      description:
          'Incoming requests across your properties, filterable by status, '
          'with accept / decline / mark-completed actions.',
      dependsOn: [
        'GET /owner/visit-requests?status=',
        'PATCH /owner/visit-requests/:id',
      ],
    );
  }
}
