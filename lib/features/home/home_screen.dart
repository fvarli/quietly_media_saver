// ─────────────────────────────────────────────────────────────
// Quietly — Home screen (placeholder)
//
// HANDOFF screen 1: paste a link to get started; lightweight recent-saves peek.
// Shell pass: structure + flow wiring + rights note only. Real hero input,
// clipboard-detected card, and recent strip come next.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/flow/app_flow.dart';
import '../../core/widgets/placeholder_scaffold.dart';
import '../../core/widgets/rights_note.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = AppFlow(context, ref);
    return PlaceholderScaffold(
      screenName: 'home',
      appBarTitle: 'Quietly',
      showBack: false,
      title: 'Paste a link to get started.',
      description:
          'We’ll check what media is publicly available for you to save.',
      actions: [
        PlaceholderAction('Paste link', flow.paste),
        PlaceholderAction('History', flow.openHistory, primary: false),
        PlaceholderAction('Settings', flow.openSettings, primary: false),
      ],
      footer: const RightsNote(RightsCopy.home),
    );
  }
}
