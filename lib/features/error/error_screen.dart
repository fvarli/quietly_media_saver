// ─────────────────────────────────────────────────────────────
// Quietly — Error / edge-state screen (config-driven)
//
// HANDOFF screens 12–17 (+ permission-denied-permanently and queue-item-failed):
// ONE reusable screen rendered from kErrorConfig (lib/state/error_config.dart),
// selected by AppState.error. Calm, rights-aware refusals — copy is preserved
// verbatim from the config; do not soften.
//
// The config is pure data (string icon names, tone). This UI layer maps those to
// QIcons + token colors and wires each kind's CTAs through AppFlow (with SnackBar
// placeholders for the not-yet-real gallery / system-settings actions). No
// permission_handler / downloader this pass.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/flow/app_flow.dart';
import '../../core/icons/q_icons.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_radius.dart';
import '../../core/theme/tokens/app_spacing.dart';
import '../../core/theme/tokens/app_typography.dart';
import '../../core/widgets/q_button.dart';
import '../../core/widgets/q_top_bar.dart';
import '../../core/widgets/rights_note.dart';
import '../../state/app_state_provider.dart';
import '../../state/error_config.dart';
import '../../state/models/app_enums.dart';

/// Resolves a design icon name (from ErrorConfig) to a Material [IconData].
IconData _errorIcon(String name) => switch (name) {
  'lock' => QIcons.lock,
  'alert' => QIcons.alert,
  'wifiOff' => QIcons.wifiOff,
  'globe' => QIcons.globe,
  'folder' => QIcons.folder,
  'check' => QIcons.check,
  'settings' => QIcons.settings,
  'link' => QIcons.link,
  'paste' => QIcons.paste,
  'refresh' => QIcons.refresh,
  'sliders' => QIcons.sliders,
  'photo' => QIcons.photo,
  _ => QIcons.info,
};

/// Tone → (foreground, soft background) token pair.
({Color fg, Color bg}) _toneColors(ErrorTone tone) => switch (tone) {
  ErrorTone.neutral => (fg: AppColors.faintText, bg: AppColors.bgSunken),
  ErrorTone.warn => (fg: AppColors.warn, bg: AppColors.warnSoft),
  ErrorTone.success => (fg: AppColors.success, bg: AppColors.successSoft),
  ErrorTone.danger => (fg: AppColors.danger, bg: AppColors.dangerSoft),
};

class ErrorScreen extends ConsumerWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = AppFlow(context, ref);
    final kind = ref.watch(appStateProvider).error;
    final cfg = errorConfigFor(AppLocalizations.of(context), kind);
    final tone = _toneColors(cfg.tone);
    final actions = _actionsFor(kind, flow);
    final showRefusal =
        kind == AppErrorKind.protected || kind == AppErrorKind.unsupported;

    return Scaffold(
      appBar: QTopBar(onBack: flow.goHome),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.sizeOf(context).height * 0.5,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl + 6,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: tone.bg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _errorIcon(cfg.icon),
                            size: 34,
                            color: tone.fg,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxl),
                        Semantics(
                          header: true,
                          child: Text(
                            cfg.title,
                            textAlign: TextAlign.center,
                            style: AppTypography.title.copyWith(fontSize: 21),
                          ),
                        ),
                        SizedBox(height: AppSpacing.md - 1),
                        Text(
                          cfg.body,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySub,
                        ),
                        if (cfg.tips != null) ...[
                          SizedBox(height: AppSpacing.xl),
                          _TipsCard(tips: cfg.tips!),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xxl - 2,
                AppSpacing.md,
                AppSpacing.xxl - 2,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QButton(
                    label: cfg.cta,
                    icon: cfg.ctaIcon == null ? null : _errorIcon(cfg.ctaIcon!),
                    onPressed: actions.primary,
                  ),
                  if (cfg.secondary != null) ...[
                    SizedBox(height: AppSpacing.sm + 1),
                    QButton(
                      label: cfg.secondary!,
                      variant: QButtonVariant.ghost,
                      onPressed: actions.secondary,
                    ),
                  ],
                  if (showRefusal) ...[
                    SizedBox(height: AppSpacing.md),
                    const RightsNote(RightsCopy.refusal),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Maps each error kind to its primary/secondary callbacks.
  ({VoidCallback primary, VoidCallback secondary}) _actionsFor(
    AppErrorKind kind,
    AppFlow flow,
  ) {
    return switch (kind) {
      AppErrorKind.network => (
        primary: flow.retryAnalysis,
        secondary: flow.goHome,
      ),
      AppErrorKind.storage => (
        primary: flow.goHome,
        secondary: flow.openSettings,
      ),
      // "Already in your gallery" → open the matching saved entry.
      AppErrorKind.exists => (
        primary: flow.openExistingSaved,
        secondary: flow.goHome,
      ),
      AppErrorKind.permissionDeniedPermanently => (
        // Real OS app-settings deep-link.
        primary: flow.openSystemSettings,
        secondary: flow.goHome,
      ),
      AppErrorKind.queueItemFailed => (
        primary: flow.retryDownload,
        secondary: flow.goHome,
      ),
      // protected / invalid / unsupported: both return Home.
      _ => (primary: flow.goHome, secondary: flow.goHome),
    };
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard({required this.tips});

  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: AppColors.hair),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).errTipsHeader,
            style: AppTypography.caption.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSpacing.xs + 1),
          for (final tip in tips)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: _Dot(),
                  ),
                  SizedBox(width: AppSpacing.sm + 1),
                  Expanded(
                    child: Text(
                      tip,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.sub,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) => Container(
    width: 5,
    height: 5,
    decoration: const BoxDecoration(
      color: AppColors.faintText,
      shape: BoxShape.circle,
    ),
  );
}
