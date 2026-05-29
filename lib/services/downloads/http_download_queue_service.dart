// ─────────────────────────────────────────────────────────────
// Quietly — HTTP download/queue service
//
// The real implementation of DownloadQueueService (package:http). Items are
// processed sequentially; each one either:
//   • has a URL → a real streamed HTTP GET with per-item progress, or
//   • has no URL → a local sample-bytes ramp fallback (no network).
// The sample analyzer supplies no URLs, so the shipped demo uses the fallback
// (offline + legally safe); a real analyzer populating downloadUrl activates the
// HTTP path with no further wiring. No scraping; no private/DRM access.
//
// Pause/resume use the byte-stream subscription's backpressure (HTTP) or a
// paused-flag (fallback) — no byte-range resume. Failures → failed status, which
// the screen maps to AppErrorKind.queueItemFailed. Tests inject an http
// MockClient (in-memory) — never real network.
// ─────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../state/models/app_enums.dart';
import 'download_models.dart';
import 'download_queue_service.dart';

class HttpDownloadQueueService implements DownloadQueueService {
  HttpDownloadQueueService({
    http.Client? client,
    this.tick = const Duration(milliseconds: 120),
    this.step = 0.08,
    Set<String> failItemIds = const <String>{},
    Future<Directory> Function()? cacheDirProvider,
  }) : _client = client ?? http.Client(),
       _failItemIds = failItemIds,
       _cacheDirProvider = cacheDirProvider ?? getTemporaryDirectory;

  final http.Client _client;
  final Duration tick;
  final double step;
  final Set<String> _failItemIds;

  /// Resolves the directory completed downloads are written to (injected in
  /// tests so no real path_provider channel is needed).
  final Future<Directory> Function() _cacheDirProvider;

  final StreamController<DownloadQueueState> _controller =
      StreamController<DownloadQueueState>.broadcast();
  DownloadQueueState _state = DownloadQueueState.empty;
  List<DownloadRequest> _requests = const [];

  StreamSubscription<List<int>>? _activeSub;
  Completer<void>? _activeCompleter;
  Timer? _fallbackTimer;
  bool _paused = false;
  bool _canceled = false;

  @override
  Stream<DownloadQueueState> get updates => _controller.stream;

  @override
  DownloadQueueState get current => _state;

  @override
  void start(List<DownloadRequest> requests) {
    _stopActive();
    _requests = requests;
    _paused = false;
    _canceled = false;
    _set(
      DownloadQueueState([
        for (var i = 0; i < requests.length; i++)
          DownloadItem(
            id: 'item_$i',
            kind: requests[i].kind,
            name: requests[i].kind == MediaKind.video
                ? 'clip_${i + 1}.mp4'
                : 'image_${i + 1}.jpg',
            meta: requests[i].kind == MediaKind.video
                ? 'MP4 · 1080p'
                : 'JPG · 1440px',
            status: DownloadItemStatus.downloading,
          ),
      ]),
    );
    unawaited(_processFrom(0));
  }

  @override
  void pause() {
    _paused = true;
    _activeSub?.pause();
    _set(_mapStatus(DownloadItemStatus.downloading, DownloadItemStatus.paused));
  }

  @override
  void resume() {
    _paused = false;
    _activeSub?.resume();
    _set(_mapStatus(DownloadItemStatus.paused, DownloadItemStatus.downloading));
  }

  @override
  void cancel() {
    _canceled = true;
    _stopActive();
    _set(
      DownloadQueueState([
        for (final item in _state.items)
          item.isComplete || item.isFailed
              ? item
              : item.copyWith(status: DownloadItemStatus.canceled),
      ]),
    );
  }

  @override
  void retry() {
    _canceled = false;
    _paused = false;
    _set(_mapStatus(DownloadItemStatus.failed, DownloadItemStatus.downloading));
    final next = _state.items.indexWhere((i) => !i.isComplete);
    if (next != -1) unawaited(_processFrom(next));
  }

  @override
  void dispose() {
    _canceled = true;
    _stopActive();
    _client.close();
    if (!_controller.isClosed) _controller.close();
  }

  // ── internals ─────────────────────────────────────────────
  Future<void> _processFrom(int index) async {
    for (var i = index; i < _state.items.length; i++) {
      if (_canceled) return;
      if (_state.items[i].isComplete) continue;
      try {
        await _downloadItem(i);
      } catch (_) {
        if (_canceled) return;
        _updateItem(i, status: DownloadItemStatus.failed);
        return; // halt the queue on failure
      }
      if (_canceled) return;
    }
  }

  Future<void> _downloadItem(int index) async {
    final file = await _targetFile(index);
    final url = _requests[index].url;
    if (url == null) return _fallbackDownload(index, file);

    final response = await _client.send(http.Request('GET', Uri.parse(url)));
    if (response.statusCode != 200) {
      throw http.ClientException('HTTP ${response.statusCode}', Uri.parse(url));
    }
    final total = response.contentLength ?? 0;
    var received = 0;
    final bytes = <int>[];
    final completer = Completer<void>();
    _activeCompleter = completer;
    _activeSub = response.stream.listen(
      (chunk) {
        bytes.addAll(chunk);
        received += chunk.length;
        final p = total > 0 ? (received / total).clamp(0.0, 1.0) : 0.05;
        _updateItem(index, progress: p);
      },
      onError: (Object e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      onDone: () {
        if (_canceled) {
          if (!completer.isCompleted) completer.complete();
          return;
        }
        // Small demo files → synchronous write (streaming-to-disk is a refinement).
        file.writeAsBytesSync(bytes);
        _updateItem(
          index,
          progress: 1,
          status: DownloadItemStatus.completed,
          localPath: file.path,
        );
        if (!completer.isCompleted) completer.complete();
      },
      cancelOnError: true,
    );
    await completer.future;
    _activeSub = null;
    _activeCompleter = null;
  }

  Future<void> _fallbackDownload(int index, File file) async {
    final completer = Completer<void>();
    _activeCompleter = completer;
    _fallbackTimer = Timer.periodic(tick, (_) {
      if (_canceled || _paused) return;
      final item = _state.items[index];
      final next = item.progress + step;
      if (next < 1) {
        _updateItem(index, progress: next);
        return;
      }
      _fallbackTimer?.cancel();
      _fallbackTimer = null;
      if (_failItemIds.contains(item.id)) {
        _updateItem(index, status: DownloadItemStatus.failed);
        if (!completer.isCompleted) {
          completer.completeError(const _SampleFailure());
        }
      } else {
        // Write synthetic sample bytes to a real local file.
        file.writeAsBytesSync(_sampleBytes(item.kind));
        _updateItem(
          index,
          progress: 1,
          status: DownloadItemStatus.completed,
          localPath: file.path,
        );
        if (!completer.isCompleted) completer.complete();
      }
    });
    await completer.future;
    _activeCompleter = null;
  }

  /// Resolves the destination file for item [index] (creating the dir).
  Future<File> _targetFile(int index) async {
    final dir = Directory(
      '${(await _cacheDirProvider()).path}/quietly_downloads',
    );
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final item = _state.items[index];
    final ext = item.kind == MediaKind.video ? 'mp4' : 'png';
    return File(
      '${dir.path}/${item.id}_${DateTime.now().microsecondsSinceEpoch}.$ext',
    );
  }

  /// Synthetic, legally-safe placeholder bytes (NOT downloaded content) used by
  /// the fallback: a 1×1 transparent PNG for images; a tiny blob for video.
  Uint8List _sampleBytes(MediaKind kind) {
    if (kind == MediaKind.video) {
      return Uint8List.fromList('QUIETLY_SAMPLE_MEDIA'.codeUnits);
    }
    return Uint8List.fromList(const [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
      0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
      0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
      0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
      0x42, 0x60, 0x82,
    ]);
  }

  void _stopActive() {
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
    _activeSub?.cancel();
    _activeSub = null;
    // Unblock any awaiting download so the processing loop can exit.
    if (_activeCompleter?.isCompleted == false) _activeCompleter!.complete();
    _activeCompleter = null;
  }

  void _updateItem(
    int index, {
    double? progress,
    DownloadItemStatus? status,
    String? localPath,
  }) {
    _set(
      DownloadQueueState([
        for (var i = 0; i < _state.items.length; i++)
          i == index
              ? _state.items[i].copyWith(
                  progress: progress,
                  status: status,
                  localPath: localPath,
                )
              : _state.items[i],
      ]),
    );
  }

  DownloadQueueState _mapStatus(
    DownloadItemStatus from,
    DownloadItemStatus to,
  ) => DownloadQueueState([
    for (final item in _state.items)
      item.status == from ? item.copyWith(status: to) : item,
  ]);

  void _set(DownloadQueueState state) {
    _state = state;
    if (!_controller.isClosed) _controller.add(state);
  }
}

class _SampleFailure implements Exception {
  const _SampleFailure();
}
