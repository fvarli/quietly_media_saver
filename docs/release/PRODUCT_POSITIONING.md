# Quietly — Product Positioning (locked)

> **Status:** 🔒 Locked · **Last updated:** 2026-05-30 · **Owner:** Lunexa
> Permanent strategy document. Its purpose is to **prevent drift** of Quietly's
> product vision. Changes here are deliberate and rare. The live store copy
> ([STORE_LISTING.md](STORE_LISTING.md)) and identity
> ([RELEASE_IDENTITY.md](RELEASE_IDENTITY.md)) must obey this document.

## TL;DR
**Quietly's public identity is a "Media Saver", NOT a "Downloader."** It is a
privacy-first, rights-aware, **platform-neutral** Tools utility for saving
**publicly accessible** media the user has the right to keep. We never brand around
specific platforms, and we never position around bypassing protections.

## How we got here (evolution)
Quietly started as a traditional multi-platform **video downloader** idea. Concepts
considered early on included an Instagram downloader, a TikTok downloader, an
X/Twitter downloader, and a YouTube downloader.

After **Google Play policy review and launch planning**, the direction evolved.
Platform-specific "downloader" framing is a high-risk category on Google Play
(unauthorized-download policy, IP/ToS concerns) and is off-brand for a calm,
privacy-first product. The approved direction is a **generic, platform-neutral
media saver**.

## Approved positioning
| | |
|---|---|
| **Product** | Quietly – Media Saver |
| **Category** | Tools |
| **Core positioning** | Privacy-first media saver |

**Store language to USE**
- Save publicly accessible media
- Analyze media links
- Save media to your gallery
- Rights-aware workflow
- Respect creators and platform policies

**Store language to AVOID (never use)**
- "Video Downloader" / "Downloader"
- "Download any video" / "download from <platform>"
- Platform-specific branding or names
- Instagram / TikTok / YouTube / X / Facebook logos or marks
- Any claim that implies bypassing platform restrictions
- Piracy-oriented language

## Key distinction: capability vs marketing
**Technical capability and marketing positioning are different concepts.** What the
app *can* technically do does not dictate how it is *presented* on the store. The
two are governed separately and must not be conflated.

## 1. Technical capability
- The application **may** support additional media sources in the future; the
  resolver/extractor architecture may expand over time.
- Supporting a source **technically does not require mentioning it in Play Store
  marketing.** Capability is an engineering matter; the listing stays platform-
  neutral (see §2).
- Capability growth is always subordinate to the **Compliance Boundaries** below
  and the **Non-negotiable principles** (§5).

### Compliance Boundaries (permanent)
Any future media-source support **must not** rely on bypassing:
- **authentication / login** (no logged-in-only access),
- **DRM** or other technical protection measures,
- **paywalls** or subscription gates,
- **private content** (anything not publicly accessible),
- **platform access controls** of any kind.

Quietly is intended for **publicly accessible and permitted media workflows only.**
Expansion means adding *sources that already meet this bar* — never a way around
protections. **This boundary is permanent and overrides any capability ambition or
roadmap item.** If a proposed source can only work by defeating a protection, it is
out of scope by definition.

## 2. Store positioning
- Quietly is presented as a **generic, platform-neutral media saver.**
- The listing, title, descriptions, and graphics stay **platform-neutral** — no
  platform names or logos (see [STORE_LISTING.md](STORE_LISTING.md)).
- **Rights-aware language remains** in store listings **and** in-app onboarding —
  the first-run acceptable-use gate and the persistent rights note are part of the
  product, not optional dressing.

## 3. Risk model
**Low-risk positioning (our chosen path)**
- Generic "media saver" in the **Tools** category.
- Platform-neutral; no platform names/logos anywhere.
- Rights-aware copy + acceptable-use onboarding.
- Minimal, justified permissions; no ads/analytics/account.
- Works with direct, publicly accessible media.

**High-risk positioning (rejected)**
- Platform-specific "downloader" branding (e.g. "Instagram/TikTok/YouTube
  downloader").
- "Download any video", "save any content", bypass-implying claims.
- Platform logos / mimicking platform brands.

**Why high-risk positioning raises Play review risk:** Google Play scrutinizes apps
that facilitate unauthorized downloading — especially from Google's own services
and in violation of third-party ToS. Platform-specific downloader branding signals
exactly that pattern to reviewers, invites IP/ToS complaints, and is a common cause
of rejection or removal **regardless of how the app is actually implemented.**
Platform-neutral, rights-aware positioning keeps Quietly clearly on the compliant
side and is honestly defensible in review.

## 4. Long-term roadmap
**Phase 1 — Launch**
- Closed testing.
- Production access.

**Phase 2 — Product improvements**
- Product/UX improvements.
- Additional supported media sources (within the Compliance Boundaries).
- Better analysis workflows.

**Phase 3 — Broader support**
- Evaluate broader media support **without changing the core positioning** —
  Quietly stays a platform-neutral, privacy-first, rights-aware media saver.

## 5. Non-negotiable principles
1. **No piracy positioning.**
2. **No copyright-infringement messaging.**
3. **No misleading marketing.**
4. **Respect creators.**
5. **Respect platform policies.**
6. **Privacy-first experience** (no ads, no tracking, no account, local-only data).

## For future contributors
If you are tempted to add "Downloader" to the title, name a platform in the
listing, use a platform logo, or market the ability to grab content from a specific
service — **don't.** That choice was deliberately rejected for Play-policy and brand
reasons documented above. Quietly's public identity is **"Media Saver", not
"Downloader."** Engineering capability may grow within the Compliance Boundaries;
the **positioning does not.**

See also: [RELEASE_IDENTITY.md](RELEASE_IDENTITY.md) · [STORE_LISTING.md](STORE_LISTING.md).
