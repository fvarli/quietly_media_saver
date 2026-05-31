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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/analysis/media_analysis_provider.dart';
import '../../services/clipboard/clipboard_service_provider.dart';
import '../../services/downloads/download_models.dart';
import '../../services/downloads/download_queue_provider.dart';
import '../../services/gallery/gallery_service.dart';
import '../../services/gallery/gallery_service_provider.dart';
import '../../services/permissions/permission_service_provider.dart';
import '../../state/app_state_provider.dart';
import '../../state/models/analysis_result.dart';
import '../../state/models/app_enums.dart';
import '../../state/models/history_entry.dart';
import '../router/app_routes.dart';
import '../router/sheets.dart';

/// Calm minimum duration the Analyzing screen shows before routing on the
/// service result (the outcome comes from the service, not this timer).
const Duration kMinAnalyzeDuration = Duration(milliseconds: 900);

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
  /// Read the clipboard and analyze a copied link. Empty clipboard → a calm
  /// prompt (no error screen); any non-empty text is submitted (a non-URL
  /// surfaces the `invalid` error via analysis).
  Future<void> pasteFromClipboard() async {
    final text = await ref.read(clipboardServiceProvider).readText();
    if (!context.mounted) return;
    final trimmed = text?.trim() ?? '';
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copy a public link, then tap Paste.')),
      );
      return;
    }
    submitUrl(trimmed);
  }

  /// Submit [url] for analysis → Analyzing screen (which runs [runAnalysis]).
  void submitUrl(String url) {
    _notifier
      ..setSubmittedUrl(url)
      ..paste();
    context.pushNamed(AppRoutes.analyzing);
  }

  /// Run the (sample) analysis with a calm minimum duration, then route on the
  /// service result: single → Result, carousel → Carousel; typed failures →
  /// the matching error screen. Offline short-circuits to the network error.
  Future<void> runAnalysis() async {
    final url = ref.read(appStateProvider).lastSubmittedUrl ?? '';
    await Future<void>.delayed(kMinAnalyzeDuration);
    if (!context.mounted) return;
    if (ref.read(appStateProvider).offline) {
      showError(AppErrorKind.network);
      return;
    }
    try {
      final result = await ref.read(mediaAnalysisServiceProvider).analyze(url);
      if (!context.mounted) return;
      _notifier.setAnalysis(result);
      if (result.isCarousel) {
        openCarousel();
      } else {
        showResult();
      }
    } on AnalysisException catch (e) {
      if (!context.mounted) return;
      showError(toAppErrorKind(e.kind));
    }
  }

  /// Analysis finished (single) → result (replaces analyzing so Back skips it).
  void showResult() {
    _notifier.onAnalyzed();
    context.pushReplacementNamed(AppRoutes.result);
  }

  /// Analysis finished (multi) → carousel (replaces analyzing).
  void openCarousel() {
    _notifier.setScreen(AppScreen.carousel);
    context.pushReplacementNamed(AppRoutes.carousel);
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

  Future<void> openLanguageSheet() => showLanguageSheet(context, ref);

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
    // Dedupe: re-saving the same analyzed link → "already saved".
    final key = _sourceKey();
    if (key != null && ref.read(appStateProvider).isAlreadySaved(key)) {
      showError(AppErrorKind.exists);
      return;
    }

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

  /// Enter the download screen (replaces result/carousel) and start the queue
  /// service. `notifier.startDownload` keeps the state-machine record
  /// (`lastSaved`, `screen`, requested `queue`) for retry; the live progress now
  /// comes from the download service.
  void startDownload(List<MediaKind> kinds) {
    _notifier.startDownload(kinds);
    // Pair each kind with the analyzed item's URL by index (best-effort; sample
    // URLs are null → the service uses its sample-bytes fallback).
    final items = ref.read(appStateProvider).analysis?.items;
    final requests = [
      for (var i = 0; i < kinds.length; i++)
        DownloadRequest(
          kinds[i],
          url: (items != null && i < items.length)
              ? items[i].downloadUrl
              : null,
        ),
    ];
    ref.read(downloadQueueServiceProvider).start(requests);
    context.pushReplacementNamed(AppRoutes.downloading);
  }

  /// Download finished → import each downloaded file into the gallery via the
  /// gallery service, record the first saved path on the history entry, then →
  /// success. File I/O lives in the services; the notifier only stores the
  /// resulting path / dedupe key.
  Future<void> finishDownload() async {
    final completed = ref
        .read(downloadQueueServiceProvider)
        .current
        .items
        .where((i) => i.isComplete && i.localPath != null);
    final gallery = ref.read(galleryServiceProvider);
    String? savedPath;
    try {
      for (final item in completed) {
        final path = await gallery.saveFile(item.kind, item.localPath!);
        savedPath ??= path; // record the first; all land in the gallery
      }
    } on GallerySaveException catch (e) {
      if (!context.mounted) return;
      if (e.storageFull) {
        showError(AppErrorKind.storage);
        return;
      }
      // Other save failure → proceed with a pathless history entry.
    } catch (_) {
      // Unexpected failure → proceed without a file path.
    }
    if (!context.mounted) return;
    _notifier.finishDownload(filePath: savedPath, sourceKey: _sourceKey());
    context.pushReplacementNamed(AppRoutes.success);
  }

  /// Open the already-saved entry that matches the current analysis source
  /// (the "Already in your gallery" recovery). Falls back to a calm pointer to
  /// History when the entry can't be located.
  Future<void> openExistingSaved() async {
    final key = _sourceKey();
    final state = ref.read(appStateProvider);
    HistoryEntry? entry;
    if (key != null) {
      for (final h in state.history) {
        if (h.sourceKey == key) {
          entry = h;
          break;
        }
      }
    }
    if (entry == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can open it from your History.')),
        );
      }
      return;
    }
    await ref.read(galleryServiceProvider).open(entry);
  }

  /// Dedupe key for the current analysis (host|url), or null when unknown.
  String? _sourceKey() {
    final state = ref.read(appStateProvider);
    final host = state.analysis?.host;
    final url = state.lastSubmittedUrl;
    if (host == null || url == null) return null;
    return dedupeKey(host, url);
  }
}
