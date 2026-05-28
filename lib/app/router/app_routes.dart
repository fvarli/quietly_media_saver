// ─────────────────────────────────────────────────────────────
// Quietly — Route names & paths
//
// Central registry of route identifiers. One entry per screen (HANDOFF §A) plus
// the two modal sheets. Screens are full go_router routes; the sheet entries are
// NAME constants used by the modal-sheet presentation helper (sheets are shown
// via showModalBottomSheet, not as full pages — HANDOFF §E). Keeping their names
// here means "modal sheet route/state support" is centralized alongside screens.
//
// AppScreen ↔ route mapping lives in [routePathFor]/[routeNameFor] so the
// state machine and the router never drift.
// ─────────────────────────────────────────────────────────────

import '../../state/models/app_enums.dart';

abstract final class AppRoutes {
  const AppRoutes._();

  // ── Screen route names (HANDOFF §A) ───────────────────────
  static const String home = 'home';
  static const String analyzing = 'analyzing';
  static const String result = 'result';
  static const String carousel = 'carousel';
  static const String downloading = 'downloading';
  static const String success = 'success';
  static const String history = 'history';
  static const String settings = 'settings';
  static const String error = 'error';

  // ── Screen paths ──────────────────────────────────────────
  static const String homePath = '/';
  static const String analyzingPath = '/analyzing';
  static const String resultPath = '/result';
  static const String carouselPath = '/carousel';
  static const String downloadingPath = '/downloading';
  static const String successPath = '/success';
  static const String historyPath = '/history';
  static const String settingsPath = '/settings';
  static const String errorPath = '/error';

  // ── Modal sheet names (shown via showModalBottomSheet) ─────
  static const String qualitySheet = 'quality-sheet';
  static const String permissionSheet = 'permission-sheet';
}

/// go_router route name for a given state-machine [screen].
String routeNameFor(AppScreen screen) => switch (screen) {
  AppScreen.home => AppRoutes.home,
  AppScreen.analyzing => AppRoutes.analyzing,
  AppScreen.result => AppRoutes.result,
  AppScreen.carousel => AppRoutes.carousel,
  AppScreen.downloading => AppRoutes.downloading,
  AppScreen.success => AppRoutes.success,
  AppScreen.history => AppRoutes.history,
  AppScreen.settings => AppRoutes.settings,
  AppScreen.error => AppRoutes.error,
};

/// go_router location/path for a given state-machine [screen].
String routePathFor(AppScreen screen) => switch (screen) {
  AppScreen.home => AppRoutes.homePath,
  AppScreen.analyzing => AppRoutes.analyzingPath,
  AppScreen.result => AppRoutes.resultPath,
  AppScreen.carousel => AppRoutes.carouselPath,
  AppScreen.downloading => AppRoutes.downloadingPath,
  AppScreen.success => AppRoutes.successPath,
  AppScreen.history => AppRoutes.historyPath,
  AppScreen.settings => AppRoutes.settingsPath,
  AppScreen.error => AppRoutes.errorPath,
};
