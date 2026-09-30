import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Placeholder body for a screen whose backend endpoints do not exist yet.
///
/// Split from [ComingSoonScaffold] so it can also fill a tab inside the owner
/// shell, where the shell already supplies the Scaffold and app bar and a
/// second one would double the chrome.
class ComingSoonBody extends StatelessWidget {
  const ComingSoonBody({
    super.key,
    required this.description,
    required this.dependsOn,
  });

  final String description;

  /// The API endpoints this screen is waiting on.
  final List<String> dependsOn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 56,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: AppRadius.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Waiting on',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...dependsOn.map(
                    (endpoint) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        endpoint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A full placeholder screen, for routes pushed outside the owner shell.
///
/// Every one of these corresponds to a screen in the owner screen plan and is
/// already wired into the router, so navigation and the role-based redirect can
/// be exercised end to end today. The body is replaced as each API lands.
class ComingSoonScaffold extends StatelessWidget {
  const ComingSoonScaffold({
    super.key,
    required this.title,
    required this.description,
    required this.dependsOn,
    this.actions,
    this.showBack = true,
  });

  final String title;
  final String description;
  final List<String> dependsOn;
  final List<Widget>? actions;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: showBack,
        actions: actions,
      ),
      body: ComingSoonBody(description: description, dependsOn: dependsOn),
    );
  }
}
