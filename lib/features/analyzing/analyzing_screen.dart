// ─────────────────────────────────────────────────────────────
// Quietly — Analyzing screen
//
// HANDOFF screen 2: an explainable, calm analysis — a progress ring, a stepped
// checklist ("Reaching the page" → "Checking it's public" → "Listing available
// media"), and the link under inspection with a "Public" chip.
//
// The calm explainable UI (ring + stepped checklist + QDots) is VISUAL ONLY,
// driven by a finite controller. The navigation outcome comes from
// AppFlow.runAnalysis(), which calls the MediaAnalysisService and routes to
// Result / Carousel / Error. Tests use explicit `pump(Duration)` — never
// `pumpAndSettle`, since QDots animates forever. Back cancels to Home.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/flow/app_flow.dart';
import '../../core/icons/q_icons.dart';
import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_spacing.dart';
import '../../core/theme/tokens/app_typography.dart';
import '../../core/widgets/q_dots.dart';
import '../../core/widgets/q_ring.dart';
import '../../core/widgets/q_top_bar.dart';
import '../../core/widgets/url_chip.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state_provider.dart';

/// Visual duration of the analyzing animation (mirrors the calm minimum).
const Duration kAnalyzeVisualDuration = kMinAnalyzeDuration;

// Fractions of the animation at which each step flips to "done".
const List<double> _kStepThresholds = [0.24, 0.52, 0.80];

const String _kExampleUrl = 'share.example.com/p/8fa2c91b';

class AnalyzingScreen extends ConsumerStatefulWidget {
  const AnalyzingScreen({super.key});

  @override
  ConsumerState<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends ConsumerState<AnalyzingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: kAnalyzeVisualDuration,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward(); // visual only
    // Drive the real outcome from the analysis service.
    AppFlow(context, ref).runAnalysis();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _doneCount(double v) {
    var done = 0;
    for (final t in _kStepThresholds) {
      if (v >= t) done++;
    }
    return done;
  }

  @override
  Widget build(BuildContext context) {
    final url = ref.watch(appStateProvider).lastSubmittedUrl ?? _kExampleUrl;
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: QTopBar(onBack: () => AppFlow(context, ref).goHome()),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl + 6,
                      ),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          final v = _controller.value;
                          final progress = 0.08 + 0.88 * v;
                          final done = _doneCount(v);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              QRing(
                                progress: progress,
                                size: 96,
                                strokeWidth: 7,
                                child: const Icon(
                                  QIcons.search,
                                  size: 27,
                                  color: AppColors.accent,
                                ),
                              ),
                              SizedBox(height: AppSpacing.xxl + 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Semantics(
                                      header: true,
                                      child: Text(
                                        l.analyzingTitle,
                                        style: AppTypography.title,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.sm + 1),
                                  const QDots(),
                                ],
                              ),
                              SizedBox(height: AppSpacing.sm + 1),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 250,
                                ),
                                child: Text(
                                  l.analyzingSubtitle,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodySub,
                                ),
                              ),
                              SizedBox(height: AppSpacing.xxl + 6),
                              _StepList(doneCount: done),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xxl - 2,
                0,
                AppSpacing.xxl - 2,
                AppSpacing.lg,
              ),
              child: UrlChip(url: url),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepList extends StatelessWidget {
  const _StepList({required this.doneCount});

  final int doneCount;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final steps = [l.analyzingStep1, l.analyzingStep2, l.analyzingStep3];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 270),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0) SizedBox(height: AppSpacing.md + 1),
            _StepRow(
              label: steps[i],
              done: i < doneCount,
              active: i == doneCount,
            ),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.done,
    required this.active,
  });

  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = done || active ? AppColors.ink : AppColors.faintText;
    return Semantics(
      label:
          '$label — ${done
              ? 'done'
              : active
              ? 'in progress'
              : 'pending'}',
      excludeSemantics: true,
      child: Row(
        children: [
          _StepMarker(done: done, active: active),
          SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              label,
              style: AppTypography.body.copyWith(
                color: color,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepMarker extends StatelessWidget {
  const _StepMarker({required this.done, required this.active});

  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (done) {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(QIcons.check, size: 13, color: Colors.white),
      );
    }
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? AppColors.accent : AppColors.hair,
          width: 2,
        ),
      ),
      child: active
          ? Center(
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
