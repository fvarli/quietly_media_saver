// ─────────────────────────────────────────────────────────────
// Quietly — Onboarding (value-first, short, skippable)
//
// Shown once on first run (via the router redirect, gated on
// firstRunResolved && !firstRunAcknowledged). Three calm steps that lead with
// VALUE, then the 4-step model, then a soft trust/rights note — NOT a legal
// warning. Skip or "Get started" both mark onboarding complete (persisted) and
// go Home; it never reappears.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_routes.dart';
import '../../core/icons/q_icons.dart';
import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_radius.dart';
import '../../core/theme/tokens/app_spacing.dart';
import '../../core/theme/tokens/app_typography.dart';
import '../../core/widgets/q_button.dart';
import '../../core/widgets/steps_row.dart';
import '../../core/widgets/trust_row.dart';
import '../../state/app_state_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  static const _lastPage = 2;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _complete() {
    ref.read(appStateProvider.notifier).setFirstRunAcknowledged(true);
    if (mounted) context.goNamed(AppRoutes.home);
  }

  void _next() {
    if (_page >= _lastPage) {
      _complete();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _lastPage;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [_ValuePage(), _HowPage(), _TrustPage()],
              ),
            ),
            _Dots(count: _lastPage + 1, index: _page),
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
                    label: isLast ? 'Get started' : 'Continue',
                    onPressed: _next,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 44,
                    child: isLast
                        ? null
                        : QButton(
                            label: 'Skip',
                            variant: QButtonVariant.ghost,
                            onPressed: _complete,
                          ),
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

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == index ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == index ? AppColors.accent : AppColors.accentSoft2,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xl,
        ),
        child: child,
      ),
    );
  }
}

class _ValuePage extends StatelessWidget {
  const _ValuePage();

  @override
  Widget build(BuildContext context) {
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSpacing.xxl),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Icon(
              QIcons.download,
              size: 34,
              color: AppColors.accent,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Semantics(
            header: true,
            child: Text(
              'Save public photos & videos to your gallery',
              style: AppTypography.display,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Paste a link — Quietly checks it’s public, then saves it. '
            'Calm and private.',
            style: AppTypography.bodySub,
          ),
        ],
      ),
    );
  }
}

class _HowPage extends StatelessWidget {
  const _HowPage();

  @override
  Widget build(BuildContext context) {
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSpacing.lg),
          Semantics(
            header: true,
            child: Text('How it works', style: AppTypography.title),
          ),
          SizedBox(height: AppSpacing.xl),
          const StepsList(),
        ],
      ),
    );
  }
}

class _TrustPage extends StatelessWidget {
  const _TrustPage();

  @override
  Widget build(BuildContext context) {
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSpacing.lg),
          Semantics(
            header: true,
            child: Text('Private by design', style: AppTypography.title),
          ),
          SizedBox(height: AppSpacing.lg),
          const Align(alignment: Alignment.centerLeft, child: TrustRow()),
          SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(QIcons.shield, size: 18, color: AppColors.faintText),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Quietly saves public, permitted media only. Your saves and '
                  'settings stay on your device.',
                  style: AppTypography.bodySub,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
