// ─────────────────────────────────────────────────────────────
// Quietly — Motion tokens
//
// Source: docs/design-handoff/app/ds.jsx (`DS.motion`).
//   ease   = cubic-bezier(0.22, 0.61, 0.36, 1)   // decelerate
//   spring = cubic-bezier(0.34, 1.3,  0.5,  1)    // gentle overshoot
//   durations fast/base/slow = 180/260/380 ms
//
// HANDOFF §5: CSS keyframes/transitions map to Flutter implicit animations
// (AnimatedContainer/AnimatedOpacity/TweenAnimationBuilder) + these curves.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/animation.dart';

abstract final class AppMotion {
  const AppMotion._();

  // Durations.
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 380);

  /// Decelerate curve for entrances and standard transitions.
  static const Cubic ease = Cubic(0.22, 0.61, 0.36, 1);

  /// Gentle-overshoot spring for sheets, selection checks, success pop.
  static const Cubic spring = Cubic(0.34, 1.3, 0.5, 1);
}
