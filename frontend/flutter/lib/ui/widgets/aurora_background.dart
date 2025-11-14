import 'dart:math' as math;

import 'package:flutter/material.dart';

class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 22))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value * 2 * math.pi;
          final alignment1 = Alignment(math.sin(t) * 0.8, math.cos(t) * 0.8);
          final alignment2 = Alignment(math.cos(t * 0.7) * 0.8, math.sin(t * 0.9) * 0.8);
          final alignment3 = Alignment(math.sin(t * 1.3) * 0.8, math.cos(t * 1.1) * 0.8);

          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: alignment1,
                end: alignment2,
                colors: [
                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.08),
                  theme.colorScheme.primary.withValues(alpha: 0.18),
                  theme.colorScheme.secondary.withValues(alpha: 0.12),
                ],
              ),
            ),
            child: Stack(
              children: [
                _AuroraBlob(
                  alignment: alignment1,
                  color: theme.colorScheme.primary.withValues(alpha: 0.55),
                  radius: 320,
                ),
                _AuroraBlob(
                  alignment: alignment2,
                  color: theme.colorScheme.secondary.withValues(alpha: 0.45),
                  radius: 280,
                ),
                _AuroraBlob(
                  alignment: alignment3,
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.35),
                  radius: 260,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.02),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AuroraBlob extends StatelessWidget {
  const _AuroraBlob({required this.alignment, required this.color, required this.radius});

  final Alignment alignment;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}
