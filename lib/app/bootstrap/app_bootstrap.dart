// ─────────────────────────────────────────────────────────────
// Quietly — App bootstrap
//
// Startup wiring that connects the platform services to the (pure) state
// notifier, so AppStateNotifier itself never performs I/O:
//   • load persisted preferences → apply (and resolve the first-run flag)
//   • seed + subscribe to connectivity, confirmed by a real reachability probe
//   • refresh the real permission status
//   • detect a clipboard link
// Plus a single ref.listen that persists preference changes (write-through),
// keeping persistence out of the notifier and the widgets.
//
// [onResume] re-runs the one-shot refreshers (permission, reachability,
// clipboard) without re-subscribing to connectivity — the single subscription
// from [start] survives across resume, so there are no duplicate listeners.
//
// Every step is BEST-EFFORT: a missing platform channel (tests / unsupported
// platform) is caught and the current defaults are kept.
// ─────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/analysis/media_analysis_service.dart';
import '../../services/clipboard/clipboard_service_provider.dart';
import '../../services/connectivity/connectivity_service_provider.dart';
import '../../services/permissions/permission_service_provider.dart';
import '../../services/preferences/preferences_service_provider.dart';
import '../../services/reachability/reachability_service.dart';
import '../../services/reachability/reachability_service_provider.dart';
import '../../services/saved_media/saved_media_repository_provider.dart';
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
    await _loadHistory();
    await _initConnectivity();
    await _refreshPermission();
    await refreshClipboard();
  }

  /// Re-run the one-shot refreshers when the app returns to the foreground.
  /// Does NOT re-subscribe to connectivity (the [start] subscription persists),
  /// so no duplicate listeners accumulate.
  Future<void> onResume() async {
    await _refreshPermission();
    await refreshClipboard();
    await _refreshConnectivity();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await _ref.read(preferencesServiceProvider).load();
      _notifier
        ..setQuality(prefs.quality)
        ..setAskQuality(prefs.askQualityEveryTime)
        ..setWifiOnly(prefs.wifiOnly)
        ..setNotify(prefs.notify)
        ..setLanguageMode(prefs.languageMode)
        ..setFirstRunAcknowledged(prefs.firstRunAcknowledged)
        // Prefs loaded → the first-run flag is now authoritative.
        ..markFirstRunResolved();
    } catch (_) {
      // Storage unavailable — keep defaults (gate stays unresolved → not shown).
    }
  }

  /// Best-effort: surface a copied link as a Home suggestion (first mount +
  /// resume). One implementation, also called by HomeScreen.
  Future<void> refreshClipboard() async {
    try {
      final text = await _ref.read(clipboardServiceProvider).readText();
      final trimmed = text?.trim() ?? '';
      if (trimmed.isNotEmpty && isLikelyUrl(trimmed)) {
        _notifier.setClipboardUrl(trimmed);
      }
    } catch (_) {
      // Clipboard unavailable — leave the manual paste option.
    }
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _ref.read(savedMediaRepositoryProvider).load();
      if (history != null) _notifier.setHistory(history);
    } catch (_) {
      // Storage unavailable — keep the seed/default history.
    }
  }

  Future<void> _initConnectivity() async {
    final service = _ref.read(connectivityServiceProvider);
    // Subscribe ONCE. No interface → certainly offline; interface up → confirm
    // real reachability before clearing the banner.
    try {
      _connectivitySub = service.onlineChanges().listen((online) {
        if (!online) {
          _notifier.setOffline(true);
        } else {
          unawaited(_confirmReachability());
        }
      }, onError: (_) {});
    } catch (_) {
      // Stream unavailable — no live updates.
    }
    // Initial seed/confirm, non-blocking so startup isn't gated on the probe.
    unawaited(_refreshConnectivity());
  }

  /// Read the connectivity interface; if present, confirm real reachability.
  /// Flips the banner only when reasonably certain (unknown leaves it as-is).
  Future<void> _refreshConnectivity() async {
    bool interface;
    try {
      interface = await _ref.read(connectivityServiceProvider).isOnline();
    } catch (_) {
      return; // connectivity unavailable — leave the banner unchanged
    }
    if (!interface) {
      _notifier.setOffline(true); // no interface → certainly offline
      return;
    }
    await _confirmReachability();
  }

  /// Probe true internet reachability; only flip the banner on certainty.
  Future<void> _confirmReachability() async {
    try {
      final result = await _ref.read(reachabilityServiceProvider).check();
      switch (result) {
        case Reachability.online:
          _notifier.setOffline(false);
        case Reachability.offline:
          _notifier.setOffline(true);
        case Reachability.unknown:
          break; // not certain — leave the banner unchanged
      }
    } catch (_) {
      // Probe unavailable — leave the banner unchanged.
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
    // Preferences write-through.
    if (prev?.toPreferences != next.toPreferences) {
      // Fire-and-forget; failures must not break the UI.
      unawaited(
        ref
            .read(preferencesServiceProvider)
            .save(next.toPreferences)
            .catchError((_) {}),
      );
    }
    // History write-through (the list reference changes only on a real change).
    if (!identical(prev?.history, next.history)) {
      unawaited(
        ref
            .read(savedMediaRepositoryProvider)
            .save(next.history)
            .catchError((_) {}),
      );
    }
  });

  ref.onDispose(bootstrap.dispose);
  return bootstrap;
});
