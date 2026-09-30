import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/status_colors.dart';
import '../../../properties/data/models/property.dart';

/// The occupancy ring on the property overview (H2).
///
/// A ring rather than a bar because this is the screen's single headline
/// figure: it earns the space, and the arc reads as "how full am I" at a
/// glance in a way a percentage never does.
///
/// Three arcs, in the same order as the bed statuses they represent — occupied,
/// then maintenance, then the remaining track as available. Drawing maintenance
/// as a separate slice rather than folding it into "not occupied" matters: a
/// bed under repair is not revenue waiting to happen, and an owner who cannot
/// see the difference will chase the wrong number.
class OccupancyRing extends StatelessWidget {
  const OccupancyRing({
    super.key,
    required this.occupancy,
    this.size = 148,
    this.strokeWidth = 14,
  });

  final OccupancySummary occupancy;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = context.statusColors;
    final total = occupancy.totalBeds;

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        // Keyed on the value so a refresh animates from where it was, not from
        // zero — a pull-to-refresh that resets the ring looks like data loss.
        tween: Tween<double>(begin: 0, end: 1),
        duration: AppMotion.slow,
        curve: AppMotion.enter,
        builder: (context, t, _) {
          return CustomPaint(
            painter: _RingPainter(
              occupiedFraction: total == 0 ? 0 : occupancy.occupiedBeds / total,
              maintenanceFraction:
                  total == 0 ? 0 : occupancy.maintenanceBeds / total,
              progress: t,
              strokeWidth: strokeWidth,
              occupiedColor: status.neutral.content,
              maintenanceColor: status.info.content,
              trackColor: total == 0
                  ? theme.colorScheme.surfaceContainerHighest
                  : status.positive.fill,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (total == 0)
                    Text(
                      'No beds',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else ...[
                    // Counts up with the arc rather than snapping to the final
                    // number while the ring is still drawing.
                    Text(
                      '${(occupancy.occupancyRate * 100 * t).round()}%',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        // Tabular figures stop the number jittering sideways as
                        // it counts up.
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      'occupied',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.occupiedFraction,
    required this.maintenanceFraction,
    required this.progress,
    required this.strokeWidth,
    required this.occupiedColor,
    required this.maintenanceColor,
    required this.trackColor,
  });

  final double occupiedFraction;
  final double maintenanceFraction;
  final double progress;
  final double strokeWidth;
  final Color occupiedColor;
  final Color maintenanceColor;
  final Color trackColor;

  static const double _startAngle = -math.pi / 2; // twelve o'clock
  static const double _fullTurn = math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final bounds = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // The full circle underneath is the available capacity; the occupied and
    // maintenance arcs are painted over it.
    canvas.drawCircle(center, radius, paint..color = trackColor);

    final occupiedSweep = _fullTurn * occupiedFraction * progress;
    final maintenanceSweep = _fullTurn * maintenanceFraction * progress;

    if (maintenanceSweep > 0) {
      // Drawn first so the occupied arc's rounded cap sits on top of it rather
      // than being clipped by it.
      canvas.drawArc(
        bounds,
        _startAngle + occupiedSweep,
        maintenanceSweep,
        false,
        paint..color = maintenanceColor,
      );
    }
    if (occupiedSweep > 0) {
      canvas.drawArc(
        bounds,
        _startAngle,
        occupiedSweep,
        false,
        paint..color = occupiedColor,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.occupiedFraction != occupiedFraction ||
      old.maintenanceFraction != maintenanceFraction ||
      old.occupiedColor != occupiedColor ||
      old.maintenanceColor != maintenanceColor ||
      old.trackColor != trackColor;
}

/// The compact form, for a portfolio card where the ring would be too much.
///
/// Same three segments and the same colours as [OccupancyRing], so the card and
/// the screen it opens are obviously showing the same thing.
class OccupancyBar extends StatelessWidget {
  const OccupancyBar({
    super.key,
    required this.occupancy,
    this.height = 6,
  });

  final OccupancySummary occupancy;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = context.statusColors;
    final total = occupancy.totalBeds;

    if (total == 0) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(height),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: AppMotion.slow,
          curve: AppMotion.enter,
          builder: (context, t, _) => Row(
            children: [
              Expanded(
                flex: (occupancy.occupiedBeds * 1000 * t).round(),
                child: ColoredBox(color: status.neutral.content),
              ),
              Expanded(
                flex: (occupancy.maintenanceBeds * 1000 * t).round(),
                child: ColoredBox(color: status.info.content),
              ),
              Expanded(
                // Takes up the slack as the other two grow, so the bar is
                // always full width and only the split animates.
                flex: (total * 1000 -
                        (occupancy.occupiedBeds + occupancy.maintenanceBeds) *
                            1000 *
                            t)
                    .round(),
                child: ColoredBox(color: status.positive.fill),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The legend beneath a ring or bar. Only shows segments that exist, so a
/// property with nothing under maintenance does not carry a dead key.
class OccupancyLegend extends StatelessWidget {
  const OccupancyLegend({super.key, required this.occupancy});

  final OccupancySummary occupancy;

  @override
  Widget build(BuildContext context) {
    final status = context.statusColors;

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        _LegendDot(
          color: status.neutral.content,
          label: 'Occupied',
          count: occupancy.occupiedBeds,
        ),
        _LegendDot(
          color: status.positive.content,
          label: 'Available',
          count: occupancy.availableBeds,
        ),
        if (occupancy.maintenanceBeds > 0)
          _LegendDot(
            color: status.info.content,
            label: 'Maintenance',
            count: occupancy.maintenanceBeds,
          ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    required this.count,
  });

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text('$count $label', style: theme.textTheme.bodySmall),
      ],
    );
  }
}
