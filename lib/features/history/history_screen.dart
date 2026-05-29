// ─────────────────────────────────────────────────────────────
// Quietly — History screen
//
// HANDOFF screen 9: day-grouped saves + a storage summary, with per-row actions
// (open / share / remove) and an empty state. Built from the Q component
// library; reads AppState.history / historyGroups.
//
// Pass-4 scope: local UI only. Open/Share are placeholder SnackBars; Remove
// mutates in-memory history (pure). No OS gallery integration; the storage
// figure is a fabricated demo value. Search is a placeholder.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/flow/app_flow.dart';
import '../../core/icons/q_icons.dart';
import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_radius.dart';
import '../../core/theme/tokens/app_spacing.dart';
import '../../core/theme/tokens/app_typography.dart';
import '../../core/widgets/q_button.dart';
import '../../core/widgets/q_card.dart';
import '../../core/widgets/q_media_tile.dart';
import '../../core/widgets/q_section_label.dart';
import '../../services/gallery/gallery_service_provider.dart';
import '../../state/app_state_provider.dart';
import '../../state/models/app_enums.dart';
import '../../state/models/history_entry.dart';

const Map<HistoryGroup, String> _kGroupLabels = {
  HistoryGroup.today: 'Today',
  HistoryGroup.yesterday: 'Yesterday',
  HistoryGroup.earlier: 'Earlier',
};

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = AppFlow(context, ref);
    final state = ref.watch(appStateProvider);
    final groups = state.historyGroups;

    return Scaffold(
      appBar: QTopBarFromHistory(
        onBack: () => context.canPop() ? context.pop() : flow.goHome(),
        onSearch: () => _snack(context, 'Search is coming soon.'),
        showSearch: state.history.isNotEmpty,
      ),
      body: SafeArea(
        top: false,
        child: state.history.isEmpty
            ? _EmptyHistory(onPaste: flow.goHome)
            : ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                children: [
                  _StorageSummary(count: state.history.length),
                  SizedBox(height: AppSpacing.lg),
                  for (final group in groups) ...[
                    QSectionLabel(_kGroupLabels[group.key] ?? ''),
                    SizedBox(height: AppSpacing.md - 1),
                    for (final entry in group.value) ...[
                      _HistoryRow(
                        entry: entry,
                        onActions: () => _showRowActions(context, ref, entry),
                      ),
                      SizedBox(height: AppSpacing.sm + 1),
                    ],
                    SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
      ),
    );
  }

  Future<void> _showRowActions(
    BuildContext context,
    WidgetRef ref,
    HistoryEntry entry,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => const _RowActionsSheet(),
    );
    if (action == null) return;
    final gallery = ref.read(galleryServiceProvider);
    switch (action) {
      case 'remove':
        // Remove the gallery file (placeholder) + the persisted history entry.
        gallery.remove(entry);
        ref.read(appStateProvider.notifier).removeHistoryEntry(entry);
      case 'open':
        gallery.open(entry);
      case 'share':
        gallery.share(entry);
    }
  }

  void _snack(BuildContext context, String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

/// History top bar with an optional search action (≥48dp, labelled).
class QTopBarFromHistory extends StatelessWidget
    implements PreferredSizeWidget {
  const QTopBarFromHistory({
    super.key,
    required this.onBack,
    required this.onSearch,
    required this.showSearch,
  });

  final VoidCallback onBack;
  final VoidCallback onSearch;
  final bool showSearch;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: onBack,
        icon: const Icon(QIcons.chevronLeft, size: 24),
        color: AppColors.ink,
        tooltip: 'Back',
      ),
      title: Text('History', style: AppTypography.headline),
      actions: [
        if (showSearch)
          IconButton(
            onPressed: onSearch,
            icon: const Icon(QIcons.search, size: 20),
            color: AppColors.ink,
            tooltip: 'Search',
          ),
      ],
    );
  }
}

class _StorageSummary extends StatelessWidget {
  const _StorageSummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$count saves, 248 megabytes used, stored in your gallery',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: const BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: AppRadius.brMd,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                QIcons.folder,
                size: 18,
                color: AppColors.accent,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count saves · 248 MB used',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accentInk,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Stored in your gallery',
                    style: AppTypography.micro.copyWith(
                      color: AppColors.accentInk,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              QIcons.chevronRight,
              size: 18,
              color: AppColors.accentInk,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.onActions});

  final HistoryEntry entry;
  final VoidCallback onActions;

  @override
  Widget build(BuildContext context) {
    final isVideo = entry.kind == MediaKind.video;
    return QCard(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: QMediaTile(
              kind: entry.kind,
              tone: isVideo ? QTileTone.cool : QTileTone.neutral,
              radius: 10,
              badge: isVideo ? const Icon(QIcons.play) : null,
              semanticLabel: '${entry.title}, ${entry.meta}',
            ),
          ),
          SizedBox(width: AppSpacing.md + 1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(entry.meta, style: AppTypography.mono),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(entry.time, style: AppTypography.micro),
              IconButton(
                onPressed: onActions,
                icon: const Icon(QIcons.moreVertical, size: 18),
                color: AppColors.faintText,
                tooltip: 'More actions for ${entry.title}',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet of per-row actions. Pops with the chosen action id; the caller
/// performs it (keeps navigation/state on the screen's context).
class _RowActionsSheet extends StatelessWidget {
  const _RowActionsSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionTile(icon: QIcons.photo, label: 'Open', id: 'open'),
          _ActionTile(icon: QIcons.share, label: 'Share', id: 'share'),
          _ActionTile(
            icon: QIcons.trash,
            label: 'Remove',
            id: 'remove',
            danger: true,
          ),
          SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.id,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String id;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.ink;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: AppTypography.body.copyWith(color: color)),
      onTap: () => Navigator.of(context).pop(id),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.onPaste});

  final VoidCallback onPaste;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl + 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.bgSunken,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                QIcons.folder,
                size: 30,
                color: AppColors.faintText,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Semantics(
              header: true,
              child: Text(
                'No saves yet',
                style: AppTypography.title.copyWith(fontSize: 21),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Media you save will appear here, grouped by day.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySub,
            ),
            SizedBox(height: AppSpacing.xl),
            QButton(
              label: 'Paste a link',
              icon: QIcons.paste,
              onPressed: onPaste,
            ),
          ],
        ),
      ),
    );
  }
}
