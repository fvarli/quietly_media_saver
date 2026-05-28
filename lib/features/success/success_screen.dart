// ─────────────────────────────────────────────────────────────
// Quietly — Success screen (placeholder)
//
// HANDOFF screen 8: spring check, saved confirmation, → history. Shell pass
// reports the saved count from state and wires the two exits. Real spring
// animation + saved-thumbnails strip come next.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/flow/app_flow.dart';
import '../../core/widgets/placeholder_scaffold.dart';
import '../../state/app_state_provider.dart';

class SuccessScreen extends ConsumerWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = AppFlow(context, ref);
    final n = ref.watch(appStateProvider).lastSaved.length;
    return PlaceholderScaffold(
      screenName: 'success',
      showBack: false,
      title: n > 1 ? '$n items saved' : 'Saved to gallery',
      description: n > 1
          ? 'They’re in your gallery, ready offline.'
          : 'Your media is in your gallery, ready offline.',
      actions: [
        PlaceholderAction('Open in gallery', flow.openHistory),
        PlaceholderAction('Save another link', flow.goHome, primary: false),
      ],
    );
  }
}
