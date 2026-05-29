// ─────────────────────────────────────────────────────────────
// Quietly — Preferences service provider
//
// Exposes the PreferencesService to the bootstrap layer. Overridden with a fake
// in tests so no real platform channels are invoked.
// ─────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'preferences_service.dart';

final preferencesServiceProvider = Provider<PreferencesService>(
  (ref) => SharedPreferencesService(),
);
