// ─────────────────────────────────────────────────────────────
// Quietly — Quality picker sheet (placeholder)
//
// HANDOFF screen 5: radio list of qualities with a "Recommended" marker, wired
// to AppState.quality. Presented via showModalBottomSheet (see
// lib/app/router/sheets.dart). Shell pass uses RadioListTile rows (a11y-ready,
// ≥48dp); the bespoke card rows + size estimates come next.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_spacing.dart';
import '../../core/theme/tokens/app_typography.dart';
import '../../state/app_state_provider.dart';
import '../../state/models/quality_option.dart';

class QualitySheet extends ConsumerWidget {
  const QualitySheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(appStateProvider).quality;
    final notifier = ref.read(appStateProvider.notifier);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        // RadioGroup manages the selected value for the rows (Flutter ≥3.32 API).
        child: RadioGroup<String>(
          groupValue: selected,
          onChanged: (id) {
            if (id != null) notifier.setQuality(id);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text('Choose quality', style: AppTypography.title),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Higher quality looks sharper but uses more storage.',
                style: AppTypography.caption,
              ),
              SizedBox(height: AppSpacing.md),
              for (final option in kQualityOptions)
                RadioListTile<String>(
                  value: option.id,
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      Text(option.label, style: AppTypography.body),
                      if (option.recommended) ...[
                        SizedBox(width: AppSpacing.sm),
                        const _RecommendedPill(),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    '${option.tag} · ≈ ${option.size}',
                    style: AppTypography.micro,
                  ),
                ),
              SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendedPill extends StatelessWidget {
  const _RecommendedPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs / 2,
      ),
      decoration: const BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Text(
        'Recommended',
        style: AppTypography.micro.copyWith(
          color: AppColors.accentInk,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
