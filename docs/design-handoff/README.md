# Quietly — Implementation Handoff

A rights-aware mobile media saver. **Hybrid Direction A**: calm single-focus
wizard, explainable analysis, lightweight download queue + history, subtle
motion. This bundle is the design + behaviour reference for Flutter build.

## Preview the prototype
No build step. Open in any modern browser:
- **`Quietly — Interactive Prototype.html`** — the full clickable flow
  (paste → analyze → result → quality → permission → download → success →
  history). Use the **"All states"** button (top-right) to jump to every
  screen and edge case. *(The phone frame + states panel are a preview
  harness only — do not port them.)*
- **`design-system.html`** — tokens + component reference.

If a browser blocks the local `.jsx` script loads when opened via `file://`,
serve the folder instead: `python3 -m http.server` then open the page.

## The implementation handoff
- **`HANDOFF.md`** — the authoritative audit: screen inventory, component
  inventory, token summary, state-machine map, Flutter notes, open
  decisions, and export list. **Start here.**

## Where things live
| Concern | File |
|---|---|
| Design tokens (color, type, radius, motion, shadow) + primitives (Button, Sheet, Card, Pill, Toggle…) | `app/ds.jsx` |
| Shared low-level primitives (Icon set, MediaTile, Ring, Bar, StatusBar, HomeBar) | `lib/primitives.jsx` |
| Screens — core flow (home, analyzing, result, carousel, quality, download, success) | `app/screens-core.jsx` |
| Screens — aux (history, settings/legal, error states + `ERROR_CONFIG`, permission) | `app/screens-aux.jsx` |
| **State machine** + seed data (screen/sheet/error states, save/permission/download logic) | `app/app.jsx` |
| Design-system page renderer | `lib/docs.jsx` |

## Recommended next step (Flutter CLI)
1. Read `HANDOFF.md` end-to-end; resolve the §F open decisions first
   (default-quality behaviour, dark theme in MVP?, history storage model).
2. Scaffold: `flutter create quietly`.
3. Map `app/ds.jsx` tokens → a `ThemeData` (light now; add dark palette if MVP).
   Bundle Roboto Mono as an asset.
4. Build one route per screen in §A; bottom sheets via `showModalBottomSheet`.
   Use a real `Navigator` back-stack (the prototype's flat switch is not the
   nav model).
5. Wire `permission_handler` (incl. permanentlyDenied → settings, Android 13+
   scoped media) and a download/queue service with pause/resume/retry.
6. First-pass fixes from the audit: add `Semantics` labels, darken small-text
   `faint` color for WCAG AA, min 48dp touch targets.
