// ─────────────────────────────────────────────────────────────
// Quietly — Error configuration
//
// Dart port of ERROR_CONFIG in docs/design-handoff/app/screens-aux.jsx.
// One flexible ErrorScreen renders any of these six configs, selected by
// AppState.error (AppErrorKind). Copy is preserved verbatim from the handoff —
// it is core to the rights-aware, calm-refusal positioning. Do not soften.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

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

/// All six error configs, keyed by [AppErrorKind] (ERROR_CONFIG parity).
const Map<AppErrorKind, ErrorConfig> kErrorConfig = <AppErrorKind, ErrorConfig>{
  AppErrorKind.protected: ErrorConfig(
    icon: 'lock',
    title: 'This content is protected',
    body:
        'It looks private, login-only, or rights-protected. Quietly can only save media that’s publicly available and permitted.',
    tips: [
      'A public version of the same post',
      'A direct link you have rights to',
    ],
    cta: 'Try another link',
    ctaIcon: 'link',
    tone: ErrorTone.neutral,
  ),
  AppErrorKind.invalid: ErrorConfig(
    icon: 'alert',
    title: 'That doesn’t look like a link',
    body:
        'Make sure you’ve copied a full web address — it should start with https:// and point to a public post or page.',
    cta: 'Paste again',
    ctaIcon: 'paste',
    tone: ErrorTone.warn,
  ),
  AppErrorKind.network: ErrorConfig(
    icon: 'wifiOff',
    title: 'Couldn’t reach this link',
    body:
        'We weren’t able to connect. Check your connection and try again — your link is still here.',
    cta: 'Retry',
    ctaIcon: 'refresh',
    tone: ErrorTone.neutral,
    secondary: 'Edit link',
  ),
  AppErrorKind.unsupported: ErrorConfig(
    icon: 'globe',
    title: 'We can’t read this source yet',
    body:
        'This site isn’t supported for media analysis. We only work with public sources that allow saving.',
    cta: 'Try another link',
    ctaIcon: 'link',
    tone: ErrorTone.neutral,
  ),
  AppErrorKind.storage: ErrorConfig(
    icon: 'folder',
    title: 'Not enough space',
    body:
        'Your device is low on storage. Free up some space, or choose a smaller quality, then try again.',
    cta: 'Choose smaller quality',
    ctaIcon: 'sliders',
    tone: ErrorTone.warn,
    secondary: 'Manage storage',
  ),
  AppErrorKind.exists: ErrorConfig(
    icon: 'check',
    title: 'Already in your gallery',
    body:
        'You’ve already saved this exact media. You can open it, or save it again as a copy.',
    cta: 'Open in gallery',
    ctaIcon: 'photo',
    tone: ErrorTone.success,
    secondary: 'Save a copy',
  ),
};
