import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.points, required this.color, this.strokeWidth = 2.8});

  final List<double> points;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(points: points, color: color, strokeWidth: strokeWidth),
      size: const Size(double.infinity, double.infinity),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.points, required this.color, required this.strokeWidth});

  final List<double> points;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }

    final minValue = points.reduce(math.min);
    final maxValue = points.reduce(math.max);
    final range = (maxValue - minValue).abs().clamp(0.0001, double.infinity);

    final dx = size.width / (points.length - 1);
    final path = Path();
    final area = Path();

    for (var i = 0; i < points.length; i++) {
      final x = dx * i;
      final normalized = (points[i] - minValue) / range;
      final y = size.height - (normalized * size.height);
      final point = Offset(x, y);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
        area.moveTo(point.dx, size.height);
        area.lineTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
        area.lineTo(point.dx, point.dy);
      }
    }
    area.lineTo(size.width, size.height);
    area.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1.0);

    canvas.drawPath(area, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return !listEquals(points, oldDelegate.points) ||
        color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}