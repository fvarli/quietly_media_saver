# Quietly — Architecture

_Living document. Updated with every structural decision._
_Pass 1 (2026-05-29): app shell + design tokens + navigation/state skeleton._
_Pass 2 (2026-05-29): Home/Analyzing/Result UI + shared design-system components._

Quietly is a **rights-aware, Play-Store-safe** media saver: it helps people save
**public** media they have the rights to. The product spec is the design handoff
in [`docs/design-handoff/HANDOFF.md`](design-handoff/HANDOFF.md). This file
records how the Flutter app is structured and **why**.

---

## Pass 2 — Home / Analyzing / Result UI

Builds the real core-flow UI on the pass-1 foundation, plus the reusable
design-system components the rest of the app will share. Still presentation
only: no downloader, no `permission_handler`, no real URL analysis.

### Component convention (`Q` prefix)
Design-system widgets live in `lib/core/widgets/` and are prefixed `Q` to avoid
clashing with Material (`QButton`, `QCard`, `QPill`, `QMediaTile`, `QTopBar`,
`QSectionLabel`, `QRing`, `QDots`). Non-colliding helpers keep plain names
(`RightsNote`, `UrlChip`). All actionable components are ≥48dp and expose
`Semantics`; decorative icons use `ExcludeSemantics`; text scaling is never
locked.

| Component | Notes |
|---|---|
| `QButton` | 5 variants (primary/soft/ghost/outline/danger) × 3 sizes; optional icon; 0.965 press-scale; button semantics. |
| `QCard` | Surface + hairline (accent when active) + token shadow; tappable variant adds InkWell + ≥48dp + semantic label. |
| `QPill` | Tone→token bg/fg pairs; optional icon. |
| `QMediaTile` | **Abstract** gradient + glyph + diagonal hatch placeholder — never real media (Play-Store safety). Badge/label/dim/locked/selected; image semantics. |
| `QTopBar` | `PreferredSizeWidget` wizard bar: back (≥48, "Back") + centered title + right slot. |
| `QRing` / `QDots` | `CustomPaint` progress ring (reused later for downloads) + pulsing thinking dots. |
| `UrlChip` | Mono URL + trailing status pill (e.g. "Public"). |

### Icons — `QIcons` mapping layer
`lib/core/icons/q_icons.dart` maps product-level names (`QIcons.link`,
`QIcons.sliders`, …) to the closest **Material** icons. App code references
intent, so swapping in the handoff's custom SVG glyph set later is a one-file
change. (Material icons chosen this pass; custom SVG is deferred polish.)

### Screens
- **Home** (`features/home`): brand header + history/settings circle buttons,
  paste hero, **static** clipboard card (example URL → `flow.paste()`; real
  `Clipboard` read deferred), recent-saves strip (`QMediaTile` from seed),
  primary CTA, `RightsNote`. Middle is scroll-centered (no overflow on short
  screens / large text).
- **Analyzing** (`features/analyzing`): `QRing` + `QDots` + 3-step explainable
  checklist + `UrlChip`. **Simulated** analysis — a single finite
  `AnimationController` (`kAnalyzeDuration` = 2.7s) drives both the ring and
  step completion and, on completion, auto-advances to Result via `AppFlow`.
  One controller (not several `Timer`s) keeps it deterministic and testable.
- **Result** (`features/result`): abstract `QMediaTile` preview, source/format
  `QPill`s, explainable note, quality row (`QCard` → opens the quality sheet,
  reflecting `AppState.quality` live), "Save to gallery" → existing
  `AppFlow.requestSave` (pass-1 permission sheet). Share is a no-op placeholder.
- **Quality sheet**: unchanged behavior; restyled onto `QPill`/`QButton`.

### Testing note
Only screens with infinite animations (Analyzing's `QDots`/ring) must avoid
`pumpAndSettle` — their tests advance time with explicit `pump(Duration)`.
Widget tests set a phone-sized viewport; note the test font renders glyphs much
wider than real fonts, so row labels that can grow are kept `Flexible`.

### Still on `PlaceholderScaffold` (polished later)
Carousel, Downloading, Success, History, Settings, Error. Carousel/Error are
reachable by route but not surfaced from Result (which now matches the
prototype). Real flow into them arrives with the analysis/queue passes.

---

## Pass 3 — Carousel / Download / Success UI

Polishes the remaining core-flow screens with the `Q` library. Presentation
only: no real downloader, `permission_handler`, or gallery/storage. After this
pass the whole happy path is clickable: Home → Analyzing → Result → (quality) →
Save → permission → Download → Success.

### New component
- **`QBar`** (`lib/core/widgets/q_bar.dart`): linear progress (token track +
  accent fill, rounded), companion to `QRing`. Decorative — the enclosing row
  carries the semantic label. Used for per-item queue progress.

### Simulated progress (visual-only, notifier stays pure)
`DownloadingScreen` is a `ConsumerStatefulWidget` with one finite
`AnimationController` (`kDownloadDuration` ≈ 2.6s) — the same pattern as
`AnalyzingScreen`. It animates the ring / per-item bars 0→100% and, on
completion (guarded by `mounted`), calls `AppFlow.finishDownload()` → Success.
It **never mutates `AppState`** — the queue/items come from `AppState.queue`
(seeded by `AppStateNotifier.startDownload`); the controller only drives
visuals. Multi-item bars use a **stagger** so items finish at different times.
`kDownloadDuration` is exported for test timing.

### Screens
- **Carousel** (`features/carousel`): `QTopBar` (Select all/Clear) + `QPill`
  count chip + scrollable `QCard` rows (compact `QMediaTile` + title + mono
  meta + check), tap toggles via `AppStateNotifier.toggleCarouselItem`; sticky
  footer `QButton` ("Save N · ≈ X MB", disabled at 0) → `AppFlow.requestSave` →
  permission sheet → simulated download. `RightsNote(save)`. Reads
  `selectedCount`/`selectedSizeMb`/`selectedCarousel`/`allCarouselSelected`.
- **Download** (`features/downloading`): single → big `QRing` + fabricated
  bytes/speed caption; multi → overall `QRing` + `done/remaining` + scrollable
  `QCard` rows with `QBar` + completion check. Sticky outline `QButton`
  "Cancel" → Home. Rows wrapped in progress `Semantics`.
- **Success** (`features/success`): spring-pop check (finite
  `TweenAnimationBuilder` on `AppMotion.spring`), saved title/subtitle,
  `QMediaTile` strip from `lastSaved`, `QPill("Added to your history")`, and
  three CTAs — "Open in gallery" (**placeholder** → `SnackBar`; no real
  gallery), "View history" → `AppFlow.openHistory`, "Save another link" → Home.

### Now on `PlaceholderScaffold` (still later): History, Settings, Error only.

---

## Pass 4 — History / Settings / Error states

Completes the remaining non-service UI surfaces, plus an offline banner and
retry/try-again UX. Presentation + pure-state only: no `permission_handler`,
downloader, or gallery/storage. After this pass **every screen has real UI**;
`PlaceholderScaffold` is unused (kept as documentation of the shell pattern).

### Model additions (notifier stays pure)
- `AppErrorKind` gains `permissionDeniedPermanently`, `queueItemFailed` (now 8).
- New `PermissionStatus { granted, denied, permanentlyDenied }`. `AppState`
  replaces the `permissionGranted` **bool** with a `permissionStatus` field +
  a derived `bool get permissionGranted` (call sites/tests unchanged). This is
  the exact shape Pass 5's `permission_handler` will map onto.
- `AppState.offline` (bool) drives the Home banner.
- New pure notifier methods: `grantPermission` (→ granted), `setPermissionStatus`,
  `setOffline`, `clearHistory`, `removeHistoryEntry` (by identity).
- `kErrorConfig` gains the two new configs (data-only; still no Flutter import).

### Config-driven ErrorScreen
One screen renders all 8 kinds from `kErrorConfig` (tone badge, title, body,
optional "You can try" tips, CTAs, refusal `RightsNote` for protected/
unsupported). The UI layer maps the config's string `icon`/`ctaIcon` → `QIcons`
(`_errorIcon`) and `tone` → token colors, and resolves **per-kind CTA actions**
in one `switch` over `AppErrorKind` using `AppFlow` + placeholder SnackBars:
- network → Retry = `retryAnalysis`; queueItemFailed → Retry = `retryDownload`
  (both new `AppFlow` methods that re-enter Analyzing/Download, replacing the
  error in the stack);
- protected/invalid/unsupported → "Try another link"/"Paste again" = `goHome`;
- storage → secondary "Manage storage" = `openSettings`;
- exists → "Open in gallery" = gallery SnackBar placeholder;
- permissionDeniedPermanently → "Open settings" = system-settings SnackBar
  placeholder.

### History & Settings
- **History**: `QTopBar` + (empty state | storage summary + day-grouped `QCard`
  rows from `AppState.historyGroups`). Row `moreVertical` → actions sheet that
  pops an id; the caller does Open/Share (SnackBar placeholders) or Remove
  (`removeHistoryEntry`). Search is a placeholder. Storage MB is fabricated.
- **Settings**: calm grouped sections (`_SettingsGroup`/`_SettingsRow`, ≥48dp,
  Semantics): Downloads (default quality → quality sheet; ask-every-time;
  Wi-Fi-only), Permissions (status from `permissionStatus`; "Open system
  settings" placeholder when not granted; notifications), Storage (save location
  placeholder; Clear history → `clearHistory`), Appearance (Theme placeholder),
  About & legal (placeholders) + the verbatim rights statement + version.

### Offline banner
Slim warn-tone Home banner shown when `AppState.offline` (state-driven;
`liveRegion` semantics). Real connectivity detection is Pass 5.

### Placeholder convention
Not-yet-real actions (gallery, system settings, legal, search, theme) surface
honest SnackBars (the pass-3 "Open in gallery" pattern) rather than dead taps.

---

## Pass 5A — Permission layer (permission_handler)

First real platform integration: the gallery/media **permission** becomes real,
mapped onto the existing `PermissionStatus`. Still no download/gallery/file I/O.

### Service layer — `lib/services/permissions/`
- `permission_service.dart` — `abstract interface class PermissionService`
  (`galleryStatus` / `requestGalleryPermission` / `openSystemSettings`) +
  `PlatformPermissionService` (permission_handler + device_info_plus). The impl
  picks the permission set per platform/OS — Android 13+ (`sdkInt >= 33`)
  `[photos, videos]`, older Android `[storage]`, iOS `[photos]` — and **reduces**
  multi-permission results to one status.
- `permission_result_mapper.dart` — pure `mapPermissionStatus(ph.PermissionStatus)`
  + `reducePermissionStatuses(...)` → our enum (granted/limited→granted,
  permanentlyDenied/restricted→permanentlyDenied, else denied). Imports
  permission_handler as `ph` to avoid the `PermissionStatus` name clash.
  Host-unit-testable.
- `permission_service_provider.dart` — `permissionServiceProvider`
  (`Provider<PermissionService>`), overridden with a fake in tests.

### Wiring (platform I/O in the service/flow layer; notifier stays pure)
- `AppFlow.requestSave`: if already granted → download; else show the priming
  `PermissionSheet`, then on "Allow" call the **real** request, record it via
  `setPermissionStatus`, and branch — granted→download,
  permanentlyDenied→`permissionDeniedPermanently` error, denied→stay. `context`
  guarded across awaits.
- New `AppFlow.openSystemSettings()` (→ `openAppSettings()`) and
  `refreshPermissionStatus()`.
- Error screen `permissionDeniedPermanently` "Open settings" → real
  `openSystemSettings` (was a SnackBar).
- Settings is now a `ConsumerStatefulWidget`: `initState` refreshes the real
  status (resilient via try/catch when the channel is absent); the row shows
  Allowed / Not allowed / Blocked; "Open system settings" calls the service.
- `PermissionSheet` stays a pure priming sheet (pops a bool); the OS prompt
  fires from `AppFlow` afterward.

### Testing
A `FakePermissionService` (configurable request/status results; counts
`openSystemSettings`) is injected via `permissionServiceProvider.overrideWithValue`.
`device_info_plus`/permission_handler channels are never touched in tests. Covers
the mapper, the three save-flow branches, and Settings real-status.

### Platform config / assumptions
- Android manifest: `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, and
  `READ_EXTERNAL_STORAGE` (`maxSdkVersion=32`). Write/save perms → Pass 5C.
- iOS: `NSPhotoLibraryUsageDescription` added; `limited` treated as granted;
  add-only (`NSPhotoLibraryAddUsageDescription`) + Podfile `PERMISSION_PHOTOS=1`
  macro deferred to the save pass / device build.

---

## Pass 5B — Connectivity + persistence foundations

Two more platform foundations behind the same service/provider/fake pattern,
plus a startup **bootstrap** layer. Still no download/gallery/file I/O.

### Services
- `lib/services/connectivity/` — `ConnectivityService` (`isOnline()` +
  `onlineChanges()`) + `ConnectivityPlusService` (connectivity_plus v7
  `List<ConnectivityResult>`, mapped via the pure, host-testable
  `isOnlineFromResults` = "any result ≠ none").
- `lib/services/preferences/` — `PreferencesService` (`load()` / `save()`) +
  `SharedPreferencesService` (4 typed keys).

### Persisted slice — `AppPreferences` (lib/state/models)
Value type (quality + the three toggles) with value equality; defaults match
`AppState`. `AppState.toPreferences` snapshots it. **Permission status is NOT
persisted** — it's OS-authoritative and refreshed at startup (caching risks a
stale "Allowed"). Media/history are not persisted yet.

### Bootstrap — `lib/app/bootstrap/app_bootstrap.dart`
`AppBootstrap.start()` (run from `QuietlyApp.initState`, now a
`ConsumerStatefulWidget`): load prefs → apply via pure setters; seed + subscribe
connectivity → `setOffline`; refresh permission status. **Every step is guarded
(best-effort)** so a missing channel keeps defaults. `bootstrapProvider`'s create
body registers a single `ref.listen(appStateProvider, …)` that **write-through
persists** whenever `toPreferences` changes — so the notifier stays pure and no
widget touches storage. The connectivity subscription is cancelled via
`ref.onDispose` (container lifetime).

### Why existing tests stay green
Guarded bootstrap + the `toPreferences`-diff gate make a no-overrides
`QuietlyApp` pump a harmless no-op (channels throw → caught → defaults kept → no
banner); the persist save only fires on a real pref change, which those tests
never make. Screen tests use `MaterialApp` hosts (no bootstrap). 5B tests inject
fake connectivity/preferences/permission services.

### Connectivity caveat
connectivity_plus reports interface presence, **not** internet reachability /
captive portals — connected-but-no-internet reads as online. Real reachability
is deferred.

---

## Pass 5C — Download/queue service boundary (in-memory)

Replaces the pass-3 `AnimationController` inside `DownloadingScreen` with a real
**download service boundary**; the impl is still simulated (no network).

### Service — `lib/services/downloads/`
- `download_models.dart` — `DownloadItemStatus`, `DownloadItem` (id, kind, name,
  meta, progress 0..1, status), `DownloadQueueState` (derived `overallProgress`,
  `isMulti`, `isPaused`, `hasFailure`, `isComplete`, `isCanceled`); value equality.
- `download_queue_service.dart` — `DownloadQueueService`: `updates` stream,
  `current`, `start(kinds)`, `pause/resume/cancel/retry`, `dispose`.
- `in_memory_download_queue_service.dart` — `Timer.periodic` advances
  `downloading` items by `step`; at 100% an item completes, or **fails** if its
  id is in the injectable `failItemIds` (default empty → always completes).
  pause→cancel timer, resume→restart, cancel→canceled, retry→failed→downloading;
  cancels the timer at terminal states.
- `download_queue_provider.dart` — `downloadQueueServiceProvider` +
  `downloadQueueStateProvider` (StreamProvider that `yield`s `current` first
  then `updates` → no loading flicker).

### Wiring (notifier stays pure)
`AppFlow.startDownload` now also calls `service.start(kinds)` (the notifier still
records `lastSaved`/`screen`/requested `queue` for retry). `DownloadingScreen` is
a plain `ConsumerWidget` that watches `downloadQueueStateProvider` and uses
`ref.listen` to react to **terminal** states — `isComplete` →
`AppFlow.finishDownload()`, `hasFailure` →
`showError(AppErrorKind.queueItemFailed)` (reusing the pass-4 error + the
"Retry" CTA → `retryDownload` → restart). Footer: **Pause/Resume** (toggles the
service) + **Cancel** (`service.cancel()` + `goHome()`). No timers/streams in the
notifier — only state.

### Testing
A timer-free `FakeDownloadQueueService` drives screen/flow tests deterministically
(start/complete/fail/cancel via helpers). The real timer-driven
`InMemoryDownloadQueueService` is tested inside `testWidgets` (fake clock via
`pump(Duration)`) and disposed in-body so no timer is left pending. Never
`pumpAndSettle` the Download screen.

---

## Layering

```
lib/
  main.dart                  ProviderScope → QuietlyApp
  app/                       composition root: app widget, router, flow
    quietly_app.dart         MaterialApp.router (theme + routerConfig)
    router/
      app_routes.dart        route name/path constants + AppScreen↔route maps
      app_router.dart        GoRouter provider (one route per screen)
      sheets.dart            modal-sheet presentation (showModalBottomSheet)
    flow/
      app_flow.dart          intent → (state transition + navigation) coordinator
  core/                      cross-cutting, no feature knowledge
    theme/
      app_theme.dart         buildLightTheme() — tokens → ThemeData
      tokens/                AppColors, AppTypography, AppRadius, AppSpacing,
                             AppMotion, AppShadows  (source of truth = ds.jsx)
    a11y/                    A11y constants + MinTapTarget
    widgets/                 shared widgets (RightsNote, PlaceholderScaffold)
  state/                     domain + state machine (no I/O this pass)
    models/                  enums + value types (quality, carousel, history, …)
    app_state.dart           immutable AppState + copyWith + derived getters
    app_state_provider.dart  AppStateNotifier (Riverpod) — pure transitions
    error_config.dart        ERROR_CONFIG → typed Dart map
  features/                  one folder per screen (HANDOFF §A) + sheets
```

**Dependency direction:** `features` → `core` + `state` + `app`; `core` and
`state` depend on nothing app-specific. This keeps screens swappable as the real
UI lands.

## Key decisions

### 1. Navigation = go_router (real back-stack)
HANDOFF §6/§D flagged the prototype's flat `screen` switch (Back always returned
Home) as not the nav model. We use **go_router** with one `GoRoute` per screen
(`home, analyzing, result, carousel, downloading, success, history, settings,
error`). Forward steps `push`; transient steps (`analyzing → result`,
`result → downloading → success`, any `→ error`) use `pushReplacement` so Back
skips them and returns to a sensible prior screen. Top-level returns use `go`
to reset the stack.

### 2. State = Riverpod, with a documented split of responsibility
- **`AppState`** (immutable) is the **domain + logical state-machine** model. It
  mirrors HANDOFF §D exactly: `screen, sheet, error, permissionGranted, history,
  carousel (+selection), quality, queue` (+ `toggles`, `lastSaved`, `progress`).
- **`AppStateNotifier`** holds the only mutable state and exposes **pure**
  transition methods (ports of `app.jsx`). No timers, network, files, or
  navigation live here — which makes the machine fully unit-testable.
- **go_router** is the navigation source of truth.
- **`AppFlow`** ([app/flow/app_flow.dart](../lib/app/flow/app_flow.dart)) is the
  single place that pairs each user intent with **both** the state transition and
  the matching navigation, so `AppState.screen` and the router never drift.

> Known follow-up: the OS/system Back button pops go_router but does not yet call
> back into `AppStateNotifier.setScreen`. A `NavigatorObserver` will sync the
> logical `screen` on pop once screens are real. Acceptable for the shell.

### 3. Modal sheets: route names + showModalBottomSheet
Per HANDOFF §E, the quality and permission sheets are presented with
`showModalBottomSheet` (rounded top + drag handle from `bottomSheetTheme`), not
as full pages. Their **route names** still live in `AppRoutes` (single registry),
and `AppState.sheet` tracks the active sheet for the state machine. The
permission sheet performs **no navigation itself** — it pops with a `bool`
result and `AppFlow.requestSave` acts on the screen's (still-valid) context,
avoiding the defunct-context trap.

### 4. Tokens → ThemeData
`ds.jsx` is the source of truth. Values Material can hold are mapped in
`buildLightTheme()` (`ColorScheme`, `TextTheme`, app-bar / card / button /
bottom-sheet / switch themes, all buttons ≥48dp). Values Material has no slot for
(warm "soft" accent tints, hairlines, custom warm shadows, the full type scale)
live in the `tokens/` classes and are read directly by widgets. **Never hard-code
hex in a widget** — read a token so the future dark swap is one change.

### 5. Accessibility baseline (HANDOFF §9 first-pass fixes)
- **Touch targets ≥ 48dp**: enforced via theme button `minimumSize` +
  `materialTapTargetSize: padded`; `MinTapTarget` wraps compact affordances.
- **Caption contrast**: small text uses `AppColors.faintText` (`#857E73`),
  darker than the decorative `faint` (`#A39C92`), to clear WCAG AA.
- **Semantics-ready**: headings use `Semantics(header: true)`; decorative icons
  use `ExcludeSemantics`; `MinTapTarget` exposes button labels.
- **Dynamic type**: we never lock `textScaler`; `QuietlyApp` only clamps the
  extreme upper end so placeholder layouts don't overflow during the shell pass.

## Dark theme plan (HANDOFF §F #3, deferred)
Light only this pass. The dark palette was never specified in the handoff (§8),
so we do not invent values. `AppColors` is documented to grow a parallel dark
palette; `buildLightTheme()` is named to admit `buildDarkTheme()`; `QuietlyApp`
already sets `themeMode`, so adding dark later is additive.

## Fonts
HANDOFF §5 requires bundling **Roboto Mono**. Until the `.ttf` is added under
`assets/fonts/` and wired in `pubspec.yaml`, `AppTypography.monoFamily` is `null`
and we fall back to the platform monospace (`monoFamilyFallback`). This avoids a
missing-asset build break. Flip `monoFamily` to `'RobotoMono'` once bundled.

## Out of scope this pass (and where it goes)
- Downloader / queue execution, pause/resume/retry → a `download` service (§E).
- `permission_handler`, `permanentlyDenied` deep-link, Android 13+ scoped media
  (`READ_MEDIA_*`) → wired when permissions become real (§7).
- Gallery save + dedupe ("already saved") → save service (§E).
- History persistence model (app DB vs OS gallery) → **open decision §F #5**.
- Final visual fidelity of all screens; spring/progress animations.

## Open product decisions still pending (HANDOFF §F)
1. **Default-quality behaviour** — picker-on-tap vs always-ask (`toggles.ask`
   default off). Modeled in state; product default to confirm.
2. **First-run acceptable-use gate** — include or not.
3. **Dark theme** — MVP or later (currently later).
4. **Queue depth** — concurrency limit + Wi-Fi-only enforcement.
5. **History storage model** — app DB vs OS gallery (affects delete/dedupe).
6. **Caption contrast** — applied (`#857E73`); confirm acceptable.

## Verification
- `flutter analyze` → no issues.
- `flutter test` → shell smoke + state-machine + token tests.
- `flutter run` → Home renders themed; navigate home → analyzing → result, open
  the quality/permission sheets, visit history/settings, trigger an error state;
  Back pops correctly.
