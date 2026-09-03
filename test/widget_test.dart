import 'dart:convert';
import 'dart:io';

import 'package:dogada_gezi/main.dart';
import 'package:dogada_gezi/services/place_photo_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Place duplicateFixture({
    String name = 'Araplar Çeşmesi',
    String kind = 'Su Kaynağı',
    double latitude = 39.9200,
    double longitude = 32.8500,
  }) =>
      Place(
        name,
        'Ankara',
        kind,
        0,
        Icons.place_rounded,
        const [Color(0xFF315F45), Color(0xFF9BBF82)],
        null,
        description: 'Temiz suya ulaşılabilen doğal bir çeşme noktasıdır.',
        latitude: latitude,
        longitude: longitude,
        sourceId: 'duplicate-fixture-$name',
      );

  test('empty place name is rejected', () {
    final result = AddPlaceQualityService.validate(
      name: '   ',
      category: 'Su Kaynağı',
      description: 'Bu doğal nokta hakkında yeterince açıklayıcı bir metin.',
      latitude: 39.92,
      longitude: 32.85,
    );
    expect(result.errors['name'], isNotNull);
    expect(result.isValid, isFalse);
  });

  test('invalid coordinates are rejected', () {
    expect(AddPlaceQualityService.isValidCoordinate(0, 0), isFalse);
    expect(AddPlaceQualityService.isValidCoordinate(91, 32), isFalse);
    expect(AddPlaceQualityService.isValidCoordinate(39.92, 32.85), isTrue);
  });

  test('same name and very close coordinates are a strong duplicate', () {
    final result = AddPlaceQualityService.assessDuplicates(
      name: 'Araplar Çeşmesi',
      category: 'Su Kaynağı',
      latitude: 39.9204,
      longitude: 32.8503,
      existingPlaces: [duplicateFixture()],
    );
    expect(result.level, PlaceDuplicateLevel.strong);
    expect(result.strongMatch?.place.name, 'Araplar Çeşmesi');
  });

  test('case punctuation and excess whitespace cannot bypass duplicate check',
      () {
    final result = AddPlaceQualityService.assessDuplicates(
      name: '  ARAPLAR...   ÇEŞMESİ  ',
      category: 'Su Kaynağı',
      latitude: 39.9204,
      longitude: 32.8503,
      existingPlaces: [duplicateFixture()],
    );
    expect(AddPlaceQualityService.normalizeName(' ARAPLAR ÇEŞMESİ '),
        'araplar cesmesi');
    expect(result.level, PlaceDuplicateLevel.strong);
  });

  test('same name sufficiently far away is accepted as new', () {
    final result = AddPlaceQualityService.assessDuplicates(
      name: 'Araplar Çeşmesi',
      category: 'Su Kaynağı',
      latitude: 39.94,
      longitude: 32.85,
      existingPlaces: [duplicateFixture()],
    );
    expect(result.level, PlaceDuplicateLevel.none);
  });

  test('nearby similar place produces a probable duplicate warning', () {
    final result = AddPlaceQualityService.assessDuplicates(
      name: 'Araplar Su Noktası',
      category: 'Su Kaynağı',
      latitude: 39.9215,
      longitude: 32.8505,
      existingPlaces: [duplicateFixture()],
    );
    expect(result.level, PlaceDuplicateLevel.probable);
    expect(result.probableMatches, isNotEmpty);
  });

  test('valid new place is persisted in the local store', () async {
    SharedPreferences.setMockInitialValues({});
    UserPlacesController.places.value = const [];
    final place = duplicateFixture(
      name: 'Yeni Test Pınarı',
      latitude: 40.1,
      longitude: 33.1,
    );

    await UserPlacesController.add(place);
    UserPlacesController.places.value = const [];
    await UserPlacesController.load();

    expect(UserPlacesController.places.value, hasLength(1));
    expect(UserPlacesController.places.value.single.name, 'Yeni Test Pınarı');
  });

  test('user source and unverified status survive local-store reload',
      () async {
    SharedPreferences.setMockInitialValues({});
    UserPlacesController.places.value = const [];
    final place = Place(
      'Doğrulama Test Noktası',
      'Ankara',
      'Seyir Noktası',
      0,
      Icons.place_rounded,
      const [Color(0xFF315F45), Color(0xFF9BBF82)],
      null,
      description:
          'Topluluk tarafından eklenen yeterli açıklamaya sahip nokta.',
      latitude: 39.91,
      longitude: 32.81,
      sourceId: 'user-verification-persistence',
      source: PlaceSource.user,
      verificationStatus: VerificationStatus.unverified,
    );

    await UserPlacesController.add(place);
    UserPlacesController.places.value = const [];
    await UserPlacesController.load();

    final restored = UserPlacesController.places.value.single;
    expect(restored.source, PlaceSource.user);
    expect(restored.verificationStatus, VerificationStatus.unverified);
  });

  test('legacy local record without trust fields migrates safely', () async {
    SharedPreferences.setMockInitialValues({
      'user_added_places_v1': [
        jsonEncode({
          'name': 'Eski Yer Kaydı',
          'location': 'Ankara',
          'kind': 'Göl',
          'description': 'Eski sürümden kalan açıklama.',
          'latitude': 39.9,
          'longitude': 32.8,
          'sourceId': 'legacy-user-place',
        }),
      ],
    });

    await UserPlacesController.load();

    final restored = UserPlacesController.places.value.single;
    expect(restored.source, PlaceSource.user);
    expect(restored.verificationStatus, VerificationStatus.unverified);
  });

  test('Overpass parser marks remote place as OpenStreetMap data', () {
    final parsed = NearbyPlacesService.parseOverpassElements(
      [
        {
          'type': 'node',
          'id': 42,
          'lat': 39.92,
          'lon': 32.85,
          'tags': {'name': 'OSM Test Pınarı', 'natural': 'spring'},
        },
      ],
      39.92,
      32.85,
      'Ankara',
    );

    expect(parsed.single.source, PlaceSource.osm);
    expect(parsed.single.verificationStatus, VerificationStatus.community);
  });

  testWidgets('rapid save taps create only one local place', (tester) async {
    SharedPreferences.setMockInitialValues({});
    UserPlacesController.places.value = const [];
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: AddPlaceScreen()));
    await tester.enterText(
      find.byType(TextField).at(0),
      'Tekil Kayıt Test Gölü',
    );
    await tester.enterText(
      find.byType(TextField).at(1),
      'Sakin kıyısı ve temiz çevresi bulunan doğal bir test gölüdür.',
    );
    await tester.ensureVisible(find.text('Göl').first);
    await tester.tap(find.text('Göl').first);
    await tester.ensureVisible(find.text('Konum Seç *'));
    await tester.tap(find.text('Konum Seç *'));
    await tester.pump();

    final map = tester.widget<FlutterMap>(find.byType(FlutterMap));
    map.options.onTap!(
      const TapPosition(Offset.zero, Offset.zero),
      const LatLng(39.5, 34.5),
    );
    await tester.pump();
    expect(find.textContaining('39.50000'), findsOneWidget);

    final saveButton = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Gönder'),
        matching: find.byType(FilledButton),
      ),
    );
    saveButton.onPressed!.call();
    saveButton.onPressed!.call();
    await tester.pumpAndSettle();

    expect(
      UserPlacesController.places.value
          .where((place) => place.name == 'Tekil Kayıt Test Gölü'),
      hasLength(1),
    );
    final saved = UserPlacesController.places.value
        .singleWhere((place) => place.name == 'Tekil Kayıt Test Gölü');
    expect(saved.source, PlaceSource.user);
    expect(saved.verificationStatus, VerificationStatus.unverified);
  });

  testWidgets('user place detail shows community and unverified trust state',
      (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final place = Place(
      'Topluluk Detay Testi',
      'Ankara',
      'Su Kaynağı',
      0,
      Icons.place_rounded,
      const [Color(0xFF315F45), Color(0xFF9BBF82)],
      null,
      description: 'Topluluk tarafından eklenen test doğa noktası.',
      latitude: 39.92,
      longitude: 32.85,
      sourceId: 'user-detail-test',
      source: PlaceSource.user,
      verificationStatus: VerificationStatus.unverified,
    );

    await tester.pumpWidget(MaterialApp(
      home: DetailScreen(
        place: place,
        favorite: false,
        onFavorite: () {},
      ),
    ));

    expect(find.text('Topluluk katkısı'), findsWidgets);
    expect(find.text('Henüz incelenmedi'), findsOneWidget);
    expect(
      find.textContaining('Gitmeden önce yol ve erişim koşullarını kontrol et'),
      findsOneWidget,
    );
  });

  testWidgets('OSM detail never shows user verification labels',
      (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final place = Place(
      'OSM Detay Testi',
      'Ankara',
      'Su Kaynağı',
      0,
      Icons.place_rounded,
      const [Color(0xFF315F45), Color(0xFF9BBF82)],
      null,
      description: 'OpenStreetMap kaynağından gelen test doğa noktası.',
      latitude: 39.92,
      longitude: 32.85,
      sourceId: 'osm:node:detail-test',
      source: PlaceSource.osm,
      verificationStatus: VerificationStatus.community,
    );

    await tester.pumpWidget(MaterialApp(
      home: DetailScreen(
        place: place,
        favorite: false,
        onFavorite: () {},
      ),
    ));

    expect(find.text('OpenStreetMap verisi'), findsOneWidget);
    expect(find.text('Topluluk katkısı'), findsNothing);
    expect(find.text('Henüz doğrulanmadı'), findsNothing);
  });

  test('Overpass radius and total wait are bounded', () {
    expect(NearbyPlacesService.queryRadiusMeters, 25000);
    expect(NearbyPlacesService.queryRadiusKm, 25);
    expect(NearbyPlacesService.queryRadiusMeters, lessThan(100000));
    expect(
      NearbyPlacesService.maxOverpassDuration,
      lessThanOrEqualTo(const Duration(seconds: 10)),
    );
  });

  test('near coordinates share a cache region', () {
    const first = WeatherTarget.coordinates(
      latitude: 39.921,
      longitude: 32.851,
      label: 'Ankara 1',
    );
    const nearby = WeatherTarget.coordinates(
      latitude: 39.923,
      longitude: 32.858,
      label: 'Ankara 2',
    );
    expect(
      NearbyPlacesService.cacheRegionKey(first),
      NearbyPlacesService.cacheRegionKey(nearby),
    );
  });

  test('meaningfully different coordinates use a new cache region', () {
    const ankara = WeatherTarget.coordinates(
      latitude: 39.921,
      longitude: 32.851,
      label: 'Ankara',
    );
    const bolu = WeatherTarget.coordinates(
      latitude: 40.735,
      longitude: 31.606,
      label: 'Bolu',
    );
    expect(
      NearbyPlacesService.cacheRegionKey(ankara),
      isNot(NearbyPlacesService.cacheRegionKey(bolu)),
    );
  });

  test('local places are returned without waiting for Overpass', () async {
    const latitude = 39.9208;
    const longitude = 32.8541;
    final localPlace = Place(
      'Local test çeşmesi',
      'Ankara',
      'Su Kaynağı',
      0,
      Icons.place_rounded,
      const [Color(0xFF315F45), Color(0xFF9BBF82)],
      null,
      latitude: latitude,
      longitude: longitude,
      sourceId: 'local-first-test',
      updatedAt: DateTime(2026, 8, 16),
    );
    UserPlacesController.places.value = [localPlace];

    final stopwatch = Stopwatch()..start();
    final result = await NearbyPlacesService.fetch(
      const WeatherTarget.coordinates(
        latitude: latitude,
        longitude: longitude,
        label: 'Test konumu',
      ),
    );
    stopwatch.stop();

    expect(result.any((place) => place.sourceId == 'local-first-test'), isTrue);
    expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 250)));
  });

  test('local places remain available independently of remote refresh',
      () async {
    final localPlace = Place(
      'Offline local çeşme',
      'Ankara',
      'Su Kaynağı',
      0,
      Icons.place_rounded,
      const [Color(0xFF315F45), Color(0xFF9BBF82)],
      null,
      latitude: 39.92,
      longitude: 32.85,
      sourceId: 'offline-local-test',
    );
    UserPlacesController.places.value = [localPlace];
    const offlineTarget = WeatherTarget.city('geçersiz-test-konumu');

    final initial = await NearbyPlacesService.fetch(offlineTarget);
    final stillAvailable = NearbyPlacesService.availableNow(offlineTarget);

    expect(
        initial.any((place) => place.sourceId == 'offline-local-test'), isTrue);
    expect(
        stillAvailable.any((place) => place.sourceId == 'offline-local-test'),
        isTrue);
  });

  testWidgets('home state is preserved and map stays lazy', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.pump();
    await tester.tap(find.text('Şimdi Değil'));
    await tester.pump();

    expect(find.byType(FlutterMap), findsNothing);

    await tester.tap(find.text('Su').first);
    await tester.pump();
    expect(find.text('Yakındaki Su'), findsOneWidget);
    expect(find.text('25 km içinde'), findsOneWidget);

    await tester.tap(find.text('Harita'));
    await tester.pump();
    expect(find.byType(FlutterMap), findsOneWidget);

    await tester.tap(find.text('Keşfet'));
    await tester.pump();
    expect(find.text('Yakındaki Su'), findsOneWidget);
  });

  testWidgets('local cards render without a large section spinner',
      (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    UserPlacesController.places.value = [
      Place(
        'Anında görünen çeşme',
        'Ankara',
        'Su Kaynağı',
        0,
        Icons.place_rounded,
        const [Color(0xFF315F45), Color(0xFF9BBF82)],
        null,
        latitude: 39.92,
        longitude: 32.85,
        sourceId: 'instant-home-card',
      ),
    ];
    HomeWeatherLocationController.useDeviceCoordinates(
      latitude: 39.92,
      longitude: 32.85,
      label: 'Test konumu',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body:
            FigmaHomeScreen(onOpen: (_) {}, onSearch: () {}, onMessages: () {}),
      ),
    ));
    await tester.pump();

    expect(find.text('Anında görünen çeşme'), findsWidgets);
  });

  testWidgets('weather hides stale current-location data while resolving',
      (tester) async {
    HomeWeatherLocationController.useDeviceCoordinates(
      latitude: 39.92,
      longitude: 32.85,
      label: 'Mevcut konum',
    );
    HomeWeatherLocationController.isResolvingLocation.value = true;
    addTearDown(() {
      HomeWeatherLocationController.isResolvingLocation.value = false;
    });

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body:
            FigmaHomeScreen(onOpen: (_) {}, onSearch: () {}, onMessages: () {}),
      ),
    ));

    expect(find.text('Konum belirleniyor'), findsOneWidget);
    expect(find.text('MEVCUT KONUM  •  ŞU AN'), findsNothing);
  });

  testWidgets('empty nearby and latest sections expose useful actions',
      (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    UserPlacesController.places.value = const [];
    HomeWeatherLocationController.useManualCity('UX boş durum test bölgesi');
    var mapOpened = false;
    var addOpened = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FigmaHomeScreen(
          onOpen: (_) {},
          onSearch: () {},
          onMessages: () {},
          onExploreMap: () => mapOpened = true,
          onAddPlace: () => addOpened = true,
        ),
      ),
    ));
    await tester.pump();

    await tester.tap(find.text('Haritada keşfet').first);
    await tester.tap(find.text('İlk yeri sen ekle'));
    expect(mapOpened, isTrue);
    expect(addOpened, isTrue);
    expect(find.text('Tekrar dene'), findsWidgets);
  });

  test('selected map place closes only outside the expanded viewport', () {
    final bounds = LatLngBounds(
      const LatLng(39.8, 32.7),
      const LatLng(40.0, 33.0),
    );

    expect(
      isPlaceMeaningfullyNearViewport(const LatLng(39.9, 32.85), bounds),
      isTrue,
    );
    expect(
      isPlaceMeaningfullyNearViewport(const LatLng(40.05, 33.05), bounds),
      isTrue,
    );
    expect(
      isPlaceMeaningfullyNearViewport(const LatLng(41.0, 35.0), bounds),
      isFalse,
    );
  });

  group('deterministic recommendation engine', () {
    Place recommendationPlace({
      required String name,
      double? distanceKm,
      String kind = 'Yürüyüş',
      double rating = 4.5,
      PlaceSource source = PlaceSource.osm,
      VerificationStatus status = VerificationStatus.community,
    }) =>
        Place(
          name,
          'Ankara',
          kind,
          rating,
          Icons.place,
          const [Colors.green, Colors.lightGreen],
          null,
          distanceKm: distanceKm,
          source: source,
          verificationStatus: status,
        );

    WeatherSnapshot weather(int code) => WeatherSnapshot(
          resolvedLocation: 'Ankara',
          temperature: 20,
          apparentTemperature: 20,
          humidity: 50,
          windSpeed: 8,
          visibilityKm: 10,
          uvIndex: 3,
          minimumTemperature: 14,
          maximumTemperature: 24,
          weatherCode: code,
          isDay: true,
        );

    test('closer otherwise equal place ranks higher', () {
      final ranked = RecommendationService.rank(places: [
        recommendationPlace(name: 'Uzak rota', distanceKm: 20),
        recommendationPlace(name: 'Yakın rota', distanceKm: 3),
      ]);
      expect(ranked.first.place.name, 'Yakın rota');
      expect(ranked.first.score, greaterThan(ranked.last.score));
    });

    test('bad weather lowers an outdoor place score', () {
      final place =
          recommendationPlace(name: 'Açık hava rotası', distanceKm: 5);
      final clear = RecommendationService.score(place, weather: weather(0));
      final storm = RecommendationService.score(place, weather: weather(95));
      expect(clear.score, greaterThan(storm.score));
    });

    test('recommendations continue without weather or optional place data', () {
      final result = RecommendationService.rank(places: [
        recommendationPlace(
          name: 'Eksik verili yer',
          distanceKm: 8,
          rating: 0,
        ),
      ]);
      expect(result, hasLength(1));
      expect(result.single.score, inInclusiveRange(0, 100));
    });

    test('verified content gets a small trust advantage', () {
      final verified = recommendationPlace(
        name: 'Doğrulanmış',
        distanceKm: 8,
        source: PlaceSource.curated,
        status: VerificationStatus.verified,
      );
      final unverified = recommendationPlace(
        name: 'Doğrulanmamış',
        distanceKm: 8,
        source: PlaceSource.user,
        status: VerificationStatus.unverified,
      );
      expect(
        RecommendationService.score(verified).score,
        greaterThan(RecommendationService.score(unverified).score),
      );
    });

    test('unverified content remains in recommendation results', () {
      final result = RecommendationService.rank(places: [
        recommendationPlace(
          name: 'Topluluk kaydı',
          distanceKm: 4,
          source: PlaceSource.user,
          status: VerificationStatus.unverified,
        ),
      ]);
      expect(result.single.place.name, 'Topluluk kaydı');
    });

    test('scores are clamped and identical inputs sort deterministically', () {
      final input = [
        recommendationPlace(name: 'B rotası', distanceKm: 6),
        recommendationPlace(name: 'A rotası', distanceKm: 6),
      ];
      final first = RecommendationService.rank(places: input);
      final second = RecommendationService.rank(places: input);
      expect(first.map((item) => item.place.name),
          second.map((item) => item.place.name));
      expect(
          first.every((item) => item.score >= 0 && item.score <= 100), isTrue);
      expect(first.first.place.name, 'A rotası');
    });

    test('missing location falls back to rating and trust factors', () {
      final result = RecommendationService.rank(
        places: [
          recommendationPlace(name: 'Popüler keşif', rating: 4.9),
          recommendationPlace(name: 'Diğer keşif', rating: 4.0),
        ],
        hasUserLocation: false,
      );
      expect(result, hasLength(2));
      expect(result.first.place.name, 'Popüler keşif');
    });
  });

  group('persistent user place photos', () {
    const onePixelPng =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

    test('picked photo is copied and survives local-store reload', () async {
      SharedPreferences.setMockInitialValues({});
      final temporary =
          await Directory.systemTemp.createTemp('place-photo-test');
      addTearDown(() {
        try {
          if (temporary.existsSync()) temporary.deleteSync(recursive: true);
        } catch (_) {
          // Windows görsel çözücüsü dosyayı kısa süre kilitli tutabilir.
        }
      });
      final pickedFile =
          File('${temporary.path}${Platform.pathSeparator}picker.png');
      await pickedFile.writeAsBytes(base64Decode(onePixelPng));
      final persistentPath = await PlacePhotoStorage.persistPrimaryPhoto(
        XFile(pickedFile.path),
        'photo-place',
        directoryOverride: temporary.path,
      );
      expect(persistentPath, isNot(pickedFile.path));
      expect(File(persistentPath).existsSync(), isTrue);

      final place = Place(
        'Fotoğraflı Yer',
        'Ankara',
        'Su Kaynağı',
        0,
        Icons.water_drop,
        const [Colors.green, Colors.lightGreen],
        persistentPath,
        latitude: 39.92,
        longitude: 32.85,
        sourceId: 'photo-place',
        source: PlaceSource.user,
        verificationStatus: VerificationStatus.unverified,
      );
      UserPlacesController.places.value = const [];
      await UserPlacesController.add(place);
      UserPlacesController.places.value = const [];
      await UserPlacesController.load();
      expect(UserPlacesController.places.value.single.image, persistentPath);
    });

    testWidgets('photo-less and missing-file places use safe placeholder',
        (tester) async {
      Place place(String? image) => Place(
            'Görselsiz Yer',
            'Ankara',
            'Göl',
            0,
            Icons.landscape,
            const [Colors.green, Colors.lightGreen],
            image,
          );

      await tester.pumpWidget(MaterialApp(
        home: SizedBox(
            width: 200, height: 200, child: NatureArt(place: place(null))),
      ));
      expect(find.byIcon(Icons.landscape), findsOneWidget);

      await tester.pumpWidget(MaterialApp(
        home: SizedBox(
          width: 200,
          height: 200,
          child: NatureArt(place: place('Z:\\missing\\photo.jpg')),
        ),
      ));
      expect(find.byIcon(Icons.landscape), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('recommendation and nearby cards share the user photo renderer',
        () async {
      final temporary =
          await Directory.systemTemp.createTemp('home-photo-test');
      addTearDown(() {
        try {
          if (temporary.existsSync()) temporary.deleteSync(recursive: true);
        } catch (_) {
          // Windows görsel çözücüsü dosyayı kısa süre kilitli tutabilir.
        }
      });
      final image = File('${temporary.path}${Platform.pathSeparator}photo.png');
      await image.writeAsBytes(base64Decode(onePixelPng));
      final place = Place(
        'Ortak Fotoğraflı Yer',
        'Ankara',
        'Su Kaynağı',
        4.7,
        Icons.water_drop,
        const [Colors.green, Colors.lightGreen],
        image.path,
        latitude: 39.92,
        longitude: 32.85,
        distanceKm: 1,
        sourceId: 'shared-photo-renderer',
        source: PlaceSource.user,
        verificationStatus: VerificationStatus.unverified,
      );

      final recommendationProvider = PlaceImage.resolveProvider(place);
      final nearbyProvider = PlaceImage.resolveProvider(place);
      expect(recommendationProvider, isA<FileImage>());
      expect(nearbyProvider, isA<FileImage>());
      expect(
        (recommendationProvider! as FileImage).file.path,
        (nearbyProvider! as FileImage).file.path,
      );
    });
  });

  group('central place taxonomy and facilities', () {
    test('legacy categories resolve into the eight-category taxonomy', () {
      expect(taxonomyFromLegacy('Şelale').mainCategory, 'water');
      expect(taxonomyFromLegacy('Şelale').subtype, 'waterfall');
      expect(taxonomyFromLegacy('Tabiat Parkı').mainCategory, 'nature_area');
      expect(taxonomyFromLegacy('Tabiat Parkı').subtype, 'nature_park');
      expect(placeTaxonomy.length, 8);
    });

    test('WC and drinking water remain separate utility layers', () {
      final toilet = duplicateFixture(kind: 'WC');
      final drinkingWater = duplicateFixture(kind: 'İçme Suyu');
      expect(toilet.isUtility, isTrue);
      expect(drinkingWater.isUtility, isTrue);
      expect(toilet.resolvedTaxonomy.mainCategory, isNull);
      expect(drinkingWater.resolvedTaxonomy.mainCategory, isNull);
    });

    test('facility unknown, false and true values remain distinct', () {
      final facilities = PlaceFacilities.fromJson({
        'toilets': true,
        'drinking_water': false,
        'parking': null,
        'nearby_shower': true,
        'nearby_shower_distance_m': 240,
      });
      expect(facilities.values['toilets'], isTrue);
      expect(facilities.values['drinking_water'], isFalse);
      expect(facilities.values['parking'], isNull);
      expect(facilities.nearbyDistances['nearby_shower'], 240);
    });
  });

  group('place enrichment photo policy', () {
    test('Pixabay primary requires A or B identity and Q1 quality', () {
      const approved = PlacePhotoInfo(
        url: 'https://example.test/approved.jpg',
        source: 'Pixabay',
        identityGrade: 'A',
        qualityGrade: 'Q1',
      );
      const manualReview = PlacePhotoInfo(
        url: 'https://example.test/review.jpg',
        source: 'Pixabay',
        identityGrade: 'C',
        qualityGrade: 'Q1',
      );
      const galleryOnly = PlacePhotoInfo(
        url: 'https://example.test/gallery.jpg',
        source: 'Pixabay',
        identityGrade: 'B',
        qualityGrade: 'Q2',
      );

      expect(PlacePhotoPolicy.primaryEligible(approved), isTrue);
      expect(PlacePhotoPolicy.galleryEligible(manualReview), isFalse);
      expect(PlacePhotoPolicy.galleryEligible(galleryOnly), isTrue);
      expect(PlacePhotoPolicy.primaryEligible(galleryOnly), isFalse);
    });

    test('direct media stays ahead of Commons, Pixabay and other sources', () {
      const direct = PlacePhotoInfo(
        url: 'https://example.test/direct.jpg',
        source: 'Wikimedia Commons',
        matchMethod: 'direct',
      );
      const commons = PlacePhotoInfo(
        url: 'https://example.test/commons.jpg',
        source: 'Wikimedia Commons',
      );
      const pixabay = PlacePhotoInfo(
        url: 'https://example.test/pixabay.jpg',
        source: 'Pixabay',
        identityGrade: 'A',
        qualityGrade: 'Q1',
      );

      expect(
        PlacePhotoPolicy.ordered([pixabay, commons, direct]).first.url,
        direct.url,
      );
    });
  });

  testWidgets('splash renders application name', (tester) async {
    await tester.pumpWidget(const DogaApp());
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/branding/dogadayim_logo_full.png',
      ),
      findsOneWidget,
    );
  });
}
