// ─────────────────────────────────────────────────────────────
// Quietly — QualityOption model
//
// Mirrors QUALITY_OPTIONS in docs/design-handoff/app/app.jsx. Pure value type;
// no download logic. `size` is a human label (e.g. "24 MB") for display only in
// this pass — real byte estimates come later with the downloader.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

@immutable
class QualityOption {
  const QualityOption({
    required this.id,
    required this.label,
    required this.tag,
    required this.size,
    this.recommended = false,
  });

  /// Stable identifier, e.g. `'1080p'`, `'audio'`.
  final String id;

  /// Display label, e.g. `'1080p'`, `'Audio only'`.
  final String label;

  /// Short descriptor, e.g. `'High · landscape'`, `'Data saver'`.
  final String tag;

  /// Human-readable size estimate, e.g. `'24 MB'`.
  final String size;

  /// Whether this is the recommended option (shows the "Recommended" pill).
  final bool recommended;

  @override
  bool operator ==(Object other) => other is QualityOption && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Quality choices offered in the picker sheet (HANDOFF screen 5).
const List<QualityOption> kQualityOptions = <QualityOption>[
  QualityOption(
    id: '1080p',
    label: '1080p',
    tag: 'High · landscape',
    size: '24 MB',
    recommended: true,
  ),
  QualityOption(id: '720p', label: '720p', tag: 'Standard', size: '14 MB'),
  QualityOption(id: '480p', label: '480p', tag: 'Data saver', size: '7 MB'),
  QualityOption(id: 'audio', label: 'Audio only', tag: 'M4A', size: '2 MB'),
];
