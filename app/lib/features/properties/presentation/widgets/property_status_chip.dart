import 'package:flutter/material.dart';

import '../../../../core/widgets/status_chip.dart';
import '../../data/models/property.dart';

/// The listing-status vocabulary, mapped to a semantic tone once.
///
/// Every screen that shows whether a property is live reads this, so the answer
/// cannot drift between the portfolio card, the overview header and the
/// settings screen.
extension PropertyStatusTone on PropertyStatus {
  StatusTone get tone => switch (this) {
        // Live and visible to students — the outcome the owner is working
        // towards, so it gets the positive palette.
        PropertyStatus.published => StatusTone.positive,
        // Unfinished rather than wrong: it needs attention, it is not a fault.
        PropertyStatus.draft => StatusTone.warning,
        // A deliberate, settled choice. Nothing to act on.
        PropertyStatus.unlisted => StatusTone.neutral,
      };

  IconData get icon => switch (this) {
        PropertyStatus.published => Icons.visibility_outlined,
        PropertyStatus.draft => Icons.edit_note,
        PropertyStatus.unlisted => Icons.visibility_off_outlined,
      };

  /// What the state means, for the settings screen where the owner is choosing
  /// between them rather than just reading one.
  String get explanation => switch (this) {
        PropertyStatus.published =>
          'Visible in student search, once at least one bed is free.',
        PropertyStatus.draft =>
          'Only you can see this. Publish it when you are ready.',
        PropertyStatus.unlisted =>
          'Hidden from search, but your tenants and records stay intact.',
      };
}

class PropertyStatusChip extends StatelessWidget {
  const PropertyStatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  final PropertyStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return StatusChip(
      label: status.label,
      tone: status.tone,
      icon: status.icon,
      compact: compact,
    );
  }
}
