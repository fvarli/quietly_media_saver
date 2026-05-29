// ─────────────────────────────────────────────────────────────
// Quietly — Media analysis service provider
//
// Exposes the MediaAnalysisService. Defaults to the deterministic sample;
// the real analyzer (public-media detection only) implements the same
// interface later.
// ─────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'media_analysis_service.dart';

final mediaAnalysisServiceProvider = Provider<MediaAnalysisService>(
  (ref) => const SampleMediaAnalysisService(),
);
