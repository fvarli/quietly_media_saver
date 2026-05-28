// ─────────────────────────────────────────────────────────────
// Quietly — Entry point
//
// A rights-aware, Play-Store-safe media saver: it helps people save public
// media they have the rights to. See docs/design-handoff/HANDOFF.md for the
// product spec and docs/ARCHITECTURE.md for the app structure.
//
// This installs the Riverpod ProviderScope above the app and runs QuietlyApp.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/quietly_app.dart';

void main() {
  runApp(const ProviderScope(child: QuietlyApp()));
}
