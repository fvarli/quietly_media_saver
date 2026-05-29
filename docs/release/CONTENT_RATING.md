# Quietly — Content Rating (IARC)

> **Status:** Drafted · **Last updated:** 2026-05-29 · **Owner:** Lunexa
> Recommended answers for the Play Console IARC questionnaire. Quietly is a
> **non-game utility**, so complete the standard app questionnaire.

## Questionnaire category
**App** → **Utility / Productivity / Tools** ("All other app types"). Not a game,
reference, news, medical, or dating app.

## Recommended answers (by topic)

| IARC topic | Answer | Why |
|---|---|---|
| Violence (realistic/cartoon/fantasy) | **No** | None |
| Sexual or suggestive content / nudity | **No** | None |
| Profanity / crude humor | **No** | None |
| Controlled substances (drugs/alcohol/tobacco) | **No** | None |
| Gambling (real or simulated) | **No** | None |
| Fear / horror | **No** | None |
| In-app purchases / paid digital content | **No** | No IAP, no ads |
| Collects/shares personal info or location | **No** | Matches Data Safety "no data collected" |
| Users can communicate/interact | **No** | No accounts, chat, comments, social |
| Shares user's location with other users | **No** | No location use |

## Two judgment calls (answer honestly to avoid a mismatch)
1. **"Does the app let users share content?"** → **Effectively No / OS-level.**
   "Share" uses the **device OS share sheet** to share a file the user already
   saved, to recipients the user chooses. No in-app community/feed/public posting.
   Answer the social/UGC questions **No**; if asked specifically about system
   sharing, answer truthfully — it does not change the rating.
2. **"Does the app allow access to the internet / unrestricted web content?"** →
   **Yes, disclose it.** The user can point Quietly at any direct media URL, and it
   requests `INTERNET`. It is **not a web browser** (no page rendering, no feed),
   but declaring internet access is honest and prevents a questionnaire-vs-manifest
   mismatch. Expect the **"Unrestricted Internet"** interactive-elements label.

## Expected outcome

| Board | Expected rating |
|---|---|
| Google Play (global default) | **Rated for 3+ / Everyone** |
| ESRB (Americas) | Everyone |
| PEGI (Europe) | PEGI 3 |
| USK (Germany) | USK 0 |
| ClassInd / others | lowest age band |

- **Interactive Elements labels:** likely **"Unrestricted Internet"** only — *not*
  "Users Interact," "Shares Location," or "Digital Purchases."
- **Target audience / Families:** general/adult audience; do **not** opt into the
  Designed-for-Families program.

## Note
The rating is auto-assigned from the answers; answer truthfully. A false "no
internet" answer conflicts with the `INTERNET` permission and can trigger review
issues.
