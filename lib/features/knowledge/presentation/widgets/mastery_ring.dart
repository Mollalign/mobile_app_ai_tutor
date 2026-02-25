import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Circular progress ring showing mastery percentage.
class MasteryRing extends StatelessWidget {
  final double mastery;
  final double size;
  final double strokeWidth;

  const MasteryRing({
    super.key,
    required this.mastery,
    this.size = 64,
    this.strokeWidth = 6,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final color = _colorForMastery(mastery, colorScheme);
    final percentage = (mastery * 100).round();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: mastery,
              color: color,
              backgroundColor:
                  colorScheme.onSurfaceVariant.withAlpha(30),
              strokeWidth: strokeWidth,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percentage%',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _colorForMastery(double mastery, ColorScheme cs) {
    if (mastery >= 0.8) return Colors.green;
    if (mastery >= 0.5) return Colors.orange;
    if (mastery > 0) return cs.tertiary;
    return cs.onSurfaceVariant.withAlpha(100);
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}
