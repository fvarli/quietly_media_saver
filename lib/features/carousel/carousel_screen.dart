// ─────────────────────────────────────────────────────────────
// Quietly — Carousel screen (multi-select)
//
// HANDOFF screen 4: a multi-item post where the user picks which media to save,
// with a live selected count + total size, select-all/clear, and a save CTA.
// Built from the Q component library; selection state lives in AppState
// (carousel items) and is mutated through AppStateNotifier.
//
// Pass-3 scope: presentation + selection only. "Save selected" routes through
// the existing AppFlow.requestSave (permission sheet from pass 1) → simulated
// download. No real download/permission/gallery yet.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/flow/app_flow.dart';
import '../../core/icons/q_icons.dart';
import '../../core/theme/tokens/app_colors.dart';
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
import '../../state/models/carousel_item.dart';

class CarouselScreen extends ConsumerWidget {
  const CarouselScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = AppFlow(context, ref);
    final l = AppLocalizations.of(context);
    final notifier = ref.read(appStateProvider.notifier);
    final state = ref.watch(appStateProvider);
    final items = state.carousel;
    final selected = state.selectedCount;
    final allSelected = state.allCarouselSelected;

    return Scaffold(
      appBar: QTopBar(
        title: l.carouselItemsFound(items.length),
        onBack: () => context.canPop() ? context.pop() : flow.goHome(),
        right: QButton(
          label: allSelected ? l.carouselClear : l.carouselSelectAll,
          variant: QButtonVariant.ghost,
          size: QButtonSize.sm,
          fullWidth: false,
          onPressed: notifier.toggleSelectAll,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  QPill(
                    l.carouselTag,
                    tone: QPillTone.accent,
                    icon: QIcons.layers,
                  ),
                  SizedBox(width: AppSpacing.sm + 1),
                  Text(
                    l.carouselSelectedCount(selected),
                    style: AppTypography.caption.copyWith(color: AppColors.sub),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xs,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                itemCount: items.length,
                separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm + 1),
                itemBuilder: (context, i) => _CarouselRow(
                  item: items[i],
                  index: i,
                  onTap: () => notifier.toggleCarouselItem(i),
                ),
              ),
            ),
            _Footer(
              selectedCount: selected,
              sizeMb: state.selectedSizeMb,
              onSave: selected == 0
                  ? null
                  : () => flow.requestSave(
                      state.selectedCarousel.map((it) => it.kind).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarouselRow extends StatelessWidget {
  const _CarouselRow({
    required this.item,
    required this.index,
    required this.onTap,
  });

  final CarouselItem item;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isVideo = item.kind == MediaKind.video;
    final title = isVideo
        ? l.carouselVideoTitle
        : l.carouselImageTitle(index + 1);
    final meta = isVideo
        ? '0:${item.durationSeconds ?? 0} · MP4 · ≈ ${item.megabytes} MB'
        : 'JPG · ≈ ${item.megabytes} MB';

    return QCard(
      onTap: onTap,
      active: item.selected,
      padding: const EdgeInsets.all(10),
      semanticLabel:
          '$title, $meta, ${item.selected ? 'selected' : 'not selected'}. Tap to toggle.',
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: QMediaTile(
              kind: item.kind,
              tone: isVideo ? QTileTone.cool : QTileTone.neutral,
              radius: 10,
              badge: isVideo ? const Icon(QIcons.play) : null,
            ),
          ),
          SizedBox(width: AppSpacing.md + 1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(meta, style: AppTypography.micro),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          _CheckCircle(on: item.selected),
        ],
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: on ? AppColors.accent : Colors.transparent,
        border: on ? null : Border.all(color: AppColors.hair, width: 2),
      ),
      child: on
          ? const Icon(QIcons.check, size: 15, color: AppColors.onAccent)
          : null,
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.selectedCount,
    required this.sizeMb,
    required this.onSave,
  });

  final int selectedCount;
  final double sizeMb;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final label = selectedCount == 0
        ? l.carouselSelectToSave
        : l.carouselSaveCta(selectedCount, sizeMb.toStringAsFixed(1));

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface2,
        border: Border(top: BorderSide(color: AppColors.hair2)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QButton(label: label, icon: QIcons.download, onPressed: onSave),
          SizedBox(height: AppSpacing.md),
          const RightsNote(RightsCopy.save),
        ],
      ),
    );
  }
}
