import 'dart:io';

import 'package:dogada_gezi/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('long province labels use a smaller readable card label size', () {
    expect(
      provinceCardLabelFontSize('Afyonkarahisar', compact: true),
      lessThan(provinceCardLabelFontSize('Adana', compact: true)),
    );
    expect(
      provinceCardLabelFontSize('Kahramanmaraş', compact: false),
      lessThanOrEqualTo(provinceCardLabelFontSize('Adana', compact: false)),
    );
  });

  test('copy text keeps coordinates in a paste-ready latitude longitude form',
      () {
    const place = Place(
      'Kopyalanabilir nokta',
      'Antalya',
      'Göl',
      4.5,
      Icons.water_rounded,
      [Color(0xFF0F5A35), Color(0xFF88B399)],
      null,
      latitude: 36.89689,
      longitude: 30.71332,
    );

    expect(placeCoordinatesForClipboard(place), '36.896890, 30.713320');
  });

  test('curated source uses the product name, never the database name', () {
    expect(AppStrings.get('source_supabase'), 'Doğadayım kaydı');
  });

  test('detail type summary uses the place category icon used across the app',
      () {
    final source = File('lib/src/features/detail.dart').readAsStringSync();

    expect(
      source,
      contains("stat(widget.place.icon, widget.place.kind,"),
    );
  });

  testWidgets('place card heart saves the place to user favorites',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    UserFavoritesController.favorites.value = <String>{};
    addTearDown(() => UserFavoritesController.favorites.value = <String>{});
    const place = Place(
      'Kalple kaydedilen yer',
      'Bolu',
      'Kamp',
      4.7,
      Icons.cabin_rounded,
      [Color(0xFF0F5A35), Color(0xFF88B399)],
      null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppCompactPlaceCard(place: place, onTap: () {}),
        ),
      ),
    );

    expect(find.byTooltip('Favorilere ekle'), findsOneWidget);
    await tester.tap(find.byTooltip('Favorilere ekle'));
    await tester.pump();

    expect(UserFavoritesController.isFavorite(place.name), isTrue);
    expect(find.byTooltip('Favorilerden çıkar'), findsOneWidget);
  });
}

