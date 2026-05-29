// ─────────────────────────────────────────────────────────────
// Quietly — Permission service
//
// Abstraction over the OS gallery/media permission, plus the real
// permission_handler-backed implementation. Keeping this behind an interface
// means AppFlow depends on an abstraction (testable with a fake) and all
// platform I/O is confined here — AppStateNotifier stays pure.
//
// Pass 5A: request/read media permission only. Write/save permissions arrive
// with the gallery-save pass (5C).
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

/// Real implementation backed by `permission_handler`. Chooses the correct
/// permission set per platform/OS version (Android 13+ scoped media vs older
/// storage; iOS Photos) and reduces multi-permission results to one status.
class PlatformPermissionService implements PermissionService {
  PlatformPermissionService({DeviceInfoPlugin? deviceInfo})
    : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfo;
  int? _androidSdkInt; // cached after first lookup

  Future<List<ph.Permission>> _galleryPermissions() async {
    if (Platform.isAndroid) {
      final sdkInt = _androidSdkInt ??=
          (await _deviceInfo.androidInfo).version.sdkInt;
      // Android 13 (API 33)+ uses scoped media permissions; older uses storage.
      return sdkInt >= 33
          ? const [ph.Permission.photos, ph.Permission.videos]
          : const [ph.Permission.storage];
    }
    // iOS (and other platforms): Photos library.
    return const [ph.Permission.photos];
  }

  @override
  Future<PermissionStatus> galleryStatus() async {
    final permissions = await _galleryPermissions();
    final statuses = [for (final p in permissions) await p.status];
    return reducePermissionStatuses(statuses);
  }

  @override
  Future<PermissionStatus> requestGalleryPermission() async {
    final permissions = await _galleryPermissions();
    final results = await permissions.request();
    return reducePermissionStatuses(results.values);
  }

  @override
  Future<bool> openSystemSettings() => ph.openAppSettings();
}
