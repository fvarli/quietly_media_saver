// ─────────────────────────────────────────────────────────────
// Quietly — QMediaTile
//
// Neutral, low-chroma media placeholder (design/primitives `MediaTile`). It is
// DELIBERATELY ABSTRACT — a soft gradient + media-type glyph + faint diagonal
// hatch — and never renders real platform content. This is core to the
// Play-Store-safe positioning (HANDOFF §4/§10): the app reads as a calm utility,
// not a content scraper.
//
// Supports tone (gradient family), kind glyph, optional badge/label, and
// dim/locked/selected states. Exposes a Semantics label describing the media.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../icons/q_icons.dart';
import '../../state/models/app_enums.dart';

enum QTileTone { cool, warm, neutral, green }

class QMediaTile extends StatelessWidget {
  const QMediaTile({
    super.key,
    this.kind = MediaKind.video,
    this.tone = QTileTone.cool,
    this.radius = 14,
    this.height,
    this.aspectRatio,
    this.label,
    this.badge,
    this.dim = false,
    this.locked = false,
    this.selected,
    this.semanticLabel,
  });

  final MediaKind kind;
  final QTileTone tone;
  final double radius;

  /// Fixed height (used when [aspectRatio] is null).
  final double? height;

  /// Aspect ratio (e.g. 4/3 or 1). Takes precedence over [height].
  final double? aspectRatio;

  /// Optional uppercase label under the glyph.
  final String? label;

  /// Optional badge content (top-left), e.g. a play glyph + duration.
  final Widget? badge;

  final bool dim;
  final bool locked;

  /// When non-null, shows a selection check (top-right) in the given state.
  final bool? selected;

  final String? semanticLabel;

  static const Map<QTileTone, (Color, Color)> _gradients = {
    QTileTone.cool: (Color(0xFFAEBBCF), Color(0xFF8B9BB5)),
    QTileTone.warm: (Color(0xFFE2D6C1), Color(0xFFCDBB9D)),
    QTileTone.neutral: (Color(0xFFD9D7D1), Color(0xFFC2BFB7)),
    QTileTone.green: (Color(0xFFBCD2C4), Color(0xFF9BBAA6)),
  };

  IconData get _glyph => switch (kind) {
    MediaKind.video => QIcons.play,
    MediaKind.image => QIcons.image,
    MediaKind.carousel => QIcons.layers,
  };

  String get _defaultSemanticLabel => switch (kind) {
    MediaKind.video => 'Video thumbnail',
    MediaKind.image => 'Image thumbnail',
    MediaKind.carousel => 'Carousel thumbnail',
  };

  @override
  Widget build(BuildContext context) {
    final (c1, c2) = _gradients[tone]!;
    const glyphColor = Color(0x80282D3C); // rgba(40,45,60,0.5)

    Widget tile = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c1, c2],
              ),
            ),
          ),
          // Faint diagonal hatch so it reads as a placeholder, not real media.
          const Opacity(
            opacity: 0.6,
            child: CustomPaint(painter: _HatchPainter()),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _glyph,
                  size: kind == MediaKind.video ? 30 : 26,
                  color: glyphColor,
                ),
                if (label != null) ...[
                  const SizedBox(height: 7),
                  Text(
                    label!.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: glyphColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (dim) const ColoredBox(color: Color(0x730A0C12)),
          if (locked)
            const ColoredBox(
              color: Color(0x8C0C0E14),
              child: Center(
                child: Icon(QIcons.lock, size: 22, color: Colors.white70),
              ),
            ),
          if (badge != null)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0x9E0C0E14),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: DefaultTextStyle.merge(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                  child: IconTheme.merge(
                    data: const IconThemeData(color: Colors.white, size: 11),
                    child: badge!,
                  ),
                ),
              ),
            ),
          if (selected != null)
            Positioned(top: 8, right: 8, child: _SelectionDot(on: selected!)),
        ],
      ),
    );

    if (aspectRatio != null) {
      tile = AspectRatio(aspectRatio: aspectRatio!, child: tile);
    } else if (height != null) {
      tile = SizedBox(height: height, width: double.infinity, child: tile);
    }

    return Semantics(
      label: semanticLabel ?? _defaultSemanticLabel,
      image: true,
      child: ExcludeSemantics(child: tile),
    );
  }
}

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: on ? const Color(0xFF4B53C4) : const Color(0x47FFFFFF),
        border: on
            ? null
            : Border.all(color: const Color(0xD9FFFFFF), width: 2),
      ),
      child: on
          ? const Icon(QIcons.check, size: 15, color: Colors.white)
          : null,
    );
  }
}

/// Paints a faint diagonal hatch overlay (135°) to signal "placeholder".
class _HatchPainter extends CustomPainter {
  const _HatchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x14000000)
      ..strokeWidth = 1;
    const gap = 12.0;
    // Diagonal lines running top-right to bottom-left across the tile.
    for (double x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HatchPainter oldDelegate) => false;
}
