// ─────────────────────────────────────────────────────────────
// Quietly — Connectivity service
//
// Abstraction over device connectivity + the connectivity_plus implementation.
// Drives AppState.offline (via the bootstrap layer). Keeping it behind an
// interface means the notifier/bootstrap depend on an abstraction (faked in
// tests) and all platform I/O is confined here.
//
// CAVEAT: connectivity_plus reports the presence of a network *interface*, not
// real internet reachability or captive-portal state — a connected-but-no-
// internet device reads as online. True reachability checks are deferred.
// ─────────────────────────────────────────────────────────────

import 'package:connectivity_plus/connectivity_plus.dart';

/// Whether any connectivity result represents an active network interface.
/// Pure (no platform calls) so it is host-unit-testable.
bool isOnlineFromResults(List<ConnectivityResult> results) =>
    results.any((r) => r != ConnectivityResult.none);

/// Online/offline state, in domain terms (`true` = online).
abstract interface class ConnectivityService {
  /// Current connectivity snapshot.
  Future<bool> isOnline();

  /// Stream of online/offline changes.
  Stream<bool> onlineChanges();
}

/// Real implementation backed by `connectivity_plus`.
class ConnectivityPlusService implements ConnectivityService {
  ConnectivityPlusService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> isOnline() async =>
      isOnlineFromResults(await _connectivity.checkConnectivity());

  @override
  Stream<bool> onlineChanges() =>
      _connectivity.onConnectivityChanged.map(isOnlineFromResults);
}
