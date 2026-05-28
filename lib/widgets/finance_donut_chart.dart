import 'dart:math' as math;

import 'package:flutter/material.dart';

class DonutSegment {
  const DonutSegment({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color color;
}

class FinanceDonutChart extends StatelessWidget {
  const FinanceDonutChart({
    super.key,
    required this.segments,
    required this.totalLabel,
    this.size = 190,
  });

  final List<DonutSegment> segments;
  final String totalLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.square(size),
                painter: _DonutPainter(segments, value),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total', style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    totalLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text('100%', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.segments, this.progress);

  final List<DonutSegment> segments;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = size.width * 0.18;
    final total = segments.fold<double>(0, (sum, item) => sum + item.value);
    final bg = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect.deflate(stroke / 2),
      -math.pi / 2,
      math.pi * 2,
      false,
      bg,
    );
    if (total <= 0) return;
    var start = -math.pi / 2;
    for (final segment in segments) {
      final sweep = (segment.value / total) * math.pi * 2 * progress;
      final paint = Paint()
        ..shader = SweepGradient(
          colors: [segment.color.withValues(alpha: .8), segment.color],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect.deflate(stroke / 2),
        start,
        sweep - .035,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.segments != segments;
}
