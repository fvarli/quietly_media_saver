// ─────────────────────────────────────────────────────────────
// Quietly — App bootstrap
//
// Startup wiring that connects the platform services to the (pure) state
// notifier, so AppStateNotifier itself never performs I/O:
//   • load persisted preferences → apply
//   • seed + subscribe to connectivity → AppState.offline
//   • refresh the real permission status
// Plus a single ref.listen that persists preference changes (write-through),
// keeping persistence out of the notifier and the widgets.
//
// Every step is BEST-EFFORT: a missing platform channel (tests / unsupported
// platform) is caught and the current defaults are kept.
// ─────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/connectivity/connectivity_service_provider.dart';
import '../../services/permissions/permission_service_provider.dart';
import '../../services/preferences/preferences_service_provider.dart';
import '../../state/app_state.dart';
import '../../state/app_state_provider.dart';

class AppBootstrap {
  AppBootstrap(this._ref);

  final Ref _ref;
  StreamSubscription<bool>? _connectivitySub;

  AppStateNotifier get _notifier => _ref.read(appStateProvider.notifier);

  /// Run startup wiring. Safe to call once after the app mounts.
  Future<void> start() async {
    await _loadPreferences();
    await _initConnectivity();
    await _refreshPermission();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await _ref.read(preferencesServiceProvider).load();
      _notifier
        ..setQuality(prefs.quality)
        ..setAskQuality(prefs.askQualityEveryTime)
        ..setWifiOnly(prefs.wifiOnly)
        ..setNotify(prefs.notify);
    } catch (_) {
      // Storage unavailable — keep defaults.
    }
  }

  Future<void> _initConnectivity() async {
    final service = _ref.read(connectivityServiceProvider);
    try {
      _notifier.setOffline(!await service.isOnline());
    } catch (_) {
      // Connectivity unavailable — assume online (no banner).
    }
    try {
      _connectivitySub = service.onlineChanges().listen(
        (online) => _notifier.setOffline(!online),
        onError: (_) {},
      );
    } catch (_) {
      // Stream unavailable — no live updates.
    }
  }

  Future<void> _refreshPermission() async {
    try {
      final status = await _ref.read(permissionServiceProvider).galleryStatus();
      _notifier.setPermissionStatus(status);
    } catch (_) {
      // Permission channel unavailable — keep current status.
    }
  }

  /// Cancel the connectivity subscription (container teardown).
  void dispose() {
    _connectivitySub?.cancel();
  }
}

/// Provides [AppBootstrap] and wires preference write-through persistence: when
/// the persisted slice of state ([AppState.toPreferences]) changes, save it.
final bootstrapProvider = Provider<AppBootstrap>((ref) {
  final bootstrap = AppBootstrap(ref);

  ref.listen<AppState>(appStateProvider, (prev, next) {
    if (prev?.toPreferences != next.toPreferences) {
      // Fire-and-forget; failures must not break the UI.
      unawaited(
        ref
            .read(preferencesServiceProvider)
            .save(next.toPreferences)
            .catchError((_) {}),
      );
    }
  });

  ref.onDispose(bootstrap.dispose);
  return bootstrap;
});
