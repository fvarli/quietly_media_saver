// Quietly — widget + state + token tests (passes 1–4).
//
// Covers the foundation (state machine, tokens), the pass-2 UI (Home, Analyzing
// auto-advance, Result, components), the pass-3 UI (Carousel, Download, Success),
// and the pass-4 UI (History grouped/empty, Settings sections, all Error configs,
// error CTA routing). Screens with running animations (Analyzing/Download
// controllers, QDots) are driven with explicit pump(Duration), not pumpAndSettle;
// long lazy lists are scrolled with scrollUntilVisible.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:quietly_media_saver/state/app_state.dart';
import 'package:quietly_media_saver/state/app_state_provider.dart';
import 'package:quietly_media_saver/state/error_config.dart';
import 'package:quietly_media_saver/state/models/app_enums.dart';

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
      AppErrorKind kind,
    ) async {
      final container = ProviderContainer();
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

    testWidgets('permanently-denied Open settings shows a placeholder', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      await pumpAtError(tester, AppErrorKind.permissionDeniedPermanently);
      await tester.tap(find.text('Open settings'));
      await tester.pump(); // show SnackBar
      expect(find.textContaining('permissions support'), findsOneWidget);
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
