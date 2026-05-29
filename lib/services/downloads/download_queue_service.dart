// ─────────────────────────────────────────────────────────────
// Quietly — Download queue service (interface)
//
// The boundary for the download/queue subsystem. Pass 5C ships an in-memory
// simulated implementation; a real network downloader will implement the same
// interface later. The UI consumes [updates] (via a StreamProvider) and drives
// the lifecycle; navigation side-effects on terminal states live in the screen
// + AppFlow, so AppStateNotifier stays pure.
// ─────────────────────────────────────────────────────────────

import 'download_models.dart';

abstract interface class DownloadQueueService {
  /// Stream of queue-state changes.
  Stream<DownloadQueueState> get updates;

  /// The latest queue state (for synchronous reads / seeding the stream).
  DownloadQueueState get current;

  /// Begin a queue for the given [requests] (replaces any prior queue). Each
  /// request may carry a source URL (real HTTP download) or none (sample bytes).
  void start(List<DownloadRequest> requests);

  /// Pause all in-progress items.
  void pause();

  /// Resume paused items.
  void resume();

  /// Cancel the whole queue.
  void cancel();

  /// Retry failed items.
  void retry();

  /// Release resources (timers / stream controller).
  void dispose();
}
