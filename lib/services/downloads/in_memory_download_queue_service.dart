// ─────────────────────────────────────────────────────────────
// Quietly — In-memory download queue (simulated)
//
// The current implementation of DownloadQueueService: no real network — it
// advances each item's progress on a periodic timer and supports the full
// lifecycle. This moves the simulation that used to live in DownloadingScreen's
// AnimationController behind the service boundary, so the UI is identical
// whether progress is simulated or (later) real.
//
// Failure is injectable via [failItemIds] (default empty → always completes,
// for a calm production feel); the real downloader will fail on actual errors.
// ─────────────────────────────────────────────────────────────

import 'dart:async';

import '../../state/models/app_enums.dart';
import 'download_models.dart';
import 'download_queue_service.dart';

class InMemoryDownloadQueueService implements DownloadQueueService {
  InMemoryDownloadQueueService({
    this.tick = const Duration(milliseconds: 120),
    this.step = 0.08,
    Set<String> failItemIds = const <String>{},
  }) : _failItemIds = failItemIds;

  /// How often progress advances.
  final Duration tick;

  /// Progress added per tick to each downloading item (0..1).
  final double step;

  /// Item ids that should fail instead of completing (tests / future real errors).
  final Set<String> _failItemIds;

  final StreamController<DownloadQueueState> _controller =
      StreamController<DownloadQueueState>.broadcast();
  DownloadQueueState _state = DownloadQueueState.empty;
  Timer? _timer;

  @override
  Stream<DownloadQueueState> get updates => _controller.stream;

  @override
  DownloadQueueState get current => _state;

  @override
  void start(List<MediaKind> kinds) {
    _timer?.cancel();
    final items = <DownloadItem>[
      for (var i = 0; i < kinds.length; i++)
        DownloadItem(
          id: 'item_$i',
          kind: kinds[i],
          name: kinds[i] == MediaKind.video
              ? 'clip_${i + 1}.mp4'
              : 'image_${i + 1}.jpg',
          meta: kinds[i] == MediaKind.video ? 'MP4 · 1080p' : 'JPG · 1440px',
          status: DownloadItemStatus.downloading,
        ),
    ];
    _set(DownloadQueueState(items));
    _startTimer();
  }

  @override
  void pause() {
    _timer?.cancel();
    _timer = null;
    _set(_mapStatus(DownloadItemStatus.downloading, DownloadItemStatus.paused));
  }

  @override
  void resume() {
    _set(_mapStatus(DownloadItemStatus.paused, DownloadItemStatus.downloading));
    _startTimer();
  }

  @override
  void cancel() {
    _timer?.cancel();
    _timer = null;
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
    _set(_mapStatus(DownloadItemStatus.failed, DownloadItemStatus.downloading));
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    if (!_controller.isClosed) _controller.close();
  }

  // ── internals ─────────────────────────────────────────────
  void _startTimer() {
    if (_timer != null) return;
    if (_isTerminal(_state)) return;
    _timer = Timer.periodic(tick, (_) => _onTick());
  }

  void _onTick() {
    final next = <DownloadItem>[
      for (final item in _state.items) _advance(item),
    ];
    _set(DownloadQueueState(next));
    if (_isTerminal(_state)) {
      _timer?.cancel();
      _timer = null;
    }
  }

  DownloadItem _advance(DownloadItem item) {
    if (item.status != DownloadItemStatus.downloading) return item;
    final p = item.progress + step;
    if (p < 1) return item.copyWith(progress: p);
    // Reached the end: complete, or fail if marked.
    return _failItemIds.contains(item.id)
        ? item.copyWith(status: DownloadItemStatus.failed)
        : item.copyWith(progress: 1, status: DownloadItemStatus.completed);
  }

  DownloadQueueState _mapStatus(
    DownloadItemStatus from,
    DownloadItemStatus to,
  ) => DownloadQueueState([
    for (final item in _state.items)
      item.status == from ? item.copyWith(status: to) : item,
  ]);

  bool _isTerminal(DownloadQueueState s) =>
      s.items.isNotEmpty &&
      s.items.every(
        (i) =>
            i.status == DownloadItemStatus.completed ||
            i.status == DownloadItemStatus.failed ||
            i.status == DownloadItemStatus.canceled,
      );

  void _set(DownloadQueueState state) {
    _state = state;
    if (!_controller.isClosed) _controller.add(state);
  }
}
