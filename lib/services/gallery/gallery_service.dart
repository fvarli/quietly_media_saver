// ─────────────────────────────────────────────────────────────
// Quietly — Gallery service (boundary)
//
// The boundary for OS gallery/file operations on saved media. Pass 5D ships a
// placeholder (no-op) implementation and wires open/share/remove from the
// History row actions through it; a real plugin-backed implementation (actual
// file open/share/remove, and save during the download pass) will implement the
// same interface later.
//
// These operate on a HistoryEntry (its future [HistoryEntry.filePath] will point
// at the real file). No real file I/O this pass.
// ─────────────────────────────────────────────────────────────

import '../../state/models/history_entry.dart';

abstract interface class GalleryService {
  /// Open the saved item in the device gallery.
  Future<void> open(HistoryEntry entry);

  /// Share the saved item.
  Future<void> share(HistoryEntry entry);

  /// Remove the saved item's file from the gallery.
  Future<void> remove(HistoryEntry entry);

  /// Save bytes/file to the gallery (future — unwired this pass).
  /// Returns whether the save succeeded.
  Future<bool> save(HistoryEntry entry);
}

/// No-op placeholder. Real gallery I/O arrives in a later pass; until then these
/// succeed silently (the UI provides its own "coming soon" feedback) and [save]
/// reports unsupported.
class PlaceholderGalleryService implements GalleryService {
  const PlaceholderGalleryService();

  @override
  Future<void> open(HistoryEntry entry) async {}

  @override
  Future<void> share(HistoryEntry entry) async {}

  @override
  Future<void> remove(HistoryEntry entry) async {}

  @override
  Future<bool> save(HistoryEntry entry) async => false;
}
