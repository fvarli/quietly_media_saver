// ─────────────────────────────────────────────────────────────
// Quietly — Permission service
//
// Abstraction over the OS gallery/media permission, plus the real
// permission_handler-backed implementation. Keeping this behind an interface
// means AppFlow depends on an abstraction (testable with a fake) and all
// platform I/O is confined here — AppStateNotifier stays pure.
//
// Save-only: Quietly writes media to the gallery and never reads the user's
// library, so it requests the minimal write access (none on Android 10+).
// ─────────────────────────────────────────────────────────────

import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../../state/models/app_enums.dart';
import 'permission_result_mapper.dart';

/// Gallery/media permission operations, in terms of the domain
/// [PermissionStatus]. Implemented by [PlatformPermissionService]; faked in tests.
abstract interface class PermissionService {
  /// Current status without prompting the user.
  Future<PermissionStatus> galleryStatus();

  /// Prompt for gallery/media access and return the resulting status.
  Future<PermissionStatus> requestGalleryPermission();

  /// Open the OS app-settings page (for the permanently-denied case).
  /// Returns whether the settings page was opened.
  Future<bool> openSystemSettings();
}

/// Real implementation backed by `permission_handler`. Quietly only SAVES
/// (writes) media — it never reads/browses the user's library — so it requests
/// the minimal write-only access: nothing on Android 10+ (API 29+, scoped
/// MediaStore), `WRITE_EXTERNAL_STORAGE` on pre-Q (≤28), and add-only Photos on
/// iOS. Multi-permission results are reduced to one status.
class PlatformPermissionService implements PermissionService {
  PlatformPermissionService({DeviceInfoPlugin? deviceInfo})
    : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfo;
  int? _androidSdkInt; // cached after first lookup

  /// The runtime permissions needed to SAVE media. Empty means none are required
  /// (the caller treats that as already granted).
  Future<List<ph.Permission>> _galleryPermissions() async {
    if (Platform.isAndroid) {
      final sdkInt = _androidSdkInt ??=
          (await _deviceInfo.androidInfo).version.sdkInt;
      // API 29+ (scoped MediaStore): saving needs no runtime permission.
      // Pre-Q (≤28): WRITE_EXTERNAL_STORAGE to insert into the gallery.
      return sdkInt >= 29
          ? const <ph.Permission>[]
          : const [ph.Permission.storage];
    }
    // iOS (and other platforms): add-only Photos (write), never full-library read.
    return const [ph.Permission.photosAddOnly];
  }

  @override
  Future<PermissionStatus> galleryStatus() async {
    final permissions = await _galleryPermissions();
    if (permissions.isEmpty) return PermissionStatus.granted; // nothing to ask
    final statuses = [for (final p in permissions) await p.status];
    return reducePermissionStatuses(statuses);
  }

  @override
  Future<PermissionStatus> requestGalleryPermission() async {
    final permissions = await _galleryPermissions();
    if (permissions.isEmpty) return PermissionStatus.granted; // nothing to ask
    final results = await permissions.request();
    return reducePermissionStatuses(results.values);
  }

  @override
  Future<bool> openSystemSettings() => ph.openAppSettings();
}
