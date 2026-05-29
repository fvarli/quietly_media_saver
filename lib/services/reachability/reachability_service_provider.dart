// ─────────────────────────────────────────────────────────────
// Quietly — Reachability service provider
//
// Exposes the ReachabilityService (real HTTP probe). Faked in tests. The bootstrap
// layer uses it to confirm connectivity before flipping the offline banner.
// ─────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'reachability_service.dart';

final reachabilityServiceProvider = Provider<ReachabilityService>((ref) {
  final service = HttpReachabilityService();
  ref.onDispose(service.dispose);
  return service;
});
