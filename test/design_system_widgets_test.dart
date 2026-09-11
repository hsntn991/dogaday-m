import 'package:dogada_gezi/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('profile edit button fits a row with full-width button theme',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final width in [320.0, 390.0, 430.0, 1280.0]) {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(AppControlSizes.button),
            ),
          ),
        ),
        home: Scaffold(body: FigmaProfileScreen(onOpen: (_) {})),
      ));
      expect(tester.takeException(), isNull, reason: '${width.toInt()}px');
      expect(
          tester
              .getSize(find.widgetWithText(OutlinedButton, 'Profili Düzenle'))
              .width,
          lessThan(width - 124));
    }
  });

  testWidgets('primary button disables interaction when its callback is absent',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppPrimaryButton(label: 'Keşfe başla'),
        ),
      ),
    );

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('category chip exposes its selected state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppCategoryChip(
            label: 'Kamp',
            icon: Icons.terrain_outlined,
            selected: true,
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byType(AppCategoryChip)),
      matchesSemantics(
        label: 'Kamp',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
      ),
    );
  });

  testWidgets('compact place card presents real place metadata',
      (tester) async {
    const place = Place(
      'Test Doğa Noktası',
      'Antalya',
      'Şelale',
      4.8,
      Icons.waterfall_chart_rounded,
      [Color(0xFF0F5A35), Color(0xFF88B399)],
      null,
      distanceKm: 2.4,
      description: 'Gerçek kaynaktan gelen açıklama.',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppCompactPlaceCard(place: place, onTap: () {}),
        ),
      ),
    );

    expect(find.text('Test Doğa Noktası'), findsOneWidget);
    expect(find.text('2,4 km'), findsOneWidget);
    expect(find.byTooltip('Kaydet'), findsOneWidget);
  });

  testWidgets('place thumbnail uses a quiet fallback when no photo exists',
      (tester) async {
    const place = Place(
      'Fotoğrafsız nokta',
      'Bolu',
      'Göl',
      0,
      Icons.landscape_outlined,
      [Color(0xFF0F5A35), Color(0xFF88B399)],
      null,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppPlaceThumbnail(place: place)),
      ),
    );

    expect(find.byType(AppPlaceThumbnail), findsOneWidget);
    expect(find.byType(NatureArt), findsNothing);
  });

  testWidgets('shared place card family handles long text and absent metadata',
      (tester) async {
    const place = Place(
      'Oldukça uzun bir doğa noktası adı dar ekranlarda taşmamalıdır',
      'Bolu',
      'Göl',
      0,
      Icons.water_outlined,
      [Color(0xFF287890), Color(0xFF8DD1C9)],
      null,
      description:
          'Uzun açıklama metni kart geometrisini bozmadan güvenli biçimde kesilmelidir.',
    );

    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(
                width: 288,
                height: 220,
                child: AppPlaceHeroCard(place: place, onTap: () {}),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 288,
                child: AppMapPreviewCard(place: place, onTap: () {}),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(AppPlaceHeroCard), findsOneWidget);
    expect(find.byType(AppMapPreviewCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home header remains free of layout errors on narrow phones',
      (tester) async {
    for (final width in [320.0, 360.0, 375.0, 390.0, 412.0, 430.0]) {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FigmaHomeScreen(
              onOpen: (_) {},
              onSearch: () {},
              onMessages: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '${width.toInt()}px');
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
