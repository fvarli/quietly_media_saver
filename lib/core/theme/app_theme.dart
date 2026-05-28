// ─────────────────────────────────────────────────────────────
// Quietly — ThemeData builder
//
// Maps the design tokens (lib/core/theme/tokens/*) onto a Material 3
// [ThemeData]. This is the bridge between the handoff's design system and the
// Material widgets the app is built from.
//
// What lives where:
//   • ColorScheme / TextTheme / component themes → here (Material can hold them)
//   • warm "soft" tints, hairlines, custom shadows → AppColors / AppShadows,
//     read directly by bespoke widgets (Material has no slot for them)
//
// DARK-READY: only [buildLightTheme] exists this pass. The function is named to
// admit a future `buildDarkTheme()`; QuietlyApp already wires `themeMode` so
// adding dark later is additive. See docs/ARCHITECTURE.md.
//
// ACCESSIBILITY (HANDOFF §9): component themes set min interactive sizes ≥48dp;
// we never disable text scaling.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../a11y/a11y.dart';
import 'tokens/app_colors.dart';
import 'tokens/app_radius.dart';
import 'tokens/app_typography.dart';

/// Builds the light Quietly theme from design tokens.
ThemeData buildLightTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.accent,
    onPrimary: AppColors.onAccent,
    primaryContainer: AppColors.accentSoft,
    onPrimaryContainer: AppColors.accentInk,
    secondary: AppColors.accent,
    onSecondary: AppColors.onAccent,
    secondaryContainer: AppColors.accentSoft,
    onSecondaryContainer: AppColors.accentInk,
    error: AppColors.danger,
    onError: AppColors.onAccent,
    errorContainer: AppColors.dangerSoft,
    onErrorContainer: AppColors.danger,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    surfaceContainerLowest: AppColors.surface,
    surfaceContainerLow: AppColors.surface2,
    surfaceContainer: AppColors.bg,
    surfaceContainerHigh: AppColors.bgSunken,
    surfaceContainerHighest: AppColors.bgSunken,
    onSurfaceVariant: AppColors.sub,
    outline: AppColors.faint,
    outlineVariant: AppColors.hair,
    shadow: Color(0xFF1E1810),
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.bg,
    canvasColor: AppColors.bg,
    splashFactory: InkSparkle.splashFactory,
    textTheme: AppTypography.textTheme,
    // System font stack (`DS.font.sans`) — leave family null for platform default.
    fontFamily: null,
  );

  return base.copyWith(
    // ── App bar (maps to the prototype's TopBar look) ──────────
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.headline,
    ),

    // ── Cards ──────────────────────────────────────────────────
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.hair,
      thickness: 1,
      space: 1,
    ),

    // ── Bottom sheets (HANDOFF §E: rounded top, drag handle) ───
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: AppColors.hair,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      clipBehavior: Clip.antiAlias,
    ),

    // ── Buttons — all enforce ≥48dp targets (a11y) ─────────────
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        disabledBackgroundColor: AppColors.accentSoft2,
        disabledForegroundColor: AppColors.faintText,
        minimumSize: const Size(0, A11y.primaryButtonHeight),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brLg),
        textStyle: AppTypography.headline,
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        minimumSize: const Size(A11y.minTouchTarget, A11y.minTouchTarget),
        textStyle: AppTypography.headline,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.sub,
        backgroundColor: AppColors.surface,
        minimumSize: const Size(0, A11y.primaryButtonHeight),
        side: const BorderSide(color: AppColors.hair, width: 1.5),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brLg),
        textStyle: AppTypography.headline,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        // Audit fix: ≥48dp tap target (prototype used 40px).
        minimumSize: const Size(A11y.minTouchTarget, A11y.minTouchTarget),
        foregroundColor: AppColors.sub,
      ),
    ),

    // ── Toggles (Settings) ─────────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(AppColors.surface),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.accent
            : AppColors.hair,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),

    // Ensure Material's own min tap target guard is on.
    materialTapTargetSize: MaterialTapTargetSize.padded,
  );
}
