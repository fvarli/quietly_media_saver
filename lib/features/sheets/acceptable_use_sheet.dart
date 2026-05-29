// ─────────────────────────────────────────────────────────────
// Quietly — First-run acceptable-use sheet
//
// A calm, one-time acknowledgement shown over Home on first launch. It states
// the rights-aware positioning plainly (public media only; you must have the
// rights; private/login/DRM isn't supported) without being scary or legalistic.
// It is non-dismissible (no scrim tap, no drag, no back) — the single
// "I understand" button is the only way out, and it pops `true` so the caller
// can persist the acknowledgement.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../core/icons/q_icons.dart';
import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_spacing.dart';
import '../../core/theme/tokens/app_typography.dart';
import '../../core/widgets/q_button.dart';

class AcceptableUseSheet extends StatelessWidget {
  const AcceptableUseSheet({super.key});

  static const _points = <String>[
    'Quietly saves public media only.',
    'Save only content you have the rights or permission to save.',
    'Private, login-only, and DRM-protected media isn’t supported.',
  ];

  @override
  Widget build(BuildContext context) {
    // Block back-dismissal; the sheet is also shown non-dismissible / no-drag.
    return PopScope(
      canPop: false,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
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
                  'A quick note before you start',
                  style: AppTypography.title,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Quietly helps you save media the calm, respectful way.',
                style: AppTypography.bodySub,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),
              for (final point in _points) ...[
                _Point(point),
                SizedBox(height: AppSpacing.md),
              ],
              SizedBox(height: AppSpacing.sm),
              QButton(
                label: 'I understand',
                icon: QIcons.check,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(QIcons.check, size: 15, color: AppColors.accent),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTypography.body.copyWith(color: AppColors.ink),
          ),
        ),
      ],
    );
  }
}
