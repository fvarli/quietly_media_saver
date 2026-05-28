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
