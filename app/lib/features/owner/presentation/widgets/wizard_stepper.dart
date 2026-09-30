import 'package:flutter/material.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_theme.dart';

/// The progress header for a multi-step flow (H3 now, tenant onboarding in
/// Wave 3).
///
/// A continuous bar with a step label rather than a row of numbered circles:
/// five circles do not fit on a small phone without shrinking to the point of
/// being unreadable, and the owner only ever needs to know how far along they
/// are, not to navigate to step four directly.
class WizardStepper extends StatelessWidget {
  const WizardStepper({
    super.key,
    required this.step,
    required this.total,
    required this.title,
    this.subtitle,
  });

  /// Zero-based.
  final int step;
  final int total;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (step + 1) / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Step ${step + 1} of $total',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: AppMotion.medium,
              curve: AppMotion.standard,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Cross-fades between step titles so the header changes with the
          // page instead of snapping a frame ahead of it.
          AnimatedSwitcher(
            duration: AppMotion.medium,
            child: Column(
              key: ValueKey(step),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.headlineSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The Back / Next pair pinned to the bottom of a wizard.
///
/// Next is disabled rather than hidden when the step is incomplete — a button
/// that vanishes leaves the owner with nothing to aim at and no clue what is
/// missing, so the disabled state plus [hint] does the explaining.
class WizardNavBar extends StatelessWidget {
  const WizardNavBar({
    super.key,
    required this.onNext,
    this.onBack,
    this.nextLabel = 'Continue',
    this.hint,
    this.busy = false,
  });

  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final String nextLabel;

  /// Shown when [onNext] is null, saying what is still needed.
  final String? hint;

  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        // Clears the home indicator on gesture-nav devices.
        AppSpacing.md + MediaQuery.viewPaddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: AppMotion.fast,
            child: onNext == null && hint != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 15,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(hint!, style: theme.textTheme.bodySmall),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Row(
            children: [
              if (onBack != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy ? null : onBack,
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: busy ? null : onNext,
                  child: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(nextLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
