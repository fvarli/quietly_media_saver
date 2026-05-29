// ─────────────────────────────────────────────────────────────
// Quietly — Reachability service
//
// connectivity_plus reports the presence of a network *interface*, not real
// internet reachability (a connected-but-no-internet / captive-portal device
// reads as online). This service adds a lightweight, real reachability probe so
// the offline banner only flips when we're reasonably certain.
//
// The probe is a small HEAD to a neutral "generate 204" endpoint with a short
// timeout. It is deliberately tri-state: a clear success → online, a clear
// connection failure → offline, anything ambiguous (timeout / unexpected) →
// unknown, so the caller can choose NOT to change the banner on uncertainty.
//
// No content is fetched; no scraping; the endpoint is a standard connectivity
// check. The http.Client is injectable so tests never hit the network.
// ─────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Tri-state reachability result. `unknown` means "don't change the banner".
enum Reachability { online, offline, unknown }

abstract interface class ReachabilityService {
  /// Probe real internet reachability. Never throws — ambiguity → [Reachability.unknown].
  Future<Reachability> check();
}

/// Real implementation: a short HEAD to a neutral generate-204 endpoint.
class HttpReachabilityService implements ReachabilityService {
  HttpReachabilityService({
    http.Client? client,
    Uri? endpoint,
    this.timeout = const Duration(seconds: 3),
  }) : _client = client ?? http.Client(),
       _endpoint =
           endpoint ?? Uri.parse('https://www.gstatic.com/generate_204');

  final http.Client _client;
  final Uri _endpoint;
  final Duration timeout;

  @override
  Future<Reachability> check() async {
    try {
      final resp = await _client.head(_endpoint).timeout(timeout);
      // 2xx (generate_204 → 204) means we reached the internet.
      return (resp.statusCode >= 200 && resp.statusCode < 400)
          ? Reachability.online
          : Reachability.unknown;
    } on SocketException {
      // No route / connection refused / DNS failure → confidently offline.
      return Reachability.offline;
    } on TimeoutException {
      // Slow or captive — don't claim either way.
      return Reachability.unknown;
    } on http.ClientException {
      return Reachability.unknown;
    } catch (_) {
      return Reachability.unknown;
    }
  }

  /// Closes the underlying client (the provider calls this on dispose).
  void dispose() => _client.close();
}
