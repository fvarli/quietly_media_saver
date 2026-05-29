// ─────────────────────────────────────────────────────────────
// Quietly — AppPreferences
//
// The persisted slice of app state: the lightweight user preferences that
// should survive a restart (selected quality + the three toggles). It lives in
// the state/models layer so both AppState (via `toPreferences`) and the
// preferences service depend on it — services depend on state, never the reverse.
//
// Defaults intentionally match AppState's defaults, so a fresh install loads a
// value equal to the starting state (no spurious first-run write).
//
// NOTE: permission status is deliberately NOT persisted — it is authoritative
// from the OS and refreshed at startup; caching it risks showing a stale status.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

@immutable
class AppPreferences {
  const AppPreferences({
    this.quality = '1080p',
    this.askQualityEveryTime = false,
    this.wifiOnly = true,
    this.notify = true,
    this.firstRunAcknowledged = false,
  });

  final String quality;
  final bool askQualityEveryTime;
  final bool wifiOnly;
  final bool notify;

  /// Whether the first-run acceptable-use acknowledgement has been accepted.
  /// Persisted so the calm rights gate is shown only once.
  final bool firstRunAcknowledged;

  AppPreferences copyWith({
    String? quality,
    bool? askQualityEveryTime,
    bool? wifiOnly,
    bool? notify,
    bool? firstRunAcknowledged,
  }) => AppPreferences(
    quality: quality ?? this.quality,
    askQualityEveryTime: askQualityEveryTime ?? this.askQualityEveryTime,
    wifiOnly: wifiOnly ?? this.wifiOnly,
    notify: notify ?? this.notify,
    firstRunAcknowledged: firstRunAcknowledged ?? this.firstRunAcknowledged,
  );

  @override
  bool operator ==(Object other) =>
      other is AppPreferences &&
      other.quality == quality &&
      other.askQualityEveryTime == askQualityEveryTime &&
      other.wifiOnly == wifiOnly &&
      other.notify == notify &&
      other.firstRunAcknowledged == firstRunAcknowledged;

  @override
  int get hashCode => Object.hash(
    quality,
    askQualityEveryTime,
    wifiOnly,
    notify,
    firstRunAcknowledged,
  );
}
