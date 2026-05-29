// ─────────────────────────────────────────────────────────────
// Quietly — Permission result mapper
//
// Translates the platform plugin's permission result (permission_handler's
// `PermissionStatus`) into Quietly's domain enum (lib/state/models/app_enums.dart).
// permission_handler is imported with the `ph` prefix because it also exports a
// type named `PermissionStatus` — our enum stays unprefixed everywhere else.
//
// This is pure logic with no platform calls, so it is unit-testable on the host.
// ─────────────────────────────────────────────────────────────

import 'package:permission_handler/permission_handler.dart' as ph;

import '../../state/models/app_enums.dart';

/// Maps a single plugin status to our domain [PermissionStatus].
///
///   granted / limited / provisional → granted   (usable for our purposes)
///   permanentlyDenied / restricted  → permanentlyDenied (needs system settings)
///   everything else (denied)        → denied      (can ask again)
PermissionStatus mapPermissionStatus(ph.PermissionStatus status) {
  if (status.isGranted || status.isLimited || status.isProvisional) {
    return PermissionStatus.granted;
  }
  if (status.isPermanentlyDenied || status.isRestricted) {
    return PermissionStatus.permanentlyDenied;
  }
  return PermissionStatus.denied;
}

/// Reduces several plugin statuses (e.g. images + video on Android 13+) to one
/// domain status: granted only if all are granted; else permanentlyDenied if
/// any is permanently denied/restricted; else denied.
PermissionStatus reducePermissionStatuses(
  Iterable<ph.PermissionStatus> statuses,
) {
  final mapped = statuses.map(mapPermissionStatus).toList();
  if (mapped.isEmpty) return PermissionStatus.denied;
  if (mapped.every((s) => s == PermissionStatus.granted)) {
    return PermissionStatus.granted;
  }
  if (mapped.any((s) => s == PermissionStatus.permanentlyDenied)) {
    return PermissionStatus.permanentlyDenied;
  }
  return PermissionStatus.denied;
}
