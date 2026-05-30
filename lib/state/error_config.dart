// ─────────────────────────────────────────────────────────────
// Quietly — Error configuration
//
// One flexible ErrorScreen renders any of these configs, selected by
// AppState.error (AppErrorKind). The icon/tone/ctaIcon are non-localized data;
// the title/body/CTAs/tips are resolved from AppLocalizations via
// [errorConfigFor]. Copy is core to the rights-aware, calm-refusal positioning.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

import '../l10n/app_localizations.dart';
import 'models/app_enums.dart';

/// Visual/semantic tone for an error config, mapped to color tokens in the UI.
enum ErrorTone { neutral, warn, success, danger }

@immutable
class ErrorConfig {
  const ErrorConfig({
    required this.icon,
    required this.title,
    required this.body,
    required this.cta,
    required this.tone,
    this.ctaIcon,
    this.tips,
    this.secondary,
  });

  /// Icon name from the design icon set (resolved to a Flutter icon later).
  final String icon;
  final String title;
  final String body;

  /// Primary CTA label.
  final String cta;
  final String? ctaIcon;
  final ErrorTone tone;

  /// Optional "You can try" bullet list (only the protected state uses it).
  final List<String>? tips;

  /// Optional secondary action label.
  final String? secondary;
}

/// Builds the localized [ErrorConfig] for [kind]. Icon/tone/ctaIcon are static;
/// the user-facing text comes from [l].
ErrorConfig errorConfigFor(AppLocalizations l, AppErrorKind kind) =>
    switch (kind) {
      AppErrorKind.protected => ErrorConfig(
        icon: 'lock',
        title: l.errProtectedTitle,
        body: l.errProtectedBody,
        tips: [l.errProtectedTip1, l.errProtectedTip2],
        cta: l.errProtectedCta,
        ctaIcon: 'link',
        tone: ErrorTone.neutral,
      ),
      AppErrorKind.invalid => ErrorConfig(
        icon: 'alert',
        title: l.errInvalidTitle,
        body: l.errInvalidBody,
        cta: l.errInvalidCta,
        ctaIcon: 'paste',
        tone: ErrorTone.warn,
      ),
      AppErrorKind.network => ErrorConfig(
        icon: 'wifiOff',
        title: l.errNetworkTitle,
        body: l.errNetworkBody,
        cta: l.errNetworkCta,
        ctaIcon: 'refresh',
        tone: ErrorTone.neutral,
        secondary: l.errNetworkSecondary,
      ),
      AppErrorKind.unsupported => ErrorConfig(
        icon: 'globe',
        title: l.errUnsupportedTitle,
        body: l.errUnsupportedBody,
        cta: l.errUnsupportedCta,
        ctaIcon: 'link',
        tone: ErrorTone.neutral,
      ),
      AppErrorKind.storage => ErrorConfig(
        icon: 'folder',
        title: l.errStorageTitle,
        body: l.errStorageBody,
        cta: l.errStorageCta,
        ctaIcon: 'sliders',
        tone: ErrorTone.warn,
        secondary: l.errStorageSecondary,
      ),
      AppErrorKind.exists => ErrorConfig(
        icon: 'check',
        title: l.errExistsTitle,
        body: l.errExistsBody,
        cta: l.errExistsCta,
        ctaIcon: 'photo',
        tone: ErrorTone.success,
        secondary: l.errExistsSecondary,
      ),
      AppErrorKind.permissionDeniedPermanently => ErrorConfig(
        icon: 'settings',
        title: l.errPermTitle,
        body: l.errPermBody,
        cta: l.errPermCta,
        ctaIcon: 'settings',
        tone: ErrorTone.warn,
        secondary: l.errPermSecondary,
      ),
      AppErrorKind.queueItemFailed => ErrorConfig(
        icon: 'alert',
        title: l.errQueueTitle,
        body: l.errQueueBody,
        cta: l.errQueueCta,
        ctaIcon: 'refresh',
        tone: ErrorTone.warn,
        secondary: l.errQueueSecondary,
      ),
    };
