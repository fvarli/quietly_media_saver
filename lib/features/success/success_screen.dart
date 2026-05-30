// ─────────────────────────────────────────────────────────────
// Quietly — Success screen
//
// HANDOFF screen 8: a calm saved-confirmation with a spring-pop check, the
// saved media, an "added to history" pill, and exits. Built from the Q
// component library + tokens.
//
// Pass-3 scope: "Open in gallery" is a PLACEHOLDER (shows a SnackBar) — no real
// gallery access yet. "View history" navigates to History; "Save another link"
// returns Home. The success state itself is already recorded by
// AppStateNotifier.finishDownload (history prepended) in earlier passes.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/flow/app_flow.dart';
import '../../core/icons/q_icons.dart';
import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_motion.dart';
import '../../core/theme/tokens/app_spacing.dart';
import '../../core/theme/tokens/app_typography.dart';
import '../../core/widgets/q_button.dart';
import '../../core/widgets/q_media_tile.dart';
import '../../core/widgets/q_pill.dart';
import '../../core/widgets/q_top_bar.dart';
import '../../core/widgets/trust_row.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state_provider.dart';
import '../../state/models/app_enums.dart';

class SuccessScreen extends ConsumerWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = AppFlow(context, ref);
    final l = AppLocalizations.of(context);
    final saved = ref.watch(appStateProvider).lastSaved;
    final n = saved.length;

    return Scaffold(
      appBar: QTopBar(
        right: IconButton(
          onPressed: flow.goHome,
          icon: const Icon(QIcons.close, size: 20),
          color: AppColors.sub,
          tooltip: l.closeTooltip,
        ),
      ),
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
                        const _SuccessCheck(),
                        SizedBox(height: AppSpacing.xxl + 2),
                        Semantics(
                          header: true,
                          child: Text(
                            n > 1
                                ? l.successTitleMulti(n)
                                : l.successTitleSingle,
                            textAlign: TextAlign.center,
                            style: AppTypography.title.copyWith(fontSize: 24),
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm + 1),
                        Text(
                          n > 1 ? l.successBodyMulti : l.successBodySingle,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySub,
                        ),
                        SizedBox(height: AppSpacing.xxl),
                        _SavedStrip(kinds: saved),
                        SizedBox(height: AppSpacing.lg),
                        QPill(
                          l.successAddedHistory,
                          tone: QPillTone.success,
                          icon: QIcons.check,
                        ),
                        SizedBox(height: AppSpacing.lg),
                        const TrustRow(),
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
                    label: l.successOpenGallery,
                    icon: QIcons.photo,
                    onPressed: () => _openGalleryPlaceholder(context),
                  ),
                  SizedBox(height: AppSpacing.sm + 1),
                  QButton(
                    label: l.successViewHistory,
                    icon: QIcons.clock,
                    variant: QButtonVariant.soft,
                    onPressed: flow.openHistory,
                  ),
                  SizedBox(height: AppSpacing.sm + 1),
                  QButton(
                    label: l.successSaveAnother,
                    icon: QIcons.paste,
                    variant: QButtonVariant.ghost,
                    onPressed: flow.goHome,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder: real gallery access arrives with the storage/permission pass.
  void _openGalleryPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).successGalleryPlaceholder),
      ),
    );
  }
}

// Spring-pop success check (finite scale animation on the spring curve).
class _SuccessCheck extends StatelessWidget {
  const _SuccessCheck();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.72, end: 1),
        duration: AppMotion.slow,
        curve: AppMotion.spring,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Container(
          width: 92,
          height: 92,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(QIcons.check, size: 46, color: Colors.white),
        ),
      ),
    );
  }
}

class _SavedStrip extends StatelessWidget {
  const _SavedStrip({required this.kinds});

  final List<MediaKind> kinds;

  @override
  Widget build(BuildContext context) {
    final shown = kinds.take(4).toList();
    final tileWidth = shown.length > 1 ? 58.0 : 76.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0) SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: tileWidth,
            child: QMediaTile(
              kind: shown[i],
              tone: shown[i] == MediaKind.video
                  ? QTileTone.cool
                  : QTileTone.neutral,
              radius: 13,
              aspectRatio: 1,
            ),
          ),
        ],
      ],
    );
  }
}
