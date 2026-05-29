// ─────────────────────────────────────────────────────────────
// Quietly — Connectivity service provider
//
// Exposes the ConnectivityService to the bootstrap layer. Overridden with a
// fake in tests so no real platform channels are invoked.
// ─────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connectivity_service.dart';

final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => ConnectivityPlusService(),
);
