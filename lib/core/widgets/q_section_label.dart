// ─────────────────────────────────────────────────────────────
// Quietly — QSectionLabel
//
// Small uppercase section heading (design `SectionLabel`): 12/700, +0.5
// letter-spacing, faint tertiary color. Used above grouped lists / strips.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../theme/tokens/app_colors.dart';

class QSectionLabel extends StatelessWidget {
  const QSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AppColors.faintText,
      ),
    );
  }
}
