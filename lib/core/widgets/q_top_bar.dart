// ─────────────────────────────────────────────────────────────
// Quietly — QTopBar
//
// Wizard top bar (design `TopBar`): optional back affordance, centered title,
// optional right-side action. Implemented as a PreferredSizeWidget so it drops
// into Scaffold.appBar (gaining safe-area handling) while keeping the calm,
// flat, canvas-colored look of the prototype.
//
// The back button is a ≥48dp tap target labelled "Back" for screen readers.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../a11y/a11y.dart';
import '../icons/q_icons.dart';
import '../theme/tokens/app_colors.dart';
import '../theme/tokens/app_typography.dart';

class QTopBar extends StatelessWidget implements PreferredSizeWidget {
  const QTopBar({super.key, this.title, this.onBack, this.right});

  final String? title;

  /// When non-null, shows a back chevron that invokes this.
  final VoidCallback? onBack;

  /// Optional trailing action widget.
  final Widget? right;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              SizedBox(
                width: A11y.minTouchTarget,
                child: onBack == null
                    ? null
                    : IconButton(
                        onPressed: onBack,
                        icon: const Icon(QIcons.chevronLeft, size: 24),
                        color: AppColors.ink,
                        tooltip: 'Back',
                      ),
              ),
              Expanded(
                child: Text(
                  title ?? '',
                  textAlign: TextAlign.center,
                  style: AppTypography.headline,
                ),
              ),
              SizedBox(
                width: A11y.minTouchTarget,
                child: right == null
                    ? null
                    : Align(alignment: Alignment.centerRight, child: right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
