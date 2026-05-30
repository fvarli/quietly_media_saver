# Quietly — Play Console Submission Sheet (copy-paste)

> **Status:** Ready · **Last updated:** 2026-05-30 · **Owner:** Lunexa
> Operational, copy-paste values for every Play Console field, from actual project
> facts. `<…>` marks values only you can supply. Mirrors `docs/release/` sources.

## 0. Identity (reference)
- **App title:** `Quietly – Media Saver`  · **Package:** `com.lunexa.quietly`
- **Publisher:** Lunexa · **Category:** Tools · **Price:** Free
- **Support:** hello@uselunexa.com · **Website:** https://uselunexa.com
- **Privacy:** https://uselunexa.com/privacy/quietly
- **Min Android:** 7.0 (API 24) · **Target:** API 36 · AAB signed with upload key `quietly_upload`

## 1. App details
- **App name:** `Quietly – Media Saver` (identical in every locale).
- **Default language:** English (United States) – `en-US`
- **Short description (≤80):**
  `Calmly save public media you have the rights to — private, no ads, no tracking.`
- **Full description:** use the full text in [STORE_LISTING.md](STORE_LISTING.md).
- **Additional languages (add via Store listing → Manage translations):**
  - **Turkish (tr-TR):** title/short/full + "What's new" from [STORE_LISTING.tr.md](STORE_LISTING.tr.md).
  - **Spanish (es-ES):** title/short/full + "What's new" from [STORE_LISTING.es.md](STORE_LISTING.es.md).
  - In-app UI is localized for these locales; the title stays `Quietly – Media Saver`.

## 2. Category
- **App category:** Tools
- **(App or game):** App

## 3. Tags
Pick the most accurate Tools/utility tags (≤5). Suggested: **Utilities**,
**File management / Files**. **Do NOT** choose any "video downloader" / platform tag.

## 4. Contact details (Store settings → Store listing contact)
- **Email:** hello@uselunexa.com
- **Website:** https://uselunexa.com
- **Phone:** `<optional — leave blank if none>`

## 5. Target audience & content
- **Target age group(s):** **18 and over** (recommended — utility, not for children;
  avoids the Designed-for-Families program and child-content scrutiny).
- **Appeals to children?** No.
- **Store presence / ads targeting children?** No.

## 6. App access
- Select **"All functionality is available without special access"** — Quietly has
  **no login, no account, no region lock, no special credentials**. No instructions
  needed for reviewers.

## 7. Ads
- **Does your app contain ads?** **No.**

## 8. Data safety
Use [DATA_SAFETY.md](DATA_SAFETY.md). Key answers:
- **Does your app collect or share any required user data types?** **No.**
- **Uses an advertising ID (AD_ID)?** **No.** (Not declared in the manifest.)
- **Data encrypted in transit?** N/A (no user data collected).
- **Users can request data deletion?** Yes — in-app **Settings → Clear history** +
  uninstall remove all local data; no server-side data; no account.
- All data categories (location, personal info, photos/videos, files, app activity,
  device IDs, etc.) → **Not collected, Not shared.**

## 9. Content rating (IARC questionnaire)
Use [CONTENT_RATING.md](CONTENT_RATING.md). Summary:
- **Category:** Utility / Productivity / Tools (not a game).
- Violence / sexual / profanity / drugs / gambling / fear → **No**.
- Collects/shares personal info or location → **No**. Users interact / share location → **No**.
- **Allows access to the internet (user-provided URLs)?** **Yes** (disclose; expect
  the **"Unrestricted Internet"** interactive-elements label).
- **Expected rating:** Everyone / PEGI 3 / USK 0 (lowest band).

## 10. Privacy policy
- **URL:** `https://uselunexa.com/privacy/quietly` (must be live before review;
  body is [PRIVACY_POLICY.md](PRIVACY_POLICY.md)).

## 11. Store listing
- **App name:** `Quietly – Media Saver` (same in en/tr/es).
- **Short / Full description:** en from [STORE_LISTING.md](STORE_LISTING.md);
  tr from [STORE_LISTING.tr.md](STORE_LISTING.tr.md);
  es from [STORE_LISTING.es.md](STORE_LISTING.es.md).
- **Graphics (you must supply — no platform logos, no "download from X"):**
  - **App icon:** 512 × 512 px, 32-bit PNG (≤1 MB).
  - **Feature graphic:** 1024 × 500 px, PNG/JPG (required).
  - **Phone screenshots:** 6 per language, 1080 × 2400 PNG (within 320–3840 px/side,
    ≤8 MB). Upload per language:
    - en (default) → `docs/store-assets/screenshots/en/01-home … 06-private.png`
    - Turkish (tr-TR) → `docs/store-assets/screenshots/tr/…`
    - Spanish (es-ES) → `docs/store-assets/screenshots/es/…`
    (If a language has no localized screenshots in Console, Play falls back to the
    default-language set — but localized shots are supplied here.)
  - *(Optional)* 7" & 10" tablet screenshots.
- **Status:** copy is final (en/tr/es); **screenshots done (18, localized)**; icon
  interim + final brand art pending (see Deferred in README).

## 12. Release notes (v1.0.0)
- **en-US:**
```
First release of Quietly — a calm, private way to save public media you have the
rights to. Paste a direct link, check it, and save it to your gallery. No ads,
no tracking, no account.
```
- **tr-TR:** use the "What's new" block in [STORE_LISTING.tr.md](STORE_LISTING.tr.md).
- **es-ES:** use the "What's new" block in [STORE_LISTING.es.md](STORE_LISTING.es.md).

## 13. Pricing & distribution
- **Price:** Free (cannot later switch a free app to paid).
- **Contains ads:** No.
- **In-app purchases:** None.
- **Content guidelines & US export laws:** confirm/accept the declarations.

## 14. Countries / regions
- **Recommended:** start with **all countries/regions**, or a named launch subset
  `<list>`. (During closed testing, only opted-in testers can install regardless of
  country selection.) Ensure compliance with local/export rules.

## 15. Closed testing setup
1. **Testing → Closed testing → Create track** (or use the default "Closed testing").
2. **Release name:** `1.0.0 (1)` · upload `build/app/outputs/bundle/release/app-release.aab`.
3. **Testers:** add an **email list** (≥12 addresses) or a **Google Group**.
4. Accept **Play App Signing** enrollment on first upload.
5. **Roll out** to the closed track; share the **opt-in URL** with testers.
6. Keep ≥12 testers opted in for **14 continuous days** (see [CLOSED_TESTING_OPS.md](CLOSED_TESTING_OPS.md)).

> Pre-submission gate: complete every BLOCKER in
> [CLOSED_TESTING_CHECKLIST.md](CLOSED_TESTING_CHECKLIST.md) first.
