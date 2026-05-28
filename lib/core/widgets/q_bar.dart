// ─────────────────────────────────────────────────────────────
// Quietly — QBar
//
// Linear progress bar (design/primitives `Bar`): a rounded track with an accent
// fill. The companion to QRing, used for per-item progress in the multi-file
// download queue. Decorative — the enclosing row provides the semantic label
// (e.g. "clip_1.mp4, 40 percent").
//
// [progress] is 0..1. Drive it from an AnimationController for smooth motion.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../theme/tokens/app_colors.dart';

class QBar extends StatelessWidget {
  const QBar({
    super.key,
    required this.progress,
    this.height = 5,
    this.color = AppColors.accent,
    this.track = AppColors.bgSunken,
  });

  /// Progress in the range 0..1.
  final double progress;
  final double height;
  final Color color;
  final Color track;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height);
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: track)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0, 1),
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, borderRadius: radius),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
