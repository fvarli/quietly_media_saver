// ─────────────────────────────────────────────────────────────
// Quietly — Modal sheet presentation
//
// HANDOFF §E: bottom sheets are shown via showModalBottomSheet (rounded top,
// drag handle, spring curve) rather than as full routes. This file is the
// single presentation point for the two sheets (quality, permission) and keeps
// AppState.sheet in sync: openSheet() before showing, closeSheet() when the
// sheet is dismissed by any means (drag, scrim tap, action).
//
// The shape/handle come from the theme's bottomSheetTheme (app_theme.dart).
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/sheets/acceptable_use_sheet.dart';
import '../../features/sheets/permission_sheet.dart';
import '../../features/sheets/quality_sheet.dart';
import '../../state/app_state_provider.dart';
import '../../state/models/app_enums.dart';

/// Shared options matching the design (spring transition, ≤ ~88% height,
/// rounded top via theme). [isScrollControlled] lets tall sheets size to content.
Future<T?> _showQuietlySheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: const Color(0x57190E08), // ≈ rgba(28,22,14,0.34) scrim
    builder: builder,
  );
}

/// Opens the quality picker sheet (HANDOFF screen 5) and keeps state in sync.
Future<void> showQualitySheet(BuildContext context, WidgetRef ref) async {
  ref.read(appStateProvider.notifier).openSheet(AppSheet.quality);
  await _showQuietlySheet(context, builder: (_) => const QualitySheet());
  ref.read(appStateProvider.notifier).closeSheet();
}

/// Shows the one-time, non-dismissible acceptable-use gate over Home and records
/// the acknowledgement (persisted via the bootstrap write-through). No back / no
/// scrim-tap / no drag — the single "I understand" button is the only exit.
Future<void> showAcceptableUseSheet(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    useSafeArea: true,
    barrierColor: const Color(0x57190E08),
    builder: (_) => const AcceptableUseSheet(),
  );
  ref.read(appStateProvider.notifier).setFirstRunAcknowledged(true);
}

/// Opens the gallery-permission request sheet (HANDOFF screen 11) and returns
/// whether the user allowed access (`true`), declined (`false`), or dismissed
/// it (`null`). The caller decides what to do next so navigation runs on the
/// underlying screen's context, not the sheet's.
Future<bool?> showPermissionSheet(BuildContext context, WidgetRef ref) async {
  ref.read(appStateProvider.notifier).openSheet(AppSheet.permission);
  final allowed = await _showQuietlySheet<bool>(
    context,
    builder: (_) => const PermissionSheet(),
  );
  ref.read(appStateProvider.notifier).closeSheet();
  return allowed;
}
