// ─────────────────────────────────────────────────────────────
// Quietly — Direct-media analysis service (real, prototype)
//
// A real, legally-safe analyzer for DIRECT, publicly accessible media FILE URLs
// only (e.g. https://cdn.host/clip.mp4, …/photo.jpg). It performs a lightweight
// HTTP probe — prefer HEAD; fall back to a tiny range GET on 405/501 — and
// confirms the resource is media via its Content-Type. It NEVER downloads the
// full file during analysis, never scrapes or parses web/social pages, and never
// bypasses private / login / DRM / protected content: anything that isn't a
// confirmed public media file maps to the existing invalid / protected /
// unsupported / network errors.
//
// No platform-specific support is claimed or implied. A successful result is a
// single DetectedMediaItem whose downloadUrl is the original URL, so the existing
// download → gallery-save pipeline flows real bytes.
// ─────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../state/models/analysis_result.dart';
import '../../state/models/app_enums.dart';
import 'media_analysis_service.dart';

class DirectMediaAnalysisService implements MediaAnalysisService {
  DirectMediaAnalysisService({
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  static const _videoExts = {'mp4', 'mov', 'webm', 'm4v'};
  static const _imageExts = {'jpg', 'jpeg', 'png', 'webp', 'gif'};

  @override
  Future<AnalysisResult> analyze(String url) async {
    final u = url.trim();
    final uri = Uri.tryParse(u);
    if (uri == null ||
        !(uri.scheme == 'http' || uri.scheme == 'https') ||
        uri.host.isEmpty) {
      throw const AnalysisException(AnalysisFailureKind.invalidUrl);
    }

    final probe = await _probe(uri);
    final kind = _kindFor(probe.contentType, uri.path);
    final sizeMb = (probe.bytes != null && probe.bytes! > 0)
        ? probe.bytes! / (1024 * 1024)
        : 0.0;

    return AnalysisResult(
      type: AnalysisResultType.single,
      host: uri.host,
      isPublic: true,
      items: [
        DetectedMediaItem(
          id: 'm0',
          kind: kind,
          sizeMb: double.parse(sizeMb.toStringAsFixed(1)),
          downloadUrl: u,
        ),
      ],
    );
  }

  /// Closes the underlying client (the provider calls this on dispose).
  void dispose() => _client.close();

  // ── internals ─────────────────────────────────────────────
  /// HEAD probe, falling back to a tiny range GET when the server rejects HEAD
  /// (405/501). Returns the status (already validated 2xx), content-type, and
  /// total byte size when known.
  Future<({int status, String? contentType, int? bytes})> _probe(
    Uri uri,
  ) async {
    http.Response head;
    try {
      head = await _client.head(uri).timeout(timeout);
    } on TimeoutException {
      throw const AnalysisException(AnalysisFailureKind.network);
    } on SocketException {
      throw const AnalysisException(AnalysisFailureKind.network);
    } on http.ClientException {
      throw const AnalysisException(AnalysisFailureKind.network);
    }

    if (head.statusCode == 405 || head.statusCode == 501) {
      return _rangeGet(uri);
    }
    _checkStatus(head.statusCode);
    return (
      status: head.statusCode,
      contentType: head.headers['content-type'],
      bytes: _bytesFromHeaders(head.headers, head.contentLength),
    );
  }

  /// Lightweight `Range: bytes=0-0` GET used only when HEAD isn't allowed. The
  /// body (≤1 byte) is drained so the full file is never downloaded.
  Future<({int status, String? contentType, int? bytes})> _rangeGet(
    Uri uri,
  ) async {
    final request = http.Request('GET', uri)..headers['range'] = 'bytes=0-0';
    http.StreamedResponse resp;
    try {
      resp = await _client.send(request).timeout(timeout);
    } on TimeoutException {
      throw const AnalysisException(AnalysisFailureKind.network);
    } on SocketException {
      throw const AnalysisException(AnalysisFailureKind.network);
    } on http.ClientException {
      throw const AnalysisException(AnalysisFailureKind.network);
    }
    try {
      await resp.stream.drain<void>();
    } catch (_) {
      // Best-effort drain; headers are already available.
    }
    _checkStatus(resp.statusCode);
    return (
      status: resp.statusCode,
      contentType: resp.headers['content-type'],
      bytes: _bytesFromHeaders(resp.headers, resp.contentLength),
    );
  }

  /// Maps a non-2xx status to the matching failure. 2xx returns normally.
  void _checkStatus(int status) {
    if (status >= 200 && status < 300) return;
    if (status == 401 || status == 403 || status == 407) {
      throw const AnalysisException(AnalysisFailureKind.protected);
    }
    if (status >= 500) {
      throw const AnalysisException(AnalysisFailureKind.network);
    }
    // 404 / 410 and other 4xx → not a readable public media file.
    throw const AnalysisException(AnalysisFailureKind.unsupported);
  }

  /// Content-Type is authoritative: `video/*` / `image/*` only. A concrete
  /// non-media type (e.g. text/html) is never treated as media — Quietly does
  /// not scrape pages. An ambiguous/absent type falls back to the file
  /// extension; anything else is unsupported.
  MediaKind _kindFor(String? rawContentType, String path) {
    final ct = rawContentType?.split(';').first.trim().toLowerCase() ?? '';
    if (ct.startsWith('video/')) return MediaKind.video;
    if (ct.startsWith('image/')) return MediaKind.image;

    final ambiguous =
        ct.isEmpty ||
        ct == 'application/octet-stream' ||
        ct == 'binary/octet-stream';
    if (ambiguous) {
      final ext = _extOf(path);
      if (_videoExts.contains(ext)) return MediaKind.video;
      if (_imageExts.contains(ext)) return MediaKind.image;
    }
    throw const AnalysisException(AnalysisFailureKind.unsupported);
  }

  String _extOf(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return '';
    return path.substring(dot + 1).toLowerCase();
  }

  /// Total size in bytes: prefer the `content-range` total (range GET), then
  /// `content-length`, then the parsed [fallback].
  int? _bytesFromHeaders(Map<String, String> headers, int? fallback) {
    final range = headers['content-range'];
    if (range != null) {
      final slash = range.lastIndexOf('/');
      if (slash != -1) {
        final total = int.tryParse(range.substring(slash + 1).trim());
        if (total != null) return total;
      }
    }
    final len = headers['content-length'];
    if (len != null) {
      final n = int.tryParse(len.trim());
      if (n != null) return n;
    }
    return fallback;
  }
}
