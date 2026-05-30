// ─────────────────────────────────────────────────────────────
// Quietly — Trust row
//
// A calm, reassuring strip surfacing Quietly's privacy posture:
//   No ads · No account · No tracking.   (localized)
// Used on Home, onboarding, and Success so the reassurance is visible rather
// than buried in rights copy.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../icons/q_icons.dart';
import '../theme/tokens/app_colors.dart';
import '../theme/tokens/app_spacing.dart';
import '../theme/tokens/app_typography.dart';

class TrustRow extends StatelessWidget {
  const TrustRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = [l.trustNoAds, l.trustNoAccount, l.trustNoTracking];
    return Semantics(
      label: l.trustRowSemantic,
      excludeSemantics: true,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.xs,
        children: [
          for (final item in items)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(QIcons.check, size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Text(
                  item,
                  style: AppTypography.caption.copyWith(color: AppColors.sub),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
