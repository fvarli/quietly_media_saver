// ─────────────────────────────────────────────────────────────
// Quietly — AppToggles model
//
// Settings toggles persisted in the prototype state (`toggles` in app.jsx):
//   ask    — "Ask quality every time" (off by default; see HANDOFF §F #1)
//   wifi   — "Save on Wi-Fi only" (on by default)
//   notify — "Download notifications" (on by default)
//
// Persistence is not wired this pass (no storage backend) — these live in
// memory in AppState.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

@immutable
class AppToggles {
  const AppToggles({
    this.askQualityEveryTime = false,
    this.wifiOnly = true,
    this.notify = true,
  });

  final bool askQualityEveryTime;
  final bool wifiOnly;
  final bool notify;

  AppToggles copyWith({
    bool? askQualityEveryTime,
    bool? wifiOnly,
    bool? notify,
  }) => AppToggles(
    askQualityEveryTime: askQualityEveryTime ?? this.askQualityEveryTime,
    wifiOnly: wifiOnly ?? this.wifiOnly,
    notify: notify ?? this.notify,
  );
}
