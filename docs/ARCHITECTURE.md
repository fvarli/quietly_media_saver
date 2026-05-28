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
