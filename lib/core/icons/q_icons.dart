// ─────────────────────────────────────────────────────────────
// Quietly — Icon mapping layer (QIcons)
//
// The prototype ships a ~55-glyph custom line-icon set (primitives.jsx). For
// this pass we map each product-level icon name to the closest built-in
// Material icon, so app code references intent ("QIcons.sliders") rather than
// raw Material names scattered everywhere. Swapping in a custom SVG set later is
// then a single-file change.
//
// Names mirror the handoff's ICONS keys where practical.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

abstract final class QIcons {
  const QIcons._();

  // Input / links
  static const IconData link = Icons.link;
  static const IconData paste = Icons.content_paste_outlined;
  static const IconData globe = Icons.public;
  static const IconData arrowRight = Icons.arrow_forward;

  // Navigation / chrome
  static const IconData chevronLeft = Icons.chevron_left;
  static const IconData chevronRight = Icons.chevron_right;
  static const IconData chevronDown = Icons.expand_more;
  static const IconData close = Icons.close;
  static const IconData search = Icons.search;
  static const IconData clock = Icons.history;
  static const IconData settings = Icons.settings_outlined;
  static const IconData share = Icons.ios_share;
  static const IconData moreVertical = Icons.more_vert;

  // Media kinds
  static const IconData play = Icons.play_arrow;
  static const IconData image = Icons.image_outlined;
  static const IconData layers = Icons.layers_outlined;
  static const IconData film = Icons.movie_outlined;
  static const IconData photo = Icons.photo_library_outlined;

  // Actions / status
  static const IconData download = Icons.file_download_outlined;
  static const IconData sliders = Icons.tune;
  static const IconData check = Icons.check;
  static const IconData checkCircle = Icons.check_circle;
  static const IconData info = Icons.info_outline;
  static const IconData help = Icons.help_outline;
  static const IconData shield = Icons.shield_outlined;
  static const IconData folder = Icons.folder_outlined;
  static const IconData refresh = Icons.refresh;
  static const IconData trash = Icons.delete_outline;
  static const IconData bell = Icons.notifications_none;
  static const IconData wifi = Icons.wifi;
  static const IconData wifiOff = Icons.wifi_off;
  static const IconData lock = Icons.lock_outline;
  static const IconData alert = Icons.warning_amber_rounded;
  static const IconData external = Icons.open_in_new;
}
