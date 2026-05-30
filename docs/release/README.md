# Quietly — Release documentation

> **Status:** Active · **Last updated:** 2026-05-30 · **Owner:** Lunexa
> Single source of truth for Quietly's Google Play release identity, policy, and
> store materials. The hosted privacy policy and Play Console listing are mirrored
> *from* these files.

Quietly is a calm, rights-aware **media saver** (a Tools utility, not a game) that
saves **direct, public media files** from links the user pastes. No scraping, no
social-platform extraction, no private/DRM access, no account, no ads, no tracking.

## Documents

| Doc | Purpose | Status |
|---|---|---|
| [RELEASE_IDENTITY.md](RELEASE_IDENTITY.md) | Locked app id, publisher, category, URLs, title | 🔒 Locked |
| [PRODUCT_POSITIONING.md](PRODUCT_POSITIONING.md) | Permanent positioning lock — "Media Saver", not "Downloader"; what to avoid; risk model; roadmap | 🔒 Locked |
| [PERMISSIONS_REVIEW.md](PERMISSIONS_REVIEW.md) | Per-permission justification + target set + Q3 actions | ✅ Reviewed (Q3B/Q3C done) |
| [DATA_SAFETY.md](DATA_SAFETY.md) | Play Data Safety questionnaire answers | ✅ Drafted |
| [PRIVACY_POLICY.md](PRIVACY_POLICY.md) | Canonical privacy policy (source of truth) | ✅ Draft (2 publish placeholders) |
| [STORE_LISTING.md](STORE_LISTING.md) | Locked title, descriptions, "What's new" | ✅ Locked |
| [CONTENT_RATING.md](CONTENT_RATING.md) | IARC answers + expected rating | ✅ Drafted |
| [PLAY_CONSOLE_SUBMISSION.md](PLAY_CONSOLE_SUBMISSION.md) | Copy-paste Play Console submission sheet (15 sections) | ✅ Ready |
| [CLOSED_TESTING_OPS.md](CLOSED_TESTING_OPS.md) | Closed-testing rollout + tester/email/feedback/bug templates + production-access answers | ✅ Ready |
| [CLOSED_TESTING_CHECKLIST.md](CLOSED_TESTING_CHECKLIST.md) | Release go/no-go gate | ✅ Active |

Related: device/functional QA lives in [../QA_CHECKLIST.md](../QA_CHECKLIST.md);
architecture in [../ARCHITECTURE.md](../ARCHITECTURE.md).

## Locked release identity (summary)

| Field | Value |
|---|---|
| applicationId | `com.lunexa.quietly` |
| Publisher | Lunexa |
| Category | Tools |
| Website / contact | https://uselunexa.com |
| Privacy URL | https://uselunexa.com/privacy/quietly (+ `/tr/`, `/es/`) |
| Support email | hello@uselunexa.com |
| Store title | **Quietly – Media Saver** (locked) |

## How to use
- **Privacy policy:** publish [PRIVACY_POLICY.md](PRIVACY_POLICY.md) to
  `uselunexa.com/privacy/quietly` (and localized variants). The repo copy is
  authoritative; the website mirrors it.
- **Play Console:** copy listing text from [STORE_LISTING.md](STORE_LISTING.md),
  answer Data Safety from [DATA_SAFETY.md](DATA_SAFETY.md), and the content-rating
  questionnaire from [CONTENT_RATING.md](CONTENT_RATING.md).
- **Before submitting:** work top-to-bottom through
  [CLOSED_TESTING_CHECKLIST.md](CLOSED_TESTING_CHECKLIST.md).

## Store assets
See [../store-assets/README.md](../store-assets/README.md). **Done:** adaptive +
legacy launcher icon, **512×512 Play icon**, **1024×500 feature graphic**, and **18
localized phone screenshots (en/tr/es, 1080×2400)**. **Pending (production only):**
replace the **interim** icon with the final Lunexa brand mark, then regenerate the
derived art.

## Deferred / follow-ups
- `PRIVACY_POLICY.tr.md` / `PRIVACY_POLICY.es.md` — localized privacy policy
  (need translations; use existing live pages if available).
- **Localize History entry titles** — data-layer strings ("Video clip", "Image",
  "3 images") render in English in the tr/es history screenshots; small follow-up
  in the state layer (no `BuildContext` today). Out of scope for the store-assets phase.
- Final Lunexa brand icon (production only), then regenerate derived art (see store-assets).
