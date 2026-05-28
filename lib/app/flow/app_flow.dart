// ─────────────────────────────────────────────────────────────
// Quietly — Flow coordinator
//
// The bridge between user intents, the AppState machine, and go_router. Each
// method pairs a state transition (AppStateNotifier) with the matching
// navigation, so AppState.screen and the router never drift (see app_state.dart
// "separation of concerns").
//
// NAVIGATION SEMANTICS (real back-stack, HANDOFF §6):
//   • go*    → reset the stack to a top-level destination (Home).
//   • push   → add a destination so Back returns to the previous one.
//   • pushReplacement → swap the current destination (e.g. analyzing → result),
//     so Back skips transient steps and returns to Home.
// This yields a sane stack, e.g. Home → Result → History → Back → Result.
//
// Screens construct an [AppFlow] with their BuildContext + WidgetRef and call
// these instead of touching the router or notifier directly.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_state_provider.dart';
import '../../state/models/app_enums.dart';
import '../router/app_routes.dart';
import '../router/sheets.dart';

/// Coordinates one screen's navigation + state transitions.
class AppFlow {
  AppFlow(this.context, this.ref);

  final BuildContext context;
  final WidgetRef ref;

  AppStateNotifier get _notifier => ref.read(appStateProvider.notifier);

  // ── Top-level destinations ────────────────────────────────
  /// Return to Home, resetting the navigation stack.
  void goHome() {
    _notifier.setScreen(AppScreen.home);
    context.goNamed(AppRoutes.home);
  }

  void openHistory() {
    _notifier.setScreen(AppScreen.history);
    context.pushNamed(AppRoutes.history);
  }

  void openSettings() {
    _notifier.setScreen(AppScreen.settings);
    context.pushNamed(AppRoutes.settings);
  }

  // ── Core wizard flow ──────────────────────────────────────
  /// Paste a link → analyzing (HANDOFF happy path).
  void paste() {
    _notifier.paste();
    context.pushNamed(AppRoutes.analyzing);
  }

  /// Analysis finished → result (replaces analyzing so Back skips it).
  void showResult() {
    _notifier.onAnalyzed();
    context.pushReplacementNamed(AppRoutes.result);
  }

  /// Open the multi-select carousel screen.
  void openCarousel() {
    _notifier.setScreen(AppScreen.carousel);
    context.pushNamed(AppRoutes.carousel);
  }

  /// Show an error/edge state (replaces the current transient screen).
  void showError(AppErrorKind kind) {
    _notifier.showError(kind);
    context.pushReplacementNamed(AppRoutes.error);
  }

  // ── Sheets ────────────────────────────────────────────────
  Future<void> openQualitySheet() => showQualitySheet(context, ref);

  // ── Save / permission / download ──────────────────────────
  /// Request a save. If permission is still required, present the permission
  /// sheet and only proceed when the user allows it; otherwise begin the
  /// (placeholder) download flow immediately. Navigation runs on [context]
  /// (the screen), which stays valid after the sheet is dismissed.
  Future<void> requestSave(List<MediaKind> kinds) async {
    final needsPermission = _notifier.requestSave(kinds);
    if (!needsPermission) {
      startDownload(kinds);
      return;
    }
    final allowed = await showPermissionSheet(context, ref);
    if (allowed == true && context.mounted) {
      _notifier.grantPermission();
      startDownload(kinds);
    }
    // Declined / dismissed → stay on the current screen (no-op).
  }

  /// Enter the download screen (replaces result/carousel).
  void startDownload(List<MediaKind> kinds) {
    _notifier.startDownload(kinds);
    context.pushReplacementNamed(AppRoutes.downloading);
  }

  /// Download finished → success (replaces the download screen).
  void finishDownload() {
    _notifier.finishDownload();
    context.pushReplacementNamed(AppRoutes.success);
  }
}
