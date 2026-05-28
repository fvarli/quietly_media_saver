// ─────────────────────────────────────────────────────────────
// Quietly — QCard
//
// List-item / surface shell (design `Card`). Surface bg, hairline border that
// turns accent when [active], md radius, soft shadow (accent shadow when
// active). When [onTap] is set it becomes a button: InkWell ripple + a ≥48dp
// minimum height + a Semantics button label.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../a11y/a11y.dart';
import '../theme/tokens/app_colors.dart';
import '../theme/tokens/app_radius.dart';
import '../theme/tokens/app_elevation.dart';

class QCard extends StatelessWidget {
  const QCard({
    super.key,
    required this.child,
    this.onTap,
    this.active = false,
    this.padding = const EdgeInsets.all(12),
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool active;
  final EdgeInsetsGeometry padding;

  /// Screen-reader label when the card is tappable.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadius.brMd,
      border: Border.all(
        color: active ? AppColors.accent : AppColors.hair,
        width: 1,
      ),
      boxShadow: active ? AppShadows.accentSm : AppShadows.sm,
    );

    if (onTap == null) {
      return DecoratedBox(
        decoration: decoration,
        child: Padding(padding: padding, child: child),
      );
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      container: true,
      child: DecoratedBox(
        decoration: decoration,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.brMd,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: A11y.minTouchTarget),
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
