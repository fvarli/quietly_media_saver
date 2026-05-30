// ─────────────────────────────────────────────────────────────
// Quietly — Trust row
//
// A calm, reassuring strip surfacing Quietly's privacy posture:
//   No ads · No account · No tracking.
// Used on Home, onboarding, and Success so the reassurance is visible rather
// than buried in rights copy.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../icons/q_icons.dart';
import '../theme/tokens/app_colors.dart';
import '../theme/tokens/app_spacing.dart';
import '../theme/tokens/app_typography.dart';

class TrustRow extends StatelessWidget {
  const TrustRow({super.key});

  static const _items = ['No ads', 'No account', 'No tracking'];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'No ads, no account, no tracking',
      excludeSemantics: true,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.xs,
        children: [
          for (final item in _items)
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
