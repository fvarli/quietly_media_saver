// ─────────────────────────────────────────────────────────────
// Quietly — QDots
//
// Three gently pulsing "thinking" dots (design `Dots`), used beside the
// Analyzing title. Decorative — excluded from semantics. Uses a repeating
// AnimationController; screens hosting it should avoid `pumpAndSettle` in tests
// (use explicit `pump(Duration)` instead).
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../theme/tokens/app_colors.dart';

class QDots extends StatefulWidget {
  const QDots({super.key, this.color = AppColors.accent, this.dotSize = 7});

  final Color color;
  final double dotSize;

  @override
  State<QDots> createState() => _QDotsState();
}

class _QDotsState extends State<QDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              // Staggered pulse: each dot leads the next by ~0.16 of the cycle.
              final phase = (_controller.value - i * 0.16) % 1.0;
              final t = (phase < 0.4) ? (phase / 0.4) : 0.0;
              final opacity = 0.25 + 0.75 * t;
              return Padding(
                padding: EdgeInsets.only(right: i == 2 ? 0 : 4),
                child: Opacity(
                  opacity: opacity.clamp(0.25, 1.0),
                  child: Container(
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
