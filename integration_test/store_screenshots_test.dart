// ─────────────────────────────────────────────────────────────
// Quietly — Play Store screenshot capture (integration_test, device-only).
//
// Renders the REAL app screens on a device/emulator (real fonts + UI) and saves
// PNGs via the screenshot driver. Debug/test-only; no runtime production code is
// changed. Run on a phone/emulator (recommend a 1080×2340 profile):
//
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/store_screenshots_test.dart \
//     -d <device-id>
//
// Output → docs/store-assets/screenshots/NN-*.png (written by the driver).
// ─────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

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
      Completer<AnalysisResult>().future;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  baseOverrides({String? clipboard}) => [
    clipboardServiceProvider.overrideWithValue(_Clip(clipboard)),
    preferencesServiceProvider.overrideWithValue(_Prefs()),
    savedMediaRepositoryProvider.overrideWithValue(_Saved()),
  ];

  testWidgets('capture store screenshots', (tester) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    Future<void> shoot(
      String name,
      Widget child, {
      required ProviderContainer container,
      void Function(AppStateNotifier notifier)? seed,
      Duration settle = const Duration(milliseconds: 600),
    }) async {
      if (seed != null) seed(container.read(appStateProvider.notifier));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: buildLightTheme(),
            home: child,
          ),
        ),
      );
      await tester.pump(settle);
      await binding.takeScreenshot(name);
      container.dispose();
    }

    await shoot(
      '01-home',
      const HomeScreen(),
      container: ProviderContainer(
        overrides: baseOverrides(clipboard: 'media.example.com/clip.mp4'),
      ),
    );
    await shoot(
      '02-public-media',
      const ResultScreen(),
      container: ProviderContainer(overrides: baseOverrides()),
      seed: (n) => n.setAnalysis(
        const AnalysisResult(
          type: AnalysisResultType.single,
          host: 'media.example.com',
          isPublic: true,
          items: [DetectedMediaItem(id: 'm0', kind: MediaKind.image, sizeMb: 3.2)],
        ),
      ),
    );
    await shoot(
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
    await shoot(
      '04-save',
      const SuccessScreen(),
      container: ProviderContainer(overrides: baseOverrides()),
      seed: (n) => n.startDownload(const [MediaKind.image]),
    );
    await shoot(
      '05-history',
      const HistoryScreen(),
      container: ProviderContainer(overrides: baseOverrides()),
    );
    await shoot(
      '06-private',
      const ErrorScreen(),
      container: ProviderContainer(overrides: baseOverrides()),
      seed: (n) => n.showError(AppErrorKind.protected),
    );
  });
}
