// ─────────────────────────────────────────────────────────────
// Quietly — Download queue models
//
// Service-layer value types for the download queue boundary. The service owns
// these (live progress + per-item status); they are distinct from the state-
// layer `DownloadJob` (which records the *requested* items for retry metadata).
//
// `progress` is 0..1. These are pure data with value equality so stream
// emissions and widget rebuilds compare cleanly.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

import '../../state/models/app_enums.dart';

enum DownloadItemStatus {
  queued,
  downloading,
  paused,
  completed,
  failed,
  canceled,
}

/// What to download: a media [kind] and, when known, the source [url].
/// A null [url] makes the service fall back to local sample bytes (no network).
@immutable
class DownloadRequest {
  const DownloadRequest(this.kind, {this.url});

  final MediaKind kind;
  final String? url;
}

@immutable
class DownloadItem {
  const DownloadItem({
    required this.id,
    required this.kind,
    required this.name,
    required this.meta,
    this.progress = 0,
    this.status = DownloadItemStatus.queued,
  });

  final String id;
  final MediaKind kind;
  final String name;
  final String meta;

  /// Progress in the range 0..1.
  final double progress;
  final DownloadItemStatus status;

  bool get isComplete => status == DownloadItemStatus.completed;
  bool get isFailed => status == DownloadItemStatus.failed;

  DownloadItem copyWith({double? progress, DownloadItemStatus? status}) =>
      DownloadItem(
        id: id,
        kind: kind,
        name: name,
        meta: meta,
        progress: progress ?? this.progress,
        status: status ?? this.status,
      );

  @override
  bool operator ==(Object other) =>
      other is DownloadItem &&
      other.id == id &&
      other.kind == kind &&
      other.name == name &&
      other.meta == meta &&
      other.progress == progress &&
      other.status == status;

  @override
  int get hashCode => Object.hash(id, kind, name, meta, progress, status);
}

@immutable
class DownloadQueueState {
  const DownloadQueueState(this.items);

  final List<DownloadItem> items;

  static const DownloadQueueState empty = DownloadQueueState(<DownloadItem>[]);

  bool get isEmpty => items.isEmpty;
  bool get isMulti => items.length > 1;

  int get completedCount => items.where((i) => i.isComplete).length;

  /// Average progress across all items (0..1).
  double get overallProgress => items.isEmpty
      ? 0
      : items.map((i) => i.progress).reduce((a, b) => a + b) / items.length;

  bool get hasFailure => items.any((i) => i.isFailed);

  /// All items finished successfully.
  bool get isComplete => items.isNotEmpty && items.every((i) => i.isComplete);

  bool get isPaused => items.any((i) => i.status == DownloadItemStatus.paused);

  bool get isCanceled =>
      items.isNotEmpty &&
      items.every((i) => i.status == DownloadItemStatus.canceled);

  @override
  bool operator ==(Object other) =>
      other is DownloadQueueState && listEquals(other.items, items);

  @override
  int get hashCode => Object.hashAll(items);
}
