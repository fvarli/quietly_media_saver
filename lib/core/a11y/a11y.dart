// ─────────────────────────────────────────────────────────────
// Quietly — Accessibility foundations
//
// HANDOFF §9 calls out four a11y must-fixes for the first build pass:
//   1. Touch targets ≥ 48dp (prototype icon buttons were 40px).
//   2. Caption contrast (handled in tokens: AppColors.faintText).
//   3. Semantics labels on every actionable + media tile.
//   4. Dynamic type — never lock the platform text-scale factor.
//
// This file holds the numeric constants and small helpers; see
// [min_tap_target.dart] for the wrapper widget, and individual widgets for the
// Semantics they attach.
// ─────────────────────────────────────────────────────────────

abstract final class A11y {
  const A11y._();

  /// Minimum interactive touch-target size in logical pixels (Android/Material
  /// guidance). Matches Flutter's [kMinInteractiveDimension] but named here so
  /// the design intent is explicit at call sites.
  static const double minTouchTarget = 48;

  /// Primary CTA height from the design system (`Button size="lg"` = 56px).
  /// Still ≥ [minTouchTarget].
  static const double primaryButtonHeight = 56;

  /// Secondary/medium button height (`Button size="md"` = 48px).
  static const double mediumButtonHeight = 48;

  /// Upper bound we honor for text scaling in layout reasoning. We do NOT clamp
  /// the user's setting; this is only a hint for choosing flexible layouts.
  static const double maxReasonableTextScale = 1.6;
}
