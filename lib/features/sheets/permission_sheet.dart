// ─────────────────────────────────────────────────────────────
// Quietly — Permission request sheet (placeholder)
//
// HANDOFF screen 11: ask to save to the gallery; allow / not now. Presented via
// showModalBottomSheet. The sheet itself performs NO navigation: it simply pops
// with a bool result (true = allowed). The caller (AppFlow.requestSave) then
// grants permission and starts the download using the underlying screen's
// still-valid context — avoiding the defunct-context trap of navigating from a
// widget that is being torn down.
//
// NO real OS permission this pass — permission_handler, permanentlyDenied
// deep-link, and Android 13+ scoped media (READ_MEDIA_*) are a later pass
// (HANDOFF §7/§E). The grant only flips the in-memory permissionGranted flag.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../core/theme/tokens/app_spacing.dart';
import '../../core/theme/tokens/app_typography.dart';

class PermissionSheet extends StatelessWidget {
  const PermissionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Allow saving to your gallery',
                style: AppTypography.title,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Quietly needs permission to save media to your device’s gallery. '
              'We only write the files you choose — nothing else.',
              style: AppTypography.bodySub,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Allow access'),
            ),
            SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not now'),
            ),
          ],
        ),
      ),
    );
  }
}
