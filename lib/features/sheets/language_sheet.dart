// ─────────────────────────────────────────────────────────────
// Quietly — Language picker sheet
//
// Settings → Language. A radio list (System default / English / Türkçe / Español)
// wired to AppState.languageMode, presented via showModalBottomSheet (lib/app/
// router/sheets.dart). Mirrors the quality sheet: RadioListTile rows inside a
// RadioGroup (Flutter ≥3.32), plus the shared QButton. Selecting a language
// applies immediately — MaterialApp.router rebuilds in the new locale — and the
// choice is persisted via the bootstrap write-through.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icons/q_icons.dart';
import '../../core/theme/tokens/app_spacing.dart';
import '../../core/theme/tokens/app_typography.dart';
import '../../core/widgets/q_button.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state_provider.dart';
import '../../state/models/app_enums.dart';

/// Localized label for a language mode (used by the rows and the Settings value).
String languageModeLabel(AppLocalizations l, AppLanguageMode mode) =>
    switch (mode) {
      AppLanguageMode.system => l.languageSystem,
      AppLanguageMode.en => l.languageEnglish,
      AppLanguageMode.tr => l.languageTurkish,
      AppLanguageMode.es => l.languageSpanish,
    };

class LanguageSheet extends ConsumerWidget {
  const LanguageSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(appStateProvider).languageMode;
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
        child: RadioGroup<AppLanguageMode>(
          groupValue: selected,
          onChanged: (mode) {
            if (mode != null) notifier.setLanguageMode(mode);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(l.settingLanguage, style: AppTypography.title),
              ),
              SizedBox(height: AppSpacing.md),
              for (final mode in AppLanguageMode.values)
                RadioListTile<AppLanguageMode>(
                  value: mode,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    languageModeLabel(l, mode),
                    style: AppTypography.body,
                  ),
                ),
              SizedBox(height: AppSpacing.md),
              QButton(
                label: l.languageDone,
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
