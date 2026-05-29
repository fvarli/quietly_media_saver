// ─────────────────────────────────────────────────────────────
// Quietly — Preferences service
//
// Abstraction over lightweight preference persistence + the shared_preferences
// implementation. Persists only the four user preferences (selected quality +
// the three toggles); see [AppPreferences]. No media files / history are
// persisted here (that is a later pass).
//
// Platform I/O is confined here; the bootstrap layer loads on startup and a
// single ref.listen persists on change, so AppStateNotifier stays pure.
// ─────────────────────────────────────────────────────────────

import 'package:shared_preferences/shared_preferences.dart';

import '../../state/models/app_preferences.dart';

abstract interface class PreferencesService {
  /// Load persisted preferences (defaults when nothing is stored).
  Future<AppPreferences> load();

  /// Persist the given preferences.
  Future<void> save(AppPreferences prefs);
}

/// Real implementation backed by `shared_preferences`.
class SharedPreferencesService implements PreferencesService {
  static const _kQuality = 'pref.quality';
  static const _kAskQuality = 'pref.askQualityEveryTime';
  static const _kWifiOnly = 'pref.wifiOnly';
  static const _kNotify = 'pref.notify';

  @override
  Future<AppPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    const defaults = AppPreferences();
    return AppPreferences(
      quality: prefs.getString(_kQuality) ?? defaults.quality,
      askQualityEveryTime:
          prefs.getBool(_kAskQuality) ?? defaults.askQualityEveryTime,
      wifiOnly: prefs.getBool(_kWifiOnly) ?? defaults.wifiOnly,
      notify: prefs.getBool(_kNotify) ?? defaults.notify,
    );
  }

  @override
  Future<void> save(AppPreferences p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kQuality, p.quality);
    await prefs.setBool(_kAskQuality, p.askQualityEveryTime);
    await prefs.setBool(_kWifiOnly, p.wifiOnly);
    await prefs.setBool(_kNotify, p.notify);
  }
}
