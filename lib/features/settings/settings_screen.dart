// ─────────────────────────────────────────────────────────────
// Quietly — Settings / legal / permissions
//
// HANDOFF screen 10: calm grouped settings + the rights statement. Built from a
// small reusable group/row pair. Reads/writes AppState (toggles, quality,
// permission status) through the notifier; navigation via AppFlow.
//
// Pass-4 scope: local UI only. Permission rows reflect the in-memory
// PermissionStatus (no permission_handler yet); "Open system settings", legal
// links, theme, and save-location are placeholder SnackBars. "Clear history"
// mutates in-memory history. Rights-aware copy preserved verbatim.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/flow/app_flow.dart';
import '../../core/icons/q_icons.dart';
import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_radius.dart';
import '../../core/theme/tokens/app_spacing.dart';
import '../../core/theme/tokens/app_typography.dart';
import '../../core/widgets/q_section_label.dart';
import '../../core/widgets/rights_note.dart';
import '../../state/app_state_provider.dart';
import '../../state/models/app_enums.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = AppFlow(context, ref);
    final state = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);
    final t = state.toggles;

    String permissionValue() => switch (state.permissionStatus) {
      PermissionStatus.granted => 'Allowed',
      PermissionStatus.denied => 'Not allowed',
      PermissionStatus.permanentlyDenied => 'Blocked',
    };

    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: AppTypography.headline)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          children: [
            _SettingsGroup(
              label: 'Downloads',
              children: [
                _SettingsRow(
                  icon: QIcons.sliders,
                  label: 'Default quality',
                  value: state.qualityOption.label,
                  onTap: flow.openQualitySheet,
                ),
                _SettingsRow(
                  icon: QIcons.help,
                  label: 'Ask quality every time',
                  toggleValue: t.askQualityEveryTime,
                  onToggle: notifier.setAskQuality,
                ),
                _SettingsRow(
                  icon: QIcons.wifi,
                  label: 'Save on Wi-Fi only',
                  toggleValue: t.wifiOnly,
                  onToggle: notifier.setWifiOnly,
                  last: true,
                ),
              ],
            ),
            _SettingsGroup(
              label: 'Permissions',
              children: [
                _SettingsRow(
                  icon: QIcons.photo,
                  label: 'Save to gallery',
                  value: permissionValue(),
                ),
                if (!state.permissionGranted)
                  _SettingsRow(
                    icon: QIcons.settings,
                    label: 'Open system settings',
                    onTap: () => _snack(
                      context,
                      'Opening system settings arrives with permissions support.',
                    ),
                  ),
                _SettingsRow(
                  icon: QIcons.bell,
                  label: 'Download notifications',
                  toggleValue: t.notify,
                  onToggle: notifier.setNotify,
                  last: true,
                ),
              ],
            ),
            _SettingsGroup(
              label: 'Storage',
              children: [
                _SettingsRow(
                  icon: QIcons.folder,
                  label: 'Save location',
                  value: 'Gallery',
                  onTap: () =>
                      _snack(context, 'Save location is fixed for now.'),
                ),
                _SettingsRow(
                  icon: QIcons.trash,
                  label: 'Clear history',
                  danger: true,
                  last: true,
                  onTap: () {
                    notifier.clearHistory();
                    _snack(context, 'History cleared.');
                  },
                ),
              ],
            ),
            _SettingsGroup(
              label: 'Appearance',
              children: [
                _SettingsRow(
                  icon: QIcons.theme,
                  label: 'Theme',
                  value: 'Light',
                  last: true,
                  onTap: () => _snack(context, 'Dark theme is coming.'),
                ),
              ],
            ),
            _SettingsGroup(
              label: 'About & legal',
              children: [
                _SettingsRow(
                  icon: QIcons.info,
                  label: 'How Quietly works',
                  onTap: () => _snack(context, 'Coming soon.'),
                ),
                _SettingsRow(
                  icon: QIcons.shield,
                  label: 'Acceptable use & your rights',
                  onTap: () => _snack(context, 'Coming soon.'),
                ),
                _SettingsRow(
                  icon: QIcons.lock,
                  label: 'Privacy policy',
                  onTap: () => _snack(context, 'Coming soon.'),
                ),
                _SettingsRow(
                  icon: QIcons.external,
                  label: 'Terms of service',
                  last: true,
                  onTap: () => _snack(context, 'Coming soon.'),
                ),
              ],
            ),
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

  void _snack(BuildContext context, String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.sm + 1,
            ),
            child: QSectionLabel(label),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.brMd,
              border: Border.all(color: AppColors.hair),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.value,
    this.toggleValue,
    this.onToggle,
    this.onTap,
    this.danger = false,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;
  final bool danger;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final fg = danger ? AppColors.danger : AppColors.ink;
    final iconBg = danger ? AppColors.dangerSoft : AppColors.bgSunken;
    final iconFg = danger ? AppColors.danger : AppColors.sub;
    final hasToggle = toggleValue != null;

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 17, color: iconFg),
          ),
          SizedBox(width: AppSpacing.md + 1),
          Expanded(
            child: Text(
              label,
              style: AppTypography.body.copyWith(
                color: fg,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (value != null)
            Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: Text(value!, style: AppTypography.caption),
            ),
          if (hasToggle)
            Switch.adaptive(value: toggleValue!, onChanged: onToggle)
          else if (onTap != null)
            const Icon(
              QIcons.chevronRight,
              size: 18,
              color: AppColors.faintText,
            ),
        ],
      ),
    );

    // The whole row is the tap target (≥48dp via vertical padding + icon box).
    final content = onTap != null && !hasToggle
        ? Semantics(
            button: true,
            label: value == null ? label : '$label, $value',
            excludeSemantics: true,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap, child: row),
            ),
          )
        : row;

    if (last) return content;
    return Column(
      children: [
        content,
        const Divider(height: 1, thickness: 1, indent: 15, endIndent: 15),
      ],
    );
  }
}
