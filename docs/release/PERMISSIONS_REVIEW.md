# Quietly — Permissions Justification Review

> **Status:** Reviewed (config changes pending in Q3) · **Last updated:** 2026-05-29 · **Owner:** Lunexa
> What the app actually requests vs what it actually needs, with the minimal
> target permission set and the code/config actions to reach it.

## What the app actually does (verified in code)
- **Saves only.** `OsGalleryService.saveFile` (`lib/services/gallery/gallery_service.dart`)
  copies the downloaded file into **app-private** documents, then writes a copy to
  the device gallery via `gal` (`Gal.putImage/putVideo`, best-effort). `open` /
  `share` / `remove` act on the app's **own** file.
- **It never reads or browses the user's media library.** No gallery picker, no
  `MediaStore` query, no read of user photos/videos.
- **Permission request** (`PlatformPermissionService._galleryPermissions`,
  `lib/services/permissions/permission_service.dart`): Android 13+ requests
  `Permission.photos` + `Permission.videos` → `READ_MEDIA_IMAGES` +
  `READ_MEDIA_VIDEO`; older Android → `Permission.storage`; iOS → `Permission.photos`.

## Headline finding
> **The app requests READ media permissions but only ever WRITES media.** This is
> over-permissioning. `READ_MEDIA_IMAGES/VIDEO` is a sensitive, heavily-scrutinized
> Play permission and is **not justifiable** for a save-only app — a realistic
> cause of permission-policy rejection or a Data Safety mismatch.

`gal` saving needs **no runtime permission on Android 10+ (API 29+)** and only
`WRITE_EXTERNAL_STORAGE` on API ≤28. It never needs `READ_MEDIA_*`. The read
permissions are vestigial from Pass 5A, predating the save-only design (Pass 7B).

## Per-permission verdict

| Permission (current) | Used for | Verdict | Play risk |
|---|---|---|---|
| `INTERNET` | Analysis HEAD probe + media download | ✅ **Keep** — essential | None (normal) |
| `WRITE_EXTERNAL_STORAGE` (maxSdk 28) | `gal` save on Android ≤9 | ✅ **Keep** — correctly scoped | None (legacy-only) |
| `READ_MEDIA_IMAGES` | *(nothing — never reads images)* | ❌ **Remove** | High scrutiny (sensitive) |
| `READ_MEDIA_VIDEO` | *(nothing — never reads video)* | ❌ **Remove** | High scrutiny (sensitive) |
| `READ_EXTERNAL_STORAGE` (maxSdk 32) | *(nothing — no library read)* | ❌ **Remove** | Moderate |
| `ACCESS_NETWORK_STATE` *(auto-merged by connectivity_plus)* | Connectivity check | ✅ Keep (implicit) | None (normal, no prompt) |

## Recommended target permission set
```
INTERNET
WRITE_EXTERNAL_STORAGE   (android:maxSdkVersion="28")
ACCESS_NETWORK_STATE     (added via connectivity_plus manifest merge — benign)
```
…and nothing else. Minimal, fully justifiable, and materially de-risks review.
After this trim, **no Play sensitive-permission declaration form is triggered**.

## Q3 config action items (NOT done yet)
1. **Manifest** (`android/app/src/main/AndroidManifest.xml`): remove
   `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_EXTERNAL_STORAGE`; keep
   `INTERNET` + `WRITE_EXTERNAL_STORAGE`(≤28).
2. **Code** (`lib/services/permissions/permission_service.dart`): rework
   `PlatformPermissionService` to gal-based access (no media-read perms):
   - Android API ≥29 → no runtime permission needed to save (the priming sheet /
     permission gate can be skipped); route via `Gal.requestAccess()`/`hasAccess()`.
   - Android API ≤28 → request `Permission.storage` (WRITE) only.
   - Adjust `AppFlow.requestSave` accordingly. **Update affected permission tests;
     keep `flutter analyze` + `flutter test` green.**
3. **iOS** (deferred): request **add-only** Photos (`NSPhotoLibraryAddUsageDescription`
   already present); drop the unused full-library `NSPhotoLibraryUsageDescription`.
4. **Verify** the merged manifest (`flutter build` output) shows only the intended
   permissions.
