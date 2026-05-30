// ─────────────────────────────────────────────────────────────
// Quietly — integration_test screenshot driver.
//
// Receives screenshot bytes from integration_test/store_screenshots_test.dart and
// writes them as PNGs into docs/store-assets/screenshots/. Debug/test-only.
//
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/store_screenshots_test.dart \
//     -d <device-id>
// ─────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (
      String name,
      List<int> bytes, [
      Map<String, Object?>? args,
    ]) async {
      final file = File('docs/store-assets/screenshots/$name.png');
      file.parent.createSync(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}
