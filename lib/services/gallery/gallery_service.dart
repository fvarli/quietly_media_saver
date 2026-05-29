// ─────────────────────────────────────────────────────────────
// Quietly — Gallery / file-save service (boundary)
//
// Pass 7A: real local file behavior using SAMPLE bytes — no real downloading,
// scraping, or protected-media access. `LocalGalleryService` writes a small
// synthetic file to the app documents directory on save, deletes it on remove,
// and shares it via share_plus. `open` is a documented placeholder.
//
// Real OS gallery insertion (MediaStore / Photos) + real `open` are deferred to
// Pass 7B. Operates on HistoryEntry (its [HistoryEntry.filePath] points at the
// local file). All file I/O is confined here; the notifier stays pure.
// ─────────────────────────────────────────────────────────────

import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../state/models/app_enums.dart';
import '../../state/models/history_entry.dart';

abstract interface class GalleryService {
  /// Write a sample local file for [kind] and return its path.
  Future<String> saveSample(MediaKind kind);

  /// Open the saved item (placeholder this pass — real open in 7B).
  Future<void> open(HistoryEntry entry);

  /// Share the saved item's file.
  Future<void> share(HistoryEntry entry);

  /// Delete the saved item's local file.
  Future<void> remove(HistoryEntry entry);
}

/// Saves synthetic sample bytes to the app documents directory.
class LocalGalleryService implements GalleryService {
  const LocalGalleryService();

  static const _dirName = 'quietly_media';

  @override
  Future<String> saveSample(MediaKind kind) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/$_dirName');
    if (!await dir.exists()) await dir.create(recursive: true);
    final ext = kind == MediaKind.video ? 'mp4' : 'png';
    final file = File(
      '${dir.path}/${DateTime.now().microsecondsSinceEpoch}.$ext',
    );
    await file.writeAsBytes(_sampleBytes(kind));
    return file.path;
  }

  @override
  Future<void> open(HistoryEntry entry) async {
    // TODO(7B): open the saved file with open_filex once cross-platform-safe.
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

  /// Synthetic, legally-safe placeholder bytes (NOT downloaded content):
  /// a 1×1 transparent PNG for images; a tiny labelled blob for video.
  Uint8List _sampleBytes(MediaKind kind) {
    if (kind == MediaKind.video) {
      return Uint8List.fromList('QUIETLY_SAMPLE_MEDIA'.codeUnits);
    }
    // Minimal 1×1 transparent PNG.
    return Uint8List.fromList(const [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
      0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
      0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
      0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
      0x42, 0x60, 0x82,
    ]);
  }
}
