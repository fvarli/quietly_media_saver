// ─────────────────────────────────────────────────────────────
// Quietly — Clipboard service
//
// Thin boundary over the system clipboard so the Paste flow can read a copied
// link (and Home can suggest it). No special permissions are required to read
// the clipboard on tap. Faked in tests.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/services.dart';

abstract interface class ClipboardService {
  /// The current plain-text clipboard contents, or null when empty/unavailable.
  Future<String?> readText();
}

class FlutterClipboardService implements ClipboardService {
  const FlutterClipboardService();

  @override
  Future<String?> readText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }
}
