// ─────────────────────────────────────────────────────────────
// Quietly — HistoryEntry model
//
// A saved-media record shown in the day-grouped History screen and the Home
// "recent saves" strip. As of Pass 5D it is persisted via SavedMediaRepository,
// so it carries a stable [id] (identity that survives a reload — used for
// remove) and serializes to/from JSON. [filePath] is a placeholder for a future
// local/gallery file reference (null until the real GalleryService lands).
// ─────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

import 'app_enums.dart';

/// Day grouping bucket for the History list.
enum HistoryGroup { today, yesterday, earlier }

@immutable
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.meta,
    required this.time,
    required this.group,
    this.filePath,
  });

  /// Stable identity (persistence + remove-by-id).
  final String id;

  final MediaKind kind;

  /// e.g. `'Video clip'`, `'3 images'`.
  final String title;

  /// Monospace metadata line, e.g. `'1080p · 24 MB'`.
  final String meta;

  /// Display timestamp, e.g. `'2:14 PM'`, `'Just now'`, `'Mon'`.
  final String time;

  final HistoryGroup group;

  /// Placeholder for a future local/gallery file reference (null this pass).
  final String? filePath;

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'title': title,
    'meta': meta,
    'time': time,
    'group': group.name,
    'filePath': filePath,
  };

  static HistoryEntry fromJson(Map<String, dynamic> json) => HistoryEntry(
    id: json['id'] as String,
    kind: MediaKind.values.byName(json['kind'] as String),
    title: json['title'] as String,
    meta: json['meta'] as String,
    time: json['time'] as String,
    group: HistoryGroup.values.byName(json['group'] as String),
    filePath: json['filePath'] as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is HistoryEntry &&
      other.id == id &&
      other.kind == kind &&
      other.title == title &&
      other.meta == meta &&
      other.time == time &&
      other.group == group &&
      other.filePath == filePath;

  @override
  int get hashCode => Object.hash(id, kind, title, meta, time, group, filePath);
}

/// Seed history (HANDOFF screen 9), matching the prototype's SEED_HISTORY.
const List<HistoryEntry> kSeedHistory = <HistoryEntry>[
  HistoryEntry(
    id: 'seed_0',
    kind: MediaKind.video,
    title: 'Video clip',
    meta: '1080p · 24 MB',
    time: '2:14 PM',
    group: HistoryGroup.today,
  ),
  HistoryEntry(
    id: 'seed_1',
    kind: MediaKind.image,
    title: '3 images',
    meta: 'JPG · 4.1 MB',
    time: '11:02 AM',
    group: HistoryGroup.today,
  ),
  HistoryEntry(
    id: 'seed_2',
    kind: MediaKind.image,
    title: 'Image',
    meta: 'PNG · 0.9 MB',
    time: '8:40 PM',
    group: HistoryGroup.yesterday,
  ),
  HistoryEntry(
    id: 'seed_3',
    kind: MediaKind.video,
    title: 'Video clip',
    meta: '720p · 12 MB',
    time: '6:15 PM',
    group: HistoryGroup.yesterday,
  ),
  HistoryEntry(
    id: 'seed_4',
    kind: MediaKind.image,
    title: 'Image',
    meta: 'JPG · 1.4 MB',
    time: 'Mon',
    group: HistoryGroup.earlier,
  ),
  HistoryEntry(
    id: 'seed_5',
    kind: MediaKind.video,
    title: 'Video clip',
    meta: '1080p · 30 MB',
    time: 'Sun',
    group: HistoryGroup.earlier,
  ),
];
