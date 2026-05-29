// ─────────────────────────────────────────────────────────────
// Quietly — Root application widget
//
// Wires the theme (light now; themeMode set so dark is additive later) and the
// go_router config into MaterialApp.router. This is the composition root for
// presentation; ProviderScope is installed above it in main.dart.
//
// ACCESSIBILITY: we deliberately do NOT override MediaQuery.textScaler — user
// text-size settings flow through (HANDOFF §9 dynamic type). We only guard
// against pathologically large scales causing overflow via a generous upper
// clamp, while always honoring the user's intent to enlarge.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/a11y/a11y.dart';
import '../core/theme/app_theme.dart';
import 'bootstrap/app_bootstrap.dart';
import 'router/app_router.dart';

class QuietlyApp extends ConsumerStatefulWidget {
  const QuietlyApp({super.key});

  @override
  ConsumerState<QuietlyApp> createState() => _QuietlyAppState();
}

class _QuietlyAppState extends ConsumerState<QuietlyApp> {
  @override
  void initState() {
    super.initState();
    // Startup wiring (load prefs, connectivity, permission refresh). Reading the
    // provider also registers the preference write-through listener. Best-effort.
    ref.read(bootstrapProvider).start();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Quietly',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      // Dark theme is a planned follow-up (HANDOFF §F #3); themeMode is set so
      // adding `darkTheme:` later requires no structural change here.
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        // Honor the user's text-scale setting; only clamp the extreme upper end
        // so the placeholder layouts don't overflow during the shell pass.
        final mq = MediaQuery.of(context);
        final clamped = mq.textScaler.clamp(
          maxScaleFactor: A11y.maxReasonableTextScale,
        );
        return MediaQuery(
          data: mq.copyWith(textScaler: clamped),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
