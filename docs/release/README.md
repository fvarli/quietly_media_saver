# Quietly — Release documentation

> **Status:** Active · **Last updated:** 2026-05-29 · **Owner:** Lunexa
> Single source of truth for Quietly's Google Play release identity, policy, and
> store materials. The hosted privacy policy and Play Console listing are mirrored
> *from* these files.

Quietly is a calm, rights-aware **media saver** (a Tools utility, not a game) that
saves **direct, public media files** from links the user pastes. No scraping, no
social-platform extraction, no private/DRM access, no account, no ads, no tracking.

## Documents

| Doc | Purpose | Status |
|---|---|---|
| [RELEASE_IDENTITY.md](RELEASE_IDENTITY.md) | Locked app id, publisher, category, URLs, title | 🔒 Locked (title provisional) |
| [PERMISSIONS_REVIEW.md](PERMISSIONS_REVIEW.md) | Per-permission justification + target set + Q3 actions | ✅ Reviewed |
| [DATA_SAFETY.md](DATA_SAFETY.md) | Play Data Safety questionnaire answers | ✅ Drafted |
| [PRIVACY_POLICY.md](PRIVACY_POLICY.md) | Canonical privacy policy (source of truth) | ✅ Draft (2 publish placeholders) |
| [STORE_LISTING.md](STORE_LISTING.md) | Title options, descriptions, "What's new" | ✅ Drafted |
| [CONTENT_RATING.md](CONTENT_RATING.md) | IARC answers + expected rating | ✅ Drafted |
| [CLOSED_TESTING_CHECKLIST.md](CLOSED_TESTING_CHECKLIST.md) | Release go/no-go gate | ✅ Active |

Related: device/functional QA lives in [../QA_CHECKLIST.md](../QA_CHECKLIST.md);
architecture in [../ARCHITECTURE.md](../ARCHITECTURE.md).

## Locked release identity (summary)

| Field | Value |
|---|---|
| applicationId | `com.lunexa.quietly` |
| Publisher | Lunexa |
| Category | Tools |
| Privacy URL | https://uselunexa.com/privacy/quietly (+ `/tr/`, `/es/`) |
| Support email | hello@uselunexa.com |
| Store title | **Provisional** — see RELEASE_IDENTITY.md |

## How to use
- **Privacy policy:** publish [PRIVACY_POLICY.md](PRIVACY_POLICY.md) to
  `uselunexa.com/privacy/quietly` (and localized variants). The repo copy is
  authoritative; the website mirrors it.
- **Play Console:** copy listing text from [STORE_LISTING.md](STORE_LISTING.md),
  answer Data Safety from [DATA_SAFETY.md](DATA_SAFETY.md), and the content-rating
  questionnaire from [CONTENT_RATING.md](CONTENT_RATING.md).
- **Before submitting:** work top-to-bottom through
  [CLOSED_TESTING_CHECKLIST.md](CLOSED_TESTING_CHECKLIST.md).

## Deferred (not yet created)
- `PRIVACY_POLICY.tr.md` / `PRIVACY_POLICY.es.md`, `STORE_LISTING.tr.md` /
  `STORE_LISTING.es.md` — localized copies (need translations).
- Play listing **art** (512×512 icon, 1024×500 feature graphic, screenshots) —
  to be produced and stored alongside these docs when ready.
