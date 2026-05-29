// ─────────────────────────────────────────────────────────────
// Quietly — Gallery service provider
//
// Exposes the GalleryService. Defaults to the no-op placeholder; overridden
// with a fake in tests to assert open/share/remove are invoked.
// ─────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'gallery_service.dart';

final galleryServiceProvider = Provider<GalleryService>(
  (ref) => const LocalGalleryService(),
);
