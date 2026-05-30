// ─────────────────────────────────────────────────────────────
// Quietly — Play Store screenshot generator (debug-only, NOT a unit test).
//
// Renders the REAL app screens to PNGs for the Play listing. Named without the
// `_test` suffix so it is EXCLUDED from the normal `flutter test` suite; run it
// explicitly:
//     flutter test test/store_screenshots.dart
//
// Each screen is pumped standalone (seeded ProviderContainer + real theme) and
// captured via RepaintBoundary.toImage → PNG at 1080×2340. No runtime app code is
// changed. Output → docs/store-assets/screenshots/NN-*.png.
// ─────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quietly_media_saver/core/theme/app_theme.dart';
import 'package:quietly_media_saver/features/analyzing/analyzing_screen.dart';
import 'package:quietly_media_saver/features/error/error_screen.dart';
import 'package:quietly_media_saver/features/history/history_screen.dart';
import 'package:quietly_media_saver/features/home/home_screen.dart';
import 'package:quietly_media_saver/features/result/result_screen.dart';
import 'package:quietly_media_saver/features/success/success_screen.dart';
import 'package:quietly_media_saver/services/analysis/media_analysis_provider.dart';
import 'package:quietly_media_saver/services/analysis/media_analysis_service.dart';
import 'package:quietly_media_saver/services/clipboard/clipboard_service.dart';
import 'package:quietly_media_saver/services/clipboard/clipboard_service_provider.dart';
import 'package:quietly_media_saver/services/preferences/preferences_service.dart';
import 'package:quietly_media_saver/services/preferences/preferences_service_provider.dart';
import 'package:quietly_media_saver/services/saved_media/saved_media_repository.dart';
import 'package:quietly_media_saver/services/saved_media/saved_media_repository_provider.dart';
import 'package:quietly_media_saver/state/app_state_provider.dart';
import 'package:quietly_media_saver/state/models/analysis_result.dart';
import 'package:quietly_media_saver/state/models/app_enums.dart';
import 'package:quietly_media_saver/state/models/app_preferences.dart';
import 'package:quietly_media_saver/state/models/history_entry.dart';

// ── Minimal inline fakes (no platform channels for Home/bootstrap) ──
class _Clip implements ClipboardService {
  _Clip(this.text);
  final String? text;
  @override
  Future<String?> readText() async => text;
}

class _Prefs implements PreferencesService {
  @override
  Future<AppPreferences> load() async =>
      const AppPreferences(firstRunAcknowledged: true);
  @override
  Future<void> save(AppPreferences prefs) async {}
}

class _Saved implements SavedMediaRepository {
  @override
  Future<List<HistoryEntry>?> load() async => null;
  @override
  Future<void> save(List<HistoryEntry> entries) async {}
}

class _HangAnalyzer implements MediaAnalysisService {
  @override
  Future<AnalysisResult> analyze(String url) =>
      Completer<AnalysisResult>().future; // never completes, no timer
}

// Load the bundled fonts (MaterialIcons + any app fonts) so text/icons render
// as real glyphs instead of the headless test placeholder boxes.
Future<void> _loadBundledFonts() async {
  final manifest =
      json.decode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final entry in manifest) {
    final family = (entry as Map)['family'] as String;
    final loader = FontLoader(family);
    for (final font in entry['fonts'] as List) {
      loader.addFont(rootBundle.load((font as Map)['asset'] as String));
    }
    await loader.load();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadBundledFonts);

  const outDir = 'docs/store-assets/screenshots';

  // Shared overrides so Home's bootstrap/clipboard never touch real channels.
  // (Return type inferred as List<Override>.)
  baseOverrides({String? clipboard}) => [
    clipboardServiceProvider.overrideWithValue(_Clip(clipboard)),
    preferencesServiceProvider.overrideWithValue(_Prefs()),
    savedMediaRepositoryProvider.overrideWithValue(_Saved()),
  ];

  Future<void> capture(
    WidgetTester tester,
    String name,
    Widget child, {
    required ProviderContainer container,
    void Function(AppStateNotifier notifier)? seed,
    Duration settle = const Duration(milliseconds: 350),
  }) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    addTearDown(container.dispose);
    if (seed != null) seed(container.read(appStateProvider.notifier));

    final key = GlobalKey();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(),
          home: RepaintBoundary(key: key, child: child),
        ),
      ),
    );
    await tester.pump(settle);

    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      Directory(outDir).createSync(recursive: true);
      File('$outDir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
      image.dispose();
    });

    // Dispose the screen (stops any controllers/tickers before teardown).
    await tester.pumpWidget(const SizedBox());
  }

  testWidgets('01-home', (tester) async {
    await capture(
      tester,
      '01-home',
      const HomeScreen(),
      container: ProviderContainer(
        overrides: baseOverrides(clipboard: 'media.example.com/clip.mp4'),
      ),
    );
  });

  testWidgets('02-public-media', (tester) async {
    await capture(
      tester,
      '02-public-media',
      const ResultScreen(),
      container: ProviderContainer(overrides: baseOverrides()),
      seed: (n) => n.setAnalysis(
        const AnalysisResult(
          type: AnalysisResultType.single,
          host: 'media.example.com',
          isPublic: true,
          items: [
            DetectedMediaItem(id: 'm0', kind: MediaKind.image, sizeMb: 3.2),
          ],
        ),
      ),
    );
  });

  testWidgets('03-analyze', (tester) async {
    await capture(
      tester,
      '03-analyze',
      const AnalyzingScreen(),
      container: ProviderContainer(
        overrides: [
          ...baseOverrides(),
          mediaAnalysisServiceProvider.overrideWithValue(_HangAnalyzer()),
        ],
      ),
      seed: (n) => n.setSubmittedUrl('media.example.com/clip.mp4'),
      settle: const Duration(milliseconds: 1000),
    );
  });

  testWidgets('04-save', (tester) async {
    await capture(
      tester,
      '04-save',
      const SuccessScreen(),
      container: ProviderContainer(overrides: baseOverrides()),
      seed: (n) => n.startDownload(const [MediaKind.image]),
      settle: const Duration(milliseconds: 700),
    );
  });

  testWidgets('05-history', (tester) async {
    await capture(
      tester,
      '05-history',
      const HistoryScreen(),
      container: ProviderContainer(overrides: baseOverrides()),
    );
  });

  testWidgets('06-private', (tester) async {
    await capture(
      tester,
      '06-private',
      const ErrorScreen(),
      container: ProviderContainer(overrides: baseOverrides()),
      seed: (n) => n.showError(AppErrorKind.protected),
    );
  });
}
