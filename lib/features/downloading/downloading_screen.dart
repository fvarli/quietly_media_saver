// ─────────────────────────────────────────────────────────────
// Quietly — Downloading screen (placeholder · single + multi queue)
//
// HANDOFF screens 6/7: single-file ring progress, or a multi-file queue with
// per-item bars. Shell pass renders the queue shape from state and offers a
// "Complete" action standing in for the real progress stream. NO download
// execution this pass (HANDOFF §E — queue service is a later pass).
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/flow/app_flow.dart';
import '../../core/widgets/placeholder_scaffold.dart';
import '../../state/app_state_provider.dart';

class DownloadingScreen extends ConsumerWidget {
  const DownloadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = AppFlow(context, ref);
    final state = ref.watch(appStateProvider);
    final description = state.isMultiDownload
        ? 'Saving ${state.queue.length} items (queue). Per-item progress streams '
            'are wired in the downloader pass.'
        : 'Saving 1 item. Ring progress is wired in the downloader pass.';

    return PlaceholderScaffold(
      screenName: 'downloading',
      appBarTitle: state.isMultiDownload ? 'Saving items' : null,
      showBack: false,
      title: state.isMultiDownload ? 'Saving items…' : 'Saving…',
      description: description,
      actions: [
        PlaceholderAction('Complete download', flow.finishDownload),
        PlaceholderAction('Cancel', flow.goHome, primary: false),
      ],
    );
  }
}
