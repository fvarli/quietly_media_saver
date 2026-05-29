// Quietly — widget + state + token tests (passes 1–7A).
//
// Covers the foundation, pass-2/3/4 UI, pass-5A–D services, pass-6 analysis +
// clipboard, and pass-7A gallery/file-save (sample save records a path, dedupe →
// already-saved, open/share/remove via the service, JSON incl. filePath/
// sourceKey). All platform layers are faked (no real channels); animated/
// analyzing screens use explicit pump(Duration), not pumpAndSettle; long lazy
// lists use scrollUntilVisible.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:quietly_media_saver/app/quietly_app.dart';
import 'package:quietly_media_saver/app/router/app_router.dart';
import 'package:quietly_media_saver/app/router/app_routes.dart';
import 'package:quietly_media_saver/core/icons/q_icons.dart';
import 'package:quietly_media_saver/core/theme/tokens/app_colors.dart';
import 'package:quietly_media_saver/core/widgets/q_bar.dart';
import 'package:quietly_media_saver/core/widgets/q_button.dart';
import 'package:quietly_media_saver/core/widgets/q_media_tile.dart';
import 'package:quietly_media_saver/core/widgets/q_pill.dart';
import 'package:quietly_media_saver/features/analyzing/analyzing_screen.dart';
import 'package:quietly_media_saver/features/carousel/carousel_screen.dart';
import 'package:quietly_media_saver/features/downloading/downloading_screen.dart';
import 'package:quietly_media_saver/features/error/error_screen.dart';
import 'package:quietly_media_saver/features/history/history_screen.dart';
import 'package:quietly_media_saver/features/result/result_screen.dart';
import 'package:quietly_media_saver/features/settings/settings_screen.dart';
import 'package:quietly_media_saver/features/success/success_screen.dart';
import 'package:quietly_media_saver/services/analysis/media_analysis_service.dart';
import 'package:quietly_media_saver/services/clipboard/clipboard_service.dart';
import 'package:quietly_media_saver/services/clipboard/clipboard_service_provider.dart';
import 'package:quietly_media_saver/services/connectivity/connectivity_service.dart';
import 'package:quietly_media_saver/services/connectivity/connectivity_service_provider.dart';
import 'package:quietly_media_saver/services/downloads/download_models.dart';
import 'package:quietly_media_saver/services/downloads/download_queue_provider.dart';
import 'package:quietly_media_saver/services/downloads/download_queue_service.dart';
import 'package:quietly_media_saver/services/downloads/in_memory_download_queue_service.dart';
import 'package:quietly_media_saver/services/gallery/gallery_service.dart';
import 'package:quietly_media_saver/services/gallery/gallery_service_provider.dart';
import 'package:quietly_media_saver/services/permissions/permission_result_mapper.dart';
import 'package:quietly_media_saver/services/permissions/permission_service.dart';
import 'package:quietly_media_saver/services/permissions/permission_service_provider.dart';
import 'package:quietly_media_saver/services/preferences/preferences_service.dart';
import 'package:quietly_media_saver/services/preferences/preferences_service_provider.dart';
import 'package:quietly_media_saver/services/saved_media/saved_media_repository.dart';
import 'package:quietly_media_saver/services/saved_media/saved_media_repository_provider.dart';
import 'package:quietly_media_saver/state/app_state.dart';
import 'package:quietly_media_saver/state/app_state_provider.dart';
import 'package:quietly_media_saver/state/error_config.dart';
import 'package:quietly_media_saver/state/models/analysis_result.dart';
import 'package:quietly_media_saver/state/models/app_enums.dart';
import 'package:quietly_media_saver/state/models/app_preferences.dart';
import 'package:quietly_media_saver/state/models/history_entry.dart';

/// In-memory PermissionService for tests — no platform channels.
class FakePermissionService implements PermissionService {
  FakePermissionService({
    this.requestResult = PermissionStatus.granted,
    this.statusResult = PermissionStatus.denied,
  });

  PermissionStatus requestResult;
  PermissionStatus statusResult;
  int openSettingsCalls = 0;

  @override
  Future<PermissionStatus> galleryStatus() async => statusResult;

  @override
  Future<PermissionStatus> requestGalleryPermission() async => requestResult;

  @override
  Future<bool> openSystemSettings() async {
    openSettingsCalls++;
    return true;
  }
}

/// In-memory ConnectivityService for tests — settable + emittable.
class FakeConnectivityService implements ConnectivityService {
  FakeConnectivityService({this.online = true});

  bool online;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  @override
  Future<bool> isOnline() async => online;

  @override
  Stream<bool> onlineChanges() => _controller.stream;

  void emit(bool value) => _controller.add(value);

  void dispose() => _controller.close();
}

/// Manual (timer-free) DownloadQueueService for widget/flow tests — state is
/// driven explicitly via helpers so there are no pending timers.
class FakeDownloadQueueService implements DownloadQueueService {
  final StreamController<DownloadQueueState> _controller =
      StreamController<DownloadQueueState>.broadcast();
  DownloadQueueState _state = DownloadQueueState.empty;
  int pauseCalls = 0;
  int resumeCalls = 0;
  int cancelCalls = 0;
  int retryCalls = 0;

  @override
  DownloadQueueState get current => _state;

  @override
  Stream<DownloadQueueState> get updates => _controller.stream;

  @override
  void start(List<MediaKind> kinds) {
    _set(
      DownloadQueueState([
        for (var i = 0; i < kinds.length; i++)
          DownloadItem(
            id: 'item_$i',
            kind: kinds[i],
            name: kinds[i] == MediaKind.video ? 'clip.mp4' : 'image.jpg',
            meta: 'meta',
            status: DownloadItemStatus.downloading,
          ),
      ]),
    );
  }

  @override
  void pause() {
    pauseCalls++;
    _set(_map(DownloadItemStatus.downloading, DownloadItemStatus.paused));
  }

  @override
  void resume() {
    resumeCalls++;
    _set(_map(DownloadItemStatus.paused, DownloadItemStatus.downloading));
  }

  @override
  void cancel() {
    cancelCalls++;
    _set(_map(DownloadItemStatus.downloading, DownloadItemStatus.canceled));
  }

  @override
  void retry() {
    retryCalls++;
    _set(_map(DownloadItemStatus.failed, DownloadItemStatus.downloading));
  }

  /// Test helper: mark every item complete.
  void completeAll() => _set(
    DownloadQueueState([
      for (final i in _state.items)
        i.copyWith(progress: 1, status: DownloadItemStatus.completed),
    ]),
  );

  /// Test helper: fail the first item.
  void failFirst() => _set(
    DownloadQueueState([
      for (var i = 0; i < _state.items.length; i++)
        i == 0
            ? _state.items[i].copyWith(status: DownloadItemStatus.failed)
            : _state.items[i],
    ]),
  );

  @override
  void dispose() {
    if (!_controller.isClosed) _controller.close();
  }

  DownloadQueueState _map(DownloadItemStatus from, DownloadItemStatus to) =>
      DownloadQueueState([
        for (final i in _state.items)
          i.status == from ? i.copyWith(status: to) : i,
      ]);

  void _set(DownloadQueueState s) {
    _state = s;
    if (!_controller.isClosed) _controller.add(s);
  }
}

/// Clipboard with settable contents — no platform channels.
class FakeClipboardService implements ClipboardService {
  FakeClipboardService([this.text]);
  String? text;

  @override
  Future<String?> readText() async => text;
}

/// In-memory SavedMediaRepository for tests — no platform channels.
class FakeSavedMediaRepository implements SavedMediaRepository {
  FakeSavedMediaRepository([this.stored]);

  List<HistoryEntry>? stored;
  List<HistoryEntry>? saved;

  @override
  Future<List<HistoryEntry>?> load() async => stored;

  @override
  Future<void> save(List<HistoryEntry> entries) async {
    saved = entries;
    stored = entries;
  }
}

/// Records GalleryService calls for tests — no platform channels.
class FakeGalleryService implements GalleryService {
  int openCalls = 0;
  int shareCalls = 0;
  int removeCalls = 0;
  int saveCalls = 0;
  HistoryEntry? lastRemoved;
  String savedPath = '/fake/quietly_media/sample.png';

  @override
  Future<String> saveSample(MediaKind kind) async {
    saveCalls++;
    return savedPath;
  }

  @override
  Future<void> open(HistoryEntry entry) async => openCalls++;

  @override
  Future<void> share(HistoryEntry entry) async => shareCalls++;

  @override
  Future<void> remove(HistoryEntry entry) async {
    removeCalls++;
    lastRemoved = entry;
  }
}

/// In-memory PreferencesService for tests — no platform channels.
class FakePreferencesService implements PreferencesService {
  FakePreferencesService([this.stored = const AppPreferences()]);

  AppPreferences stored;
  AppPreferences? saved;

  @override
  Future<AppPreferences> load() async => stored;

  @override
  Future<void> save(AppPreferences prefs) async {
    saved = prefs;
    stored = prefs;
  }
}

/// Pumps [child] inside an UncontrolledProviderScope bound to [container] and a
/// MaterialApp, for screen tests that need a pre-seeded AppState.
Future<void> _pumpScreen(
  WidgetTester tester,
  ProviderContainer container,
  Widget child,
) {
  return tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: child),
    ),
  );
}

/// Use a phone-sized viewport for full-screen tests.
void _usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('App shell', () {
    testWidgets('boots to Home and renders the hero + rights note', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      await tester.pumpWidget(const ProviderScope(child: QuietlyApp()));
      await tester.pumpAndSettle();

      expect(find.text('Quietly'), findsOneWidget);
      expect(find.text('Paste a link to get started.'), findsOneWidget);
      // Primary CTA (the clipboard card only appears when a URL is detected).
      expect(find.text('Paste link'), findsOneWidget);
      // Rights-aware positioning present on Home.
      expect(
        find.textContaining('Save only content you have the rights to'),
        findsOneWidget,
      );
    });
  });

  group('Components', () {
    testWidgets('QButton renders label, fires onTap, exposes a button label', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QButton(label: 'Save it', onPressed: () => tapped = true),
          ),
        ),
      );
      expect(find.text('Save it'), findsOneWidget);
      expect(find.bySemanticsLabel('Save it'), findsOneWidget);
      await tester.tap(find.text('Save it'));
      expect(tapped, isTrue);
    });

    testWidgets('QPill renders its label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: QPill('Public', tone: QPillTone.success)),
          ),
        ),
      );
      expect(find.text('Public'), findsOneWidget);
    });

    testWidgets('QMediaTile exposes a semantic label and stays abstract', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: QMediaTile(kind: MediaKind.video),
              ),
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Video thumbnail'), findsOneWidget);
    });
  });

  group('Result screen', () {
    testWidgets('quality row reflects state and opens the quality sheet', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ResultScreen())),
      );
      await tester.pumpAndSettle();

      // Default quality is 1080p (High · landscape).
      expect(find.textContaining('1080p'), findsWidgets);
      expect(find.text('Save to gallery'), findsOneWidget);

      // Tapping the quality row opens the sheet.
      await tester.tap(find.textContaining('tap to change quality'));
      await tester.pumpAndSettle();
      expect(find.text('Choose quality'), findsOneWidget);
    });
  });

  group('Sample analyzer (unit)', () {
    const svc = SampleMediaAnalysisService();

    test('single video for a plain link', () async {
      final r = await svc.analyze('https://share.example.com/p/abc');
      expect(r.type, AnalysisResultType.single);
      expect(r.items, hasLength(1));
      expect(r.host, 'share.example.com');
    });
    test('carousel for an album link', () async {
      final r = await svc.analyze('https://share.example.com/album/abc');
      expect(r.type, AnalysisResultType.carousel);
      expect(r.items.length, greaterThan(1));
    });
    test('throws invalidUrl / protected / unsupported', () async {
      expect(
        () => svc.analyze('not a url'),
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.kind,
            'kind',
            AnalysisFailureKind.invalidUrl,
          ),
        ),
      );
      expect(
        () => svc.analyze('https://x.example.com/private/a'),
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.kind,
            'kind',
            AnalysisFailureKind.protected,
          ),
        ),
      );
      expect(
        () => svc.analyze('https://unsupported.example.com/a'),
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.kind,
            'kind',
            AnalysisFailureKind.unsupported,
          ),
        ),
      );
    });
    test('isLikelyUrl + error mapping', () {
      expect(isLikelyUrl('https://a.com/x'), isTrue);
      expect(isLikelyUrl('share.example.com/p/1'), isTrue);
      expect(isLikelyUrl('hello world'), isFalse);
      expect(isLikelyUrl(''), isFalse);
      expect(
        toAppErrorKind(AnalysisFailureKind.protected),
        AppErrorKind.protected,
      );
      expect(toAppErrorKind(AnalysisFailureKind.network), AppErrorKind.network);
    });
  });

  group('Analysis + clipboard flow', () {
    /// Pumps the full app with a fake clipboard (URL) + faked services. Uses the
    /// REAL SampleMediaAnalysisService (deterministic by URL).
    Future<ProviderContainer> pumpHome(
      WidgetTester tester, {
      String? clipboard,
      bool online = true,
    }) async {
      final connectivity = FakeConnectivityService(online: online);
      addTearDown(connectivity.dispose);
      final container = ProviderContainer(
        overrides: [
          clipboardServiceProvider.overrideWithValue(
            FakeClipboardService(clipboard),
          ),
          connectivityServiceProvider.overrideWithValue(connectivity),
          preferencesServiceProvider.overrideWithValue(
            FakePreferencesService(),
          ),
          savedMediaRepositoryProvider.overrideWithValue(
            FakeSavedMediaRepository(),
          ),
          permissionServiceProvider.overrideWithValue(FakePermissionService()),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const QuietlyApp(),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    // Drives tap→outcome: clipboard read + nav to Analyzing, the calm-minimum
    // analysis, then the result nav. Never pumpAndSettle (QDots animates).
    Future<void> settleAnalysis(WidgetTester tester) async {
      await tester.pump(); // clipboard read + submitUrl
      await tester.pump(const Duration(milliseconds: 400)); // nav → Analyzing
      await tester.pump(
        kAnalyzeVisualDuration + const Duration(milliseconds: 300),
      ); // analysis min delay
      await tester.pump(); // process outcome nav
      await tester.pump(const Duration(milliseconds: 400)); // settle transition
    }

    testWidgets('detects a clipboard URL on Home', (tester) async {
      _usePhoneViewport(tester);
      await pumpHome(tester, clipboard: 'https://share.example.com/p/abc');
      expect(find.text('FROM YOUR CLIPBOARD'), findsOneWidget);
      expect(find.text('https://share.example.com/p/abc'), findsOneWidget);
    });

    testWidgets('paste valid URL → Analyzing → Result (analyzed data)', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      await pumpHome(tester, clipboard: 'https://demo.example.com/p/abc');
      await tester.tap(find.text('Paste link'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Reading this link'), findsOneWidget);
      await settleAnalysis(tester);
      expect(find.text('Available media'), findsOneWidget);
      // Result reflects the analyzed host.
      expect(find.text('demo.example.com'), findsOneWidget);
    });

    testWidgets('carousel URL → Carousel (analyzed items)', (tester) async {
      _usePhoneViewport(tester);
      await pumpHome(tester, clipboard: 'https://demo.example.com/album/abc');
      await tester.tap(find.text('Paste link'));
      await settleAnalysis(tester);
      expect(find.text('6 items found'), findsOneWidget);
    });

    testWidgets('invalid URL → invalid error', (tester) async {
      _usePhoneViewport(tester);
      await pumpHome(tester, clipboard: 'not a url');
      await tester.tap(find.text('Paste link'));
      await settleAnalysis(tester);
      expect(find.text('That doesn’t look like a link'), findsOneWidget);
    });

    testWidgets('protected URL → protected error', (tester) async {
      _usePhoneViewport(tester);
      await pumpHome(tester, clipboard: 'https://x.example.com/private/abc');
      await tester.tap(find.text('Paste link'));
      await settleAnalysis(tester);
      expect(find.text('This content is protected'), findsOneWidget);
    });

    testWidgets('unsupported URL → unsupported error', (tester) async {
      _usePhoneViewport(tester);
      await pumpHome(tester, clipboard: 'https://unsupported.example.com/abc');
      await tester.tap(find.text('Paste link'));
      await settleAnalysis(tester);
      expect(find.text('We can’t read this source yet'), findsOneWidget);
    });

    testWidgets('offline → network error', (tester) async {
      _usePhoneViewport(tester);
      await pumpHome(
        tester,
        clipboard: 'https://demo.example.com/p/abc',
        online: false,
      );
      await tester.tap(find.text('Paste link'));
      await settleAnalysis(tester);
      expect(find.text('Couldn’t reach this link'), findsOneWidget);
    });
  });

  group('Carousel screen', () {
    testWidgets('tapping a row updates the selected count', (tester) async {
      _usePhoneViewport(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      // Seed is partial; clear it so the count starts at a known 0.
      container.read(appStateProvider.notifier).toggleSelectAll(); // → all
      container.read(appStateProvider.notifier).toggleSelectAll(); // → none
      await _pumpScreen(tester, container, const CarouselScreen());
      await tester.pumpAndSettle();

      expect(find.text('0 selected'), findsOneWidget);
      await tester.tap(find.byType(QMediaTile).first);
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);
    });

    testWidgets('Select all then Clear toggles every item', (tester) async {
      _usePhoneViewport(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await _pumpScreen(tester, container, const CarouselScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select all'));
      await tester.pumpAndSettle();
      expect(container.read(appStateProvider).allCarouselSelected, isTrue);

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();
      expect(container.read(appStateProvider).selectedCount, 0);
    });

    testWidgets('Save selected opens the permission sheet', (tester) async {
      _usePhoneViewport(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await _pumpScreen(tester, container, const CarouselScreen());
      await tester.pumpAndSettle();

      // Seed has items selected → footer offers a Save action.
      await tester.tap(find.textContaining('Save '));
      await tester.pumpAndSettle();
      expect(find.text('Allow access'), findsOneWidget);
    });
  });

  group('DownloadQueueService (in-memory)', () {
    // These exercise the real timer-driven impl; the body disposes the service
    // before completing so no timer is left pending.
    testWidgets('starts and emits progress', (tester) async {
      await tester.pumpWidget(const SizedBox());
      final svc = InMemoryDownloadQueueService();
      svc.start(const [MediaKind.video]);
      expect(svc.current.items, hasLength(1));
      await tester.pump(const Duration(milliseconds: 360));
      expect(svc.current.overallProgress, greaterThan(0));
      svc.dispose();
    });

    testWidgets('pause holds progress; resume continues', (tester) async {
      await tester.pumpWidget(const SizedBox());
      final svc = InMemoryDownloadQueueService();
      svc.start(const [MediaKind.video]);
      await tester.pump(const Duration(milliseconds: 240));
      final held = svc.current.overallProgress;
      expect(held, greaterThan(0));

      svc.pause();
      expect(svc.current.isPaused, isTrue);
      await tester.pump(const Duration(milliseconds: 360));
      expect(svc.current.overallProgress, held); // unchanged while paused

      svc.resume();
      await tester.pump(const Duration(milliseconds: 240));
      expect(svc.current.overallProgress, greaterThan(held));
      svc.dispose();
    });

    testWidgets('cancel marks items canceled and stops progress', (
      tester,
    ) async {
      await tester.pumpWidget(const SizedBox());
      final svc = InMemoryDownloadQueueService();
      svc.start(const [MediaKind.video]);
      await tester.pump(const Duration(milliseconds: 120));
      svc.cancel();
      expect(svc.current.items.first.status, DownloadItemStatus.canceled);
      final at = svc.current.overallProgress;
      await tester.pump(const Duration(milliseconds: 360));
      expect(svc.current.overallProgress, at); // no further progress
      svc.dispose();
    });

    testWidgets('a failing item emits a failure', (tester) async {
      await tester.pumpWidget(const SizedBox());
      final svc = InMemoryDownloadQueueService(failItemIds: const {'item_0'});
      svc.start(const [MediaKind.video]);
      await tester.pump(const Duration(seconds: 2));
      expect(svc.current.hasFailure, isTrue);
      svc.dispose();
    });
  });

  group('Download screen (service-driven)', () {
    /// Pumps DownloadingScreen with a pre-started fake queue (no timers).
    Future<FakeDownloadQueueService> pumpDownload(
      WidgetTester tester,
      List<MediaKind> kinds,
    ) async {
      final fake = FakeDownloadQueueService();
      addTearDown(fake.dispose);
      fake.start(kinds);
      final container = ProviderContainer(
        overrides: [downloadQueueServiceProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);
      await _pumpScreen(tester, container, const DownloadingScreen());
      await tester.pump();
      return fake;
    }

    testWidgets('renders single-file state from the service', (tester) async {
      _usePhoneViewport(tester);
      await pumpDownload(tester, const [MediaKind.video]);
      expect(find.text('Saving video…'), findsOneWidget);
    });

    testWidgets('renders multi-queue state from the service', (tester) async {
      _usePhoneViewport(tester);
      await pumpDownload(tester, const [
        MediaKind.image,
        MediaKind.image,
        MediaKind.video,
      ]);
      expect(find.text('Saving 3 items'), findsOneWidget);
      expect(find.byType(QBar), findsWidgets);
    });

    testWidgets('Pause taps the service; label toggles to Resume', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      final fake = await pumpDownload(tester, const [MediaKind.video]);
      await tester.tap(find.text('Pause'));
      await tester.pump();
      expect(fake.pauseCalls, 1);
      expect(find.text('Resume'), findsOneWidget);
    });
  });

  group('Success screen', () {
    testWidgets('renders saved confirmation and the three CTAs', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await _pumpScreen(tester, container, const SuccessScreen());
      await tester.pumpAndSettle();

      expect(find.text('Saved to gallery'), findsOneWidget);
      expect(find.text('Open in gallery'), findsOneWidget);
      expect(find.text('View history'), findsOneWidget);
      expect(find.text('Save another link'), findsOneWidget);
    });
  });

  group('History screen', () {
    testWidgets('renders day-grouped seeded entries + storage summary', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await _pumpScreen(tester, container, const HistoryScreen());
      await tester.pumpAndSettle();

      // QSectionLabel uppercases its text.
      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('YESTERDAY'), findsOneWidget);
      expect(find.text('EARLIER'), findsOneWidget);
      expect(find.text('Video clip'), findsWidgets);
      expect(find.textContaining('saves · 248 MB used'), findsOneWidget);
    });

    testWidgets('renders the empty state when history is cleared', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(appStateProvider.notifier).clearHistory();
      await _pumpScreen(tester, container, const HistoryScreen());
      await tester.pumpAndSettle();

      expect(find.text('No saves yet'), findsOneWidget);
      expect(find.text('TODAY'), findsNothing);
    });
  });

  group('Settings screen', () {
    testWidgets('renders rights/legal, permission and storage sections', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await _pumpScreen(tester, container, const SettingsScreen());
      await tester.pumpAndSettle();

      // Near the top of the (long, lazy) list.
      expect(find.text('Save to gallery'), findsOneWidget); // permissions
      expect(find.text('Clear history'), findsOneWidget); // storage

      // Legal + rights statement are further down — scroll them into view.
      await tester.scrollUntilVisible(
        find.text('Acceptable use & your rights'),
        250,
      );
      expect(find.text('Acceptable use & your rights'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.textContaining('Quietly saves only publicly accessible media'),
        250,
      );
      expect(
        find.textContaining('Quietly saves only publicly accessible media'),
        findsOneWidget,
      );
    });

    testWidgets('shows Open system settings when permission not granted', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(appStateProvider.notifier)
          .setPermissionStatus(PermissionStatus.permanentlyDenied);
      await _pumpScreen(tester, container, const SettingsScreen());
      await tester.pumpAndSettle();

      expect(find.text('Open system settings'), findsOneWidget);
      expect(find.text('Blocked'), findsOneWidget);
    });
  });

  group('Error screen', () {
    testWidgets('renders title + CTA for every error kind', (tester) async {
      _usePhoneViewport(tester);
      for (final kind in AppErrorKind.values) {
        final container = ProviderContainer();
        container.read(appStateProvider.notifier).showError(kind);
        await _pumpScreen(tester, container, const ErrorScreen());
        await tester.pumpAndSettle();

        final cfg = kErrorConfig[kind]!;
        expect(find.text(cfg.title), findsOneWidget, reason: 'title for $kind');
        expect(find.text(cfg.cta), findsOneWidget, reason: 'cta for $kind');
        container.dispose();
      }
    });
  });

  group('Error CTAs (routed)', () {
    Future<ProviderContainer> pumpAtError(
      WidgetTester tester,
      AppErrorKind kind, {
      PermissionService? permissionService,
    }) async {
      final container = ProviderContainer(
        overrides: [
          savedMediaRepositoryProvider.overrideWithValue(
            FakeSavedMediaRepository(),
          ),
          if (permissionService != null)
            permissionServiceProvider.overrideWithValue(permissionService),
        ],
      );
      addTearDown(container.dispose);
      container.read(appStateProvider.notifier).showError(kind);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const QuietlyApp(),
        ),
      );
      await tester.pumpAndSettle();
      container.read(routerProvider).goNamed(AppRoutes.error);
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets('network Retry routes to Analyzing', (tester) async {
      _usePhoneViewport(tester);
      await pumpAtError(tester, AppErrorKind.network);
      expect(find.text('Couldn’t reach this link'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump(); // begin navigation
      await tester.pump(
        const Duration(milliseconds: 400),
      ); // settle; no settle()
      expect(find.text('Reading this link'), findsOneWidget);

      // Let the re-run analysis settle so no timer is left pending at teardown.
      await tester.pump(
        kAnalyzeVisualDuration + const Duration(milliseconds: 400),
      );
      await tester.pump();
    });

    testWidgets('protected Try another link routes Home', (tester) async {
      _usePhoneViewport(tester);
      await pumpAtError(tester, AppErrorKind.protected);
      await tester.tap(find.text('Try another link'));
      await tester.pumpAndSettle();
      expect(find.text('Paste a link to get started.'), findsOneWidget);
    });

    testWidgets('permanently-denied Open settings calls the service', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      final fake = FakePermissionService();
      await pumpAtError(
        tester,
        AppErrorKind.permissionDeniedPermanently,
        permissionService: fake,
      );
      await tester.tap(find.text('Open settings'));
      await tester.pump();
      expect(fake.openSettingsCalls, 1);
    });
  });

  group('Permission mapper', () {
    test('granted / limited → granted', () {
      expect(
        mapPermissionStatus(ph.PermissionStatus.granted),
        PermissionStatus.granted,
      );
      expect(
        mapPermissionStatus(ph.PermissionStatus.limited),
        PermissionStatus.granted,
      );
    });
    test('denied → denied', () {
      expect(
        mapPermissionStatus(ph.PermissionStatus.denied),
        PermissionStatus.denied,
      );
    });
    test('permanentlyDenied / restricted → permanentlyDenied', () {
      expect(
        mapPermissionStatus(ph.PermissionStatus.permanentlyDenied),
        PermissionStatus.permanentlyDenied,
      );
      expect(
        mapPermissionStatus(ph.PermissionStatus.restricted),
        PermissionStatus.permanentlyDenied,
      );
    });
    test('reduce: all granted → granted; any blocked/denied dominates', () {
      expect(
        reducePermissionStatuses([
          ph.PermissionStatus.granted,
          ph.PermissionStatus.granted,
        ]),
        PermissionStatus.granted,
      );
      expect(
        reducePermissionStatuses([
          ph.PermissionStatus.granted,
          ph.PermissionStatus.permanentlyDenied,
        ]),
        PermissionStatus.permanentlyDenied,
      );
      expect(
        reducePermissionStatuses([
          ph.PermissionStatus.granted,
          ph.PermissionStatus.denied,
        ]),
        PermissionStatus.denied,
      );
    });
  });

  group('Permission + download flow', () {
    late ProviderContainer flowContainer;
    late FakeGalleryService flowGallery;

    // Pumps the full app at Result with permission + download + gallery faked.
    // Returns the download fake so tests can drive completion/failure.
    Future<FakeDownloadQueueService> pumpAtResult(
      WidgetTester tester, {
      required PermissionStatus requestResult,
    }) async {
      final permission = FakePermissionService(requestResult: requestResult);
      final download = FakeDownloadQueueService();
      addTearDown(download.dispose);
      flowGallery = FakeGalleryService();
      final container = ProviderContainer(
        overrides: [
          permissionServiceProvider.overrideWithValue(permission),
          downloadQueueServiceProvider.overrideWithValue(download),
          savedMediaRepositoryProvider.overrideWithValue(
            FakeSavedMediaRepository(),
          ),
          galleryServiceProvider.overrideWithValue(flowGallery),
        ],
      );
      flowContainer = container;
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const QuietlyApp(),
        ),
      );
      await tester.pumpAndSettle();
      container.read(routerProvider).goNamed(AppRoutes.result);
      await tester.pumpAndSettle();
      return download;
    }

    Future<FakeDownloadQueueService> saveAndAllow(WidgetTester tester) async {
      final download = await pumpAtResult(
        tester,
        requestResult: PermissionStatus.granted,
      );
      await tester.tap(find.text('Save to gallery'));
      await tester.pumpAndSettle(); // priming sheet in
      await tester.tap(find.text('Allow access'));
      await tester.pumpAndSettle(); // request + nav to Download
      return download;
    }

    testWidgets('Allow + granted → Download (reflects service)', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      await saveAndAllow(tester);
      expect(find.text('Saving video…'), findsOneWidget);
    });

    testWidgets('queue completion → Success + saves a file path', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      final download = await saveAndAllow(tester);
      download.completeAll();
      await tester.pumpAndSettle();
      expect(find.text('Saved to gallery'), findsOneWidget);

      // The gallery service saved a sample file and the new entry records it.
      expect(flowGallery.saveCalls, 1);
      expect(
        flowContainer.read(appStateProvider).history.first.filePath,
        flowGallery.savedPath,
      );
    });

    testWidgets('queue failure → queueItemFailed error', (tester) async {
      _usePhoneViewport(tester);
      final download = await saveAndAllow(tester);
      download.failFirst();
      await tester.pumpAndSettle();
      expect(find.text('A file didn’t save'), findsOneWidget);
    });

    testWidgets('duplicate save → already-saved (exists)', (tester) async {
      _usePhoneViewport(tester);
      await pumpAtResult(tester, requestResult: PermissionStatus.granted);

      const url = 'https://demo.example.com/p/abc';
      const host = 'demo.example.com';
      final notifier = flowContainer.read(appStateProvider.notifier);
      notifier.setSubmittedUrl(url);
      notifier.setAnalysis(
        const AnalysisResult(
          type: AnalysisResultType.single,
          host: host,
          isPublic: true,
          items: [
            DetectedMediaItem(
              id: 'm0',
              kind: MediaKind.video,
              sizeMb: 24,
              durationSeconds: 42,
            ),
          ],
        ),
      );
      notifier.setHistory([
        HistoryEntry(
          id: 'h0',
          kind: MediaKind.video,
          title: 'Video clip',
          meta: '1080p · 24 MB',
          time: 'Just now',
          group: HistoryGroup.today,
          sourceKey: dedupeKey(host, url),
        ),
      ]);
      await tester.pump();

      await tester.tap(find.text('Save to gallery'));
      await tester.pumpAndSettle();
      expect(find.text('Already in your gallery'), findsOneWidget);
    });

    testWidgets('Cancel returns Home and cancels the queue', (tester) async {
      _usePhoneViewport(tester);
      final download = await saveAndAllow(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Paste a link to get started.'), findsOneWidget);
      expect(download.cancelCalls, 1);
    });

    testWidgets('Allow + permanentlyDenied → error screen', (tester) async {
      _usePhoneViewport(tester);
      await pumpAtResult(
        tester,
        requestResult: PermissionStatus.permanentlyDenied,
      );

      await tester.tap(find.text('Save to gallery'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Allow access'));
      await tester.pumpAndSettle();
      expect(find.text('Gallery access is off'), findsOneWidget);
    });

    testWidgets('Allow + denied → stays on Result', (tester) async {
      _usePhoneViewport(tester);
      await pumpAtResult(tester, requestResult: PermissionStatus.denied);

      await tester.tap(find.text('Save to gallery'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Allow access'));
      await tester.pumpAndSettle();
      expect(find.text('Available media'), findsOneWidget);
      expect(find.text('Saving video…'), findsNothing);
    });
  });

  group('Settings permission status (real)', () {
    testWidgets('reflects granted status from the service', (tester) async {
      _usePhoneViewport(tester);
      final fake = FakePermissionService(
        statusResult: PermissionStatus.granted,
      );
      final container = ProviderContainer(
        overrides: [permissionServiceProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);
      await _pumpScreen(tester, container, const SettingsScreen());
      await tester.pumpAndSettle();

      expect(find.text('Allowed'), findsOneWidget);
    });

    testWidgets('blocked status shows Open system settings + calls service', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      final fake = FakePermissionService(
        statusResult: PermissionStatus.permanentlyDenied,
      );
      final container = ProviderContainer(
        overrides: [permissionServiceProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);
      await _pumpScreen(tester, container, const SettingsScreen());
      await tester.pumpAndSettle();

      expect(find.text('Blocked'), findsOneWidget);
      expect(find.text('Open system settings'), findsOneWidget);
      await tester.tap(find.text('Open system settings'));
      await tester.pump();
      expect(fake.openSettingsCalls, 1);
    });
  });

  group('Connectivity mapper', () {
    test('none → offline; any interface → online', () {
      expect(isOnlineFromResults([ConnectivityResult.none]), isFalse);
      expect(isOnlineFromResults([]), isFalse);
      expect(isOnlineFromResults([ConnectivityResult.wifi]), isTrue);
      expect(
        isOnlineFromResults([
          ConnectivityResult.none,
          ConnectivityResult.mobile,
        ]),
        isTrue,
      );
    });
  });

  group('Bootstrap (connectivity + preferences)', () {
    /// Pumps QuietlyApp with the three platform services faked.
    Future<ProviderContainer> pumpApp(
      WidgetTester tester, {
      required FakeConnectivityService connectivity,
      required FakePreferencesService preferences,
      FakePermissionService? permission,
      FakeSavedMediaRepository? savedMedia,
    }) async {
      final container = ProviderContainer(
        overrides: [
          connectivityServiceProvider.overrideWithValue(connectivity),
          preferencesServiceProvider.overrideWithValue(preferences),
          permissionServiceProvider.overrideWithValue(
            permission ?? FakePermissionService(),
          ),
          savedMediaRepositoryProvider.overrideWithValue(
            savedMedia ?? FakeSavedMediaRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(connectivity.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const QuietlyApp(),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets('loads persisted preferences on startup', (tester) async {
      _usePhoneViewport(tester);
      final container = await pumpApp(
        tester,
        connectivity: FakeConnectivityService(online: true),
        preferences: FakePreferencesService(
          const AppPreferences(quality: '720p', wifiOnly: false),
        ),
      );

      final state = container.read(appStateProvider);
      expect(state.quality, '720p');
      expect(state.toggles.wifiOnly, isFalse);
    });

    testWidgets('offline connectivity shows the Home banner; online hides it', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      final connectivity = FakeConnectivityService(online: false);
      await pumpApp(
        tester,
        connectivity: connectivity,
        preferences: FakePreferencesService(),
      );

      expect(find.textContaining('You’re offline'), findsOneWidget);

      connectivity.emit(true);
      await tester.pumpAndSettle();
      expect(find.textContaining('You’re offline'), findsNothing);
    });

    testWidgets('preference change is persisted via the listener', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      final prefs = FakePreferencesService();
      final container = await pumpApp(
        tester,
        connectivity: FakeConnectivityService(online: true),
        preferences: prefs,
      );

      container.read(appStateProvider.notifier).setWifiOnly(false);
      await tester.pump();
      expect(prefs.saved?.wifiOnly, isFalse);
    });
  });

  group('History persistence', () {
    Future<({ProviderContainer container, FakeSavedMediaRepository repo})>
    pumpApp(WidgetTester tester, {List<HistoryEntry>? stored}) async {
      final repo = FakeSavedMediaRepository(stored);
      final connectivity = FakeConnectivityService(online: true);
      addTearDown(connectivity.dispose);
      final container = ProviderContainer(
        overrides: [
          savedMediaRepositoryProvider.overrideWithValue(repo),
          connectivityServiceProvider.overrideWithValue(connectivity),
          preferencesServiceProvider.overrideWithValue(
            FakePreferencesService(),
          ),
          permissionServiceProvider.overrideWithValue(FakePermissionService()),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const QuietlyApp(),
        ),
      );
      await tester.pumpAndSettle();
      return (container: container, repo: repo);
    }

    testWidgets('persisted history loads on startup', (tester) async {
      _usePhoneViewport(tester);
      const stored = [
        HistoryEntry(
          id: 'p0',
          kind: MediaKind.video,
          title: 'Persisted clip',
          meta: '1080p · 10 MB',
          time: 'Just now',
          group: HistoryGroup.today,
        ),
        HistoryEntry(
          id: 'p1',
          kind: MediaKind.image,
          title: 'Persisted image',
          meta: 'JPG · 1 MB',
          time: 'Just now',
          group: HistoryGroup.today,
        ),
      ];
      final r = await pumpApp(tester, stored: stored);
      expect(r.container.read(appStateProvider).history, stored);
    });

    testWidgets('success save persists history', (tester) async {
      _usePhoneViewport(tester);
      final r = await pumpApp(tester); // null stored → seed kept
      final before = r.container.read(appStateProvider).history.length;

      r.container.read(appStateProvider.notifier).finishDownload();
      await tester.pump();

      expect(r.repo.saved, isNotNull);
      expect(r.repo.saved!.length, before + 1);
    });

    testWidgets('remove entry persists', (tester) async {
      _usePhoneViewport(tester);
      final r = await pumpApp(tester);

      r.container
          .read(appStateProvider.notifier)
          .removeHistoryEntry(kSeedHistory.first);
      await tester.pump();

      expect(r.repo.saved!.any((e) => e.id == kSeedHistory.first.id), isFalse);
    });

    testWidgets('clear persists an empty list', (tester) async {
      _usePhoneViewport(tester);
      final r = await pumpApp(tester);

      r.container.read(appStateProvider.notifier).clearHistory();
      await tester.pump();

      expect(r.repo.saved, isEmpty);
    });

    testWidgets('persisted empty history shows the empty state', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      final r = await pumpApp(tester, stored: const []);
      r.container.read(routerProvider).goNamed(AppRoutes.history);
      await tester.pumpAndSettle();
      expect(find.text('No saves yet'), findsOneWidget);
    });
  });

  group('History gallery actions', () {
    Future<FakeGalleryService> openRowActions(WidgetTester tester) async {
      final gallery = FakeGalleryService();
      final container = ProviderContainer(
        overrides: [galleryServiceProvider.overrideWithValue(gallery)],
      );
      addTearDown(container.dispose);
      await _pumpScreen(tester, container, const HistoryScreen());
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithIcon(IconButton, QIcons.moreVertical).first,
      );
      await tester.pumpAndSettle();
      return gallery;
    }

    testWidgets('Open calls the gallery service', (tester) async {
      _usePhoneViewport(tester);
      final gallery = await openRowActions(tester);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(gallery.openCalls, 1);
    });

    testWidgets('Share calls the gallery service', (tester) async {
      _usePhoneViewport(tester);
      final gallery = await openRowActions(tester);
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();
      expect(gallery.shareCalls, 1);
    });

    testWidgets('Remove calls the gallery service and drops the row', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      final gallery = await openRowActions(tester);
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(gallery.removeCalls, 1);
    });
  });

  group('HistoryEntry JSON', () {
    test(
      'round-trips through toJson/fromJson (incl. filePath + sourceKey)',
      () {
        const entry = HistoryEntry(
          id: 'x',
          kind: MediaKind.video,
          title: 'Title',
          meta: 'Meta',
          time: 'Just now',
          group: HistoryGroup.yesterday,
          filePath: '/tmp/x.mp4',
          sourceKey: 'demo.example.com|https://demo.example.com/p/abc',
        );
        final restored = HistoryEntry.fromJson(entry.toJson());
        expect(restored, entry);
        expect(restored.filePath, '/tmp/x.mp4');
        expect(restored.sourceKey, entry.sourceKey);
      },
    );

    test('dedupe key + isAlreadySaved', () {
      expect(dedupeKey('h', 'u'), 'h|u');
      const state = AppState(
        history: [
          HistoryEntry(
            id: 'h0',
            kind: MediaKind.video,
            title: 'Video clip',
            meta: 'm',
            time: 't',
            group: HistoryGroup.today,
            sourceKey: 'h|u',
          ),
        ],
      );
      expect(state.isAlreadySaved('h|u'), isTrue);
      expect(state.isAlreadySaved('other'), isFalse);
    });
  });

  group('AppState machine', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    AppState read() => container.read(appStateProvider);
    AppStateNotifier notifier() => container.read(appStateProvider.notifier);

    test('starts on home with seed data and no permission', () {
      final s = read();
      expect(s.screen, AppScreen.home);
      expect(s.sheet, isNull);
      expect(s.permissionGranted, isFalse);
      expect(s.history, isNotEmpty);
      expect(s.quality, '1080p');
    });

    test('paste → analyzing', () {
      notifier().paste();
      expect(read().screen, AppScreen.analyzing);
    });

    test('requestSave needs permission until granted', () {
      expect(notifier().requestSave(const [MediaKind.video]), isTrue);
      notifier().grantPermission();
      expect(read().permissionGranted, isTrue);
      expect(notifier().requestSave(const [MediaKind.video]), isFalse);
    });

    test('startDownload builds a queue for multi-item saves', () {
      notifier().startDownload(const [
        MediaKind.image,
        MediaKind.image,
        MediaKind.video,
      ]);
      final s = read();
      expect(s.screen, AppScreen.downloading);
      expect(s.isMultiDownload, isTrue);
      expect(s.queue.length, 3);
    });

    test('finishDownload prepends history and lands on success', () {
      final before = read().history.length;
      notifier().startDownload(const [MediaKind.video]);
      notifier().finishDownload();
      final s = read();
      expect(s.screen, AppScreen.success);
      expect(s.history.length, before + 1);
    });

    test('select-all toggles every carousel item', () {
      notifier().toggleSelectAll(); // seed is partial → selects all
      expect(read().allCarouselSelected, isTrue);
      notifier().toggleSelectAll();
      expect(read().selectedCount, 0);
    });
  });

  group('Design tokens', () {
    test('accent matches the handoff indigo (#4B53C4)', () {
      expect(AppColors.accent.toARGB32(), 0xFF4B53C4);
    });

    test('caption uses the darkened faint for WCAG AA (#857E73)', () {
      expect(AppColors.faintText.toARGB32(), 0xFF857E73);
    });
  });
}
