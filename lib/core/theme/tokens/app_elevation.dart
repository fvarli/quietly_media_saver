// ─────────────────────────────────────────────────────────────
// Quietly — Elevation / shadow tokens
//
// Source: docs/design-handoff/app/ds.jsx (`DS.shadow`).
// CSS box-shadows mapped to Flutter [BoxShadow] lists. Quietly uses soft, warm
// shadows (warm-black base) rather than Material's default elevation, so these
// are applied directly to containers/cards via [BoxDecoration.boxShadow].
// ─────────────────────────────────────────────────────────────

import 'package:flutter/widgets.dart';

abstract final class AppShadows {
  const AppShadows._();

  // Shadow color bases (alpha encoded per token below):
  //   warm   ≈ rgba(30,24,16,a)  → 0x..1E1810
  //   accent ≈ rgba(75,83,196,a) → 0x..4B53C4

  /// `DS.shadow.sm`
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0D1E1810), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A1E1810), blurRadius: 3, offset: Offset(0, 1)),
  ];

  /// `DS.shadow.md`
  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x121E1810), blurRadius: 14, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0D1E1810), blurRadius: 3, offset: Offset(0, 1)),
  ];

  /// `DS.shadow.lg`
  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x1F1E1810), blurRadius: 40, offset: Offset(0, 14)),
    BoxShadow(color: Color(0x0F1E1810), blurRadius: 12, offset: Offset(0, 4)),
  ];

  /// `DS.shadow.accent` — for the primary CTA's resting glow.
  static const List<BoxShadow> accent = [
    BoxShadow(color: Color(0x524B53C4), blurRadius: 22, offset: Offset(0, 8)),
  ];

  /// `DS.shadow.accentSm`
  static const List<BoxShadow> accentSm = [
    BoxShadow(color: Color(0x474B53C4), blurRadius: 12, offset: Offset(0, 4)),
  ];
}
