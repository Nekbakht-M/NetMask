@Tags(["screens"])
library;

// Renders key screens with the real fonts so the layout can be reviewed.
// Run: flutter test --update-goldens test/screens_test.dart  (images go to test/goldens/, not committed)
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netmask/main.dart';
import 'package:netmask/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _loadFont(String family, String path) async {
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
  await loader.load();
}

void main() {
  setUpAll(() async {
    await _loadFont('JetBrainsMono', 'assets/fonts/JetBrainsMono.ttf');
    await _loadFont('IBMPlexSans', 'assets/fonts/IBMPlexSans.ttf');
    await _loadFont('MaterialIcons',
        '${Platform.environment['FLUTTER_ROOT'] ?? '${Platform.environment['HOME']}/sdk/flutter'}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  });

  Future<void> pumpApp(WidgetTester t, Map<String, Object> prefs) async {
    t.view.physicalSize = const Size(360 * 3, 1400 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    SharedPreferences.setMockInitialValues(prefs);
    final s = await Settings.load();
    await t.pumpWidget(NetMaskApp(settings: s));
    await t.runAsync(() async {
      final ctx = t.element(find.byType(Scaffold).first);
      await precacheImage(const AssetImage('assets/brand/icon.png'), ctx);
    });
    await t.pumpAndSettle();
  }

  for (final lang in ['tj', 'ru']) {
    testWidgets('home ipv4 $lang', (t) async {
      await pumpApp(t, {'lang': lang, 'ip4': '192.168.1.1', 'p4': 30});
      await t.tap(find.byIcon(Icons.expand_more));
      await t.pumpAndSettle();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/home_v4_$lang.png'));
    });
  }

  testWidgets('home ipv6 light', (t) async {
    await pumpApp(t, {'lang': 'tj', 'dark': false, 'startV6': true});
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/home_v6_light.png'));
  });

  testWidgets('networks', (t) async {
    await pumpApp(t, {'lang': 'ru', 'ip4': '192.168.1.77', 'p4': 30});
    await t.tap(find.byIcon(Icons.lan_outlined));
    await t.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/networks.png'));
  });

  testWidgets('settings', (t) async {
    await pumpApp(t, {'lang': 'tj'});
    await t.tap(find.byIcon(Icons.settings_outlined));
    await t.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/settings.png'));
  });

  testWidgets('auto dots in field', (t) async {
    await pumpApp(t, {'lang': 'en', 'ip4': ''});
    await t.enterText(find.byType(TextField).first, '192168');
    await t.pump();
    expect(find.text('192.168.'), findsOneWidget);
  });
}
