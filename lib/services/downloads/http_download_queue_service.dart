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

import 'package:http/http.dart' as http;

import '../../state/models/app_enums.dart';
import 'download_models.dart';
import 'download_queue_service.dart';

class HttpDownloadQueueService implements DownloadQueueService {
  HttpDownloadQueueService({
    http.Client? client,
    this.tick = const Duration(milliseconds: 120),
    this.step = 0.08,
    Set<String> failItemIds = const <String>{},
  }) : _client = client ?? http.Client(),
       _failItemIds = failItemIds;

  final http.Client _client;
  final Duration tick;
  final double step;
  final Set<String> _failItemIds;

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
    final url = _requests[index].url;
    if (url == null) return _fallbackDownload(index);

    final response = await _client.send(http.Request('GET', Uri.parse(url)));
    if (response.statusCode != 200) {
      throw http.ClientException('HTTP ${response.statusCode}', Uri.parse(url));
    }
    final total = response.contentLength ?? 0;
    var received = 0;
    final completer = Completer<void>();
    _activeCompleter = completer;
    _activeSub = response.stream.listen(
      (chunk) {
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
        _updateItem(index, progress: 1, status: DownloadItemStatus.completed);
        if (!completer.isCompleted) completer.complete();
      },
      cancelOnError: true,
    );
    await completer.future;
    _activeSub = null;
    _activeCompleter = null;
  }

  Future<void> _fallbackDownload(int index) async {
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
        _updateItem(index, progress: 1, status: DownloadItemStatus.completed);
        if (!completer.isCompleted) completer.complete();
      }
    });
    await completer.future;
    _activeCompleter = null;
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

  void _updateItem(int index, {double? progress, DownloadItemStatus? status}) {
    _set(
      DownloadQueueState([
        for (var i = 0; i < _state.items.length; i++)
          i == index
              ? _state.items[i].copyWith(progress: progress, status: status)
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
