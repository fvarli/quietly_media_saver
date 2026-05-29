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

import '../../services/permissions/permission_service_provider.dart';
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

  /// Retry analysis after a network/edge error → back to Analyzing (replaces
  /// the error screen). No real analysis yet (simulated on AnalyzingScreen).
  void retryAnalysis() {
    _notifier.paste();
    context.pushReplacementNamed(AppRoutes.analyzing);
  }

  /// Retry a failed download → re-enter Download with the last requested kinds
  /// (replaces the error screen). No real downloader yet (simulated).
  void retryDownload() {
    final kinds = ref.read(appStateProvider).lastSaved;
    _notifier.startDownload(kinds);
    context.pushReplacementNamed(AppRoutes.downloading);
  }

  // ── Sheets ────────────────────────────────────────────────
  Future<void> openQualitySheet() => showQualitySheet(context, ref);

  // ── Save / permission / download ──────────────────────────
  /// Request a save. If gallery permission is already granted, begin the
  /// (simulated) download. Otherwise show the priming sheet and, on "Allow",
  /// make the REAL OS permission request via [PermissionService], record the
  /// result, and branch: granted → download; permanentlyDenied → the
  /// "gallery access is off" error; denied → stay (the user can try again).
  ///
  /// Platform I/O lives here, not in the notifier. Navigation runs on [context]
  /// (the screen), guarded across awaits with `context.mounted`.
  Future<void> requestSave(List<MediaKind> kinds) async {
    _notifier.requestSave(kinds); // record lastSaved / pendingSave
    if (ref.read(appStateProvider).permissionGranted) {
      startDownload(kinds);
      return;
    }

    final allowed = await showPermissionSheet(context, ref);
    if (allowed != true || !context.mounted) return;

    final result = await ref
        .read(permissionServiceProvider)
        .requestGalleryPermission();
    _notifier.setPermissionStatus(result);
    if (!context.mounted) return;

    switch (result) {
      case PermissionStatus.granted:
        startDownload(kinds);
      case PermissionStatus.permanentlyDenied:
        showError(AppErrorKind.permissionDeniedPermanently);
      case PermissionStatus.denied:
        break; // stay on the current screen; the user can try again
    }
  }

  /// Open the OS app-settings page (permanently-denied recovery).
  Future<void> openSystemSettings() =>
      ref.read(permissionServiceProvider).openSystemSettings();

  /// Query the real permission status and record it (e.g. when Settings opens).
  Future<void> refreshPermissionStatus() async {
    final status = await ref.read(permissionServiceProvider).galleryStatus();
    _notifier.setPermissionStatus(status);
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
