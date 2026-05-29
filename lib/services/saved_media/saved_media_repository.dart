// ─────────────────────────────────────────────────────────────
// Quietly — Saved-media repository
//
// Persistence boundary for the saved-media history list. Snapshot persistence:
// `load()` reads the whole list, `save()` writes the whole list. The bootstrap
// layer loads on startup and a single ref.listen persists on change
// (write-through), so AppStateNotifier stays pure.
//
// Pass 5D persists only the history *records* (HistoryEntry JSON) — not media
// files. The shared_preferences implementation stores them under one JSON key.
// ─────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../state/models/history_entry.dart';

abstract interface class SavedMediaRepository {
  /// Load persisted history, or `null` when nothing has been persisted yet
  /// (so the caller can keep its seed/default on first run).
  Future<List<HistoryEntry>?> load();

  /// Persist the full history list (snapshot).
  Future<void> save(List<HistoryEntry> entries);
}

class SharedPreferencesSavedMediaRepository implements SavedMediaRepository {
  static const _kKey = 'history.entries';

  @override
  Future<List<HistoryEntry>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null) return null;
    final list = (jsonDecode(raw) as List)
        .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  @override
  Future<void> save(List<HistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode([for (final e in entries) e.toJson()]);
    await prefs.setString(_kKey, raw);
  }
}
