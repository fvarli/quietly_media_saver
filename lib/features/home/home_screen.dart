// ─────────────────────────────────────────────────────────────
// Quietly — Home screen
//
// HANDOFF screen 1: paste-a-link hero, clipboard-detected card, a lightweight
// recent-saves strip, and the always-present rights note. Built from the shared
// design-system components (QButton/QCard/QMediaTile/RightsNote/…).
//
// Pass-2 scope notes:
//   • The clipboard card is a STATIC example (prototype URL); tapping it runs
//     flow.paste(). Real Clipboard detection is a later input/analysis pass.
//   • No real URL analysis — paste() simulates it on the Analyzing screen.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/flow/app_flow.dart';
import '../../core/a11y/a11y.dart';
import '../../core/icons/q_icons.dart';
import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_elevation.dart';
import '../../core/theme/tokens/app_radius.dart';
import '../../core/theme/tokens/app_spacing.dart';
import '../../core/theme/tokens/app_typography.dart';
import '../../core/widgets/q_button.dart';
import '../../core/widgets/q_card.dart';
import '../../core/widgets/q_media_tile.dart';
import '../../core/widgets/q_section_label.dart';
import '../../core/widgets/rights_note.dart';
import '../../state/app_state_provider.dart';
import '../../state/models/app_enums.dart';
import '../../state/models/history_entry.dart';

/// Example URL shown in the clipboard card (static this pass).
const String _kExampleUrl = 'share.example.com/p/8fa2c91b';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = AppFlow(context, ref);
    final state = ref.watch(appStateProvider);
    final history = state.history;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HomeHeader(flow: flow),
            if (state.offline) const _OfflineBanner(),
            // Hero + clipboard card occupy the flexible middle. Scroll-centered
            // so it stays centered on tall phones but never overflows on short
            // screens / large text scales.
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl - 2,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeroIcon(),
                          SizedBox(height: AppSpacing.xl),
                          Semantics(
                            header: true,
                            child: Text(
                              'Paste a link to get started.',
                              style: AppTypography.display,
                            ),
                          ),
                          SizedBox(height: AppSpacing.md - 1),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 280),
                            child: Text(
                              'We’ll check what media is publicly available for you to save.',
                              style: AppTypography.bodySub,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xxl),
                          _ClipboardCard(onTap: flow.paste),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (history.isNotEmpty) _RecentStrip(history: history, flow: flow),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xxl - 2,
                AppSpacing.lg,
                AppSpacing.xxl - 2,
                AppSpacing.md,
              ),
              child: Column(
                children: [
                  QButton(
                    label: 'Paste link',
                    icon: QIcons.paste,
                    onPressed: flow.paste,
                  ),
                  SizedBox(height: AppSpacing.md),
                  const RightsNote(RightsCopy.home),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header: brand + history/settings icon buttons ───────────────
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.flow});

  final AppFlow flow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg + 2,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            'Quietly',
            style: AppTypography.title.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          _CircleIconButton(
            icon: QIcons.clock,
            label: 'History',
            onTap: flow.openHistory,
          ),
          SizedBox(width: AppSpacing.sm - 2),
          _CircleIconButton(
            icon: QIcons.settings,
            label: 'Settings',
            onTap: flow.openSettings,
          ),
        ],
      ),
    );
  }
}

// Slim offline banner shown above the hero when AppState.offline is true.
// State-driven; real connectivity detection arrives in Pass 5.
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.warnSoft,
          borderRadius: AppRadius.brMd,
        ),
        child: Row(
          children: [
            const Icon(QIcons.wifiOff, size: 16, color: AppColors.warn),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'You’re offline — saved media still works.',
                style: AppTypography.caption.copyWith(color: AppColors.warn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: A11y.minTouchTarget,
            height: A11y.minTouchTarget,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: AppShadows.sm,
            ),
            child: Icon(icon, size: 20, color: AppColors.sub),
          ),
        ),
      ),
    );
  }
}

class _HeroIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg - 1),
      ),
      child: const Icon(QIcons.link, size: 25, color: AppColors.accent),
    );
  }
}

// ── Clipboard-detected card (static example) ────────────────────
class _ClipboardCard extends StatelessWidget {
  const _ClipboardCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return QCard(
      onTap: onTap,
      semanticLabel: 'Use link from your clipboard: $_kExampleUrl',
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(QIcons.paste, size: 17, color: AppColors.accent),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FROM YOUR CLIPBOARD',
                  style: AppTypography.micro.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _kExampleUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.mono.copyWith(color: AppColors.ink),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          const Icon(QIcons.arrowRight, size: 18, color: AppColors.faintText),
        ],
      ),
    );
  }
}

// ── Recent saves strip ──────────────────────────────────────────
class _RecentStrip extends StatelessWidget {
  const _RecentStrip({required this.history, required this.flow});

  final List<HistoryEntry> history;
  final AppFlow flow;

  @override
  Widget build(BuildContext context) {
    final recent = history.take(4).toList();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl - 2,
        0,
        AppSpacing.xxl - 2,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const QSectionLabel('Recent saves'),
              const Spacer(),
              QButton(
                label: 'See all',
                variant: QButtonVariant.ghost,
                size: QButtonSize.sm,
                fullWidth: false,
                onPressed: flow.openHistory,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md - 1),
          Row(
            children: [
              for (var i = 0; i < recent.length; i++) ...[
                if (i > 0) SizedBox(width: AppSpacing.sm + 1),
                Expanded(
                  child: QMediaTile(
                    kind: recent[i].kind,
                    tone: recent[i].kind == MediaKind.video
                        ? QTileTone.cool
                        : QTileTone.neutral,
                    radius: 13,
                    aspectRatio: 1,
                    badge: recent[i].kind == MediaKind.video
                        ? const Icon(QIcons.play)
                        : null,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
