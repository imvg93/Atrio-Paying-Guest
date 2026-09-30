import 'package:flutter/material.dart';

/// The app's motion vocabulary, in the same spirit as [AppSpacing] and
/// [AppRadius]: durations and curves live here so screens stop inventing their
/// own 300ms easeInOut.
///
/// Kept deliberately short. Motion that varies per screen reads as jitter
/// rather than polish — the whole point is that everything decelerates the same
/// way, so the app feels like one object.
///
/// Built on Flutter's own primitives (implicit animations, [Hero],
/// [CustomPainter]) rather than an animation package: nothing here needs a
/// dependency, and staying in the framework keeps every transition
/// interruptible and cheap.
class AppMotion {
  const AppMotion._();

  /// Chip selection, checkbox, small state flips.
  static const Duration fast = Duration(milliseconds: 150);

  /// The default. Card entrances, cross-fades, expanding panels.
  static const Duration medium = Duration(milliseconds: 280);

  /// Page-level moves and the occupancy ring drawing itself in.
  static const Duration slow = Duration(milliseconds: 520);

  /// Material 3's standard easing: quick to leave, gentle to arrive.
  static const Curve standard = Curves.easeOutCubic;

  /// For things that grow or slide in — slightly more deceleration, which
  /// reads as weight.
  static const Curve enter = Curves.easeOutQuart;

  /// Leaving the screen. Faster, because nobody wants to watch an exit.
  static const Curve exit = Curves.easeInCubic;

  /// Gap between consecutive list items in a staggered entrance.
  ///
  /// Small on purpose: at 60ms a ten-item list finishes in under a second, and
  /// anything slower turns scrolling into waiting.
  static const Duration stagger = Duration(milliseconds: 55);

  /// Items past this index skip the stagger and appear with the last one.
  ///
  /// Without a cap, the fortieth card of a long list would sit blank for two
  /// seconds — the effect that is meant to feel responsive becoming the reason
  /// the screen feels slow.
  static const int maxStaggered = 8;
}

/// Fades and lifts a child into place, optionally staggered by its position in
/// a list.
///
/// Runs once on first build and then stays out of the way — it holds no
/// controller after completing, so a long list does not accumulate tickers.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = AppMotion.medium,
    this.offset = 16,
    this.enabled = true,
  });

  final Widget child;

  /// Position in the list, for the stagger. Ignored past
  /// [AppMotion.maxStaggered].
  final int index;

  final Duration duration;

  /// How far below its final position the child starts, in logical pixels.
  final double offset;

  /// Set false to render immediately — for tests, or for a rebuild where the
  /// content was already on screen.
  final bool enabled;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();

    // Respect the platform's reduce-motion setting: an entrance animation is
    // decoration, and for someone who gets motion sick it is not a small one.
    if (!widget.enabled) {
      _controller.value = 1;
      return;
    }

    final delay = AppMotion.stagger *
        widget.index.clamp(0, AppMotion.maxStaggered);
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }

    final curved = CurvedAnimation(parent: _controller, curve: AppMotion.enter);

    return AnimatedBuilder(
      animation: curved,
      // The child is built once and reused across every frame, rather than
      // rebuilt sixty times a second.
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: curved.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - curved.value)),
          child: child,
        ),
      ),
    );
  }
}

/// Scales a child down while it is pressed. The tactile half of a tap.
///
/// Wraps rather than replaces the child's own gesture handling, so an [InkWell]
/// underneath still draws its ripple.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => _set(true),
      onTapUp: widget.onTap == null ? null : (_) => _set(false),
      onTapCancel: widget.onTap == null ? null : () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        child: widget.child,
      ),
    );
  }
}
