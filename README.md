# Quietly — media saver

A **rights-aware, Play-Store-safe** mobile media saver. Quietly helps people save
**public** media they have the rights to — with calm, explainable flows and an
always-present rights reminder. Private, login-only, and DRM-protected media is
not supported, by design.

## Documentation

- **[`docs/design-handoff/HANDOFF.md`](docs/design-handoff/HANDOFF.md)** —
  authoritative product/design spec (screens, components, tokens, state machine).
- **[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)** — how the Flutter app is
  structured and why (layering + key decisions). **Start here for the codebase.**

## Build pass 5D — History persistence + gallery boundary

Saved-media **history now persists**: a `SavedMediaRepository`
(`lib/services/saved_media/`, shared_preferences JSON) loads history at startup
and a write-through `ref.listen` saves on every change — so saves, removes, and
clear survive a relaunch (`HistoryEntry` gained a stable `id` + `filePath`
placeholder + JSON). A new `GalleryService` boundary (`lib/services/gallery/`,
placeholder no-ops for now) backs the History open/share/remove row actions.
Still **no real file writes, gallery I/O, or downloader**; tests fake the
repository + gallery. See `docs/ARCHITECTURE.md` → "Pass 5D".

## Build pass 5C — Download/queue service boundary

Replaces the download screen's local `AnimationController` with a real
**download/queue service** (`lib/services/downloads/`) behind an interface +
Riverpod stream provider — per-item progress, start/pause/resume/cancel/retry,
and failures mapped to `AppErrorKind.queueItemFailed`. The implementation is
still **in-memory/simulated** (no real network, gallery save, or files yet);
`DownloadingScreen` is now a thin consumer of the service's progress stream and
reacts to terminal states via `ref.listen` (complete → Success, failure →
error). The notifier stays pure. Tests use a timer-free fake for screen flows
and the real in-memory impl for service-lifecycle tests. See
`docs/ARCHITECTURE.md` → "Pass 5C".

## Build pass 5B — Connectivity + persistence foundations

Adds two platform foundations behind the same service/provider/fake pattern and
a startup **bootstrap** layer (`lib/app/bootstrap/`): real **connectivity**
(`connectivity_plus`) now drives the Home offline banner, and lightweight
**preferences** (`shared_preferences`) — selected quality + the three toggles —
load on startup and persist on change (write-through via a single `ref.listen`,
so the notifier stays pure). Permission status is intentionally **not** cached
(OS-authoritative; refreshed at launch). Startup I/O is best-effort/guarded.
Still **no real download, gallery save, or URL analysis**; tests fake all
platform services. See `docs/ARCHITECTURE.md` → "Pass 5B".

## Build pass 5A — Real permission layer

First real platform integration: gallery/media **permission** is now real via
`permission_handler`, behind a `PermissionService` interface + Riverpod provider
(`lib/services/permissions/`), mapped onto the existing `PermissionStatus`.
`AppFlow` makes the OS request after the priming sheet and branches
granted→download / permanently-denied→"Gallery access is off" error / denied→stay;
Settings shows the real status and can open system settings. Android 13+ uses
scoped media perms (`READ_MEDIA_IMAGES/VIDEO`) with a storage fallback for older
Android; iOS uses Photos (`NSPhotoLibraryUsageDescription`). Still **no real
download, gallery save, or file access**. Tests inject a fake service — no real
platform channels. See `docs/ARCHITECTURE.md` → "Pass 5A".

## Build pass 4 — History / Settings / Error states

Completes the remaining UI surfaces: day-grouped **History** (with empty state +
per-row open/share/remove), calm grouped **Settings** (downloads, permissions,
storage, appearance, legal + the rights statement), and one config-driven
**ErrorScreen** covering all 8 edge states (incl. permanently-denied permission
and queue-item-failed) with Retry / Try-another / Open-settings CTAs. Adds a
lightweight Home **offline banner** and a `PermissionStatus`
(granted/denied/permanentlyDenied) model. Still no `permission_handler`,
downloader, or gallery/storage — not-yet-real actions surface honest placeholder
SnackBars. **Every screen now has real UI.** See `docs/ARCHITECTURE.md` →
"Pass 4".

## Build pass 3 — Carousel / Download / Success UI

Polishes the remaining core-flow screens with the `Q` library (adds `QBar` for
linear progress). The full happy path is now clickable: Home → Analyzing →
Result → Save → permission → Download → Success. Download progress is
**simulated** (a finite, visual-only `AnimationController` that auto-advances to
Success; the `AppState` notifier stays pure) — still no real downloader,
`permission_handler`, or gallery access. "Open in gallery" on Success is a
placeholder. Media previews stay abstract (Play-Store-safe). See
`docs/ARCHITECTURE.md` → "Pass 3".

## Build pass 2 — Home / Analyzing / Result UI

Builds the real core-flow UI plus the shared design-system components
(`QButton`, `QCard`, `QPill`, `QMediaTile`, `QTopBar`, `QRing`, `QDots`,
`UrlChip`, `RightsNote`) and a `QIcons` Material-icon mapping layer. Still
presentation only — no downloader, permissions, or real URL analysis. Analysis
is simulated (a finite timer auto-advances Analyzing → Result); the clipboard
card uses a static example URL. Media previews are deliberately abstract
placeholders (Play-Store-safe). See `docs/ARCHITECTURE.md` → "Pass 2".

## Build pass 1 — app shell

This pass builds the foundation only: design tokens → `ThemeData`, the
navigation + state-machine skeleton, and placeholder screens. **No downloader,
permissions, or backend yet.**

- **Navigation:** [go_router](https://pub.dev/packages/go_router) — one route per
  screen, real back-stack.
- **State:** [Riverpod](https://pub.dev/packages/flutter_riverpod) — an immutable
  `AppState` + pure-transition `AppStateNotifier`.
- **Theme:** light palette mapped from the design tokens; structured so a dark
  palette can be added later.
- **Accessibility:** ≥48dp touch targets, WCAG-AA caption contrast, scalable
  text (never locked), semantics-ready widgets.

### Run / verify

```bash
flutter pub get
flutter analyze   # no issues
flutter test      # shell + state-machine + token tests
flutter run       # boots to Home; tap through the flow
```

> Roboto Mono is referenced but not yet bundled — see the fonts note in
> `docs/ARCHITECTURE.md`. The app falls back to the platform monospace until the
> `.ttf` is added.
