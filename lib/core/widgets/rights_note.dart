// ─────────────────────────────────────────────────────────────
// Quietly — RightsNote
//
// The rights-aware trust note (design `RightsNote` primitive). This positioning
// is core to the product and to Play Store safety (HANDOFF §3/§4): a calm,
// always-present reminder that only public media the user has rights to may be
// saved. Reused on Home, Result, Settings, and refusal/error states.
//
// The variant is a [RightsCopy] enum; the localized text is resolved from
// AppLocalizations at render. The icon is decorative.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/tokens/app_colors.dart';
import '../theme/tokens/app_spacing.dart';
import '../theme/tokens/app_typography.dart';

/// Which rights message to show (resolved to localized copy by [RightsNote]).
enum RightsCopy { home, save, statement, refusal }

class RightsNote extends StatelessWidget {
  const RightsNote(this.copy, {super.key, this.icon = Icons.shield_outlined});

  final RightsCopy copy;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final message = switch (copy) {
      RightsCopy.home => l.rightsHome,
      RightsCopy.save => l.rightsSave,
      RightsCopy.statement => l.rightsStatement,
      RightsCopy.refusal => l.rightsRefusal,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Icon(icon, size: 15, color: AppColors.faintText),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(message, style: AppTypography.micro)),
      ],
    );
  }
}
