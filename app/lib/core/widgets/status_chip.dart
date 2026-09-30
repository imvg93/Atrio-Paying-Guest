import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/status_colors.dart';

/// Which semantic palette a status draws from.
///
/// Named after the *meaning*, not the colour, so "published" and "paid" stay
/// the same green forever without either screen knowing what green is.
enum StatusTone { positive, warning, danger, neutral, info }

extension StatusToneX on StatusTone {
  StatusPalette resolve(BuildContext context) {
    final colors = context.statusColors;
    return switch (this) {
      StatusTone.positive => colors.positive,
      StatusTone.warning => colors.warning,
      StatusTone.danger => colors.danger,
      StatusTone.neutral => colors.neutral,
      StatusTone.info => colors.info,
    };
  }
}

/// A small status pill: the one way this app renders a state.
///
/// Deliberately not Material's [Chip], which is built for input and selection
/// and brings padding, a tap target and an outline that all have to be undone.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
    this.compact = false,
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;

  /// Tighter, for use inside a dense card.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = tone.resolve(context);
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : 10,
        vertical: compact ? 2 : 5,
      ),
      decoration: BoxDecoration(
        color: palette.fill,
        borderRadius: AppRadius.chip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 12 : 14, color: palette.content),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: (compact ? theme.textTheme.labelSmall : theme.textTheme.labelMedium)
                ?.copyWith(color: palette.content),
          ),
        ],
      ),
    );
  }
}
