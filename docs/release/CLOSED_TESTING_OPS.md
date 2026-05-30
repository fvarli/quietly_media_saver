# Quietly — Closed Testing Operations (copy-paste)

> **Status:** Ready · **Last updated:** 2026-05-30 · **Owner:** Lunexa
> Operational kit for running Google Play closed testing toward production access.
> Assumes the current Play rule for personal developer accounts: **≥12 testers
> opted in for 14 continuous days** before applying for production. `<…>` = fill in.

App: **Quietly – Media Saver** · Package: `com.lunexa.quietly` · Min Android 7.0 (API 24).

---

## 1. Closed-testing rollout checklist
- [ ] BLOCKERs in [CLOSED_TESTING_CHECKLIST.md](CLOSED_TESTING_CHECKLIST.md) all done.
- [ ] `flutter build appbundle --release` → upload-key-signed AAB ready.
- [ ] Play app created; **Play App Signing** accepted.
- [ ] Store listing, Data Safety, content rating, privacy URL submitted.
- [ ] Closed-testing track created; release `1.0.0 (1)` uploaded + rolled out.
- [ ] **≥12 testers** added (email list or Google Group) — aim for **15–20** to
      absorb drop-off / inactive accounts.
- [ ] Opt-in URL shared; each tester **accepts the invite AND installs**.
- [ ] Feedback form + bug template links shared (items 4–5).
- [ ] Start date logged: `<YYYY-MM-DD>` → 14-day window ends `<YYYY-MM-DD>`.
- [ ] Mid-test check (~day 7): confirm testers still opted in + active.
- [ ] Triage feedback; ship fixes as new releases to the same track if needed.
- [ ] Day 14+: complete the production-access readiness checklist (item 6).

## 2. Tester onboarding guide
```
Welcome to the Quietly closed test 🌿

Quietly is a calm, private way to SAVE public media you have the rights to.

REQUIREMENTS
• An Android phone on Android 7.0 or newer
• The Google account you gave us (the invite is tied to that email)

JOIN (2 minutes)
1. Open this opt-in link on your phone and tap "Become a tester":
   <OPT_IN_URL>
2. Tap the Google Play link shown, then Install.
   (If Play says the app isn't available, give it a few minutes after accepting,
    then reopen the link.)

HOW TO TEST
Quietly works with DIRECT, PUBLIC media file links (a URL that ends in an image
or video file you have the right to save) — it does NOT work with social-media
page links, private/login content, or "download from <platform>" links by design.

Please try:
• First launch — read and accept the one-time "quick note" sheet.
• Paste a direct public image link (…/photo.jpg) → it should analyze → Save → it
  appears in your gallery and in History.
• Paste a direct public video link (…/clip.mp4) → analyze → Save → plays from gallery.
• Paste a normal web page / social link → you should get a calm "can't read this
  source" message (expected — not a bug).
• Open / Share / Remove an item from History.
• Turn Wi-Fi/data off → the offline note should appear; turn it back on.
• Force-close and reopen → your history + settings should persist; the first-run
  note should NOT reappear.

Tell us what felt confusing, broken, or slow. Honest feedback is the goal.
Feedback form: <FEEDBACK_FORM_URL>
Bug reports: <BUG_FORM_OR_EMAIL>
Thanks! — Lunexa · hello@uselunexa.com
```

## 3. Tester invitation email
```
Subject: You're invited to test Quietly (Android) 🌿

Hi <Name>,

Thanks for helping test Quietly — a calm, private media saver by Lunexa.

It's a small Android app that saves direct, public media links to your gallery.
No ads, no tracking, no account.

To join (about 2 minutes, on your Android phone):
1) Tap "Become a tester" here: <OPT_IN_URL>
2) Then install Quietly from the Google Play link shown.

Quick start + what to try:
<LINK_TO_ONBOARDING_OR_PASTE_SECTION_2>

Please keep the app installed for the next ~2 weeks and share any feedback:
• Feedback form: <FEEDBACK_FORM_URL>
• Found a bug? <BUG_FORM_OR_EMAIL>

The invite is tied to this email's Google account. Reply here with any trouble.

Thank you!
— <Your name>, Lunexa
hello@uselunexa.com · https://uselunexa.com
```

## 4. Feedback form template (Google Forms-ready)
```
Form title: Quietly — Tester Feedback
Intro: Thanks for testing Quietly! ~3 minutes. Be candid.

1. Your device model + Android version  (short answer)
2. Were you able to install and open Quietly?  (Yes / No / Had trouble)
3. Did saving a public media link work for you?  (Worked / Partly / Didn't work / Didn't try)
4. How clear was the first-run "quick note"?  (1–5)
5. How calm/easy did the app feel overall?  (1–5)
6. Anything confusing or surprising?  (paragraph)
7. Anything that broke or looked wrong?  (paragraph)
8. Did the app feel fast enough?  (Yes / Mostly / No)
9. Would you keep using it?  (Yes / Maybe / No)
10. Anything else for the Lunexa team?  (paragraph)
```

## 5. Bug report template
```
**Summary:** <one line>
**Severity:** Blocker / Major / Minor / Cosmetic
**Device & Android version:** <e.g. Pixel 6a, Android 14>
**App version:** 1.0.0 (1)
**Link type used:** direct image / direct video / page link / other: <…>
**Steps to reproduce:**
1.
2.
3.
**Expected result:**
**Actual result:**
**Screenshot / screen recording:** <attach if possible>
**Frequency:** every time / sometimes / once
**Notes:**
```

## 6. Production-access readiness checklist
- [ ] **≥12 testers** opted in and **stayed opted in 14 continuous days**.
- [ ] Testers actually **installed and used** the app (not just accepted).
- [ ] Feedback **collected** (form responses / emails) and **reviewed**.
- [ ] Issues **triaged**; meaningful fixes shipped to the closed track.
- [ ] Store listing, Data Safety, content rating, privacy URL all **complete & live**.
- [ ] No outstanding policy warnings in the Play Console **Policy status**.
- [ ] App is **stable** (no known blocker crashes; pre-launch report reviewed).
- [ ] Decide **production countries** + staged-rollout %.

## 7. Google Play production-access application — answers
*(Play asks how you ran closed testing; paste/adapt. Use real numbers — no invented data.)*
```
How did you recruit your testers?
> Testers are <friends/colleagues/community members> personally invited by the
> Lunexa team via email, using their Google account addresses on a closed-testing
> email list. <N> testers were invited; <N> opted in.

How did you engage with your testers / gather feedback?
> Each tester received an onboarding guide and a structured feedback form plus a
> bug-report template. We asked them to install Quietly, save public media links,
> and report any issues. We <reviewed responses on a rolling basis / met informally>.

What feedback did you receive, and what did you change?
> <Summarize real feedback themes>. In response we <list concrete changes shipped,
> e.g. clarified copy / fixed X / no changes needed because no issues were found>.

Why do you believe the app is ready for production?
> Quietly is a small, privacy-first utility (no ads, no tracking, no account, no
> data collection). It passed <N> automated tests, a release build is signed with
> our upload key, and <N> testers used it over 14 days without blocker issues.

Target countries for production:
> <All countries / named list>.
```

> Tip: keep a short log of tester count, opt-in date, and feedback so these answers
> are factual and consistent with the Console data.
