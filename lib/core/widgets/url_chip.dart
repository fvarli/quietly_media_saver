// ─────────────────────────────────────────────────────────────
// Quietly — UrlChip
//
// Shows the link under analysis (design `UrlChip`): globe icon, monospace URL
// (ellipsised), and a trailing status pill (e.g. a green "Public" chip). Used on
// the Analyzing screen.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../icons/q_icons.dart';
import '../theme/tokens/app_colors.dart';
import '../theme/tokens/app_radius.dart';
import '../theme/tokens/app_typography.dart';
import 'q_pill.dart';

class UrlChip extends StatelessWidget {
  const UrlChip({super.key, required this.url, this.trailing});

  final String url;

  /// Optional trailing pill (defaults to a green "Public" chip).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: AppColors.hair),
      ),
      child: Row(
        children: [
          const ExcludeSemantics(
            child: Icon(QIcons.globe, size: 15, color: AppColors.faintText),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.mono,
            ),
          ),
          const SizedBox(width: 9),
          trailing ??
              const QPill(
                'Public',
                tone: QPillTone.success,
                icon: QIcons.shield,
              ),
        ],
      ),
    );
  }
}
