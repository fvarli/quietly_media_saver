// ─────────────────────────────────────────────────────────────
// Quietly — Quality picker sheet
//
// HANDOFF screen 5: a radio list of qualities with a "Recommended" marker, wired
// to AppState.quality, presented via showModalBottomSheet (lib/app/router/
// sheets.dart). Uses RadioListTile rows (a11y-ready, ≥48dp) inside a RadioGroup
// (Flutter ≥3.32 API), plus the shared QPill / QButton components.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icons/q_icons.dart';
import '../../core/theme/tokens/app_spacing.dart';
import '../../core/theme/tokens/app_typography.dart';
import '../../core/widgets/q_button.dart';
import '../../core/widgets/q_pill.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state_provider.dart';
import '../../state/models/quality_option.dart';

class QualitySheet extends ConsumerWidget {
  const QualitySheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(appStateProvider).quality;
    final notifier = ref.read(appStateProvider.notifier);
    final l = AppLocalizations.of(context);

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
                child: Text(l.qualityTitle, style: AppTypography.title),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(l.qualitySubtitle, style: AppTypography.caption),
              SizedBox(height: AppSpacing.md),
              for (final option in kQualityOptions)
                RadioListTile<String>(
                  value: option.id,
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      Text(qualityLabel(l, option), style: AppTypography.body),
                      if (option.recommended) ...[
                        SizedBox(width: AppSpacing.sm),
                        QPill(l.qualityRecommended, tone: QPillTone.accent),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    l.qualitySubRow(qualityTag(l, option), option.size),
                    style: AppTypography.micro,
                  ),
                ),
              SizedBox(height: AppSpacing.md),
              QButton(
                label: l.qualityDone,
                icon: QIcons.check,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
