# Quietly — Closed Testing Checklist (release go/no-go)

> **Status:** Active · **Last updated:** 2026-05-29 · **Owner:** Lunexa
> The release-submission gate. For on-device **functional** QA, use
> [../QA_CHECKLIST.md](../QA_CHECKLIST.md) (this checklist links to it rather than
> duplicating it).

## 🚫 BLOCKERS — must be true before uploading to closed testing
- [ ] **applicationId** set to `com.lunexa.quietly` (replaces `com.example.*`); namespace + iOS bundle id match. *(Q3 config)*
- [ ] **Release signing**: real upload keystore configured (not the debug key); enrolled in **Play App Signing**. *(Q3 config)*
- [ ] **targetSdk** meets Play's current new-app requirement (**API 35**); pinned if `flutter.targetSdkVersion` is lower. *(Q3 config)*
- [ ] **Permission trim** applied per [PERMISSIONS_REVIEW.md](PERMISSIONS_REVIEW.md): only `INTERNET` + `WRITE_EXTERNAL_STORAGE`(≤28) (+ merged `ACCESS_NETWORK_STATE`); media-read perms removed; `flutter analyze`/`test` green. *(Q3 config)*
- [ ] **Privacy policy live** at `https://uselunexa.com/privacy/quietly` (body from [PRIVACY_POLICY.md](PRIVACY_POLICY.md); 2 placeholders resolved); in-app Settings link points to it.
- [ ] **Play Console app created**; **Data Safety** completed from [DATA_SAFETY.md](DATA_SAFETY.md); **content rating** from [CONTENT_RATING.md](CONTENT_RATING.md); **store listing** from [STORE_LISTING.md](STORE_LISTING.md).
- [ ] **Metadata**: real `pubspec.yaml` description; **store title locked** (see RELEASE_IDENTITY.md); developer name = Lunexa.
- [ ] Signed **AAB** builds (`flutter build appbundle --release`) and is verified signed with the **upload key**.

## ✅ RECOMMENDED — before/with closed test
- [x] **512×512 Play icon** — done (`docs/store-assets/icon-512.png`).
- [ ] Store **assets**: 1024×500 feature graphic, 4–8 phone screenshots (no platform logos / no "download from X") — see `docs/store-assets/README.md`.
- [x] **Adaptive launcher icon** (fg/bg) via `flutter_launcher_icons` — done; **verify on device** (full-bleed-foreground caveat in store-assets README).
- [ ] App **name unified** to "Quietly" across Android + iOS.
- [ ] **Support email** `hello@uselunexa.com` + **website** `https://uselunexa.com` live and in the listing.
- [ ] In-app **Privacy policy** wired; Acceptable-use/Terms link added.
- [ ] `LICENSE` added; quick legal pass on positioning copy.
- [ ] TR + ES privacy/listing translations published (if launching localized).

## 🧪 On-device functional QA
- [ ] Run the full [../QA_CHECKLIST.md](../QA_CHECKLIST.md) on a release build (direct image/video, unsupported page, duplicate save, permissions, offline, history actions, settings persistence, restart persistence, first-run gate).
- [ ] Confirm a **release build can perform HTTP** (INTERNET present in production manifest — already fixed in Pass 10).
- [ ] Launcher shows the final brand icon + "Quietly".

## 🔭 POST-TEST
- [ ] Trademark / Play name-collision check for "Quietly".
- [ ] Play Console **pre-launch report** + Android vitals review.
- [ ] Expand tablet screenshots; iterate listing from test feedback.
- [ ] iOS App Store track (separate review).
