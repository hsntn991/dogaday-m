import 'dart:io';

import 'package:dogada_gezi/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mobile service hub preserves the original, icon-led service layout',
      () {
    final source =
        File('lib/src/features/mobile_service.dart').readAsStringSync();

    expect(source, contains("emoji: '🚛'"));
    expect(source, contains('item.emoji,'));
    expect(source, contains('const itemHeight = 138.0'));
    expect(source, contains('BorderRadius.circular(16)'));
    expect(source, contains('boxShadow: ['));
    expect(source, contains("label: Text('\${item.emoji} \${item.title}')"));
  });

  test('service submission does not promise instant publication', () {
    final source =
        File('lib/src/features/mobile_service.dart').readAsStringSync();

    expect(source, contains('Başvuruyu incelemeye gönder'));
    expect(source, isNot(contains('Firmayı Kaydet ve Haritada Yayınla')));
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
