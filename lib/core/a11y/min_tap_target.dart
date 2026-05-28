// ─────────────────────────────────────────────────────────────
// Quietly — MinTapTarget
//
// Guarantees a child interactive area is at least [A11y.minTouchTarget] in both
// dimensions, and optionally attaches a Semantics button label. Use it to wrap
// compact icon affordances (the prototype's 40px buttons) so they clear the
// 48dp Android target without changing their visual size.
//
// This is a foundation primitive for the shell pass — screens are placeholders,
// but actionable affordances should already meet the target + be label-ready.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/widgets.dart';

import 'a11y.dart';

/// Ensures [child] occupies ≥ [A11y.minTouchTarget] in both axes and, when
/// [semanticLabel] is given, exposes it as a tappable button to screen readers.
class MinTapTarget extends StatelessWidget {
  const MinTapTarget({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.size = A11y.minTouchTarget,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// Screen-reader label. Omit for purely decorative content.
  final String? semanticLabel;

  /// Minimum side length (defaults to the 48dp target).
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget content = ConstrainedBox(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      child: Center(widthFactor: 1, heightFactor: 1, child: child),
    );

    if (onTap != null) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      );
    }

    if (semanticLabel != null) {
      content = Semantics(
        label: semanticLabel,
        button: onTap != null,
        excludeSemantics: true,
        child: content,
      );
    }

    return content;
  }
}
