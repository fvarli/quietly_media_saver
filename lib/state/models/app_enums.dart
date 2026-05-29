// ─────────────────────────────────────────────────────────────
// Quietly — State-machine enums
//
// Mirrors the prototype state machine (HANDOFF §D, docs/design-handoff/app/app.jsx):
//   screen ∈ {home, analyzing, result, carousel, downloading, success,
//             history, settings, error}
//   sheet  ∈ {null, quality, permission}
//   error  ∈ ERROR_CONFIG keys
//
// Navigation itself is driven by go_router (see lib/app/router); these enums are
// the typed state-machine representation used by AppState and to resolve route
// paths. Keeping them as enums (not strings) makes transitions exhaustive and
// analyzer-checked.
// ─────────────────────────────────────────────────────────────

/// The nine primary screens of the wizard/flow.
enum AppScreen {
  home,
  analyzing,
  result,
  carousel,
  downloading,
  success,
  history,
  settings,
  error,
}

/// Modal bottom sheets that overlay a screen. `null` = no sheet open, modeled
/// here as the absence of a value (AppState.sheet is nullable).
enum AppSheet { quality, permission }

/// Edge/error variants — keys of ERROR_CONFIG (see lib/state/error_config.dart).
enum AppErrorKind {
  protected,
  invalid,
  network,
  unsupported,
  storage,
  exists,
  permissionDeniedPermanently,
  queueItemFailed,
}

/// Gallery/storage permission status. Mirrors the three states a real OS
/// permission can resolve to (see Pass 5 `permission_handler` mapping):
///   granted · denied (can re-ask) · permanentlyDenied (must open settings).
enum PermissionStatus { granted, denied, permanentlyDenied }

/// Media kind for tiles/history/queue (`kind` in the prototype seed data).
enum MediaKind { video, image, carousel }
