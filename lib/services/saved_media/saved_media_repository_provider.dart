// ─────────────────────────────────────────────────────────────
// Quietly — Saved-media repository provider
//
// Exposes the SavedMediaRepository to the bootstrap layer. Overridden with a
// fake in tests so no real platform channels are invoked.
// ─────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'saved_media_repository.dart';

final savedMediaRepositoryProvider = Provider<SavedMediaRepository>(
  (ref) => SharedPreferencesSavedMediaRepository(),
);
