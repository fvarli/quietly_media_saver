// ─────────────────────────────────────────────────────────────
// Quietly — "How it works" steps
//
// Shows Quietly's 4-step model so a new user understands the app at a glance:
//   Paste link → Analyze media → Save to gallery → View history.
// [StepsRow] is a compact horizontal strip (Home); [StepsList] is a vertical,
// numbered list with one-line descriptions (onboarding + empty states).
// Copy is localized via AppLocalizations.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../icons/q_icons.dart';
import '../theme/tokens/app_colors.dart';
import '../theme/tokens/app_spacing.dart';
import '../theme/tokens/app_typography.dart';

class _Step {
  const _Step(this.icon, this.short, this.label, this.description);
  final IconData icon;
  final String short;
  final String label;
  final String description;
}

List<_Step> _steps(AppLocalizations l) => [
  _Step(QIcons.paste, l.stepPasteShort, l.stepPasteLabel, l.stepPasteDesc),
  _Step(
    QIcons.search,
    l.stepAnalyzeShort,
    l.stepAnalyzeLabel,
    l.stepAnalyzeDesc,
  ),
  _Step(QIcons.download, l.stepSaveShort, l.stepSaveLabel, l.stepSaveDesc),
  _Step(
    QIcons.clock,
    l.stepHistoryShort,
    l.stepHistoryLabel,
    l.stepHistoryDesc,
  ),
];

/// Compact horizontal strip of the 4 steps (icon + short label).
class StepsRow extends StatelessWidget {
  const StepsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = _steps(AppLocalizations.of(context));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Icon(
                QIcons.chevronRight,
                size: 16,
                color: AppColors.faintText,
              ),
            ),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(steps[i].icon, size: 19, color: AppColors.accent),
                ),
                SizedBox(height: AppSpacing.xs + 1),
                Text(
                  steps[i].short,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(color: AppColors.sub),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Vertical, numbered list of the 4 steps with one-line descriptions.
class StepsList extends StatelessWidget {
  const StepsList({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = _steps(AppLocalizations.of(context));
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == steps.length - 1 ? 0 : AppSpacing.lg,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(steps[i].icon, size: 21, color: AppColors.accent),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[i].label,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        steps[i].description,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.sub,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
