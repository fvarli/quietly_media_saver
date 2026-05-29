// ─────────────────────────────────────────────────────────────
// Quietly — Permission request sheet (placeholder)
//
// HANDOFF screen 11: a calm PRIMING sheet that explains why gallery access is
// needed before the OS prompt. It performs no I/O and no navigation — it simply
// pops a bool (true = the user tapped "Allow access"). The caller
// (AppFlow.requestSave) then triggers the REAL permission_handler request on the
// underlying screen's still-valid context and branches on the result (Pass 5A).
// This pre-permission priming improves grant rates and keeps the OS dialog from
// appearing cold.
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
