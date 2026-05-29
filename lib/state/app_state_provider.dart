// ─────────────────────────────────────────────────────────────
// Quietly — AppState provider (Riverpod Notifier)
//
// The single owner of mutable app state. Transition methods mirror the
// prototype controller `app` object (docs/design-handoff/app/app.jsx) but are
// PURE STATE mutations — no timers, no network, no file I/O, no navigation.
//
// Navigation is performed separately via go_router; lib/app/flow/app_flow.dart
// pairs each user intent with both the state transition here and the matching
// route push/go, keeping AppState.screen and the router in lockstep.
//
// Riverpod 3.x API: extend [Notifier], expose via [NotifierProvider].
// ─────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_state.dart';
import 'models/analysis_result.dart';
import 'models/app_enums.dart';
import 'models/carousel_item.dart';
import 'models/download_job.dart';
import 'models/history_entry.dart';

/// Global app state provider.
final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(
  AppStateNotifier.new,
);

class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() => const AppState();

  // ── Screen / sheet transitions ────────────────────────────
  /// Set the logical current screen (mirrors `app.go`). Navigation is handled
  /// by the flow layer; this only records the state-machine position.
  void setScreen(AppScreen screen) =>
      state = state.copyWith(screen: screen, clearSheet: true);

  /// Begin analysis after a paste (mirrors `app.paste`).
  void paste() =>
      state = state.copyWith(screen: AppScreen.analyzing, clearSheet: true);

  /// Analysis finished → show result (mirrors `app.onAnalyzed`).
  void onAnalyzed() => state = state.copyWith(screen: AppScreen.result);

  /// Record the URL submitted for analysis.
  void setSubmittedUrl(String url) =>
      state = state.copyWith(lastSubmittedUrl: url);

  /// Record a valid-looking clipboard URL (Home suggestion).
  void setClipboardUrl(String url) => state = state.copyWith(clipboardUrl: url);

  /// Apply an analysis result. For a carousel, also (re)populate the selectable
  /// carousel list from the detected items (all selected by default).
  void setAnalysis(AnalysisResult result) {
    state = state.copyWith(
      analysis: result,
      carousel: result.isCarousel
          ? [
              for (final m in result.items)
                CarouselItem(
                  kind: m.kind,
                  megabytes: m.sizeMb,
                  selected: true,
                  durationSeconds: m.durationSeconds,
                ),
            ]
          : state.carousel,
    );
  }

  void openSheet(AppSheet sheet) => state = state.copyWith(sheet: sheet);

  void closeSheet() => state = state.copyWith(clearSheet: true);

  /// Select an error variant and move to the error screen.
  void showError(AppErrorKind error) => state = state.copyWith(
    screen: AppScreen.error,
    error: error,
    clearSheet: true,
  );

  // ── Selections / preferences ──────────────────────────────
  void setQuality(String id) => state = state.copyWith(quality: id);

  /// Toggle a single carousel item's selection (mirrors `app.toggleItem`).
  void toggleCarouselItem(int index) {
    final next = [
      for (var i = 0; i < state.carousel.length; i++)
        if (i == index)
          state.carousel[i].copyWith(selected: !state.carousel[i].selected)
        else
          state.carousel[i],
    ];
    state = state.copyWith(carousel: next);
  }

  /// Select-all / clear-all (mirrors `app.toggleAll`).
  void toggleSelectAll() {
    final selectAll = !state.allCarouselSelected;
    state = state.copyWith(
      carousel: [
        for (final i in state.carousel) i.copyWith(selected: selectAll),
      ],
    );
  }

  void setAskQuality(bool value) => state = state.copyWith(
    toggles: state.toggles.copyWith(askQualityEveryTime: value),
  );

  void setWifiOnly(bool value) =>
      state = state.copyWith(toggles: state.toggles.copyWith(wifiOnly: value));

  void setNotify(bool value) =>
      state = state.copyWith(toggles: state.toggles.copyWith(notify: value));

  // ── Save / permission / download (state only) ─────────────
  /// Record a save request (mirrors `app.requestSave`). Returns `true` when a
  /// permission grant is still required, so the flow layer can decide whether
  /// to open the permission sheet or start the download.
  bool requestSave(List<MediaKind> kinds) {
    state = state.copyWith(lastSaved: kinds, pendingSave: kinds);
    return !state.permissionGranted;
  }

  /// Grant permission (mirrors `app.grantPermission`). Closes the sheet.
  void grantPermission() => state = state.copyWith(
    permissionStatus: PermissionStatus.granted,
    clearSheet: true,
  );

  /// Set the gallery permission status (no OS this pass; Pass 5 maps the real
  /// permission_handler result here).
  void setPermissionStatus(PermissionStatus status) =>
      state = state.copyWith(permissionStatus: status);

  /// Toggle the offline banner state (real connectivity detection in Pass 5).
  void setOffline(bool value) => state = state.copyWith(offline: value);

  /// Record the first-run acceptable-use acknowledgement (persisted via the
  /// bootstrap write-through listener).
  void setFirstRunAcknowledged(bool value) =>
      state = state.copyWith(firstRunAcknowledged: value);

  /// Mark that preferences loaded successfully, so [AppState.firstRunResolved]
  /// is authoritative and the first-run gate can be evaluated.
  void markFirstRunResolved() => state = state.copyWith(firstRunResolved: true);

  /// Replace the history list (bootstrap applies persisted history).
  void setHistory(List<HistoryEntry> history) =>
      state = state.copyWith(history: history);

  /// Clear all saved history (Settings → Clear history). Persisted by the
  /// bootstrap write-through listener.
  void clearHistory() => state = state.copyWith(history: const []);

  /// Remove a single history entry by [id] (stable across persistence reloads).
  void removeHistoryEntry(HistoryEntry entry) => state = state.copyWith(
    history: state.history.where((h) => h.id != entry.id).toList(),
  );

  /// Prepare the download (mirrors `app.startDownload`) — builds the queue for
  /// multi-saves or resets single-file progress. No bytes are transferred this
  /// pass; this only shapes the state the DownloadScreen renders.
  void startDownload(List<MediaKind> kinds) {
    if (kinds.length > 1) {
      final queue = <DownloadJob>[
        for (var i = 0; i < kinds.length; i++)
          DownloadJob(
            kind: kinds[i],
            name: kinds[i] == MediaKind.video
                ? 'clip_${i + 1}.mp4'
                : 'image_${i + 1}.jpg',
            meta: kinds[i] == MediaKind.video ? 'MP4 · 1080p' : 'JPG · 1440px',
          ),
      ];
      state = state.copyWith(
        screen: AppScreen.downloading,
        queue: queue,
        progress: 0,
        lastSaved: kinds,
        clearSheet: true,
      );
    } else {
      state = state.copyWith(
        screen: AppScreen.downloading,
        queue: const [],
        progress: 0,
        lastSaved: kinds,
        clearSheet: true,
      );
    }
  }

  /// Finalize a completed download (mirrors `app.finishDownload`): prepend a
  /// history entry and move to success. The downloader will call this later;
  /// exposed now so the flow/tests can exercise the transition.
  void finishDownload({String? filePath, String? sourceKey}) {
    final kinds = state.lastSaved;
    final id = 'save_${DateTime.now().microsecondsSinceEpoch}';
    final HistoryEntry entry = kinds.length > 1
        ? HistoryEntry(
            id: id,
            kind: kinds.contains(MediaKind.video)
                ? MediaKind.video
                : MediaKind.image,
            title: '${kinds.length} items',
            meta: 'Mixed · saved',
            time: 'Just now',
            group: HistoryGroup.today,
            filePath: filePath,
            sourceKey: sourceKey,
          )
        : HistoryEntry(
            id: id,
            kind: kinds.isNotEmpty ? kinds.first : MediaKind.video,
            title: kinds.firstOrNull == MediaKind.image
                ? 'Image'
                : 'Video clip',
            meta: '${state.quality} · saved',
            time: 'Just now',
            group: HistoryGroup.today,
            filePath: filePath,
            sourceKey: sourceKey,
          );
    state = state.copyWith(
      screen: AppScreen.success,
      history: [entry, ...state.history],
    );
  }
}
