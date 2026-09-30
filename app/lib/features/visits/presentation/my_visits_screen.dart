import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_scaffold.dart';

/// Screen 8b — the student's visit requests and their statuses.
class MyVisitsScreen extends StatelessWidget {
  const MyVisitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScaffold(
      title: 'My visits',
      description:
          'Every visit you have requested, with its status, and the option '
          'to cancel one that is still pending.',
      dependsOn: [
        'GET /me/visit-requests',
        'PATCH /me/visit-requests/:id/cancel',
      ],
    );
  }
}
