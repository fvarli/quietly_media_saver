// ─────────────────────────────────────────────────────────────
// Quietly — Media analysis service
//
// The boundary for inspecting a pasted link and reporting the PUBLIC media it
// exposes. Pass 6 ships a deterministic SAMPLE implementation: it does NOT
// fetch, scrape, or access any real content, and it never bypasses private /
// login-only / DRM-protected media — those map to a calm refusal
// (AnalysisException). It routes purely on illustrative URL substrings so the
// flow can be demonstrated and tested; a real implementation will replace it.
//
// No platform-specific support is claimed or implied.
// ─────────────────────────────────────────────────────────────

import '../../state/models/analysis_result.dart';
import '../../state/models/app_enums.dart';

/// Heuristic "looks like a URL" check (no network). Used to decide whether to
/// surface a clipboard suggestion and, in the sample analyzer, to reject
/// obvious non-links.
bool isLikelyUrl(String text) {
  final t = text.trim();
  if (t.isEmpty || t.contains(RegExp(r'\s'))) return false;
  if (t.startsWith('http://') || t.startsWith('https://')) return true;
  // Bare host/path like "share.example.com/p/8fa2c91b".
  return t.contains('.') && t.length > 3;
}

abstract interface class MediaAnalysisService {
  /// Inspect [url] and return the public media it exposes, or throw an
  /// [AnalysisException] describing why it can't.
  Future<AnalysisResult> analyze(String url);
}

/// Deterministic, legally-safe sample. Routes on illustrative substrings:
///   not URL-ish              → invalidUrl
///   private/protected/login  → protected
///   unsupported              → unsupported
///   network                  → network
///   album/carousel/gallery   → carousel (mixed items)
///   otherwise                → single video
class SampleMediaAnalysisService implements MediaAnalysisService {
  const SampleMediaAnalysisService();

  @override
  Future<AnalysisResult> analyze(String url) async {
    final u = url.trim();
    final lower = u.toLowerCase();

    if (!isLikelyUrl(u)) {
      throw const AnalysisException(AnalysisFailureKind.invalidUrl);
    }
    if (lower.contains('private') ||
        lower.contains('protected') ||
        lower.contains('login')) {
      throw const AnalysisException(AnalysisFailureKind.protected);
    }
    if (lower.contains('unsupported')) {
      throw const AnalysisException(AnalysisFailureKind.unsupported);
    }
    if (lower.contains('network')) {
      throw const AnalysisException(AnalysisFailureKind.network);
    }

    final host = _hostOf(u);

    if (lower.contains('album') ||
        lower.contains('carousel') ||
        lower.contains('gallery')) {
      return AnalysisResult(
        type: AnalysisResultType.carousel,
        host: host,
        isPublic: true,
        items: const [
          DetectedMediaItem(id: 'm0', kind: MediaKind.image, sizeMb: 1.4),
          DetectedMediaItem(id: 'm1', kind: MediaKind.image, sizeMb: 1.3),
          DetectedMediaItem(
            id: 'm2',
            kind: MediaKind.video,
            sizeMb: 9.0,
            durationSeconds: 18,
          ),
          DetectedMediaItem(id: 'm3', kind: MediaKind.image, sizeMb: 1.5),
          DetectedMediaItem(id: 'm4', kind: MediaKind.image, sizeMb: 1.2),
          DetectedMediaItem(
            id: 'm5',
            kind: MediaKind.video,
            sizeMb: 7.5,
            durationSeconds: 12,
          ),
        ],
      );
    }

    return AnalysisResult(
      type: AnalysisResultType.single,
      host: host,
      isPublic: true,
      items: const [
        DetectedMediaItem(
          id: 'm0',
          kind: MediaKind.video,
          sizeMb: 24,
          durationSeconds: 42,
        ),
      ],
    );
  }

  String _hostOf(String url) {
    final withScheme = url.startsWith('http') ? url : 'https://$url';
    return Uri.tryParse(withScheme)?.host ?? url;
  }
}
