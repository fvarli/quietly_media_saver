// ─────────────────────────────────────────────────────────────
// Quietly — "How it works" steps
//
// Shows Quietly's 4-step model so a new user understands the app at a glance:
//   Paste link → Analyze media → Save to gallery → View history.
// [StepsRow] is a compact horizontal strip (Home); [StepsList] is a vertical,
// numbered list with one-line descriptions (onboarding + empty states).
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../icons/q_icons.dart';
import '../theme/tokens/app_colors.dart';
import '../theme/tokens/app_spacing.dart';
import '../theme/tokens/app_typography.dart';

/// One Quietly step: glyph, short label (row), full label + description (list).
class QStep {
  const QStep(this.icon, this.short, this.label, this.description);
  final IconData icon;
  final String short;
  final String label;
  final String description;
}

const List<QStep> kQuietlySteps = [
  QStep(
    QIcons.paste,
    'Paste',
    'Paste link',
    'Copy a public media link, then paste it.',
  ),
  QStep(
    QIcons.search,
    'Analyze',
    'Analyze media',
    'Quietly checks it’s public and readable.',
  ),
  QStep(
    QIcons.download,
    'Save',
    'Save to gallery',
    'The media is saved to your gallery.',
  ),
  QStep(
    QIcons.clock,
    'History',
    'View history',
    'Find everything you’ve saved, anytime.',
  ),
];

/// Compact horizontal strip of the 4 steps (icon + short label).
class StepsRow extends StatelessWidget {
  const StepsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'How it works: paste link, analyze media, save to gallery, view history',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < kQuietlySteps.length; i++) ...[
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
                    child: Icon(
                      kQuietlySteps[i].icon,
                      size: 19,
                      color: AppColors.accent,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs + 1),
                  Text(
                    kQuietlySteps[i].short,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(color: AppColors.sub),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Vertical, numbered list of the 4 steps with one-line descriptions.
class StepsList extends StatelessWidget {
  const StepsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < kQuietlySteps.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == kQuietlySteps.length - 1 ? 0 : AppSpacing.lg,
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
                  child: Icon(
                    kQuietlySteps[i].icon,
                    size: 21,
                    color: AppColors.accent,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kQuietlySteps[i].label,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        kQuietlySteps[i].description,
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
