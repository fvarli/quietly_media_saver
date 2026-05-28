// ─────────────────────────────────────────────────────────────
// Quietly — Typography tokens
//
// Source: docs/design-handoff/app/ds.jsx + HANDOFF §C type scale:
//   Display 28/700 · Title 21/700 · Headline 17/650 · Body 15/400
//   Caption 13/500 · Micro 11.5 · Mono 12.5 (Roboto Mono)
//
// Sans = the platform system font (we let Flutter pick the platform default by
// leaving `fontFamily` null, matching `DS.font.sans`'s system stack).
// Mono = Roboto Mono for URLs / metadata (`DS.font.mono`).
//
// ACCESSIBILITY (HANDOFF §9): sizes here are logical and are scaled by the
// platform text-scale factor at render time — we never lock `textScaler`.
//
// FONT ASSET TODO: HANDOFF §5 requires bundling Roboto Mono as an asset. Until
// the .ttf is added under assets/fonts/ and wired in pubspec.yaml, [monoFamily]
// is left null so we fall back to the platform monospace via
// [monoFamilyFallback]; this keeps `flutter build`/`flutter test` green (no
// missing-asset error). Flip [monoFamily] to 'RobotoMono' once bundled.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  const AppTypography._();

  /// Set to `'RobotoMono'` once the font asset is bundled (see header TODO).
  static const String? monoFamily = null;

  /// Platform monospace fallbacks used for URL/metadata text.
  static const List<String> monoFamilyFallback = <String>[
    'RobotoMono',
    'Roboto Mono',
    'monospace',
  ];

  // Letter-spacing matching the prototype's tightened display/title text.
  static const double _tightDisplay = -0.7;
  static const double _tightTitle = -0.4;
  static const double _tightHeadline = -0.2;

  // ── Scale (HANDOFF §C) ────────────────────────────────────
  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: _tightDisplay,
    color: AppColors.ink,
  );

  static const TextStyle title = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: _tightTitle,
    color: AppColors.ink,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600, // 650 → nearest concrete weight
    height: 1.3,
    letterSpacing: _tightHeadline,
    color: AppColors.ink,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.ink,
  );

  /// Secondary body — same size, [AppColors.sub].
  static const TextStyle bodySub = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.sub,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.45,
    // Audit fix: caption uses the darker faint token for contrast.
    color: AppColors.faintText,
  );

  static const TextStyle micro = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: AppColors.faintText,
  );

  /// Monospace for URLs / file metadata.
  static const TextStyle mono = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    fontFamily: monoFamily,
    fontFamilyFallback: monoFamilyFallback,
    color: AppColors.sub,
  );

  // ── Material TextTheme mapping ────────────────────────────
  /// Maps the Quietly scale onto a Material [TextTheme] so default-styled
  /// Material widgets inherit sensible Quietly typography. Bespoke screens can
  /// still reference the named styles above directly.
  static const TextTheme textTheme = TextTheme(
    displaySmall: display,
    titleLarge: title,
    titleMedium: headline,
    bodyLarge: body,
    bodyMedium: bodySub,
    bodySmall: caption,
    labelSmall: micro,
  );
}
