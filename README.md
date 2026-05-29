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
- **[`docs/release/`](docs/release/README.md)** — Google Play release identity,
  privacy policy, Data Safety, store listing, content rating, and the closed-testing
  checklist. **Start here for publishing.**

## Build pass 10 — Release-readiness stabilization

Hardens the app for a first release (no new media sources — still direct public
URLs only). **Lifecycle resume**: an `AppLifecycleListener` re-checks permission,
reachability, and the clipboard on foreground (no duplicate connectivity
listeners). **First-run gate**: a calm, non-dismissible acceptable-use sheet over
Home (public media only · you must have the rights · no private/login/DRM),
persisted so it shows once — and failing open (no gate) if storage is
unavailable. **True reachability**: a lightweight HEAD probe
(`ReachabilityService`) layered on `connectivity_plus`, flipping the offline
banner only when reasonably certain. **Error polish**: rights-aware copy stays
verbatim; "Already in your gallery" now opens the saved item. **Android**: the
release-blocking `INTERNET` permission is added to the production manifest and the
launcher label is "Quietly" (production `applicationId` + release signing remain
documented tasks). Adds `docs/QA_CHECKLIST.md`; tests stay fake/`MockClient`-only
(91 total, no real network). See `docs/ARCHITECTURE.md` → "Pass 10".

## Build pass 9A — Real direct-media analyzer

The analyzer is now **real** for **direct, publicly accessible media file URLs
only** (e.g. `https://cdn.host/clip.mp4`, `…/photo.jpg`). `DirectMediaAnalysisService`
(`lib/services/analysis/`) does a lightweight HTTP probe — prefer `HEAD`, fall
back to a tiny range `GET` on 405/501 (the full file is **never** downloaded
during analysis) — and confirms the resource is media via its **Content-Type**
(`video/*` / `image/*`). A success carries the original URL as `downloadUrl`, so
the download→gallery pipeline now flows **real bytes**, and Result shows the real
host / kind / size. A `CompositeMediaAnalysisService` routes the reserved
`*.example.com` demo URLs to the offline sample (so the demo + tests stay
network-free) and everything else to the direct analyzer. Strictly legal: **no
page scraping, no social-platform parsing, no private/login/DRM bypass, no
platform claims** — anything that isn't a confirmed public media file maps to the
existing invalid / protected / unsupported / network errors. Tests are
`MockClient`-only (no real network). See `docs/ARCHITECTURE.md` → "Pass 9A".

## Build pass 8B — Downloaded bytes → gallery save

Connects the download queue to the gallery: completed downloads now write a real
local file (`DownloadItem.localPath`; `HttpDownloadQueueService` writes the
streamed bytes, or synthetic fallback bytes, to a temp dir), and
`GalleryService.saveFile(kind, sourcePath)` imports that file into app documents
+ the OS gallery — so the saved `HistoryEntry.filePath` is the downloaded file,
not synthetic bytes. `finishDownload` only imports on success (a failed download
saves nothing); out-of-space → "Not enough space". Tests stay fake-/temp-dir-only
(no real network or platform gallery). See `docs/ARCHITECTURE.md` → "Pass 8B".

## Build pass 8A — Real HTTP download/queue service

The simulated in-memory queue is replaced by `HttpDownloadQueueService`
(`package:http`): a real streamed HTTP GET with per-item progress when a media
item carries a `downloadUrl`, and a local sample-bytes ramp fallback when it
doesn't. Cancel/retry/pause-resume (stream backpressure, no byte-range) and
failure→`queueItemFailed` are preserved behind the unchanged
`DownloadQueueService` interface. The sample analyzer supplies no URLs, so the
shipped demo uses the fallback (offline, legally safe); a real analyzer (next)
activates the HTTP path. Tests never hit the network — widget/flow use the fake
service; the real path is unit-tested with an http `MockClient`. See
`docs/ARCHITECTURE.md` → "Pass 8A".

## Build pass 7B — Real OS gallery integration (Android-first)

`OsGalleryService` now inserts saved sample media into the **device gallery**
(`gal`, Android-first) alongside the local app-documents copy, opens files with
`open_filex`, and shares via `share_plus`. Write/space failures map to the
"Not enough space" (`storage`) error; `remove` deletes the local copy (the
gallery copy is user-managed). Android manifest gains pre-Q
`WRITE_EXTERNAL_STORAGE`; iOS gains `NSPhotoLibraryAddUsageDescription` (add-only
permission wiring deferred). Still synthetic bytes — **no real download/scraping**;
tests fake the gallery so nothing platform-specific runs. See
`docs/ARCHITECTURE.md` → "Pass 7B".

## Build pass 7A — Gallery / file-save boundary

The gallery service is now real: `LocalGalleryService` (`lib/services/gallery/`)
writes a saved file to the **app documents directory** using **synthetic sample
bytes** (no real download/scraping), records it on `HistoryEntry.filePath`,
deletes it on remove, and shares via `share_plus`. **Dedupe** (link-level
`host|url`, stored on `HistoryEntry.sourceKey`) drives the "Already in your
gallery" (`exists`) state. `open` is a documented placeholder. Real OS gallery
insertion (MediaStore/Photos) + real open are deferred to **7B**; real network
download + analyzer to **8**. See `docs/ARCHITECTURE.md` → "Pass 7A".

## Build pass 6 — URL analysis + real clipboard

The core flow is now **data-driven**. A `MediaAnalysisService`
(`lib/services/analysis/`) inspects a pasted link and returns the public media
it exposes; the result drives Result (single) or Carousel (multi), and typed
failures map to the existing error screens (invalid / protected / unsupported /
network). A `ClipboardService` (`lib/services/clipboard/`) reads the real
clipboard — Home suggests a detected link and "Paste link" submits it. Analyzing
keeps a calm ~0.9s minimum but the outcome comes from the service. The shipped
analyzer is a **deterministic, legally-safe sample** (no scraping, no private/
DRM access, no platform-specific claims); a real analyzer/downloader comes next.
See `docs/ARCHITECTURE.md` → "Pass 6".

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
