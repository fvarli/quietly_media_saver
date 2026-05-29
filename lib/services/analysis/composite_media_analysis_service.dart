// ─────────────────────────────────────────────────────────────
// Quietly — Composite media analysis service
//
// Routes between the real direct-media analyzer and the deterministic sample.
// Demo / documentation URLs use the reserved `*.example.com` hosts, which are
// routed to the offline SampleMediaAnalysisService — so the shipped demo and the
// test suite stay deterministic and never touch the network. Every other URL
// goes to DirectMediaAnalysisService (a real HTTP probe of a direct public media
// file). The MediaAnalysisService interface is unchanged.
// ─────────────────────────────────────────────────────────────

import '../../state/models/analysis_result.dart';
import 'direct_media_analysis_service.dart';
import 'media_analysis_service.dart';

class CompositeMediaAnalysisService implements MediaAnalysisService {
  CompositeMediaAnalysisService({
    required this.direct,
    this.sample = const SampleMediaAnalysisService(),
  });

  final DirectMediaAnalysisService direct;
  final MediaAnalysisService sample;

  @override
  Future<AnalysisResult> analyze(String url) =>
      _isDemoHost(url) ? sample.analyze(url) : direct.analyze(url);

  /// Reserved documentation/demo hosts (RFC 2606) → the offline sample.
  static bool _isDemoHost(String url) {
    final u = url.trim();
    final withScheme = u.startsWith('http') ? u : 'https://$u';
    final host = Uri.tryParse(withScheme)?.host ?? '';
    return host == 'example.com' || host.endsWith('.example.com');
  }
}
