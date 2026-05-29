// Quietly — widget + state + token tests (passes 1–5B).
//
// Covers the foundation, pass-2/3/4 UI, pass-5A permissions, and pass-5B
// bootstrap (connectivity → offline banner, preference load/persist). All
// platform layers are faked (permission/connectivity/preferences) — no real
// platform channels. Screens with running animations use explicit
// pump(Duration), not pumpAndSettle; long lazy lists use scrollUntilVisible.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:quietly_media_saver/app/quietly_app.dart';
import 'package:quietly_media_saver/app/router/app_router.dart';
import 'package:quietly_media_saver/app/router/app_routes.dart';
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
import 'package:quietly_media_saver/services/connectivity/connectivity_service.dart';
import 'package:quietly_media_saver/services/connectivity/connectivity_service_provider.dart';
import 'package:quietly_media_saver/services/permissions/permission_result_mapper.dart';
import 'package:quietly_media_saver/services/permissions/permission_service.dart';
import 'package:quietly_media_saver/services/permissions/permission_service_provider.dart';
import 'package:quietly_media_saver/services/preferences/preferences_service.dart';
import 'package:quietly_media_saver/services/preferences/preferences_service_provider.dart';
import 'package:quietly_media_saver/state/app_state.dart';
import 'package:quietly_media_saver/state/app_state_provider.dart';
import 'package:quietly_media_saver/state/error_config.dart';
import 'package:quietly_media_saver/state/models/app_enums.dart';
import 'package:quietly_media_saver/state/models/app_preferences.dart';

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
      // Clipboard card + primary CTA.
      expect(find.text('FROM YOUR CLIPBOARD'), findsOneWidget);
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

  group('Analyzing screen', () {
    testWidgets('auto-advances from Home → Analyzing → Result', (tester) async {
      _usePhoneViewport(tester);
      await tester.pumpWidget(const ProviderScope(child: QuietlyApp()));
      await tester.pumpAndSettle();

      // Start the flow.
      await tester.tap(find.text('Paste link'));
      await tester.pump(); // begin route push
      await tester.pump(const Duration(milliseconds: 400)); // settle transition

      // Analyzing is showing its explainer (QDots animates forever → no settle).
      expect(find.text('Reading this link'), findsOneWidget);

      // Advance past the simulated analysis; the controller completes and
      // auto-navigates to Result.
      await tester.pump(kAnalyzeDuration);
      await tester.pump(); // process navigation
      await tester.pump(const Duration(milliseconds: 400)); // settle transition

      expect(find.text('Available media'), findsOneWidget);
      expect(find.text('Save to gallery'), findsOneWidget);
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

  group('Download screen', () {
    testWidgets('renders the single-file ring state', (tester) async {
      _usePhoneViewport(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(appStateProvider.notifier).startDownload(const [
        MediaKind.video,
      ]);
      await _pumpScreen(tester, container, const DownloadingScreen());
      await tester.pump(
        const Duration(milliseconds: 50),
      ); // build; do NOT settle

      expect(find.text('Saving video…'), findsOneWidget);
    });

    testWidgets('renders the multi-item queue state', (tester) async {
      _usePhoneViewport(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(appStateProvider.notifier).startDownload(const [
        MediaKind.image,
        MediaKind.image,
        MediaKind.video,
      ]);
      await _pumpScreen(tester, container, const DownloadingScreen());
      await tester.pump(
        const Duration(milliseconds: 50),
      ); // build; do NOT settle

      expect(find.text('Saving 3 items'), findsOneWidget);
      expect(find.byType(QBar), findsWidgets);
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

  group('Permission save flow', () {
    Future<FakePermissionService> pumpAtResult(
      WidgetTester tester, {
      required PermissionStatus requestResult,
    }) async {
      final fake = FakePermissionService(requestResult: requestResult);
      final container = ProviderContainer(
        overrides: [permissionServiceProvider.overrideWithValue(fake)],
      );
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
      return fake;
    }

    testWidgets('Allow + granted → Download', (tester) async {
      _usePhoneViewport(tester);
      await pumpAtResult(tester, requestResult: PermissionStatus.granted);

      await tester.tap(find.text('Save to gallery'));
      await tester.pumpAndSettle(); // priming sheet in
      await tester.tap(find.text('Allow access'));
      await tester.pump(); // pop + request
      await tester.pump(const Duration(milliseconds: 400)); // settle nav
      expect(find.text('Saving video…'), findsOneWidget);
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
    }) async {
      final container = ProviderContainer(
        overrides: [
          connectivityServiceProvider.overrideWithValue(connectivity),
          preferencesServiceProvider.overrideWithValue(preferences),
          permissionServiceProvider.overrideWithValue(
            permission ?? FakePermissionService(),
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
