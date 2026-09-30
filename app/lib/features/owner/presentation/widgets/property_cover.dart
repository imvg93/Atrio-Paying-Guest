import 'package:flutter/material.dart';

import '../../../../core/theme/app_motion.dart';

/// The cover image for a property, with a designed fallback rather than a grey
/// box.
///
/// Photos are Wave 1's one missing piece — the upload endpoint waits on the
/// object-storage decision — so **every** property renders the fallback today.
/// That makes it the common case, not the edge case, and it is built
/// accordingly: a gradient derived from the property's own id, so two cards in
/// a list are always visually distinct and a given property keeps the same
/// colour every time the owner opens the app.
class PropertyCover extends StatelessWidget {
  const PropertyCover({
    super.key,
    required this.propertyId,
    required this.name,
    this.url,
    this.height,
    this.borderRadius,
  });

  final String propertyId;
  final String name;
  final String? url;
  final double? height;
  final BorderRadius? borderRadius;

  /// Deterministic per property: the same id always picks the same pair.
  ///
  /// Hues rather than fixed colours so the result stays inside the app's own
  /// palette range instead of landing on an arbitrary stock colour.
  static const _gradients = <List<Color>>[
    [Color(0xFF1E6F5C), Color(0xFF2E9E7E)],
    [Color(0xFF2A5C8A), Color(0xFF4E8FC4)],
    [Color(0xFF6B4A8F), Color(0xFF9B76C4)],
    [Color(0xFF8A5A2B), Color(0xFFC08A4E)],
    [Color(0xFF1F6470), Color(0xFF3E97A6)],
    [Color(0xFF7A3F55), Color(0xFFB06B85)],
  ];

  List<Color> get _gradient {
    // hashCode is not stable across runs for some types, but String.hashCode is
    // deterministic within a Dart process and the id itself never changes —
    // good enough for choosing a colour, and it costs no storage.
    final index = propertyId.codeUnits.fold<int>(0, (a, b) => a + b) %
        _gradients.length;
    return _gradients[index];
  }

  String get _initials {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.characters.first.toUpperCase();
    return (words.first.characters.first + words.elementAt(1).characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: url == null ? _fallback(context) : _photo(context),
      ),
    );
  }

  Widget _photo(BuildContext context) {
    return Image.network(
      url!,
      fit: BoxFit.cover,
      // Fades in instead of popping, and shows the gradient underneath while
      // the bytes are still arriving — so the card never flashes empty.
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedSwitcher(
          duration: AppMotion.medium,
          child: frame == null ? _fallback(context) : child,
        );
      },
      // A broken URL must not leave a hole in the layout.
      errorBuilder: (context, _, _) => _fallback(context),
    );
  }

  Widget _fallback(BuildContext context) {
    final colors = _gradient;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // A soft off-centre highlight, which stops a flat gradient reading as
          // a placeholder and makes it read as art direction.
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Center(
            child: Text(
              _initials,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: (height ?? 120) * 0.28,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
