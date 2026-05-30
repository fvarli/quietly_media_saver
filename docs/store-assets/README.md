# Quietly — Store assets

> **Status:** icon = **interim** (serviceable, not final brand) · feature graphic = done · screenshots = run integration_test on a device · **Last updated:** 2026-05-30 · **Owner:** Lunexa
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
| **Phone screenshots** (6) | ✅ | ⏳ Run on device | `docs/store-assets/screenshots/` (via integration_test) |

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

## Screenshots — run the integration_test capture on a device/emulator
Headless `flutter test` renders text as boxes (no bundled font), so screenshots use
**`integration_test`** (real device fonts + real UI). Files:
- `integration_test/store_screenshots_test.dart` — seeds + renders the 6 screens, calls `binding.takeScreenshot('NN-name')`.
- `test_driver/integration_test.dart` — writes the bytes to `docs/store-assets/screenshots/NN-name.png`.

Run on a phone/emulator (recommend a 1080×2340 phone profile for Play dimensions):
```
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/store_screenshots_test.dart \
  -d <device-id>
```
Produces (real fonts, legible): `01-home`, `02-public-media`, `03-analyze`,
`04-save`, `05-history`, `06-private` `.png`. Verify each is legible + within Play
limits (24-bit, sides 320–3840 px, ≤8 MB) before upload.

Captions (storyboard): Save public media, calmly. · Public media only — rights
respected. · Check what's there, then save. · Straight to your gallery. ·
Everything you saved, in one calm place. · No ads. No tracking. No account.

> `test/store_screenshots.dart` (headless) remains as a layout preview only (text
> renders as boxes); the integration_test path is the real-screenshot route.

## Target dimensions (reference)
- Hi-res icon: **512×512**, 32-bit PNG, no alpha, ≤1 MB. *(done, interim art)*
- Feature graphic: **1024×500**, 24-bit, no alpha. *(done)*
- Phone screenshots: 6; **1080×2340** recommended; sides 320–3840 px; ≤8 MB.
- Adaptive icon: 108×108 dp, foreground in central 72×72 dp safe zone. *(done)*

## Final brand icon prompt (for later)
> "Minimalist app icon for 'Quietly', a calm privacy-first media saver. Flat vector
> on warm off-white (#FAF8F4) rounded square. A single soft indigo (#4B53C4) glyph:
> a rounded shape that suggests calmly saving media into a tray/pocket. Thick
> rounded strokes, generous padding, no text, no platform logos, no photos.
> 1024×1024, centered with safe margins for adaptive masking."
