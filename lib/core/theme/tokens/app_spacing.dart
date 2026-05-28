// ─────────────────────────────────────────────────────────────
// Quietly — Spacing tokens
//
// Source: docs/design-handoff/app/ds.jsx (`DS.space(n) => n * 4`).
// 4px base grid. Prefer [AppSpacing.space] for arbitrary multiples and the
// named steps for common values so spacing reads consistently across screens.
// ─────────────────────────────────────────────────────────────

abstract final class AppSpacing {
  const AppSpacing._();

  /// Base grid unit in logical pixels.
  static const double base = 4;

  /// `n` grid units → logical pixels (mirrors `DS.space(n)`).
  static double space(num n) => n * base;

  // Common named steps (multiples of [base]).
  static const double xs = base; // 4
  static const double sm = base * 2; // 8
  static const double md = base * 3; // 12
  static const double lg = base * 4; // 16
  static const double xl = base * 5; // 20
  static const double xxl = base * 6; // 24
}
