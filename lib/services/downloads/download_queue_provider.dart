// ─────────────────────────────────────────────────────────────
// Quietly — Download queue providers
//
// Exposes the DownloadQueueService and a StreamProvider of its state. The state
// provider seeds the service's `current` first so the Download screen has data
// on its first frame (no loading flicker), then forwards live updates.
// Overridden with an in-memory / fake service in tests.
// ─────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'download_models.dart';
import 'download_queue_service.dart';
import 'in_memory_download_queue_service.dart';

final downloadQueueServiceProvider = Provider<DownloadQueueService>((ref) {
  final service = InMemoryDownloadQueueService();
  ref.onDispose(service.dispose);
  return service;
});

final downloadQueueStateProvider = StreamProvider<DownloadQueueState>((
  ref,
) async* {
  final service = ref.watch(downloadQueueServiceProvider);
  yield service.current;
  yield* service.updates;
});
