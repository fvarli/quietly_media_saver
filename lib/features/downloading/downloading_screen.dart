// ─────────────────────────────────────────────────────────────
// Quietly — Download screen (single + multi queue)
//
// HANDOFF screens 6/7: single-file ring progress, or a multi-file queue with
// per-item bars. Built from QRing / QBar / QCard.
//
// SIMULATED (no real downloader this pass): a single finite AnimationController
// drives the visuals 0→100% and, on completion, auto-advances to Success via
// AppFlow. It is VISUAL ONLY — it never mutates AppState, keeping the notifier
// pure (the queue/items come from AppState.queue seeded by startDownload). The
// queue items animate with a stagger so they finish at slightly different times.
// Cancel returns Home. Like AnalyzingScreen, tests drive it with explicit
// pump(Duration) (never pumpAndSettle).
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
import '../../state/app_state_provider.dart';
import '../../state/models/app_enums.dart';
import '../../state/models/download_job.dart';

/// Total simulated-download duration before auto-advancing to Success.
const Duration kDownloadDuration = Duration(milliseconds: 2600);

class DownloadingScreen extends ConsumerStatefulWidget {
  const DownloadingScreen({super.key});

  @override
  ConsumerState<DownloadingScreen> createState() => _DownloadingScreenState();
}

class _DownloadingScreenState extends ConsumerState<DownloadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: kDownloadDuration,
  );

  @override
  void initState() {
    super.initState();
    _controller
      ..addStatusListener(_onStatus)
      ..forward();
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      AppFlow(context, ref).finishDownload();
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_onStatus)
      ..dispose();
    super.dispose();
  }

  /// Per-item progress with a stagger so items complete at different times.
  /// Item i ramps within the window [i*stagger, i*stagger + span].
  double _itemProgress(double v, int index, int count) {
    if (count <= 1) return v;
    const span = 0.7;
    final stagger = (1 - span) / (count - 1);
    final start = index * stagger;
    return ((v - start) / span).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final flow = AppFlow(context, ref);
    final queue = ref.watch(appStateProvider).queue;
    final multi = queue.length > 1;

    return Scaffold(
      appBar: QTopBar(title: multi ? 'Saving items' : null),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final v = _controller.value;
                  return multi
                      ? _MultiQueue(
                          value: v,
                          queue: queue,
                          itemProgress: _itemProgress,
                        )
                      : _SingleProgress(value: v);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: QButton(
                label: 'Cancel',
                icon: QIcons.close,
                variant: QButtonVariant.outline,
                onPressed: flow.goHome,
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
  const _SingleProgress({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();
    // Fabricated demo figures (no real transfer this pass).
    final mb = (value * 24).toStringAsFixed(1);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl + 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'Saving, $pct percent',
              child: QRing(
                progress: value,
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
  const _MultiQueue({
    required this.value,
    required this.queue,
    required this.itemProgress,
  });

  final double value;
  final List<DownloadJob> queue;
  final double Function(double v, int index, int count) itemProgress;

  @override
  Widget build(BuildContext context) {
    final progresses = [
      for (var i = 0; i < queue.length; i++)
        itemProgress(value, i, queue.length),
    ];
    final overall = progresses.isEmpty
        ? 0.0
        : progresses.reduce((a, b) => a + b) / progresses.length;
    final done = progresses.where((p) => p >= 1).length;
    final remaining = queue.length - done;

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
                      'Saving ${queue.length} items',
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
            itemCount: queue.length,
            separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm + 1),
            itemBuilder: (context, i) =>
                _QueueRow(job: queue[i], progress: progresses[i]),
          ),
        ),
      ],
    );
  }
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({required this.job, required this.progress});

  final DownloadJob job;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    final complete = progress >= 1;
    final isVideo = job.kind == MediaKind.video;

    return Semantics(
      label: '${job.name}, ${complete ? 'done' : '$pct percent'}',
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
                    color: complete
                        ? AppColors.successSoft
                        : AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    complete
                        ? QIcons.check
                        : (isVideo ? QIcons.film : QIcons.image),
                    size: 15,
                    color: complete ? AppColors.success : AppColors.accent,
                  ),
                ),
                SizedBox(width: AppSpacing.md - 1),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.name,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        complete ? '${job.meta} · done' : '${job.meta} · $pct%',
                        style: AppTypography.micro,
                      ),
                    ],
                  ),
                ),
                if (complete)
                  const Icon(QIcons.check, size: 16, color: AppColors.success),
              ],
            ),
            if (!complete) ...[
              SizedBox(height: AppSpacing.sm + 1),
              QBar(progress: progress),
            ],
          ],
        ),
      ),
    );
  }
}
