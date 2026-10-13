import 'dart:io';

import 'package:dogada_gezi/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mobile service hub uses stable vector icons instead of device emojis',
      () {
    final source =
        File('lib/src/features/mobile_service.dart').readAsStringSync();

    expect(source, isNot(contains("emoji: '🚛'")));
    expect(source, isNot(contains('item.emoji,')));
    expect(source, contains('Icon('));
    expect(source, contains('item.icon,'));
    expect(source, contains('const itemHeight = 138.0'));
    expect(source, contains('BorderRadius.circular(16)'));
    expect(source, contains('boxShadow: ['));
    expect(source, contains("label: Text(item.title)"));
  });

  test('service submission does not promise instant publication', () {
    final source =
        File('lib/src/features/mobile_service.dart').readAsStringSync();

    expect(source, contains('Başvuruyu incelemeye gönder'));
    expect(source, isNot(contains('Firmayı Kaydet ve Haritada Yayınla')));
  });

  test('service tiles take their border and text colors from design tokens',
      () {
    final source =
        File('lib/src/features/mobile_service.dart').readAsStringSync();

    expect(source, isNot(contains('Color(0xFFE2E8F0)')));
    expect(source, isNot(contains('Color(0xFF1E293B)')));
  });

  testWidgets('mobile service hub remains overflow-free on phone widths',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;

    for (final width in [320.0, 375.0, 430.0]) {
      tester.view.physicalSize = Size(width, 800);
      await tester
          .pumpWidget(const MaterialApp(home: MobileServiceHubScreen()));
      expect(tester.takeException(), isNull, reason: '${width.toInt()}px');
    }
  });
}
