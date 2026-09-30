import 'package:flutter/material.dart';

import 'status_colors.dart';

/// Single source of visual truth. Screens must not hardcode colours, text
/// styles, or corner radii — pull them from `Theme.of(context)`, [AppSpacing]
/// and [AppRadius].
class AppTheme {
  const AppTheme._();

  static const Color _seed = Color(0xFF1E6F5C);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    final text = _textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text,
      extensions: <ThemeExtension<dynamic>>[
        brightness == Brightness.dark ? StatusColors.dark : StatusColors.light,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: AppElevation.none,
        scrolledUnderElevation: AppElevation.raised,
        centerTitle: false,
        // Derived from the type scale rather than built as a bare TextStyle.
        // A fresh TextStyle carries no font family, so the app-bar title was
        // the one piece of text in the app not resolving to the platform font.
        titleTextStyle: text.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.field),
          // From the type scale, for the same reason as the app-bar title: a
          // bare TextStyle carries no font family.
          textStyle: text.labelLarge?.copyWith(fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.field),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: AppElevation.none,
        color: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.chip),
        side: BorderSide.none,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
        elevation: AppElevation.raised,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 68,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      ),
    );
  }

  /// One deliberate type scale, so screens stop reaching for `fontSize:`.
  ///
  /// Built from the Material 3 defaults rather than replacing them — only the
  /// sizes and weights this product actually uses are overridden, which keeps
  /// dynamic-type scaling and the platform font intact.
  static TextTheme _textTheme(ColorScheme scheme) {
    final base = ThemeData(brightness: scheme.brightness).textTheme;

    return base.copyWith(
      // Screen titles and section headers.
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      // Body copy.
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, height: 1.4),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, height: 1.4),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.35,
        color: scheme.onSurfaceVariant,
      ),
      // Chips, badges, tab labels.
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }
}

/// Corner radii. Previously 12 and 16 were retyped at every call site, which is
/// how two cards end up subtly different.
class AppRadius {
  const AppRadius._();

  static const Radius _xs = Radius.circular(8);
  static const Radius _sm = Radius.circular(12);
  static const Radius _md = Radius.circular(16);
  static const Radius _lg = Radius.circular(24);

  /// Chips, badges, small tags.
  static const BorderRadius chip = BorderRadius.all(_xs);

  /// Inputs and buttons.
  static const BorderRadius field = BorderRadius.all(_sm);

  /// Cards, tiles, grouped containers.
  static const BorderRadius card = BorderRadius.all(_md);

  /// Bottom sheets — top corners only.
  static const BorderRadius sheet =
      BorderRadius.only(topLeft: _lg, topRight: _lg);
}

/// The only elevations this app uses. Material 3 leans on tonal colour rather
/// than shadow, so the list is deliberately short.
class AppElevation {
  const AppElevation._();

  static const double none = 0;
  static const double raised = 1;
  static const double floating = 3;
}

/// Consistent spacing scale — avoids scattered magic numbers.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  static const EdgeInsets screen = EdgeInsets.all(md);
}
