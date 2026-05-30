# Quietly — Store assets

> **Status:** icon = **interim** (serviceable, not final brand) · feature graphic = done · screenshots = done (**18 @ 1080×2400, localized en/tr/es**) · **Last updated:** 2026-05-31 · **Owner:** Lunexa
> Google Play visual assets for **Quietly – Media Saver**. Brand: paper `#FAF8F4`,
> ink `#211D18`, indigo accent `#4B53C4`. **No platform logos, no "download from X".**

## ⚠️ Interim icon (replace before public production launch)
The previous icon was the **stock Flutter logo**. It has been replaced with an
**interim Quietly mark** — a calm indigo "save into tray" glyph on paper
(`assets/icon/quietly_icon_1024.png` + transparent foreground
`assets/icon/quietly_icon_foreground.png`). It is serviceable for **internal/closed
testing** but is **not the final brand**. To swap: replace those two source PNGs,
run `dart run flutter_launcher_icons`, re-export `icon-512.png`, and regenerate the
feature graphic (commands below).

## Status

| Asset | Required | Status | Location |
|---|---|---|---|
| Launcher icon (adaptive + legacy) | Android | ✅ Interim | `android/app/src/main/res/` |
| Play hi-res icon **512×512** | ✅ | ✅ Interim | `docs/store-assets/icon-512.png` |
| Icon master (1024) + foreground | source | ✅ Interim | `assets/icon/quietly_icon_1024.png`, `…_foreground.png` |
| **Feature graphic 1024×500** | ✅ | ✅ Done | `docs/store-assets/feature-graphic-1024x500.png` |
| **Phone screenshots** (6 × 3 locales) | ✅ | ✅ Done (1080×2400, on-device, localized) | `docs/store-assets/screenshots/{en,tr,es}/01-home … 06-private.png` |

## Regenerate icon + 512 + feature graphic (after swapping the icon)
```
dart run flutter_launcher_icons
convert assets/icon/quietly_icon_1024.png -resize 512x512 -alpha off -depth 8 docs/store-assets/icon-512.png
NB=/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf
NR=/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf
convert -size 1024x500 xc:'#FAF8F4' \
  -fill '#EEEFFB' -draw 'roundrectangle 664,40 984,460 40,40' \
  \( assets/icon/quietly_icon_foreground.png -resize 300x300 \) -gravity NorthWest -geometry +684+110 -composite \
  -gravity NorthWest \
  -font "$NB" -fill '#211D18' -pointsize 104 -annotate +70+135 'Quietly' \
  -font "$NR" -fill '#211D18' -pointsize 38 -annotate +74+270 'Save public media, calmly.' \
  -font "$NR" -fill '#857E73' -pointsize 27 -annotate +74+330 'No ads  ·  No tracking  ·  No account' \
  -alpha remove -alpha off -depth 8 docs/store-assets/feature-graphic-1024x500.png
```

## Screenshots — ✅ captured (1080×2400, on-device, localized en/tr/es)
18 screenshots — the 6 core screens in each of **en / tr / es** — live under
`screenshots/<locale>/`. Captured on an Android emulator (real fonts + real UI) and
verified (legible, on-brand, abstract media only, no platform logos, localized UI
confirmed per locale). Headless `flutter test` renders text as boxes, so capture
uses **`integration_test`**:
- `integration_test/store_screenshots_test.dart` — seeds + renders the 6 screens,
  forces the UI language from `--dart-define=SHOT_LOCALE`, and calls
  `binding.takeScreenshot('<locale>/NN-name')`.
- `test_driver/integration_test.dart` — writes the bytes to
  `docs/store-assets/screenshots/<locale>/NN-name.png` (creates the folder).

To **re-capture** (e.g. after the final brand icon lands), boot an Android
device/emulator and run **once per locale** (`SHOT_LOCALE` ∈ `en|tr|es`, default `en`):
```
for L in en tr es; do
  flutter drive \
    --driver=test_driver/integration_test.dart \
    --target=integration_test/store_screenshots_test.dart \
    --dart-define=SHOT_LOCALE=$L \
    -d <device-id>
done
```
Produces, per locale: `01-home`, `02-public-media`, `03-analyze`, `04-save`,
`05-history`, `06-private` `.png`. Verify each is legible + within Play limits
(8-/24-bit PNG, sides 320–3840 px, ≤8 MB) before upload. Note: the 1080×2400 (~9:20)
frame is taller than Play's 2:1 display guideline; accepted on upload — re-frame to
1080×2160 if ever rejected.

> Emulator note: the API-36 SwiftShader emulator can drop ADB on a fast cold connect.
> If `flutter drive` reports "device offline", `adb kill-server && adb start-server`,
> reboot the AVD, let it settle, and re-run that locale.

Captions (storyboard, per screen 01→06):
- **en:** Save public media, calmly. · Public media only — rights respected. · Check what's there, then save. · Straight to your gallery. · Everything you saved, in one calm place. · No ads. No tracking. No account.
- **tr:** Herkese açık medyayı sakince kaydedin. · Yalnızca herkese açık medya — haklara saygılı. · Neyin olduğunu görün, sonra kaydedin. · Doğrudan galerinize. · Kaydettiğiniz her şey tek bir sakin yerde. · Reklam yok. Takip yok. Hesap yok.
- **es:** Guarda medios públicos, con calma. · Solo medios públicos: se respetan los derechos. · Mira qué hay y luego guarda. · Directo a tu galería. · Todo lo que guardaste, en un solo lugar tranquilo. · Sin anuncios. Sin rastreo. Sin cuenta.

> **Known limitation:** on `05-history`, the screen *chrome* is fully localized, but
> the seeded demo entry titles ("Video clip", "Image", "3 images") render in English
> in the tr/es shots — they're data-layer strings produced without a `BuildContext`
> (see [PRODUCT_POSITIONING.md](../release/PRODUCT_POSITIONING.md) / the l10n notes).
> Acceptable for now; tracked as a follow-up, not fixed in this store-assets phase.

> `test/store_screenshots.dart` (headless) remains as a layout preview only (text
> renders as boxes); the integration_test path is the real-screenshot route.

## Target dimensions (reference)
- Hi-res icon: **512×512**, 32-bit PNG, no alpha, ≤1 MB. *(done, interim art)*
- Feature graphic: **1024×500**, 24-bit, no alpha. *(done)*
- Phone screenshots: 6 per locale (**18** total, en/tr/es); **1080×2400** (as captured); sides 320–3840 px; ≤8 MB.
- Adaptive icon: 108×108 dp, foreground in central 72×72 dp safe zone. *(done)*

## Final brand icon prompt (for later)
> "Minimalist app icon for 'Quietly', a calm privacy-first media saver. Flat vector
> on warm off-white (#FAF8F4) rounded square. A single soft indigo (#4B53C4) glyph:
> a rounded shape that suggests calmly saving media into a tray/pocket. Thick
> rounded strokes, generous padding, no text, no platform logos, no photos.
> 1024×1024, centered with safe margins for adaptive masking."
