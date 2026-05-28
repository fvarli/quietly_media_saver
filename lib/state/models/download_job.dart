// ─────────────────────────────────────────────────────────────
// Quietly — DownloadJob model
//
// One entry in the download queue (HANDOFF screen 7, multi-file progress).
// Mirrors the queue items built in startDownload() in app.jsx.
//
// IMPORTANT: This pass carries NO download execution. [progress] is a plain
// field the state machine can set; the real per-item progress stream / pause /
// resume / retry service is a later pass (HANDOFF §E).
// ─────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

import 'app_enums.dart';

@immutable
class DownloadJob {
  const DownloadJob({
    required this.kind,
    required this.name,
    required this.meta,
    this.progress = 0,
  });

  final MediaKind kind;

  /// File name, e.g. `'clip_1.mp4'`.
  final String name;

  /// Metadata line, e.g. `'MP4 · 1080p'`.
  final String meta;

  /// Progress 0–100 (integer percent), as in the prototype.
  final int progress;

  bool get isComplete => progress >= 100;

  DownloadJob copyWith({int? progress}) => DownloadJob(
        kind: kind,
        name: name,
        meta: meta,
        progress: progress ?? this.progress,
      );
}
