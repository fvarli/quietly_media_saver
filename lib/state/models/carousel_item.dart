// ─────────────────────────────────────────────────────────────
// Quietly — CarouselItem model
//
// Mirrors SEED_CAROUSEL in docs/design-handoff/app/app.jsx: a multi-select
// grid of media where each item tracks its own selected state and size.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

import 'app_enums.dart';

@immutable
class CarouselItem {
  const CarouselItem({
    required this.kind,
    required this.megabytes,
    this.selected = false,
    this.durationSeconds,
  });

  final MediaKind kind;

  /// Approximate size in megabytes (display estimate only this pass).
  final double megabytes;

  /// Whether the user has selected this item for saving.
  final bool selected;

  /// Video duration in seconds, when [kind] is [MediaKind.video].
  final int? durationSeconds;

  CarouselItem copyWith({bool? selected}) => CarouselItem(
    kind: kind,
    megabytes: megabytes,
    selected: selected ?? this.selected,
    durationSeconds: durationSeconds,
  );
}

/// Seed carousel data (HANDOFF screen 4), matching the prototype.
const List<CarouselItem> kSeedCarousel = <CarouselItem>[
  CarouselItem(kind: MediaKind.image, megabytes: 1.4, selected: true),
  CarouselItem(kind: MediaKind.image, megabytes: 1.3, selected: true),
  CarouselItem(kind: MediaKind.video, megabytes: 9.0, durationSeconds: 18),
  CarouselItem(kind: MediaKind.image, megabytes: 1.5, selected: true),
  CarouselItem(kind: MediaKind.image, megabytes: 1.2),
  CarouselItem(kind: MediaKind.video, megabytes: 7.5, durationSeconds: 12),
];
