// ─────────────────────────────────────────────────────────────
// Quietly — Media analysis models
//
// Typed result of inspecting a pasted link: what public media (if any) it
// exposes. These live in the state layer so AppState can hold the current
// result; the analysis service (services/analysis) produces them.
//
// RIGHTS-AWARE: an AnalysisResult only ever describes PUBLIC, savable media.
// Private / login-only / DRM / unsupported sources surface an
// [AnalysisException] instead — Quietly never claims to access them.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

import 'app_enums.dart';
import 'quality_option.dart';

enum AnalysisResultType { single, carousel }

@immutable
class DetectedMediaItem {
  const DetectedMediaItem({
    required this.id,
    required this.kind,
    required this.sizeMb,
    this.durationSeconds,
    this.downloadUrl,
  });

  final String id;
  final MediaKind kind;
  final double sizeMb;
  final int? durationSeconds;

  /// Direct media URL, when the analyzer can provide one (the sample analyzer
  /// leaves this null → the download service uses its sample-bytes fallback).
  final String? downloadUrl;
}

@immutable
class AnalysisResult {
  const AnalysisResult({
    required this.type,
    required this.host,
    required this.isPublic,
    required this.items,
    this.qualityOptions = kQualityOptions,
  });

  final AnalysisResultType type;

  /// Source host for display (e.g. `share.example.com`).
  final String host;

  /// Always true for a successful result — Quietly only returns public media.
  final bool isPublic;

  final List<DetectedMediaItem> items;

  /// Quality choices offered for this link (sample uses [kQualityOptions]).
  final List<QualityOption> qualityOptions;

  bool get isSingle => type == AnalysisResultType.single;
  bool get isCarousel => type == AnalysisResultType.carousel;
}

/// Why analysis failed — mapped to a user-facing [AppErrorKind].
enum AnalysisFailureKind { invalidUrl, protected, unsupported, network }

class AnalysisException implements Exception {
  const AnalysisException(this.kind);
  final AnalysisFailureKind kind;

  @override
  String toString() => 'AnalysisException(${kind.name})';
}

/// Dedupe identity for a saved link (host + URL). Stored on
/// `HistoryEntry.sourceKey` and checked to drive the "already saved" state.
String dedupeKey(String host, String url) => '$host|$url';

/// Maps an analysis failure to the existing error-screen config key.
AppErrorKind toAppErrorKind(AnalysisFailureKind kind) => switch (kind) {
  AnalysisFailureKind.invalidUrl => AppErrorKind.invalid,
  AnalysisFailureKind.protected => AppErrorKind.protected,
  AnalysisFailureKind.unsupported => AppErrorKind.unsupported,
  AnalysisFailureKind.network => AppErrorKind.network,
};
