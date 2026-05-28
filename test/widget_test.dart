// Quietly — pass-2 widget + state + token tests.
//
// Covers the foundation (state machine, tokens) plus the pass-2 UI: Home boots
// and renders faithfully, the shared components behave + expose semantics, the
// Result quality row reflects state and opens the sheet, and Analyzing
// auto-advances to Result. Screens with infinite animations (Analyzing/QDots)
// are driven with explicit pump(Duration) rather than pumpAndSettle.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quietly_media_saver/app/quietly_app.dart';
import 'package:quietly_media_saver/core/theme/tokens/app_colors.dart';
import 'package:quietly_media_saver/core/widgets/q_button.dart';
import 'package:quietly_media_saver/core/widgets/q_media_tile.dart';
import 'package:quietly_media_saver/core/widgets/q_pill.dart';
import 'package:quietly_media_saver/features/analyzing/analyzing_screen.dart';
import 'package:quietly_media_saver/features/result/result_screen.dart';
import 'package:quietly_media_saver/state/app_state.dart';
import 'package:quietly_media_saver/state/app_state_provider.dart';
import 'package:quietly_media_saver/state/models/app_enums.dart';

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
