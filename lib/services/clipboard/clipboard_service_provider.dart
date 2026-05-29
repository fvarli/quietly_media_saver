// ─────────────────────────────────────────────────────────────
// Quietly — Clipboard service provider
//
// Exposes the ClipboardService. Overridden with a fake in tests so no real
// platform channel is invoked.
// ─────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'clipboard_service.dart';

final clipboardServiceProvider = Provider<ClipboardService>(
  (ref) => const FlutterClipboardService(),
);
