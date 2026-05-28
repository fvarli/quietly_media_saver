// ─────────────────────────────────────────────────────────────
// Quietly — RightsNote
//
// The rights-aware trust note (design `RightsNote` primitive). This positioning
// is core to the product and to Play Store safety (HANDOFF §3/§4): a calm,
// always-present reminder that only public media the user has rights to may be
// saved. Reused on Home, Result, Settings, and refusal/error states.
//
// Semantics: the icon is decorative; the message text is read normally by
// screen readers as part of the surrounding content.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../theme/tokens/app_colors.dart';
import '../theme/tokens/app_spacing.dart';
import '../theme/tokens/app_typography.dart';

class RightsNote extends StatelessWidget {
  const RightsNote(this.message, {super.key, this.icon = Icons.shield_outlined});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Icon(icon, size: 15, color: AppColors.faintText),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            message,
            style: AppTypography.micro,
          ),
        ),
      ],
    );
  }
}

/// Canonical rights copy reused across screens (verbatim from the handoff).
abstract final class RightsCopy {
  const RightsCopy._();

  /// Home / general.
  static const String home =
      'Save only content you have the rights to. Private or protected media isn’t supported.';

  /// Result / save confirmation.
  static const String save =
      'By saving, you confirm you have the right to keep this content.';

  /// Settings rights statement.
  static const String statement =
      'Quietly saves only publicly accessible media. You’re responsible for ensuring you have the rights to save and use any content. Private, login-only, and DRM-protected media isn’t supported.';

  /// Refusal/error footnote (protected / unsupported).
  static const String refusal =
      'Quietly respects platform rules and creators’ rights. Some media simply can’t be saved.';
}
