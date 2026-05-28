// Quietly — shell pass smoke + state + token tests.
//
// Verifies the foundation built in pass 1: the app boots to Home, the AppState
// machine transitions correctly, and design tokens carry the handoff values.
// These are intentionally lightweight; richer screen tests arrive with the UI.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quietly_media_saver/app/quietly_app.dart';
import 'package:quietly_media_saver/core/theme/tokens/app_colors.dart';
import 'package:quietly_media_saver/state/app_state.dart';
import 'package:quietly_media_saver/state/app_state_provider.dart';
import 'package:quietly_media_saver/state/models/app_enums.dart';

void main() {
  group('App shell', () {
    testWidgets('boots to Home', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: QuietlyApp()));
      await tester.pumpAndSettle();

      // Home shows the brand app-bar title and its hero copy.
      expect(find.text('Quietly'), findsOneWidget);
      expect(find.text('Paste a link to get started.'), findsOneWidget);
      // Rights-aware positioning is present on Home.
      expect(
        find.textContaining('Save only content you have the rights to'),
        findsOneWidget,
      );
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
      notifier().startDownload(
        const [MediaKind.image, MediaKind.image, MediaKind.video],
      );
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
