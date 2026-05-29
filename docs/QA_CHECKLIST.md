# Quietly — internal QA checklist

Manual device pass before a release build. Quietly only saves **public** media the
user has the rights to; there is no page scraping or private/DRM access, so the
"happy path" inputs below are **direct public media file URLs** (a link ending in
`.mp4`/`.mov`/`.webm` or `.jpg`/`.png`/`.webp` whose server reports a media
Content-Type). Run on a real device with a release-mode build where possible.

## First run

- [ ] **First-run gate** — fresh install: the calm acceptable-use sheet appears
      over Home, is **not** dismissible (no back, no scrim tap, no drag), states
      public-media-only / rights / no private-DRM, and closes on **"I understand"**.
- [ ] **Gate persists** — fully quit and relaunch: the gate does **not** reappear.

## Core pipeline (direct public media)

- [ ] **Direct image URL** — paste a public `…/photo.jpg` → Analyzing → Result
      shows the real host + `JPG · ≈ N MB` → Save → appears in the gallery and in
      History with a working file.
- [ ] **Direct video URL** — paste a public `…/clip.mp4` → Result shows
      `Landscape · MP4 · ≈ N MB` → Save → plays from the gallery; History entry
      opens it.
- [ ] **Unsupported page URL** — paste a normal web page / social link →
      "We can't read this source yet" (unsupported), no crash, no scraping.

## Errors & edges (calm, no dark patterns)

- [ ] **Duplicate save** — save the same link twice → "Already in your gallery";
      the primary action **opens the existing saved item**.
- [ ] **Permission denied** — decline the OS gallery prompt → stays on Result;
      saving can be retried.
- [ ] **Permission permanently denied** — deny-with-don't-ask → "Gallery access
      is off" → "Open settings" deep-links to the OS app settings.
- [ ] **Offline** — disable Wi-Fi/data → Home shows the offline banner; the banner
      only appears when reachability is actually lost (a connected-but-no-internet
      network should still flip it within a few seconds), and clears on reconnect.
- [ ] **Storage full** (if reproducible) — save with no free space → "Not enough
      space".

## History & settings

- [ ] **History open / share / remove** — each row action works on the real saved
      file; remove drops the row and survives relaunch.
- [ ] **Settings toggles persistence** — change quality + the three toggles, quit,
      relaunch → values are retained.
- [ ] **App-restart persistence** — saved History + preferences survive a full
      restart.

## Lifecycle

- [ ] **Resume refresh** — background the app, change the OS gallery permission and
      copy a new link, return to foreground → permission status, the clipboard
      suggestion, and the offline banner all reflect the new reality (no duplicate
      banners / no stuck state).

## Release config

- [ ] **Network in release** — a release build can analyze + download (the
      `INTERNET` permission is in the production manifest, not only debug/profile).
- [ ] **Launcher name** — the home-screen label reads **"Quietly"**.
- [ ] **Permissions audit** — only media-read (+ scoped legacy write) and
      `INTERNET` are requested; nothing excessive.

## Known release tasks (not blockers for internal QA)

- [ ] Set a **production `applicationId`** (currently `com.example.quietly_media_saver`)
      and a real **release signing config** (currently uses the debug key).
- [ ] iOS add-only Photos permission wiring; store listing copy/assets.
