// ─────────────────────────────────────────────────────────────
// Quietly — Result screen (single video)
//
// HANDOFF screen 3: an abstract media preview, source/format chips, an
// explainable note, a quality row that opens the quality sheet, and the
// "Save to gallery" CTA with its rights note.
//
// Pass-2 scope: presentation + sheet wiring only. "Save to gallery" routes
// through the existing AppFlow.requestSave (permission sheet from pass 1); no
// real download or permission handling yet. The share action is a no-op
// placeholder. Quality reflects AppState and updates live when changed.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/flow/app_flow.dart';
import '../../core/icons/q_icons.dart';
import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_radius.dart';
import '../../core/theme/tokens/app_spacing.dart';
import '../../core/theme/tokens/app_typography.dart';
import '../../core/widgets/q_button.dart';
import '../../core/widgets/q_card.dart';
import '../../core/widgets/q_media_tile.dart';
import '../../core/widgets/q_pill.dart';
import '../../core/widgets/q_top_bar.dart';
import '../../core/widgets/rights_note.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state_provider.dart';
import '../../state/models/app_enums.dart';
import '../../state/models/quality_option.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = AppFlow(context, ref);
    final l = AppLocalizations.of(context);
    final state = ref.watch(appStateProvider);
    final quality = state.qualityOption;

    // Drive from the analysis result; fall back to the static single-video
    // sample when visited without one (route robustness).
    final analysis = state.analysis;
    final item = (analysis != null && analysis.items.isNotEmpty)
        ? analysis.items.first
        : null;
    final kind = item?.kind ?? MediaKind.video;
    final isVideo = kind == MediaKind.video;
    final host = analysis?.host ?? 'example.com';
    final sizeMb = item?.sizeMb ?? 0;
    final format = isVideo ? l.resultFormatVideo : l.resultFormatImage;
    final formatLabel = sizeMb > 0
        ? '$format${l.resultSizeSuffix(_formatSize(sizeMb))}'
        : format;
    final count = analysis?.items.length ?? 1;
    final durationLabel = _formatDuration(item?.durationSeconds ?? 42);
    final title = isVideo
        ? l.resultVideoSummary(count)
        : l.resultImageSummary(count);
    final saveKinds =
        analysis?.items.map((m) => m.kind).toList() ?? const [MediaKind.video];

    return Scaffold(
      appBar: QTopBar(
        title: l.resultTitle,
        onBack: () => context.canPop() ? context.pop() : flow.goHome(),
        right: IconButton(
          onPressed: () {}, // Share is a no-op placeholder this pass.
          icon: const Icon(QIcons.share, size: 19),
          color: AppColors.sub,
          tooltip: l.shareTooltip,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xs,
                  AppSpacing.xl,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QMediaTile(
                      kind: kind,
                      tone: isVideo ? QTileTone.cool : QTileTone.neutral,
                      radius: AppRadius.xl,
                      aspectRatio: 4 / 3,
                      label: isVideo ? l.labelVideo : l.labelImage,
                      badge: isVideo
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(QIcons.play),
                                const SizedBox(width: 3),
                                Text(durationLabel),
                              ],
                            )
                          : null,
                      semanticLabel: isVideo ? l.previewVideo : l.previewImage,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Text(
                      title,
                      style: AppTypography.headline.copyWith(fontSize: 18),
                    ),
                    SizedBox(height: AppSpacing.sm - 1),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        QPill(
                          host,
                          tone: QPillTone.neutral,
                          icon: QIcons.globe,
                        ),
                        QPill(formatLabel, tone: QPillTone.neutral),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md + 2),
                    _ExplainNote(),
                    SizedBox(height: AppSpacing.lg),
                    _QualityRow(
                      label: l.resultQualityRow(
                        qualityLabel(l, quality),
                        qualityTag(l, quality),
                      ),
                      sub: l.resultQualitySub(quality.size),
                      onTap: flow.openQualitySheet,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              child: Column(
                children: [
                  QButton(
                    label: l.resultSaveCta,
                    icon: QIcons.download,
                    onPressed: () => flow.requestSave(saveKinds),
                  ),
                  SizedBox(height: AppSpacing.md),
                  const RightsNote(RightsCopy.save),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDuration(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

/// Compact size label for the detected media (e.g. "24 MB" / "1.4 MB").
String _formatSize(double mb) =>
    mb >= 10 ? '${mb.round()} MB' : '${mb.toStringAsFixed(1)} MB';

class _ExplainNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ExcludeSemantics(
          child: Icon(QIcons.info, size: 15, color: AppColors.faintText),
        ),
        SizedBox(width: AppSpacing.sm + 1),
        Expanded(
          child: Text(
            AppLocalizations.of(context).resultExplain,
            style: AppTypography.caption.copyWith(color: AppColors.sub),
          ),
        ),
      ],
    );
  }
}

class _QualityRow extends StatelessWidget {
  const _QualityRow({
    required this.label,
    required this.sub,
    required this.onTap,
  });

  final String label;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return QCard(
      onTap: onTap,
      semanticLabel: 'Quality: $label. Tap to change.',
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              QIcons.sliders,
              size: 19,
              color: AppColors.accent,
            ),
          ),
          SizedBox(width: AppSpacing.md + 1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(sub, style: AppTypography.micro),
              ],
            ),
          ),
          const Icon(QIcons.chevronDown, size: 18, color: AppColors.faintText),
        ],
      ),
    );
  }
}
