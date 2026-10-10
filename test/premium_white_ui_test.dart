import 'dart:io';

import 'package:dogada_gezi/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('premium light palette uses the approved neutral colors', () {
    expect(AppColors.background, const Color(0xFFFFFFFF));
    expect(AppColors.surface, const Color(0xFFFFFFFF));
    expect(AppColors.surfaceMuted, const Color(0xFFF5F6F4));
    expect(AppColors.border, const Color(0xFFE5E7E5));
    expect(AppColors.primary, const Color(0xFF173F32));
    expect(AppColors.textPrimary, const Color(0xFF202420));
    expect(AppColors.textSecondary, const Color(0xFF747A75));
  });

  testWidgets('shared section divider follows the premium border token',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppSectionDivider()));

    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.thickness, 1);
    expect(divider.color, AppColors.border);
  });

  testWidgets('province cards keep both rows fully visible on phone widths',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    for (final width in [320.0, 375.0, 430.0, 497.0]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FigmaHomeScreen(
              onOpen: (_) {},
              onSearch: () {},
              onMessages: () {},
              onExploreProvince: (_) {},
            ),
          ),
        ),
      );

      final gridSize = tester.getSize(find.byType(GridView).first);
      final availableWidth = width - 32;
      final cardWidth = (availableWidth - 10) / 2;
      final expectedHeight = cardWidth / 1.62 * 2 + 10;
      expect(gridSize.height, closeTo(expectedHeight, .1),
          reason: '${width.toInt()}px');
      expect(tester.takeException(), isNull, reason: '${width.toInt()}px');
    }
  });

  test('selected map panel reserves room for its handle and divider', () {
    final map = File('lib/src/features/search_map.dart').readAsStringSync();

    expect(map, contains('selectedPlace == null ? 0.0 : 248.0'));
  });
}
