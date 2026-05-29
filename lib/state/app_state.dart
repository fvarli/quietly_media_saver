// ─────────────────────────────────────────────────────────────
// Quietly — AppState (immutable state-machine model)
//
// Faithful Dart port of the prototype controller state (HANDOFF §D,
// docs/design-handoff/app/app.jsx). Holds the documented state-machine fields:
//   screen · sheet · error · permissionGranted · history · carousel selection ·
//   quality · queue  (+ toggles, lastSaved/pendingSave, single-download progress)
//
// Immutable with [copyWith] and derived getters. The Riverpod notifier
// (app_state_provider.dart) is the only thing that produces new instances.
//
// SEPARATION OF CONCERNS:
//   • This model = domain + logical state-machine state (testable, no I/O).
//   • go_router (lib/app/router) = navigation source of truth + back-stack.
//   • lib/app/flow/app_flow.dart keeps the two in lockstep at call sites.
// No download/network/permission side effects live here (shell pass).
// ─────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

import 'models/app_enums.dart';
import 'models/app_toggles.dart';
import 'models/carousel_item.dart';
import 'models/download_job.dart';
import 'models/history_entry.dart';
import 'models/quality_option.dart';

@immutable
class AppState {
  const AppState({
    this.screen = AppScreen.home,
    this.sheet,
    this.error = AppErrorKind.protected,
    this.permissionStatus = PermissionStatus.denied,
    this.offline = false,
    this.quality = '1080p',
    this.progress = 0,
    this.history = kSeedHistory,
    this.carousel = kSeedCarousel,
    this.queue = const <DownloadJob>[],
    this.toggles = const AppToggles(),
    this.lastSaved = const <MediaKind>[MediaKind.video],
    this.pendingSave = const <MediaKind>[],
  });

  /// Current logical screen (state-machine). Navigation is reflected by
  /// go_router; this is the canonical machine state for logic/tests.
  final AppScreen screen;

  /// Active modal sheet, or `null` when none is open.
  final AppSheet? sheet;

  /// Selected error config when [screen] is [AppScreen.error].
  final AppErrorKind error;

  /// Gallery/storage permission status (in-memory this pass; mapped from the OS
  /// in Pass 5). [permissionGranted] is derived from it.
  final PermissionStatus permissionStatus;

  /// Whether the device is offline (drives the Home banner). Set via the
  /// notifier; real connectivity detection arrives in Pass 5.
  final bool offline;

  /// Whether gallery/storage permission has been granted.
  bool get permissionGranted => permissionStatus == PermissionStatus.granted;

  /// Selected quality option id (see [kQualityOptions]).
  final String quality;

  /// Single-download progress 0–100 (used when [queue] has ≤ 1 item).
  final int progress;

  final List<HistoryEntry> history;
  final List<CarouselItem> carousel;

  /// Multi-file download queue (empty / single → use [progress]).
  final List<DownloadJob> queue;

  final AppToggles toggles;

  /// Kinds saved in the most recent save (drives the success screen).
  final List<MediaKind> lastSaved;

  /// Kinds awaiting a permission grant before download can start.
  final List<MediaKind> pendingSave;

  // ── Derived getters ───────────────────────────────────────
  /// Resolved quality option for [quality].
  QualityOption get qualityOption => kQualityOptions.firstWhere(
    (o) => o.id == quality,
    orElse: () => kQualityOptions.first,
  );

  /// Currently selected carousel items.
  List<CarouselItem> get selectedCarousel =>
      carousel.where((i) => i.selected).toList(growable: false);

  int get selectedCount => carousel.where((i) => i.selected).length;

  /// Sum of selected carousel item sizes (MB, display estimate).
  double get selectedSizeMb =>
      selectedCarousel.fold(0, (sum, i) => sum + i.megabytes);

  bool get allCarouselSelected =>
      carousel.isNotEmpty && carousel.every((i) => i.selected);

  /// True when the active download is a multi-file queue.
  bool get isMultiDownload => queue.length > 1;

  /// History grouped in display order (only non-empty groups).
  List<MapEntry<HistoryGroup, List<HistoryEntry>>> get historyGroups {
    const order = [
      HistoryGroup.today,
      HistoryGroup.yesterday,
      HistoryGroup.earlier,
    ];
    return [
      for (final g in order)
        if (history.any((h) => h.group == g))
          MapEntry(
            g,
            history.where((h) => h.group == g).toList(growable: false),
          ),
    ];
  }

  AppState copyWith({
    AppScreen? screen,
    AppSheet? sheet,
    bool clearSheet = false,
    AppErrorKind? error,
    PermissionStatus? permissionStatus,
    bool? offline,
    String? quality,
    int? progress,
    List<HistoryEntry>? history,
    List<CarouselItem>? carousel,
    List<DownloadJob>? queue,
    AppToggles? toggles,
    List<MediaKind>? lastSaved,
    List<MediaKind>? pendingSave,
  }) {
    return AppState(
      screen: screen ?? this.screen,
      sheet: clearSheet ? null : (sheet ?? this.sheet),
      error: error ?? this.error,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      offline: offline ?? this.offline,
      quality: quality ?? this.quality,
      progress: progress ?? this.progress,
      history: history ?? this.history,
      carousel: carousel ?? this.carousel,
      queue: queue ?? this.queue,
      toggles: toggles ?? this.toggles,
      lastSaved: lastSaved ?? this.lastSaved,
      pendingSave: pendingSave ?? this.pendingSave,
    );
  }
}
