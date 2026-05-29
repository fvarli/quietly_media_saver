// ─────────────────────────────────────────────────────────────
// Quietly — Download screen (single + multi queue)
//
// HANDOFF screens 6/7: single-file ring progress, or a multi-file queue with
// per-item bars. Progress now comes from the DownloadQueueService (via
// downloadQueueStateProvider) — the screen is a thin consumer, not a driver.
//
// Terminal states are handled with ref.listen → AppFlow (keeps the notifier
// pure): all-complete → Success; any failure → the "queueItemFailed" error.
// Footer controls drive the service: Pause/Resume + Cancel (→ Home).
//
// Still simulated (no real network); the simulation lives in the service now.
// Tests drive it with explicit pump(Duration) (never pumpAndSettle — the
// service timer only settles at a terminal state).
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/flow/app_flow.dart';
import '../../core/icons/q_icons.dart';
import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_spacing.dart';
import '../../core/theme/tokens/app_typography.dart';
import '../../core/widgets/q_bar.dart';
import '../../core/widgets/q_button.dart';
import '../../core/widgets/q_card.dart';
import '../../core/widgets/q_ring.dart';
import '../../core/widgets/q_top_bar.dart';
import '../../services/downloads/download_models.dart';
import '../../services/downloads/download_queue_provider.dart';
import '../../state/models/app_enums.dart';

class DownloadingScreen extends ConsumerWidget {
  const DownloadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = AppFlow(context, ref);
    final service = ref.read(downloadQueueServiceProvider);
    final state =
        ref.watch(downloadQueueStateProvider).value ?? service.current;

    // React to terminal states (navigation lives here, not in the notifier).
    ref.listen(downloadQueueStateProvider, (_, next) {
      final s = next.value;
      if (s == null) return;
      if (s.isComplete) {
        flow.finishDownload();
      } else if (s.hasFailure) {
        flow.showError(AppErrorKind.queueItemFailed);
      }
    });

    final multi = state.isMulti;
    final paused = state.isPaused;

    return Scaffold(
      appBar: QTopBar(title: multi ? 'Saving items' : null),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: multi
                  ? _MultiQueue(state: state)
                  : _SingleProgress(progress: state.overallProgress),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QButton(
                    label: paused ? 'Resume' : 'Pause',
                    icon: paused ? QIcons.download : QIcons.close,
                    variant: QButtonVariant.soft,
                    onPressed: paused ? service.resume : service.pause,
                  ),
                  SizedBox(height: AppSpacing.sm + 1),
                  QButton(
                    label: 'Cancel',
                    icon: QIcons.close,
                    variant: QButtonVariant.outline,
                    onPressed: () {
                      service.cancel();
                      flow.goHome();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Single-file progress ────────────────────────────────────────
class _SingleProgress extends StatelessWidget {
  const _SingleProgress({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    // Fabricated demo figures (no real transfer this pass).
    final mb = (progress * 24).toStringAsFixed(1);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl + 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'Saving, $pct percent',
              child: QRing(
                progress: progress,
                size: 150,
                strokeWidth: 11,
                child: Text.rich(
                  TextSpan(
                    text: '$pct',
                    style: AppTypography.display.copyWith(
                      fontSize: 36,
                      letterSpacing: -1,
                    ),
                    children: const [
                      TextSpan(text: '%', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xxl + 4),
            Text(
              'Saving video…',
              style: AppTypography.headline.copyWith(fontSize: 18),
            ),
            SizedBox(height: AppSpacing.sm - 2),
            Text(
              '$mb MB of 24 MB · 3.2 MB/s',
              style: AppTypography.caption.copyWith(color: AppColors.sub),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Multi-file queue ────────────────────────────────────────────
class _MultiQueue extends StatelessWidget {
  const _MultiQueue({required this.state});

  final DownloadQueueState state;

  @override
  Widget build(BuildContext context) {
    final items = state.items;
    final overall = state.overallProgress;
    final done = state.completedCount;
    final remaining = items.length - done;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Row(
            children: [
              Semantics(
                label: 'Overall progress ${(overall * 100).round()} percent',
                child: QRing(
                  progress: overall,
                  size: 62,
                  strokeWidth: 6,
                  child: Text(
                    '${(overall * 100).round()}%',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saving ${items.length} items',
                      style: AppTypography.headline,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$done done · $remaining remaining',
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
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm + 1),
            itemBuilder: (context, i) => _QueueRow(item: items[i]),
          ),
        ),
      ],
    );
  }
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({required this.item});

  final DownloadItem item;

  @override
  Widget build(BuildContext context) {
    final pct = (item.progress * 100).round();
    final complete = item.isComplete;
    final failed = item.isFailed;
    final isVideo = item.kind == MediaKind.video;

    final statusText = switch (item.status) {
      DownloadItemStatus.completed => '${item.meta} · done',
      DownloadItemStatus.failed => '${item.meta} · failed',
      DownloadItemStatus.paused => '${item.meta} · paused',
      DownloadItemStatus.canceled => '${item.meta} · canceled',
      _ => '${item.meta} · $pct%',
    };

    final Color iconBg = complete
        ? AppColors.successSoft
        : failed
        ? AppColors.dangerSoft
        : AppColors.accentSoft;
    final Color iconFg = complete
        ? AppColors.success
        : failed
        ? AppColors.danger
        : AppColors.accent;
    final IconData glyph = complete
        ? QIcons.check
        : failed
        ? QIcons.alert
        : (isVideo ? QIcons.film : QIcons.image);

    return Semantics(
      label: '${item.name}, ${item.status.name}',
      container: true,
      child: QCard(
        padding: const EdgeInsets.all(11),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(glyph, size: 15, color: iconFg),
                ),
                SizedBox(width: AppSpacing.md - 1),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(statusText, style: AppTypography.micro),
                    ],
                  ),
                ),
                if (complete)
                  const Icon(QIcons.check, size: 16, color: AppColors.success),
              ],
            ),
            if (!complete && !failed) ...[
              SizedBox(height: AppSpacing.sm + 1),
              QBar(progress: item.progress),
            ],
          ],
        ),
      ),
    );
  }
}
