# Quietly — Google Play Data Safety Answers

> **Status:** Drafted · **Last updated:** 2026-05-29 · **Owner:** Lunexa
> Recommended answers for the Play Console Data Safety form. Consistent with
> [PERMISSIONS_REVIEW.md](PERMISSIONS_REVIEW.md) and [PRIVACY_POLICY.md](PRIVACY_POLICY.md).

## Top-level answer
**"Does your app collect or share any of the required user data types?" → `No`.**

### Rationale (defensible)
Quietly transmits **no** user data to Lunexa or any third party. There are **no**
analytics, ads, crash-reporting, or account SDKs (verified: zero matches). Two
network behaviors exist and **neither is data collection by the developer**:
1. Fetches to **user-pasted** media URLs — user-initiated, to destinations the
   user chooses.
2. A reachability `HEAD` to `https://www.gstatic.com/generate_204` — carries **no**
   user data.

All app data (preferences + history incl. pasted URLs and local file paths) is
stored **on-device only**. Local storage is **not** "collection" (collection =
transmitted off device).

## Data type matrix

| Category | Collected? | Shared? |
|---|---|---|
| Location | No | No |
| Personal info | No | No |
| Financial info | No | No |
| Health & fitness | No | No |
| Messages | No | No |
| **Photos and videos** | **No** — app *writes/saves* media; never collects/transmits it (and, post-cleanup, never reads the library) | No |
| Audio files | No | No |
| Files and docs | No | No |
| Calendar | No | No |
| Contacts | No | No |
| App activity | No | No |
| Web browsing | No | No |
| App info & performance | No | No |
| Device or other IDs | No | No |

## Other form fields
- **Encrypted in transit?** N/A (no user data collected). *(Downloads use HTTPS
  when the user's URL is HTTPS.)*
- **Can users request data deletion?** Yes, on-device: **Settings → Clear history**;
  uninstalling removes all local data. No server-side data exists.
- **Account creation / deletion URL required?** **No accounts** → not applicable.
- **Designed for / appeals to children (Families policy)?** No — general-purpose
  utility; target a general/adult audience.

## Consistency note
This "No data collected" posture is airtight **after** the permission trim in
[PERMISSIONS_REVIEW.md](PERMISSIONS_REVIEW.md) (removing media-read access). Ship
the manifest trim and this declaration together.
