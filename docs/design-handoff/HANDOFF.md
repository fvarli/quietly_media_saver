# Quietly — Production Handoff Audit
_Rights-aware media saver · Hybrid Direction A · audit date 2026-05-29_

Scope: review only. No redesign. Covers the interactive prototype
(`Quietly — Interactive Prototype.html`) and the design system
(`design-system.html`).

---

## Verdict

**Ready for Flutter CLI implementation** — no blocking defects.
A handful of *minor* gaps and product decisions are listed in §F; none
require redesign, and all can be resolved during build. The two
contrast/touch-target items in §9 should be fixed in the first pass.

---

## Review findings (1–10)

**1. Missing core states** — Core flow is complete. Gaps (all minor, optional):
- Permission **denied permanently** (after "Not now" twice / OS block) → no "open system settings" screen. Currently only request + dismiss.
- Queue **paused** and **single-item failed → retry** states (pause icon exists, no resting paused/failed UI).
- **Empty history** (zero saves) state — list always seeded.
- **Offline banner** on Home (you only learn you're offline after analyzing).

**2. Inconsistent components** — Small, easy to unify before build:
- `Toggle` is defined twice (`screens-aux.jsx` and `DocToggle` in `docs.jsx`). Pick one.
- Icon buttons use both an `iconBtn()` helper (Home header) and inline styles (TopBar) — same look, two code paths.
- Settings "value + chevron" rows show value **and** a chevron (double disclosure); fine but standardise.

**3. Legal / rights-aware copy** — Strong. Present on every save, analysis ("Public" chip), Settings rights statement, and all refusal states. Optional hardening: a one-time **acceptable-use acknowledgement** on first run, and a rights line on the result **Share** action.

**4. Play Store perception** — Low risk. No platform logos, no "download anything" language, abstract placeholders, no ad surfaces, calm visual tone. Keep the store listing copy aligned ("save your own / public media").

**5. Flutter implementation risks** —
- CSS keyframes/`transition` → use implicit animations (`AnimatedContainer`, `AnimatedOpacity`, `TweenAnimationBuilder`) + a spring `Curve`.
- `backdrop-filter` blur (sheets/scrim) → `BackdropFilter` + `ImageFilter.blur` (fine on Android, watch perf on low-end).
- `oklch` already removed → all colors are hex, safe.
- Scaled phone frame + `All states` panel are **prototype-only** harness; do not port.
- Mono font (Roboto Mono) must be bundled as an asset.
- `flex:1` / `minHeight:0` patterns map to `Expanded` + `Flexible`; scroll regions → `ListView`/`SingleChildScrollView`.

**6. Navigation / state transitions** — The prototype uses a flat `screen` switch; **back always returns Home**. Real app needs a proper `Navigator` back-stack (e.g. analyzing→result→quality should pop correctly). Transitions are mount-fade only; define real route transitions.

**7. Permission / storage / network** — Covered: storage request, storage-full, network-failure, unsupported source. Missing: permission **denied-permanently** deep-link, Android 13+ **scoped media** (`READ_MEDIA_*`) nuance, and network **resume/retry mid-download**.

**8. Token / component gaps** —
- **Dark theme** is described as supported but **tokens are not defined** — add a dark palette before claiming it.
- No **focus-ring** token (needed for a11y / keyboard).
- No explicit **line-height** or **disabled-state** tokens (disabled handled ad hoc in `Button`).

**9. Accessibility** — Needs attention in build:
- **No semantics** anywhere (prototype is divs). In Flutter, every actionable needs a `Semantics` label; media tiles need descriptions.
- **Contrast:** `faint #A39C92` on the cream canvas for 11.5–12px captions is borderline/below WCAG AA. Darken to ~`#857E73` for small text.
- **Touch targets:** icon buttons are 40px; bump to ≥48dp for Android.
- No **dynamic type** scaling yet — use scalable text styles.

**10. Downloader / piracy feel** — None. Reads as a legitimate, calm utility. No change needed.

---

## A. Final screen inventory

| # | Screen | State component | Notes |
|---|--------|-----------------|-------|
| 1 | Home / paste (empty + clipboard-detected + recent peek) | `HomeScreen` | hero input, lightweight recent strip |
| 2 | Analyzing (explainable steps + Public chip) | `AnalyzingScreen` | auto-advances |
| 3 | Result · single video | `ResultScreen` | quality row → sheet |
| 4 | Carousel multi-select | `CarouselScreen` | live count + size sum |
| 5 | Quality picker (bottom sheet) | `QualitySheet` | radio + recommended |
| 6 | Download progress · single | `DownloadScreen` | ring + bytes/speed |
| 7 | Download progress · multi queue | `DownloadScreen` (multi) | per-file bars |
| 8 | Success / saved | `SuccessScreen` | spring check, → history |
| 9 | History (day-grouped + storage summary) | `HistoryScreen` | |
| 10 | Settings / legal / permissions | `SettingsScreen` | groups + rights statement |
| 11 | Permission request (sheet) | `PermissionSheet` | allow / not now |
| 12–17 | Error states: protected · invalid URL · network · unsupported · storage-full · already-saved | `ErrorScreen` (+`ERROR_CONFIG`) | one component, 6 configs |

**To add for production (see §1/§7):** permission-denied-permanently, queue-paused, item-failed/retry, empty-history, offline-banner.

## B. Final component inventory

Buttons (`primary / soft / ghost / outline / danger`, sizes `lg/md/sm`) · TopBar · RightsNote · Sheet (scrim + spring panel) · SectionLabel · Card (+active) · Dots · CheckCircle · Pill (`neutral/accent/success/warn/danger`) · Toggle · Ring (circular progress) · Bar (linear progress) · MediaTile (video/image/carousel; states: dim/locked/selected/badge) · StatusBar · HomeBar · Icon set (~55 line glyphs) · Settings rows/groups.

## C. Design token summary

- **Color:** warm-neutral surfaces (`#FAF8F4` canvas → `#211D18` ink), single indigo accent (`#4B53C4` + press/soft/ink), status (success `#2E9E6B`, warn `#C98A2B`, danger `#C5503F`).
- **Type:** system sans; mono (Roboto Mono) for URLs/metadata. Scale: Display 28/700 · Title 21/700 · Headline 17/650 · Body 15/400 · Caption 13/500 · Micro 11.5 · Mono 12.5.
- **Radius:** 10/14/18/22/28/pill. **Spacing:** 4px base (`DS.space(n)`).
- **Elevation:** sm/md/lg + accent shadows. **Motion:** decel `cubic-bezier(.22,.61,.36,1)`, spring `cubic-bezier(.34,1.3,.5,1)`, durations 180/260/380.
- **Gaps to add:** dark palette, focus-ring, disabled + line-height tokens.

## D. State machine summary

`screen ∈ {home, analyzing, result, carousel, downloading, success, history, settings, error}`
`sheet ∈ {null, quality, permission}` · `error ∈ ERROR_CONFIG keys`

Happy path: `home → (paste) analyzing → result → [quality sheet] → (save) → [permission sheet if !granted] → downloading → success → history`.
Carousel branch: `carousel → (save N) → permission? → downloading(multi) → success`.
Persisted: `permissionGranted`, `history` (saves prepend), `carousel selection`, `quality`, `toggles`.
**Production need:** replace flat switch with a `Navigator` stack so Back pops correctly (currently Back → Home).

## E. Flutter implementation notes

- One screen per route; bottom sheets via `showModalBottomSheet` (drag handle, rounded top, spring curve).
- Implicit animations for entrances/progress; `AnimatedSwitcher` for screen changes.
- `permission_handler` for gallery/storage; handle `denied`, `permanentlyDenied` (→ `openAppSettings`), Android 13+ `READ_MEDIA_IMAGES/VIDEO`.
- Downloads: a queue service with per-item progress streams; support pause/resume/cancel/retry.
- Save to gallery via a platform plugin; dedupe to drive the "already saved" state.
- Bundle Roboto Mono; map tokens to a `ThemeData` (light now, dark later).
- Add `Semantics` labels to every actionable + media tile; min 48dp targets; respect text scale factor.

## F. Known decisions / open questions

1. **Default-quality behaviour:** picker-on-tap vs always-ask (Settings toggle off by default). Confirm intended default.
2. **First-run consent / acceptable-use** gate — include or not?
3. **Dark theme** — in MVP or later? (tokens needed if MVP.)
4. **Queue depth** — concurrent download limit + Wi-Fi-only enforcement behaviour.
5. **History storage model** — app DB vs reading the OS gallery; affects delete/dedupe.
6. **Caption contrast** fix (`#A39C92` → darker) — confirm acceptable.

## G. Recommended export / download list

Hand off the whole project, or these files specifically:
- `Quietly — Interactive Prototype.html` (flow reference)
- `design-system.html` (token + component reference)
- `app/ds.jsx` (tokens + primitives — source of truth)
- `lib/primitives.jsx` (Icon, MediaTile, Ring, Bar, StatusBar, HomeBar)
- `app/screens-core.jsx`, `app/screens-aux.jsx` (screen specs incl. `ERROR_CONFIG`)
- `app/app.jsx` (state machine + seed data)
- `lib/docs.jsx` (design-system page)
- This file: `HANDOFF.md`
