// ─────────────────────────────────────────────────────────────
// Quietly — HistoryEntry model
//
// Mirrors SEED_HISTORY in docs/design-handoff/app/app.jsx. A saved-media record
// shown in the day-grouped History screen and the Home "recent saves" strip.
//
// NOTE: The persistence/storage model (app DB vs reading the OS gallery) is an
// open product decision (HANDOFF §F #5) and is NOT decided in this pass — this
// is an in-memory display model only.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

import 'app_enums.dart';

/// Day grouping bucket for the History list.
enum HistoryGroup { today, yesterday, earlier }

@immutable
class HistoryEntry {
  const HistoryEntry({
    required this.kind,
    required this.title,
    required this.meta,
    required this.time,
    required this.group,
  });

  final MediaKind kind;

  /// e.g. `'Video clip'`, `'3 images'`.
  final String title;

  /// Monospace metadata line, e.g. `'1080p · 24 MB'`.
  final String meta;

  /// Display timestamp, e.g. `'2:14 PM'`, `'Just now'`, `'Mon'`.
  final String time;

  final HistoryGroup group;
}

/// Seed history (HANDOFF screen 9), matching the prototype's SEED_HISTORY.
const List<HistoryEntry> kSeedHistory = <HistoryEntry>[
  HistoryEntry(
    kind: MediaKind.video,
    title: 'Video clip',
    meta: '1080p · 24 MB',
    time: '2:14 PM',
    group: HistoryGroup.today,
  ),
  HistoryEntry(
    kind: MediaKind.image,
    title: '3 images',
    meta: 'JPG · 4.1 MB',
    time: '11:02 AM',
    group: HistoryGroup.today,
  ),
  HistoryEntry(
    kind: MediaKind.image,
    title: 'Image',
    meta: 'PNG · 0.9 MB',
    time: '8:40 PM',
    group: HistoryGroup.yesterday,
  ),
  HistoryEntry(
    kind: MediaKind.video,
    title: 'Video clip',
    meta: '720p · 12 MB',
    time: '6:15 PM',
    group: HistoryGroup.yesterday,
  ),
  HistoryEntry(
    kind: MediaKind.image,
    title: 'Image',
    meta: 'JPG · 1.4 MB',
    time: 'Mon',
    group: HistoryGroup.earlier,
  ),
  HistoryEntry(
    kind: MediaKind.video,
    title: 'Video clip',
    meta: '1080p · 30 MB',
    time: 'Sun',
    group: HistoryGroup.earlier,
  ),
];
