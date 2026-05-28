// ─────────────────────────────────────────────────────────────
// Quietly — Settings screen (placeholder, with wired toggles)
//
// HANDOFF screen 10: grouped settings + the rights statement. Shell pass wires
// the three real toggles to AppState (demonstrating state binding + the a11y
// baseline via SwitchListTile) and shows the rights statement verbatim. Real
// grouped rows, value+chevron rows, and legal links come next.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_radius.dart';
import '../../core/theme/tokens/app_spacing.dart';
import '../../core/theme/tokens/app_typography.dart';
import '../../core/widgets/rights_note.dart';
import '../../state/app_state_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toggles = ref.watch(appStateProvider).toggles;
    final notifier = ref.read(appStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: AppTypography.headline)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          children: [
            SwitchListTile.adaptive(
              value: toggles.askQualityEveryTime,
              onChanged: notifier.setAskQuality,
              title: const Text('Ask quality every time'),
            ),
            SwitchListTile.adaptive(
              value: toggles.wifiOnly,
              onChanged: notifier.setWifiOnly,
              title: const Text('Save on Wi-Fi only'),
            ),
            SwitchListTile.adaptive(
              value: toggles.notify,
              onChanged: notifier.setNotify,
              title: const Text('Download notifications'),
            ),
            SizedBox(height: AppSpacing.xl),
            // Rights statement (HANDOFF §3) — core positioning, verbatim.
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.bgSunken,
                borderRadius: AppRadius.brMd,
              ),
              child: const RightsNote(RightsCopy.statement),
            ),
            SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                'Quietly · version 1.0.0',
                style: AppTypography.micro,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
