import 'package:flutter/material.dart';

/// Semantic colours for the five status vocabularies the owner side renders:
/// bed, payment, complaint, visit request and property listing.
///
/// A [ThemeExtension] rather than a constants class so light and dark each get
/// their own values and screens keep reading everything from
/// `Theme.of(context)`. Without this, every screen that shows a status invents
/// its own green — and "paid" ends up a different colour from "available" for
/// no reason anyone can defend.
///
/// Each status is a [StatusPalette]: a `fill` for chip backgrounds and a
/// `content` for text and icons on top of it, so contrast is decided once here
/// instead of at each call site.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.positive,
    required this.warning,
    required this.danger,
    required this.neutral,
    required this.info,
  });

  /// Available, paid, resolved, published, accepted — the good outcome.
  final StatusPalette positive;

  /// Pending, on notice, in progress, draft — needs attention, not yet wrong.
  final StatusPalette warning;

  /// Overdue, declined, open complaint — actively bad.
  final StatusPalette danger;

  /// Occupied, ended, closed, unlisted — settled, not actionable.
  final StatusPalette neutral;

  /// Maintenance, completed visits — informational.
  final StatusPalette info;

  static const StatusColors light = StatusColors(
    positive: StatusPalette(fill: Color(0xFFD7F2E3), content: Color(0xFF0F6B47)),
    warning: StatusPalette(fill: Color(0xFFFDF0D5), content: Color(0xFF8A5A00)),
    danger: StatusPalette(fill: Color(0xFFFCE0E0), content: Color(0xFFB3261E)),
    neutral: StatusPalette(fill: Color(0xFFE7E9EC), content: Color(0xFF44474E)),
    info: StatusPalette(fill: Color(0xFFDCE7FB), content: Color(0xFF1B4F9C)),
  );

  /// Darker, desaturated fills so a chip does not glow on a dark surface, with
  /// light content for contrast.
  static const StatusColors dark = StatusColors(
    positive: StatusPalette(fill: Color(0xFF1B3D30), content: Color(0xFF7FDCB4)),
    warning: StatusPalette(fill: Color(0xFF413317), content: Color(0xFFF5C468)),
    danger: StatusPalette(fill: Color(0xFF4A2120), content: Color(0xFFF2B8B5)),
    neutral: StatusPalette(fill: Color(0xFF2E3135), content: Color(0xFFC5C7CB)),
    info: StatusPalette(fill: Color(0xFF1C2E4A), content: Color(0xFFA8C7FA)),
  );

  @override
  StatusColors copyWith({
    StatusPalette? positive,
    StatusPalette? warning,
    StatusPalette? danger,
    StatusPalette? neutral,
    StatusPalette? info,
  }) {
    return StatusColors(
      positive: positive ?? this.positive,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      neutral: neutral ?? this.neutral,
      info: info ?? this.info,
    );
  }

  @override
  StatusColors lerp(covariant StatusColors? other, double t) {
    if (other == null) return this;
    return StatusColors(
      positive: positive.lerp(other.positive, t),
      warning: warning.lerp(other.warning, t),
      danger: danger.lerp(other.danger, t),
      neutral: neutral.lerp(other.neutral, t),
      info: info.lerp(other.info, t),
    );
  }
}

/// A background and the colour that stays legible on top of it.
@immutable
class StatusPalette {
  const StatusPalette({required this.fill, required this.content});

  final Color fill;
  final Color content;

  StatusPalette lerp(StatusPalette other, double t) => StatusPalette(
        fill: Color.lerp(fill, other.fill, t) ?? fill,
        content: Color.lerp(content, other.content, t) ?? content,
      );
}

/// Reads the extension without the ceremony, and fails loudly rather than
/// silently rendering the wrong palette if it was never registered.
extension StatusColorsX on BuildContext {
  StatusColors get statusColors {
    final colors = Theme.of(this).extension<StatusColors>();
    assert(colors != null, 'StatusColors is missing from ThemeData.extensions');
    return colors ?? StatusColors.light;
  }
}
