// ─────────────────────────────────────────────────────────────
// Quietly — Analyzing screen (placeholder)
//
// HANDOFF screen 2: explainable analysis steps + "Public" chip; auto-advances
// to Result. Shell pass uses an explicit "Continue" action in place of the
// auto-advance timer (deferred — no timers in the skeleton). Real progress ring
// + stepped checklist come next.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/flow/app_flow.dart';
import '../../core/widgets/placeholder_scaffold.dart';

class AnalyzingScreen extends ConsumerWidget {
  const AnalyzingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = AppFlow(context, ref);
    return PlaceholderScaffold(
      screenName: 'analyzing',
      title: 'Reading this link…',
      description:
          'Finding media that’s publicly available for you to save. (Auto-advance is wired to a timer in the real build.)',
      actions: [
        PlaceholderAction('Continue to result', flow.showResult),
        PlaceholderAction('Cancel', flow.goHome, primary: false),
      ],
    );
  }
}
