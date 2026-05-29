// ─────────────────────────────────────────────────────────────
// Quietly — Permission service provider
//
// Exposes the PermissionService to the app. AppFlow reads this to perform
// permission I/O; tests override it with a fake so no real platform channels
// are invoked.
// ─────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'permission_service.dart';

final permissionServiceProvider = Provider<PermissionService>(
  (ref) => PlatformPermissionService(),
);
