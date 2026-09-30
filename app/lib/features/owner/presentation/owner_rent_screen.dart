import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_scaffold.dart';

/// **Rent tab root** — screen R1 of the owner screen plan.
///
/// Becomes the collection dashboard: month selector, collected / pending /
/// overdue totals, and the per-tenant dues list.
///
/// Waits on the `payments` table, which CLAUDE.md holds for Phase 3 — this tab
/// is intentionally present and empty so the navigation shape is settled before
/// the money features land in it.
class OwnerRentScreen extends StatelessWidget {
  const OwnerRentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonBody(
      description:
          'Who has paid, who has not, and what is overdue — for the month you '
          'pick.',
      dependsOn: [
        'GET /owner/rent/summary',
        'GET /owner/rent/dues',
        'table: payments (Phase 3)',
      ],
    );
  }
}
