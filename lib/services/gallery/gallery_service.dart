// ─────────────────────────────────────────────────────────────
// Quietly — Gallery / file-save service (boundary)
//
// Pass 7B: real OS gallery integration (Android-first) using SAMPLE bytes — no
// real downloading, scraping, or protected-media access. `OsGalleryService`
// writes a local app-documents copy (the canonical reference for open/share/
// remove) AND inserts a copy into the device gallery via `gal` (best-effort).
// `open` uses open_filex; `share` uses share_plus; `remove` deletes the local
// copy (the gallery copy is user-managed — gal exposes no delete).
//
// Write/space failures throw [GallerySaveException] (storageFull on ENOSPC); the
// gallery insert is best-effort and never fails the save. iOS save is
// structurally supported (gal + NSPhotoLibraryAddUsageDescription) but add-only
// permission wiring is deferred (Android-first).
// ─────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:gal/gal.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../state/models/app_enums.dart';
import '../../state/models/history_entry.dart';

/// Raised when a save can't be written. [storageFull] when the device is out of
/// space (mapped to the "Not enough space" error).
class GallerySaveException implements Exception {
  const GallerySaveException({this.storageFull = false});
  final bool storageFull;

  @override
  String toString() => 'GallerySaveException(storageFull: $storageFull)';
}

abstract interface class GalleryService {
  /// Import a downloaded file at [sourcePath] for [kind]: copy it into app
  /// storage, insert a copy into the OS gallery, and return the saved local
  /// path. Throws [GallerySaveException] on write failure (e.g. no space).
  Future<String> saveFile(MediaKind kind, String sourcePath);

  /// Open the saved item with the OS default app.
  Future<void> open(HistoryEntry entry);

  /// Share the saved item's file.
  Future<void> share(HistoryEntry entry);

  /// Delete the saved item's local file.
  Future<void> remove(HistoryEntry entry);
}

/// Imports downloaded files into app storage + the device gallery.
class OsGalleryService implements GalleryService {
  const OsGalleryService();

  static const _dirName = 'quietly_media';

  @override
  Future<String> saveFile(MediaKind kind, String sourcePath) async {
    final isVideo = kind == MediaKind.video;
    final ext = isVideo ? 'mp4' : 'png';
    final String path;
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}/$_dirName');
      if (!await dir.exists()) await dir.create(recursive: true);
      final dest = File(
        '${dir.path}/${DateTime.now().microsecondsSinceEpoch}.$ext',
      );
      await File(sourcePath).copy(dest.path);
      path = dest.path;
    } on FileSystemException catch (e) {
      // errno 28 == ENOSPC (no space left on device).
      throw GallerySaveException(storageFull: e.osError?.errorCode == 28);
    } catch (_) {
      throw const GallerySaveException();
    }

    // Best-effort: insert a copy into the OS gallery. Failure (unsupported
    // platform / permission) does not fail the save — the local copy remains.
    try {
      if (isVideo) {
        await Gal.putVideo(path);
      } else {
        await Gal.putImage(path);
      }
    } catch (_) {
      // Gallery insert unavailable — keep the local copy only.
    }

    return path;
  }

  @override
  Future<void> open(HistoryEntry entry) async {
    final path = entry.filePath;
    if (path == null) return;
    try {
      await OpenFilex.open(path);
    } catch (_) {
      // No handler / unsupported — no-op.
    }
  }

  @override
  Future<void> share(HistoryEntry entry) async {
    final path = entry.filePath;
    if (path == null || !await File(path).exists()) return;
    try {
      await SharePlus.instance.share(ShareParams(files: [XFile(path)]));
    } catch (_) {
      // Sharing unsupported on this platform — no-op.
    }
  }

  @override
  Future<void> remove(HistoryEntry entry) async {
    final path = entry.filePath;
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Already gone / not removable — ignore.
    }
  }
}
