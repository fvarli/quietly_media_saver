// ─────────────────────────────────────────────────────────────
// Quietly — QButton
//
// Primary action component (design `Button`). Five variants and three sizes
// from the handoff; optional leading icon; full-width by default. Disabled and
// pressed states match the design system (subtle 0.965 press-scale on the decel
// curve). Every button is ≥48dp tall and exposes a Semantics button label.
//
//   primary → solid accent + accent shadow      soft   → accentSoft / accentInk
//   ghost   → transparent / accent text         outline→ surface + hair border
//   danger  → dangerSoft / danger
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../theme/tokens/app_colors.dart';
import '../theme/tokens/app_elevation.dart';
import '../theme/tokens/app_motion.dart';
import '../theme/tokens/app_radius.dart';
import '../theme/tokens/app_typography.dart';

enum QButtonVariant { primary, soft, ghost, outline, danger }

enum QButtonSize { lg, md, sm }

class QButton extends StatefulWidget {
  const QButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = QButtonVariant.primary,
    this.size = QButtonSize.lg,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final QButtonVariant variant;
  final QButtonSize size;
  final bool fullWidth;

  bool get _enabled => onPressed != null;

  @override
  State<QButton> createState() => _QButtonState();
}

class _QButtonState extends State<QButton> {
  bool _pressed = false;

  double get _height => switch (widget.size) {
    QButtonSize.lg => 56,
    QButtonSize.md => 48,
    // 40 visually, but the tap target is padded to ≥48 by the Material theme
    // / surrounding layout; keep ≥48 here to be safe on its own.
    QButtonSize.sm => 48,
  };

  ({Color bg, Color fg, List<BoxShadow>? shadow, Border? border}) get _style {
    final enabled = widget._enabled;
    switch (widget.variant) {
      case QButtonVariant.primary:
        return (
          bg: enabled ? AppColors.accent : AppColors.accentSoft2,
          fg: enabled ? AppColors.onAccent : AppColors.faintText,
          shadow: enabled ? AppShadows.accentSm : null,
          border: null,
        );
      case QButtonVariant.soft:
        return (
          bg: AppColors.accentSoft,
          fg: AppColors.accentInk,
          shadow: null,
          border: null,
        );
      case QButtonVariant.ghost:
        return (
          bg: Colors.transparent,
          fg: AppColors.accent,
          shadow: null,
          border: null,
        );
      case QButtonVariant.outline:
        return (
          bg: AppColors.surface,
          fg: AppColors.sub,
          shadow: null,
          border: Border.all(color: AppColors.hair, width: 1.5),
        );
      case QButtonVariant.danger:
        return (
          bg: AppColors.dangerSoft,
          fg: AppColors.danger,
          shadow: null,
          border: null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    final fontSize = widget.size == QButtonSize.lg ? 16.5 : 15.0;

    final content = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          ExcludeSemantics(
            child: Icon(
              widget.icon,
              size: widget.size == QButtonSize.lg ? 20 : 18,
              color: s.fg,
            ),
          ),
          const SizedBox(width: 9),
        ],
        Flexible(
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headline.copyWith(
              fontSize: fontSize,
              color: s.fg,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: widget._enabled,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: widget._enabled
            ? (_) => setState(() => _pressed = true)
            : null,
        onTapUp: widget._enabled
            ? (_) => setState(() => _pressed = false)
            : null,
        onTapCancel: widget._enabled
            ? () => setState(() => _pressed = false)
            : null,
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.965 : 1,
          duration: AppMotion.fast,
          curve: AppMotion.ease,
          child: Container(
            height: _height,
            width: widget.fullWidth ? double.infinity : null,
            padding: widget.fullWidth
                ? null
                : const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: s.bg,
              borderRadius: widget.size == QButtonSize.lg
                  ? AppRadius.brLg
                  : AppRadius.brMd,
              boxShadow: s.shadow,
              border: s.border,
            ),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}
