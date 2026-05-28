// ─────────────────────────────────────────────────────────────
// Quietly — Color tokens
//
// Source of truth: docs/design-handoff/app/ds.jsx (`DS.color`).
// Warm-neutral surfaces + a single indigo accent + status colors.
//
// These are raw palette values. Material's [ThemeData]/[ColorScheme] can only
// hold a subset of them, so this class is the canonical reference that the
// theme builder and individual widgets read from for the warm neutrals,
// "soft" accent tints, and hairline strokes Material has no slot for.
//
// DARK-READY: only the light palette is defined this pass (HANDOFF §8 notes
// the dark tokens were never specified — we do not invent them here). When
// dark ships, add a parallel `AppColorsDark` with the same field names and
// select between them in the theme builder. Do not hard-code hex in widgets;
// always read through this class so the swap stays a one-line change.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/widgets.dart';

/// Canonical Quietly color palette (light).
///
/// All values mirror `DS.color` in the design handoff, with one audit-mandated
/// correction: see [faintText] (HANDOFF §9 contrast fix).
abstract final class AppColors {
  const AppColors._();

  // ── Surfaces ──────────────────────────────────────────────
  /// Warm off-white app canvas (`DS.color.bg`).
  static const Color bg = Color(0xFFFAF8F4);

  /// Grouped/sunken section background (`DS.color.bgSunken`).
  static const Color bgSunken = Color(0xFFF4F1EB);

  /// Card / sheet surface (`DS.color.surface`).
  static const Color surface = Color(0xFFFFFFFF);

  /// Slightly tinted secondary surface (`DS.color.surface2`).
  static const Color surface2 = Color(0xFFFBFAF7);

  // ── Text / ink ────────────────────────────────────────────
  /// Near-black warm ink — primary text (`DS.color.ink`).
  static const Color ink = Color(0xFF211D18);

  /// Secondary text (`DS.color.sub`).
  static const Color sub = Color(0xFF6F685E);

  /// Tertiary / placeholder / decorative tint (`DS.color.faint`).
  ///
  /// NOTE: borderline for WCAG AA on small text. Use only for non-text
  /// decoration (dividers-as-color, dots, large glyphs). For small text use
  /// [faintText] instead.
  static const Color faint = Color(0xFFA39C92);

  /// Audit fix (HANDOFF §9): darker "faint" for captions/micro text so small
  /// text clears WCAG AA on the cream canvas. Use for any text ≤ ~13px that
  /// would otherwise have used [faint].
  static const Color faintText = Color(0xFF857E73);

  // ── Hairlines (alpha over canvas) ─────────────────────────
  /// Primary hairline stroke (`DS.color.hair` = rgba(0,0,0,0.07)).
  static const Color hair = Color(0x12000000); // ~7% black

  /// Lighter hairline (`DS.color.hair2` = rgba(0,0,0,0.045)).
  static const Color hair2 = Color(0x0B000000); // ~4.5% black

  // ── Accent (indigo) ───────────────────────────────────────
  /// Primary accent (`DS.color.accent`).
  static const Color accent = Color(0xFF4B53C4);

  /// Pressed accent (`DS.color.accentPress`).
  static const Color accentPress = Color(0xFF3A41A8);

  /// Soft accent tint — selected backgrounds (`DS.color.accentSoft`).
  static const Color accentSoft = Color(0xFFEEEFFB);

  /// Stronger soft accent (`DS.color.accentSoft2`).
  static const Color accentSoft2 = Color(0xFFE3E5F7);

  /// Accent ink — text on soft accent (`DS.color.accentInk`).
  static const Color accentInk = Color(0xFF2E348C);

  /// Text/icon color on a solid accent fill (`DS.color.onAccent`).
  static const Color onAccent = Color(0xFFFFFFFF);

  // ── Status ────────────────────────────────────────────────
  static const Color success = Color(0xFF2E9E6B);
  static const Color successSoft = Color(0xFFE3F4EC);
  static const Color warn = Color(0xFFC98A2B);
  static const Color warnSoft = Color(0xFFFAF0DE);
  static const Color danger = Color(0xFFC5503F);
  static const Color dangerSoft = Color(0xFFFBEAE6);
}
