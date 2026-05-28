// ─────────────────────────────────────────────────────────────
// Quietly — History screen (placeholder)
//
// HANDOFF screen 9: day-grouped saves + storage summary. Shell pass reports the
// grouped counts from state. Real grouped list, thumbnails, and storage card
// come next. NOTE: the persistence model (app DB vs OS gallery) is an open
// product decision (HANDOFF §F #5) — this is in-memory only for now.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/placeholder_scaffold.dart';
import '../../state/app_state_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final groups = state.historyGroups
        .map((e) => '${e.key.name} (${e.value.length})')
        .join(' · ');
    return PlaceholderScaffold(
      screenName: 'history',
      appBarTitle: 'History',
      title: '${state.history.length} saves',
      description: groups.isEmpty
          ? 'No saves yet.'
          : 'Grouped: $groups. Stored in your gallery.',
    );
  }
}
