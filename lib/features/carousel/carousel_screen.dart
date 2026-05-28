// ─────────────────────────────────────────────────────────────
// Quietly — Carousel screen (placeholder · multi-select)
//
// HANDOFF screen 4: multi-select grid with a live selected count + size sum.
// Shell pass shows the live derived counts from state and wires select-all and
// save. Real selectable media grid comes next.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/flow/app_flow.dart';
import '../../core/widgets/placeholder_scaffold.dart';
import '../../state/app_state_provider.dart';

class CarouselScreen extends ConsumerWidget {
  const CarouselScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = AppFlow(context, ref);
    final notifier = ref.read(appStateProvider.notifier);
    final state = ref.watch(appStateProvider);
    final count = state.selectedCount;
    final total = state.carousel.length;

    return PlaceholderScaffold(
      screenName: 'carousel',
      appBarTitle: '$total items found',
      title: 'Select items to save',
      description: '$count of $total selected · '
          '≈ ${state.selectedSizeMb.toStringAsFixed(1)} MB.',
      actions: [
        PlaceholderAction(
          count == 0
              ? 'Select items to save'
              : 'Save $count item${count == 1 ? '' : 's'}',
          count == 0
              ? () {}
              : () => flow.requestSave(
                    state.selectedCarousel.map((i) => i.kind).toList(),
                  ),
        ),
        PlaceholderAction(
          state.allCarouselSelected ? 'Clear all' : 'Select all',
          notifier.toggleSelectAll,
          primary: false,
        ),
      ],
    );
  }
}
