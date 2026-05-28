// ─────────────────────────────────────────────────────────────
// Quietly — PlaceholderScaffold
//
// Shared shell for this pass's placeholder screens. It is NOT the final UI — it
// gives every screen the correct structure (app bar / title / safe area /
// scroll), real navigation affordances to exercise the flow, and the
// accessibility baseline (heading semantics, ≥48dp buttons, scalable text)
// without yet building the bespoke design.
//
// Replace the body of each screen with its real layout in the next pass; the
// surrounding structure + flow wiring can stay.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../theme/tokens/app_colors.dart';
import '../theme/tokens/app_spacing.dart';
import '../theme/tokens/app_typography.dart';

/// A labelled navigation action rendered as a full-width button.
class PlaceholderAction {
  const PlaceholderAction(this.label, this.onPressed, {this.primary = true});

  final String label;
  final VoidCallback onPressed;
  final bool primary;
}

class PlaceholderScaffold extends StatelessWidget {
  const PlaceholderScaffold({
    super.key,
    required this.screenName,
    required this.title,
    required this.description,
    this.showBack = true,
    this.actions = const <PlaceholderAction>[],
    this.footer,
    this.appBarTitle,
  });

  /// Machine/route name (e.g. "result") — surfaced for orientation while the
  /// real UI is pending.
  final String screenName;

  /// Human title shown as the screen heading.
  final String title;

  /// One-line description of the screen's purpose.
  final String description;

  /// Whether to show a back affordance in the app bar.
  final bool showBack;

  /// Navigation actions exercising the flow from this screen.
  final List<PlaceholderAction> actions;

  /// Optional footer (e.g. a [RightsNote]).
  final Widget? footer;

  /// Optional app-bar title (defaults to none, matching the wizard's bare bar).
  final String? appBarTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBack,
        title: appBarTitle == null
            ? null
            : Text(appBarTitle!, style: AppTypography.headline),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppSpacing.xl),
                      // Screen-name chip for orientation during the shell pass.
                      Semantics(
                        label: 'Screen: $screenName',
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.accentSoft,
                            borderRadius: BorderRadius.all(
                              Radius.circular(999),
                            ),
                          ),
                          child: Text(
                            screenName.toUpperCase(),
                            style: AppTypography.micro.copyWith(
                              color: AppColors.accentInk,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      // Heading semantics for screen readers.
                      Semantics(
                        header: true,
                        child: Text(title, style: AppTypography.title),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(description, style: AppTypography.bodySub),
                    ],
                  ),
                ),
              ),
              if (actions.isNotEmpty) ...[
                for (final action in actions) ...[
                  SizedBox(height: AppSpacing.md),
                  _ActionButton(action: action),
                ],
              ],
              if (footer != null) ...[SizedBox(height: AppSpacing.lg), footer!],
              SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});

  final PlaceholderAction action;

  @override
  Widget build(BuildContext context) {
    final child = Text(action.label);
    // Buttons inherit ≥48/56dp min sizes from the theme (a11y baseline).
    return action.primary
        ? FilledButton(onPressed: action.onPressed, child: child)
        : OutlinedButton(onPressed: action.onPressed, child: child);
  }
}
