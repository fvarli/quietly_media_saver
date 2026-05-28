// ─────────────────────────────────────────────────────────────
// Quietly — Result screen (placeholder · single video)
//
// HANDOFF screen 3: a single public video, quality row → quality sheet, save to
// gallery. Shell pass wires the quality sheet, the save→permission→download
// flow, the carousel branch, and an error demo. Real media tile + quality card
// come next.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/flow/app_flow.dart';
import '../../core/widgets/placeholder_scaffold.dart';
import '../../core/widgets/rights_note.dart';
import '../../state/app_state_provider.dart';
import '../../state/models/app_enums.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = AppFlow(context, ref);
    final quality = ref.watch(appStateProvider).qualityOption;
    return PlaceholderScaffold(
      screenName: 'result',
      appBarTitle: 'Available media',
      title: 'Public post · 1 video',
      description:
          'Selected quality: ${quality.label} · ${quality.tag} (≈ ${quality.size}).',
      actions: [
        PlaceholderAction('Save to gallery',
            () => flow.requestSave(const [MediaKind.video])),
        PlaceholderAction('Choose quality', flow.openQualitySheet,
            primary: false),
        PlaceholderAction('View as carousel', flow.openCarousel,
            primary: false),
        PlaceholderAction('Demo: protected error',
            () => flow.showError(AppErrorKind.protected), primary: false),
      ],
      footer: const RightsNote(RightsCopy.save),
    );
  }
}
