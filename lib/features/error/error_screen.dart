// ─────────────────────────────────────────────────────────────
// Quietly — Error screen (placeholder · 6 configs)
//
// HANDOFF screens 12–17: one flexible component, configured by AppState.error
// via kErrorConfig (lib/state/error_config.dart). Shell pass renders the config
// title/body/CTA and wires the primary action. Real iconography, tip card, and
// tone styling come next. Refusal copy is preserved (rights-aware positioning).
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/flow/app_flow.dart';
import '../../core/widgets/placeholder_scaffold.dart';
import '../../core/widgets/rights_note.dart';
import '../../state/app_state_provider.dart';
import '../../state/error_config.dart';
import '../../state/models/app_enums.dart';

class ErrorScreen extends ConsumerWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = AppFlow(context, ref);
    final kind = ref.watch(appStateProvider).error;
    final cfg = kErrorConfig[kind] ?? kErrorConfig[AppErrorKind.protected]!;

    final showRefusalNote =
        kind == AppErrorKind.protected || kind == AppErrorKind.unsupported;

    return PlaceholderScaffold(
      screenName: 'error · ${kind.name}',
      title: cfg.title,
      description: cfg.tips == null
          ? cfg.body
          : '${cfg.body}\n\nYou can try:\n• ${cfg.tips!.join('\n• ')}',
      actions: [
        // "Already saved" routes to history; everything else returns Home.
        PlaceholderAction(
          cfg.cta,
          kind == AppErrorKind.exists ? flow.openHistory : flow.goHome,
        ),
        if (cfg.secondary != null)
          PlaceholderAction(cfg.secondary!, flow.goHome, primary: false),
      ],
      footer: showRefusalNote ? const RightsNote(RightsCopy.refusal) : null,
    );
  }
}
