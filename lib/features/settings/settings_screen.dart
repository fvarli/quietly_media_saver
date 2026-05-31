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
import '../../l10n/app_localizations.dart';
import '../../services/permissions/permission_service_provider.dart';
import '../../state/app_state_provider.dart';
import '../../state/models/app_enums.dart';
import '../../state/models/quality_option.dart';
import '../sheets/language_sheet.dart' show languageModeLabel;

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    _refreshPermissionStatus();
  }

  /// Reflect the real OS permission status when Settings opens. Resilient to a
  /// missing platform channel (tests / unsupported platforms): on error the
  /// current status is kept.
  Future<void> _refreshPermissionStatus() async {
    try {
      final status = await ref.read(permissionServiceProvider).galleryStatus();
      if (mounted) {
        ref.read(appStateProvider.notifier).setPermissionStatus(status);
      }
    } catch (_) {
      // Permission channel unavailable — keep the existing status.
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = AppFlow(context, ref);
    final l = AppLocalizations.of(context);
    final state = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);
    final t = state.toggles;

    String permissionValue() => switch (state.permissionStatus) {
      PermissionStatus.granted => l.permAllowed,
      PermissionStatus.denied => l.permNotAllowed,
      PermissionStatus.permanentlyDenied => l.permBlocked,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settingsTitle, style: AppTypography.headline),
      ),
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
              label: l.settingsGroupDownloads,
              children: [
                _SettingsRow(
                  icon: QIcons.sliders,
                  label: l.settingDefaultQuality,
                  value: qualityLabel(l, state.qualityOption),
                  onTap: flow.openQualitySheet,
                ),
                _SettingsRow(
                  icon: QIcons.help,
                  label: l.settingAskQuality,
                  toggleValue: t.askQualityEveryTime,
                  onToggle: notifier.setAskQuality,
                ),
                _SettingsRow(
                  icon: QIcons.wifi,
                  label: l.settingWifiOnly,
                  toggleValue: t.wifiOnly,
                  onToggle: notifier.setWifiOnly,
                  last: true,
                ),
              ],
            ),
            _SettingsGroup(
              label: l.settingsGroupPermissions,
              children: [
                _SettingsRow(
                  icon: QIcons.photo,
                  label: l.settingSaveToGallery,
                  value: permissionValue(),
                ),
                if (!state.permissionGranted)
                  _SettingsRow(
                    icon: QIcons.settings,
                    label: l.settingOpenSystemSettings,
                    onTap: flow.openSystemSettings,
                  ),
                _SettingsRow(
                  icon: QIcons.bell,
                  label: l.settingNotifications,
                  toggleValue: t.notify,
                  onToggle: notifier.setNotify,
                  last: true,
                ),
              ],
            ),
            _SettingsGroup(
              label: l.settingsGroupStorage,
              children: [
                _SettingsRow(
                  icon: QIcons.folder,
                  label: l.settingSaveLocation,
                  value: l.settingSaveLocationValue,
                  onTap: () => _snack(context, l.snackSaveLocationFixed),
                ),
                _SettingsRow(
                  icon: QIcons.trash,
                  label: l.settingClearHistory,
                  danger: true,
                  last: true,
                  onTap: () {
                    notifier.clearHistory();
                    _snack(context, l.snackHistoryCleared);
                  },
                ),
              ],
            ),
            _SettingsGroup(
              label: l.settingsGroupAppearance,
              children: [
                _SettingsRow(
                  icon: QIcons.globe,
                  label: l.settingLanguage,
                  value: languageModeLabel(l, state.languageMode),
                  onTap: flow.openLanguageSheet,
                ),
                _SettingsRow(
                  icon: QIcons.theme,
                  label: l.settingTheme,
                  value: l.settingThemeValue,
                  last: true,
                  onTap: () => _snack(context, l.snackDarkTheme),
                ),
              ],
            ),
            _SettingsGroup(
              label: l.settingsGroupAboutLegal,
              children: [
                _SettingsRow(
                  icon: QIcons.info,
                  label: l.settingHowItWorks,
                  onTap: () => _snack(context, l.snackComingSoon),
                ),
                _SettingsRow(
                  icon: QIcons.shield,
                  label: l.settingAcceptableUse,
                  onTap: () => _snack(context, l.snackComingSoon),
                ),
                _SettingsRow(
                  icon: QIcons.lock,
                  label: l.settingPrivacy,
                  onTap: () => _snack(context, l.snackComingSoon),
                ),
                _SettingsRow(
                  icon: QIcons.external,
                  label: l.settingTerms,
                  last: true,
                  onTap: () => _snack(context, l.snackComingSoon),
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
            Center(child: Text(l.settingsVersion, style: AppTypography.micro)),
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
