# Quietly — Release Identity

> **Status:** Locked · **Last updated:** 2026-05-30 · **Owner:** Lunexa
> The permanent and near-permanent identity decisions for Quietly's Play release.

## Locked decisions

| Field | Value | Notes |
|---|---|---|
| **Store title** | **`Quietly – Media Saver`** | Locked (21 chars); brand + clear function |
| **applicationId / namespace** | `com.lunexa.quietly` | **Permanent** after first publish |
| **Publisher / developer** | **Lunexa** (umbrella) | Not "Lunexa Games" — Quietly is a utility |
| **Category** | **Tools** | Most accurate; lowest review friction |
| **Website / contact** | `https://uselunexa.com` | No dedicated product page assumed |
| **Privacy URL** | `https://uselunexa.com/privacy/quietly` | + `/tr/privacy/quietly`, `/es/privacy/quietly` |
| **Support email** | `hello@uselunexa.com` | Ecosystem-wide, monitored |
| **Versioning** | `versionName` semver + monotonic `versionCode` | Start `1.0.0+1`; bump `+N` every upload |

## Rationale

**Namespace (`com.lunexa.*`).** Chosen as the unified ecosystem root for future
games + tools + SaaS. A flat `com.lunexa.<app>` scheme (no mutable category
segment like `.tools.`/`.games.`) keeps permanent ids honest and consistent.
- **Permanence caveat:** the `applicationId` can never change after publish, and
  `com.lunexa.*` is **not** the reverse-DNS of a domain currently owned
  (uselunexa.com is). Acceptable (brands commonly use `com.<brand>`), but two
  cheap safeguards before first publish: (1) **secure `lunexa.com`** if it's the
  intended canonical brand domain; (2) keep all future apps on the same
  `com.lunexa.*` root. *(The domain-accurate alternative would have been
  `com.uselunexa.quietly`.)*

**Publisher = Lunexa (umbrella).** The developer name shows on every listing; a
utility under "Lunexa Games" would misrepresent it. One trusted publisher spans
both games and tools.

**Category = Tools.** Quietly saves media you point it at — a utility. "Video
Players & Editors" is inaccurate and invites downloader comparison; "Productivity"
is a stretch.

## Sibling ecosystem context
- RPS Duel — game (legacy package; unchanged)
- Chess Rescue — game (legacy package; unchanged)
- **Quietly — utility; first app on the unified `com.lunexa.*` root**

Legacy game packages are immutable and stay as-is; new products adopt
`com.lunexa.<app>`.
