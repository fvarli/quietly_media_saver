// ─────────────────────────────────────────────────────────────
// Quietly — Media analysis service provider
//
// Exposes the MediaAnalysisService as a composite: the real
// DirectMediaAnalysisService for genuine direct public media URLs, with the
// deterministic SampleMediaAnalysisService handling the reserved `*.example.com`
// demo URLs (so the shipped demo + tests stay offline and deterministic).
// ─────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'composite_media_analysis_service.dart';
import 'direct_media_analysis_service.dart';
import 'media_analysis_service.dart';

final mediaAnalysisServiceProvider = Provider<MediaAnalysisService>((ref) {
  final direct = DirectMediaAnalysisService();
  ref.onDispose(direct.dispose);
  return CompositeMediaAnalysisService(direct: direct);
});
