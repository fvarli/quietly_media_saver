// ─────────────────────────────────────────────────────────────
// Quietly — Corner-radius tokens
//
// Source: docs/design-handoff/app/ds.jsx (`DS.radius`).
// Exposes both raw doubles and ready-made [BorderRadius] for convenience.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/widgets.dart';

abstract final class AppRadius {
  const AppRadius._();

  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 22;
  static const double xxl = 28;

  /// Fully rounded ("pill", `DS.radius.pill = 999`).
  static const double pill = 999;

  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius brXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(pill));

  /// Top-only rounding for bottom sheets (rounded top corners, square bottom).
  static const BorderRadius sheetTop = BorderRadius.only(
    topLeft: Radius.circular(xxl),
    topRight: Radius.circular(xxl),
  );
}
