// ─────────────────────────────────────────────────────────────
// Quietly — go_router configuration
//
// Navigation source of truth + real back-stack (HANDOFF §6/§D: replaces the
// prototype's flat `screen` switch where Back always returned Home). One
// [GoRoute] per screen (HANDOFF §A). Each screen pushes onto the stack so Back
// pops correctly (e.g. home → analyzing → result → history → Back → result).
//
// The router is exposed as a Riverpod provider so it can be lifecycle-scoped and
// later read state (e.g. redirect guards) without a global singleton.
//
// Modal sheets (quality, permission) are intentionally NOT routes here — they
// are presented with showModalBottomSheet via lib/app/router/sheets.dart, per
// HANDOFF §E. Their names live in AppRoutes for a single registry.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/analyzing/analyzing_screen.dart';
import '../../features/carousel/carousel_screen.dart';
import '../../features/downloading/downloading_screen.dart';
import '../../features/error/error_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/result/result_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/success/success_screen.dart';
import 'app_routes.dart';

/// Provides the app's [GoRouter]. Kept in a provider so future redirect guards
/// (e.g. permission gating) can read other providers.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.homePath,
    debugLogDiagnostics: false,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.analyzingPath,
        name: AppRoutes.analyzing,
        builder: (context, state) => const AnalyzingScreen(),
      ),
      GoRoute(
        path: AppRoutes.resultPath,
        name: AppRoutes.result,
        builder: (context, state) => const ResultScreen(),
      ),
      GoRoute(
        path: AppRoutes.carouselPath,
        name: AppRoutes.carousel,
        builder: (context, state) => const CarouselScreen(),
      ),
      GoRoute(
        path: AppRoutes.downloadingPath,
        name: AppRoutes.downloading,
        builder: (context, state) => const DownloadingScreen(),
      ),
      GoRoute(
        path: AppRoutes.successPath,
        name: AppRoutes.success,
        builder: (context, state) => const SuccessScreen(),
      ),
      GoRoute(
        path: AppRoutes.historyPath,
        name: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsPath,
        name: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.errorPath,
        name: AppRoutes.error,
        builder: (context, state) => const ErrorScreen(),
      ),
    ],
    errorBuilder: (context, state) => const _RouteNotFound(),
  );
});

class _RouteNotFound extends StatelessWidget {
  const _RouteNotFound();

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Route not found'));
}
