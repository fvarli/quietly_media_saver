// ─────────────────────────────────────────────────────────────
// Quietly — QPill
//
// Compact status/label chip (design `Pill`). Tones map to token bg+fg pairs.
// Optional leading icon. Pill radius, micro text. Decorative by default — the
// label text is read by screen readers as content.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../theme/tokens/app_colors.dart';
import '../theme/tokens/app_radius.dart';
import '../theme/tokens/app_spacing.dart';

enum QPillTone { neutral, accent, success, warn, danger }

class QPill extends StatelessWidget {
  const QPill(
    this.label, {
    super.key,
    this.tone = QPillTone.neutral,
    this.icon,
  });

  final String label;
  final QPillTone tone;
  final IconData? icon;

  ({Color bg, Color fg}) get _colors => switch (tone) {
    QPillTone.neutral => (bg: AppColors.bgSunken, fg: AppColors.sub),
    QPillTone.accent => (bg: AppColors.accentSoft, fg: AppColors.accentInk),
    QPillTone.success => (bg: AppColors.successSoft, fg: AppColors.success),
    QPillTone.warn => (bg: AppColors.warnSoft, fg: AppColors.warn),
    QPillTone.danger => (bg: AppColors.dangerSoft, fg: AppColors.danger),
  };

  @override
  Widget build(BuildContext context) {
    final c = _colors;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs + 1,
      ),
      decoration: BoxDecoration(color: c.bg, borderRadius: AppRadius.brPill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            ExcludeSemantics(child: Icon(icon, size: 13, color: c.fg)),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              height: 1,
              color: c.fg,
            ),
          ),
        ],
      ),
    );
  }
}
