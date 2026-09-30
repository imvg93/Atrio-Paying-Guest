import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_scaffold.dart';

/// **Tenants tab root** — screen T1 of the owner screen plan.
///
/// Becomes the tenant list: active / on-notice / past, searchable, each row
/// showing bed, rent and any dues. Scoped to the active property.
class OwnerTenantsScreen extends StatelessWidget {
  const OwnerTenantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonBody(
      description:
          'Everyone living in this property — their bed, rent, and where they '
          'are in the tenancy.',
      dependsOn: ['GET /owner/occupancies'],
    );
  }
}
