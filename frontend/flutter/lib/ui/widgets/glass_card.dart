import 'dart:ui';

import 'package:flutter/material.dart';

class GlassCard extends StatefulWidget {
  const GlassCard({super.key, required this.child, this.gradient});

  final Widget child;
  final Gradient? gradient;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final isDark = theme.brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(28);

    final content = ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _hovered ? 1.0 : 0.8,
              duration: const Duration(milliseconds: 220),
              child: Container(
                decoration: BoxDecoration(
                  gradient: widget.gradient ??
                      LinearGradient(
                        colors: [
                          cardColor.withValues(alpha: 0.9),
                          cardColor.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: const SizedBox.expand(),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
            child: widget.child,
          ),
        ],
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()..translate(0.0, _hovered ? -6.0 : 0.0),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(
              alpha: _hovered ? (isDark ? 0.26 : 0.18) : (isDark ? 0.18 : 0.12),
            ),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: _hovered ? (isDark ? 0.36 : 0.18) : (isDark ? 0.26 : 0.12),
              ),
              blurRadius: _hovered ? 32 : 22,
              offset: const Offset(0, 18),
            ),
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: _hovered ? 0.14 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}
