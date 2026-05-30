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
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/result/result_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/success/success_screen.dart';
import '../../state/app_state.dart';
import '../../state/app_state_provider.dart';
import 'app_routes.dart';

/// Provides the app's [GoRouter]. The first-run redirect routes new users to
/// onboarding; a [ValueNotifier] bridged to the first-run state re-evaluates the
/// redirect when onboarding completes.
final routerProvider = Provider<GoRouter>((ref) {
  // Re-run the redirect whenever the first-run gate condition changes.
  final refresh = ValueNotifier<int>(0);
  ref.listen<bool>(
    appStateProvider.select(
      (AppState s) => s.firstRunResolved && !s.firstRunAcknowledged,
    ),
    (_, _) => refresh.value++,
  );
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.homePath,
    debugLogDiagnostics: false,
    refreshListenable: refresh,
    redirect: (context, state) {
      final s = ref.read(appStateProvider);
      // Only gate once prefs have resolved (fail open if storage is unavailable).
      final needsOnboarding = s.firstRunResolved && !s.firstRunAcknowledged;
      final atOnboarding = state.matchedLocation == AppRoutes.onboardingPath;
      if (needsOnboarding && !atOnboarding) return AppRoutes.onboardingPath;
      if (!needsOnboarding && atOnboarding) return AppRoutes.homePath;
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.onboardingPath,
        name: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
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
