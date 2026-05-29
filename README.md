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
