import 'dart:convert';
import 'dart:io';

import 'package:dogada_gezi/main.dart';
import 'package:dogada_gezi/src/services/place_photo_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('EmergencyHelpDraft', () {
    test('location-only request does not require a contact value', () {
      const draft = EmergencyHelpDraft(
        type: EmergencyHelpType.lost,
        contactPreference: EmergencyContactPreference.locationOnly,
      );

      expect(draft.validationError(latitude: 40.0, longitude: 32.0), isNull);
    });

    test('contact request requires contact information', () {
      const draft = EmergencyHelpDraft(
        type: EmergencyHelpType.vehicleStuck,
        contactPreference: EmergencyContactPreference.contactDetails,
      );

      expect(
        draft.validationError(latitude: 40.0, longitude: 32.0),
        isNotNull,
      );
    });

    test('expired request is no longer visible to helpers', () {
      final request = EmergencyHelpRequest(
        id: 'request-1',
        requesterId: 'user-1',
        type: EmergencyHelpType.injured,
        contactPreference: EmergencyContactPreference.locationOnly,
        contactValue: null,
        latitude: 40.0,
        longitude: 32.0,
        status: EmergencyHelpStatus.active,
        createdAt: DateTime(2026, 9, 20),
        expiresAt: DateTime(2026, 9, 22),
      );

      expect(request.isVisibleAt(DateTime(2026, 9, 23)), isFalse);
    });

    test('help request errors explain when a user must sign in', () {
      expect(
        EmergencyHelpController.userFacingError(
          StateError('Yardım çağrısı için giriş yapmalısın.'),
        ),
        'Yardım çağrısı için önce hesabına giriş yapmalısın.',
      );
    });

    test('manual map selection supplies a usable emergency coordinate', () {
      final coordinate = EmergencyManualLocation.fromMapPoint(
        const LatLng(39.9208, 32.8541),
      );

      expect(coordinate, isNotNull);
      expect(coordinate!.latitude, 39.9208);
      expect(coordinate.longitude, 32.8541);
      expect(coordinate.isApproximate, isFalse);
    });
  });

  group('GoodnessCampaignScore', () {
    test('assigns a stable point value to a tree planting contribution', () {
      expect(GoodnessCampaignScore.pointsFor('Fidan Diktim'), 15);
    });

    test('uses the standard score for an unrecognised contribution type', () {
      expect(GoodnessCampaignScore.pointsFor('Başka bir iyilik'), 10);
    });
  });

  test('goodness campaign includes the supplied 81-province map asset',
      () async {
    final mapAsset = await rootBundle.load(
      'assets/maps/turkiye_il_haritasi.svg',
    );

    expect(mapAsset.lengthInBytes, greaterThan(50000));
  });

  test('goodness campaign map keeps the supplied cream fill and brown borders',
      () async {
    final svg = await rootBundle.loadString(
      'assets/maps/turkiye_il_haritasi.svg',
    );

    expect(RegExp('fill="#EFE3CE"').allMatches(svg), hasLength(81));
    expect(RegExp('stroke="#4A3626"').allMatches(svg), hasLength(81));
  });

  testWidgets('goodness campaign opens without a render error in either theme',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final brightness in Brightness.values) {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          brightness: brightness,
        ),
        home: const GoodnessMovementScreen(),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull, reason: '$brightness theme');
      expect(find.text('İyilik Harekâtı'), findsOneWidget);
    }
  });

  testWidgets('main navigation reveals the goodness screen content',
      (tester) async {
    await AppLocaleController.setLocale(const Locale('tr'));
    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.pump();

    await tester.tap(find.bySemanticsLabel('İyilik'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('İyilik Harekâtı'), findsOneWidget);
  });

  test(
      'research photo package contains licensed approved media and matches a place',
      () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final records = jsonDecode(
        await File('assets/data/research_photos.json').readAsString()) as List;
    expect(records.length, 61);
    var count = 0;
    for (final row in records) {
      for (final photo in row['photos'] as List) {
        expect(photo['confidence_level'], anyOf('A', 'B'));
        expect(photo['photo_quality_status'], 'approved');
        expect(photo['license_verified'], true);
        expect(photo['author'], isNotEmpty);
        expect(photo['license_url'], isNotEmpty);
        expect(photo['file_title'], isNot('File:Troas.png'));
        count++;
      }
    }
    expect(count, 146);
    final row = records.first;
    final place = Place(row['name'], '', 'Doğa Noktası', 0, Icons.place,
        const [Colors.green, Colors.green], null,
        latitude: (row['latitude'] as num).toDouble(),
        longitude: (row['longitude'] as num).toDouble());
    final result = await PlaceEnrichmentService.find(place);
    expect(result?.primaryPhoto?.url, startsWith('https://'));
    expect(result?.primaryPhoto?.author, isNotEmpty);
  });
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

  test('fountain taxonomy stays a utility and is not promoted as a destination',
      () {
    final taxonomy = taxonomyFromLegacy('Mahalle Çeşmesi');

    expect(taxonomy.mainCategory, isNull);
    expect(taxonomy.subtype, 'water_fountain');
    expect(isUtilitySubtype(taxonomy.subtype), isTrue);
    expect(
        taxonomyDisplayLabel(
          fallback: 'Su Kaynağı',
          mainCategory: taxonomy.mainCategory,
          subtype: taxonomy.subtype,
        ),
        'Çeşme');
  });

  test('map labels use the fountain subtype instead of the legacy spring name',
      () {
    final fountain = Place(
      'Akçeşme',
      'Konya',
      'Su Kaynağı',
      0,
      Icons.water_drop,
      const [Color(0xFF315F45), Color(0xFF9BBF82)],
      null,
      mainCategory: null,
      subtype: 'water_fountain',
    );

    expect(fountain.kind, 'Çeşme');
    expect(fountain.displayKind, 'Çeşme');
    expect(fountain.resolvedTaxonomy.mainCategory, isNull);
    expect(fountain.isUtility, isTrue);
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

  test('no-location fallback never selects Antalya or creates nearby results',
      () {
    HomeWeatherLocationController.useFallbackCity();

    expect(HomeWeatherLocationController.current.value.label,
        'Konum izni gerekli');
    expect(
        HomeWeatherLocationController.current.value.usesCoordinates, isFalse);

    final results = NearbyPlacesService.filterNearbyPlaces(
      target: HomeWeatherLocationController.current.value,
      places: [
        Place(
          'Uzak doğa noktası',
          'Antalya',
          'Göl',
          4.7,
          Icons.water_outlined,
          const [Color(0xFF287890), Color(0xFF8DD1C9)],
          null,
          latitude: 36.9,
          longitude: 30.7,
        ),
      ],
    );

    expect(results, isEmpty);
  });

  test(
      'nearby filter keeps natural water but excludes distant and utility water',
      () {
    const target = WeatherTarget.coordinates(
      latitude: 39.9208,
      longitude: 32.8541,
      label: 'Ankara',
    );
    final results = NearbyPlacesService.filterNearbyPlaces(
      target: target,
      places: [
        Place(
          'Yakındaki doğal pınar',
          'Ankara',
          'Su Kaynağı',
          4.8,
          Icons.water_drop_outlined,
          const [Color(0xFF287890), Color(0xFF8DD1C9)],
          null,
          latitude: 39.925,
          longitude: 32.854,
        ),
        Place(
          'Yakındaki içme suyu',
          'Ankara',
          'İçme Suyu',
          4.8,
          Icons.water_drop_outlined,
          const [Color(0xFF287890), Color(0xFF8DD1C9)],
          null,
          latitude: 39.925,
          longitude: 32.854,
        ),
        Place(
          'Uzak göl',
          'Bartın',
          'Göl',
          4.8,
          Icons.water_outlined,
          const [Color(0xFF287890), Color(0xFF8DD1C9)],
          null,
          latitude: 41.64,
          longitude: 32.34,
        ),
      ],
    );

    expect(results.map((place) => place.name), ['Yakındaki doğal pınar']);
    expect(results.single.distanceKm, lessThanOrEqualTo(25));
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

  test('local places are not treated as nearby without device coordinates',
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

    expect(initial, isEmpty);
    expect(stillAvailable, isEmpty);
  });

  testWidgets('home state is preserved and map stays lazy', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.pump();
    await tester.tap(find.text('Şimdi Değil'));
    await tester.pump();

    expect(find.byType(FlutterMap), findsNothing);

    await tester.tap(find.byType(AppCategoryChip).first);
    await tester.pump();
    expect(find.text('Bugün sana uygun'), findsOneWidget);

    await tester.tap(find.text('Harita'));
    await tester.pump();
    expect(find.byType(FlutterMap), findsOneWidget);

    await tester.tap(find.text('Keşfet'));
    await tester.pump();
    expect(find.text('Bugün sana uygun'), findsOneWidget);
  });

  testWidgets(
      'map marker opens the shared preview and ignores invalid coordinates',
      (tester) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() => UserPlacesController.places.value = const []);

    UserPlacesController.places.value = [
      Place(
        'Harita Test Şelalesi',
        'Bolu',
        'Şelale',
        4.8,
        Icons.waterfall_chart_rounded,
        const [Color(0xFF315F45), Color(0xFF9BBF82)],
        null,
        description: 'Gerçek koordinatlı harita test noktası.',
        latitude: 40.73,
        longitude: 31.61,
        sourceId: 'map-preview-valid',
      ),
      Place(
        'Geçersiz Sıfır Noktası',
        'Bilinmiyor',
        'Şelale',
        0,
        Icons.waterfall_chart_rounded,
        const [Color(0xFF315F45), Color(0xFF9BBF82)],
        null,
        latitude: 0,
        longitude: 0,
        sourceId: 'map-preview-invalid',
      ),
    ];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: MapScreen(onOpen: (_) {})),
    ));
    await tester.pump();

    expect(find.byType(AppMapPreviewCard), findsNothing);
    expect(
        find.bySemanticsLabel('Haritada Harita Test Şelalesi'), findsOneWidget);
    expect(
        find.bySemanticsLabel('Haritada Geçersiz Sıfır Noktası'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Haritada Harita Test Şelalesi'));
    await tester.pump();

    expect(find.byType(AppMapPreviewCard), findsOneWidget);
    expect(find.text('Yakındakiler'), findsNothing);
    expect(find.byTooltip('Kartı kapat'), findsOneWidget);
    expect(find.text('Harita Test Şelalesi'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selecting another map marker updates the same preview card',
      (tester) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() => UserPlacesController.places.value = const []);

    UserPlacesController.places.value = [
      duplicateFixture(
        name: 'Birinci Harita Noktası',
        latitude: 40.73,
        longitude: 31.61,
      ),
      duplicateFixture(
        name: 'İkinci Harita Noktası',
        latitude: 37.0,
        longitude: 34.8,
      ),
    ];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: MapScreen(onOpen: (_) {})),
    ));
    await tester.pump();

    await tester.tap(find.bySemanticsLabel('Haritada Birinci Harita Noktası'));
    await tester.pump();
    expect(find.text('Birinci Harita Noktası'), findsWidgets);

    await tester.tap(find.byTooltip('En yakın sonraki yer'));
    await tester.pump();
    expect(find.byType(AppMapPreviewCard), findsOneWidget);
    expect(find.text('İkinci Harita Noktası'), findsWidgets);
    final camera = tester
        .widget<FlutterMap>(find.byType(FlutterMap))
        .mapController!
        .camera;
    expect(camera.zoom, greaterThanOrEqualTo(12));
    expect(camera.center.longitude, closeTo(34.8, 0.01));
    await tester.tap(find.byTooltip('Önceki yer'));
    await tester.pump();
    expect(find.text('Birinci Harita Noktası'), findsWidgets);
    await tester.tap(find.byTooltip('Kartı kapat'));
    await tester.pump();
    expect(find.byType(AppMapPreviewCard), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('map floating controls stay overflow-free on phone widths',
      (tester) async {
    const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            pathChannel, (_) async => Directory.systemTemp.path);
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, null));
    addTearDown(() => UserPlacesController.places.value = const []);
    if (const bool.fromEnvironment('CAPTURE_MAP')) {
      for (final family in ['Roboto', 'Outfit']) {
        await (FontLoader(family)
              ..addFont(rootBundle.load('assets/fonts/Outfit-Variable.ttf')))
            .load();
      }
      await (FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
          .load();
    }
    for (final width in [320.0, 360.0, 375.0, 390.0, 412.0, 430.0]) {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      UserPlacesController.places.value = [
        duplicateFixture(name: 'Dar Ekran Harita Noktası', kind: 'Şelale'),
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: MapScreen(onOpen: (_) {})),
      ));
      await tester.pump();
      await tester
          .tap(find.bySemanticsLabel('Haritada Dar Ekran Harita Noktası'));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '${width.toInt()}px');
      if (width == 390 && const bool.fromEnvironment('CAPTURE_MAP')) {
        await expectLater(find.byType(Scaffold),
            matchesGoldenFile('goldens/map_selection.png'));
      }
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('premium bottom navigation keeps its tabs and center add route',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.pump();
    await tester.tap(find.text('Şimdi Değil'));
    await tester.pump();

    expect(find.byTooltip('Keşfet'), findsOneWidget);
    expect(find.byTooltip('Harita'), findsOneWidget);
    expect(find.byTooltip('İyilik'), findsOneWidget);
    expect(find.byTooltip('Profil'), findsOneWidget);
    expect(find.byTooltip('Yer Ekle'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(AddPlaceScreen), findsOneWidget);
  });

  testWidgets('premium bottom navigation remains overflow-free on phones',
      (tester) async {
    for (final width in [320.0, 360.0, 375.0, 390.0, 412.0, 430.0]) {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(const MaterialApp(home: MainShell()));
      await tester.pump();
      final deferLocation = find.text('Şimdi Değil');
      if (deferLocation.evaluate().isNotEmpty) {
        await tester.tap(deferLocation);
        await tester.pump();
      }

      expect(tester.takeException(), isNull, reason: '${width.toInt()}px');
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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

  testWidgets('home header hides stale current-location data while resolving',
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
  });

  testWidgets('nearby section requests location instead of faking proximity',
      (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    UserPlacesController.places.value = const [];
    HomeWeatherLocationController.useFallbackCity();
    var locationRequested = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FigmaHomeScreen(
          onOpen: (_) {},
          onSearch: () {},
          onMessages: () {},
          onRequestLocation: () => locationRequested = true,
        ),
      ),
    ));
    await tester.pump();

    expect(find.text('Yakınındaki yerleri görmek için konum izni ver.'),
        findsOneWidget);
    await tester.tap(find.text('Konumu Aç'));
    expect(locationRequested, isTrue);
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

  test('isSafeExternalUrl allows only http and https schemes', () {
    expect(isSafeExternalUrl(null), isFalse);
    expect(isSafeExternalUrl(Uri.tryParse('')), isFalse);
    expect(isSafeExternalUrl(Uri.tryParse('javascript:alert(1)')), isFalse);
    expect(isSafeExternalUrl(Uri.tryParse('file:///etc/passwd')), isFalse);
    expect(
        isSafeExternalUrl(
            Uri.tryParse('intent://scan/#Intent;scheme=zxing;end')),
        isFalse);
    expect(isSafeExternalUrl(Uri.tryParse('tel:+905551234567')), isFalse);
    expect(isSafeExternalUrl(Uri.tryParse('sms:+905551234567')), isFalse);
    expect(isSafeExternalUrl(Uri.tryParse('data:text/html,test')), isFalse);
    expect(isSafeExternalUrl(Uri.tryParse('http://example.com')), isTrue);
    expect(isSafeExternalUrl(Uri.tryParse('https://maps.google.com/?q=test')),
        isTrue);
  });

  group('SupabasePlacesController._decodeCacheRecords', () {
    test('1. gecerli kayitlar dogru sayida Map uretir', () {
      final records = [
        jsonEncode({'name': 'Yer A', 'location': 'Antalya'}),
        jsonEncode({'name': 'Yer B', 'location': 'Muğla'}),
      ];
      final result =
          SupabasePlacesController.decodeCacheRecordsForTest(records);
      expect(result, hasLength(2));
    });

    test('2. alanlar birebir korunur', () {
      final original = {
        'name': 'Göynük Kanyonu',
        'location': 'Antalya',
        'latitude': 36.61,
        'longitude': 30.42,
        'sourceId': 'osm-123',
        'verificationStatus': 'verified',
      };
      final result = SupabasePlacesController.decodeCacheRecordsForTest(
        [jsonEncode(original)],
      );
      expect(result.single['name'], original['name']);
      expect(result.single['location'], original['location']);
      expect(result.single['latitude'], original['latitude']);
      expect(result.single['sourceId'], original['sourceId']);
    });

    test('3. bos liste -> bos sonuc', () {
      final result =
          SupabasePlacesController.decodeCacheRecordsForTest(const []);
      expect(result, isEmpty);
    });

    test('4. bozuk JSON sessizce atlanir, gecerli kayitlar korunur', () {
      final records = [
        'bozuk-json{{{',
        jsonEncode({'name': 'Gecerli Yer', 'location': 'Bolu'}),
        '###',
      ];
      final result =
          SupabasePlacesController.decodeCacheRecordsForTest(records);
      expect(result, hasLength(1));
      expect(result.single['name'], 'Gecerli Yer');
    });

    test(
        '5. helper widget ve controller bagimsiz calisir (Flutter binding gerektirmez)',
        () {
      // Bu test Flutter widget binding olmadan geciyor olmasından dolayı
      // helper'in saf Dart oldugunu kanitlar.
      final result = SupabasePlacesController.decodeCacheRecordsForTest(
        [
          jsonEncode({'name': 'Test', 'location': 'TR'})
        ],
      );
      expect(result.single['name'], 'Test');
    });
  });

  group('filterNearbyDetailPlaces utility guard', () {
    const origin = Place(
      'Düden Şelalesi',
      'Antalya',
      'Şelale',
      4.8,
      Icons.water_drop,
      [Color(0xFF315F45), Color(0xFF9BBF82)],
      null,
      latitude: 36.96,
      longitude: 30.72,
      subtype: 'waterfall',
    );

    Place createCandidate({
      required String name,
      required String subtype,
      double lat = 36.97,
      double lon = 30.73,
    }) {
      return Place(
        name,
        'Antalya',
        'Doğa',
        4.5,
        Icons.place,
        const [Color(0xFF315F45), Color(0xFF9BBF82)],
        null,
        latitude: lat,
        longitude: lon,
        subtype: subtype,
      );
    }

    test('1. Yakinda normal doga yeri -> listede kalir', () {
      final candidates = [
        createCandidate(name: 'Kurşunlu Şelalesi', subtype: 'waterfall'),
        createCandidate(name: 'Güllük Dağı', subtype: 'mountain'),
      ];
      final nearby =
          filterNearbyDetailPlaces(origin: origin, candidates: candidates);
      expect(nearby.map((p) => p.name),
          containsAll(['Kurşunlu Şelalesi', 'Güllük Dağı']));
      expect(nearby, hasLength(2));
    });

    test('2. Yakinda drinking_water -> listede gorunmez', () {
      final candidates = [
        createCandidate(name: 'Tarihi Çeşme', subtype: 'drinking_water'),
        createCandidate(name: 'Doğal Park', subtype: 'park'),
      ];
      final nearby =
          filterNearbyDetailPlaces(origin: origin, candidates: candidates);
      expect(nearby.map((p) => p.name), contains('Doğal Park'));
      expect(nearby.map((p) => p.name), isNot(contains('Tarihi Çeşme')));
      expect(nearby, hasLength(1));
    });

    test('3. Yakinda toilet -> listede gorunmez', () {
      final candidates = [
        createCandidate(name: 'Park Tuvaleti', subtype: 'toilet'),
        createCandidate(name: 'Kanyon Seyir', subtype: 'viewpoint'),
      ];
      final nearby =
          filterNearbyDetailPlaces(origin: origin, candidates: candidates);
      expect(nearby.map((p) => p.name), contains('Kanyon Seyir'));
      expect(nearby.map((p) => p.name), isNot(contains('Park Tuvaleti')));
      expect(nearby, hasLength(1));
    });

    test('4. Yakinda water_fountain -> listede gorunmez', () {
      final candidates = [
        createCandidate(name: 'Meydan Şadırvanı', subtype: 'water_fountain'),
        createCandidate(name: 'Köprülü Kanyon', subtype: 'canyon'),
      ];
      final nearby =
          filterNearbyDetailPlaces(origin: origin, candidates: candidates);
      expect(nearby.map((p) => p.name), contains('Köprülü Kanyon'));
      expect(nearby.map((p) => p.name), isNot(contains('Meydan Şadırvanı')));
      expect(nearby, hasLength(1));
    });
  });

  group('UserReviewsController persistence and lookup', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await UserReviewsController.load();
    });

    test('saves and retrieves review for a place by sourceId', () async {
      const place = Place(
        'Gizli Koy',
        'Antalya',
        'Doğa Noktası',
        0,
        Icons.place,
        [Colors.green],
        null,
        sourceId: 'user-place-123',
        latitude: 36.8,
        longitude: 30.7,
      );

      await UserReviewsController.saveReview(
        place: place,
        rating: 5,
        content: 'Harika bir yer, çok sakin.',
        recommended: true,
        reasons: ['Manzara', 'Sessizlik'],
      );

      final retrieved = UserReviewsController.userReviewForPlace(place);
      expect(retrieved, isNotNull);
      expect(retrieved!.rating, equals(5));
      expect(retrieved.content, equals('Harika bir yer, çok sakin.'));
      expect(retrieved.recommended, isTrue);
      expect(retrieved.recommendationReasons, contains('Manzara'));

      final all = UserReviewsController.forPlace(place);
      expect(all, hasLength(1));
      final entry = all.first.toEntry();
      expect(entry.rating, equals(5));
      expect(entry.content, equals('Harika bir yer, çok sakin.'));
    });

    test('updates review for the same place without creating duplicates',
        () async {
      const place = Place(
        'Uzungöl',
        'Trabzon',
        'Göl',
        0,
        Icons.place,
        [Colors.blue],
        null,
        sourceId: 'osm-lake-999',
        latitude: 40.6,
        longitude: 40.2,
      );

      await UserReviewsController.saveReview(
        place: place,
        rating: 3,
        content: 'Fena değil.',
      );
      expect(UserReviewsController.forPlace(place), hasLength(1));

      await UserReviewsController.saveReview(
        place: place,
        rating: 4,
        content: 'Tekrar gittim, daha iyiydi.',
      );
      final all = UserReviewsController.forPlace(place);
      expect(all, hasLength(1));
      expect(all.first.rating, equals(4));
      expect(all.first.content, equals('Tekrar gittim, daha iyiydi.'));
    });

    test('clear removes all reviews', () async {
      const place = Place(
        'Yedigöller',
        'Bolu',
        'Milli Park',
        0,
        Icons.place,
        [Colors.green],
        null,
        sourceId: 'park-77',
      );

      await UserReviewsController.saveReview(
        place: place,
        rating: 5,
        content: 'Muazzam doğa.',
      );
      expect(UserReviewsController.forPlace(place), hasLength(1));

      await UserReviewsController.clear();
      expect(UserReviewsController.forPlace(place), isEmpty);
      expect(UserReviewsController.userReviewForPlace(place), isNull);
    });
  });

  group('AppLocaleController and AppStrings localization', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      await AppLocaleController.setLocale(const Locale('tr'));
    });

    test('supports tr, en, ar with correct metadata', () {
      expect(AppLocaleController.supported, hasLength(3));
      expect(AppLocaleController.options, hasLength(3));
      final codes = AppLocaleController.options
          .map((o) => o.locale.languageCode)
          .toList();
      expect(codes, containsAll(['tr', 'en', 'ar']));
    });

    test('switches language and translates tab strings correctly', () async {
      await AppLocaleController.setLocale(const Locale('tr'));
      expect(AppStrings.get('tab_discover'), equals('Keşfet'));
      expect(AppLocaleController.isArabic, isFalse);
      expect(AppLocaleController.isRtl, isFalse);

      await AppLocaleController.setLocale(const Locale('en'));
      expect(AppStrings.get('tab_discover'), equals('Discover'));
      expect(AppStrings.get('tab_goodness'), equals('Goodness'));
      expect(AppLocaleController.isArabic, isFalse);
      expect(AppLocaleController.isRtl, isFalse);

      await AppLocaleController.setLocale(const Locale('ar'));
      expect(AppStrings.get('tab_discover'), equals('اكتشف'));
      expect(AppLocaleController.isArabic, isTrue);
      expect(AppLocaleController.isRtl, isTrue);
      expect(AppLocaleController.textDirection, equals(TextDirection.rtl));
    });

    test(
        'categories, subtypes, facilities, and info cards translate dynamically',
        () async {
      // Turkish
      await AppLocaleController.setLocale(const Locale('tr'));
      expect(AppStrings.category('water'), equals('Su'));
      expect(AppStrings.subtype('waterfall'), equals('Şelale'));
      expect(AppStrings.facility('parking'), equals('Otopark'));
      expect(AppStrings.get('card_coordinates'), equals('KOORDİNATLAR'));
      expect(
          AppStrings.get('card_arrival_time'), equals('Ortalama Varış Süresi'));
      expect(AppStrings.get('home_for_you_today'), equals('Bugün sana uygun'));
      expect(AppStrings.get('profile_nature_explorer'), equals('Doğa Kaşifi'));
      expect(facilityDisplayLabel('toilets'), equals('Tuvalet'));
      expect(facilityDisplayLabel('nearby_toilets'), equals('Tuvalet'));

      // English
      await AppLocaleController.setLocale(const Locale('en'));
      expect(AppStrings.category('water'), equals('Water'));
      expect(AppStrings.subtype('waterfall'), equals('Waterfall'));
      expect(AppStrings.facility('parking'), equals('Parking'));
      expect(AppStrings.get('card_coordinates'), equals('COORDINATES'));
      expect(AppStrings.get('card_arrival_time'), equals('Estimated Arrival'));
      expect(
          AppStrings.get('home_for_you_today'), equals('Handpicked for Today'));
      expect(
          AppStrings.get('profile_nature_explorer'), equals('Nature Explorer'));
      expect(AppStrings.get('profile_default_user_name'),
          equals('Doğadayım User'));
      expect(
          AppStrings.get('community_chats_title'), equals('Community Chats'));
      expect(AppStrings.get('add_place_title'), equals('Add Place'));
      expect(AppStrings.addPlaceOption('Şelale'), equals('Waterfall'));
      expect(AppStrings.addPlaceOption('Ormanlık'), equals('Forested'));
      expect(AppStrings.addPlaceOption('Binek araç'), equals('Standard Car'));
      expect(facilityDisplayLabel('toilets'), equals('Restroom'));
      expect(facilityDisplayLabel('nearby_toilets'), equals('Restroom'));

      // Arabic
      await AppLocaleController.setLocale(const Locale('ar'));
      expect(AppStrings.category('water'), equals('مياه'));
      expect(AppStrings.subtype('waterfall'), equals('شلال'));
      expect(AppStrings.facility('parking'), equals('موقف سيارات'));
      expect(AppStrings.get('card_coordinates'), equals('الإحداثيات'));
      expect(AppStrings.get('card_arrival_time'), equals('وقت الوصول المتوقع'));
      expect(AppStrings.get('home_for_you_today'), equals('مناسب لك اليوم'));
      expect(
          AppStrings.get('profile_nature_explorer'), equals('مستكشف الطبيعة'));
      expect(facilityDisplayLabel('toilets'), equals('دورة مياه'));
      expect(facilityDisplayLabel('nearby_toilets'), equals('دورة مياه'));

      // Reset to Turkish
      await AppLocaleController.setLocale(const Locale('tr'));
    });

    testWidgets('profile language selector shows in UI with options',
        (tester) async {
      tester.view.physicalSize = const Size(390, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: AppLocaleController.supported,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: FigmaProfileScreen(onOpen: (_) {}),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.language_rounded), findsOneWidget);
      expect(find.text(AppStrings.get('profile_language')), findsOneWidget);
    });
  });

  group('AppThemeController defaults and preference persistence', () {
    tearDown(() async {
      await AppThemeController.reset();
    });

    test('first time user defaults to normal (light) mode', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('app_user_dark_mode_preference');

      await AppThemeController.load();
      expect(AppThemeController.mode.value, equals(ThemeMode.light));
      expect(AppThemeController.isDark, isFalse);
    });

    test('setting dark mode updates state and persists preference', () async {
      await AppThemeController.setDark(true);
      expect(AppThemeController.mode.value, equals(ThemeMode.dark));
      expect(AppThemeController.isDark, isTrue);

      // Reloading from storage keeps user's explicit preference
      await AppThemeController.load();
      expect(AppThemeController.mode.value, equals(ThemeMode.dark));
      expect(AppThemeController.isDark, isTrue);
    });

    test('setting light mode updates state and persists preference', () async {
      await AppThemeController.setDark(false);
      expect(AppThemeController.mode.value, equals(ThemeMode.light));
      expect(AppThemeController.isDark, isFalse);

      await AppThemeController.load();
      expect(AppThemeController.mode.value, equals(ThemeMode.light));
      expect(AppThemeController.isDark, isFalse);
    });
  });

  group('5-day weather forecast and camp metrics', () {
    test(
        'DailyForecast model holds condition, emoji, and precipitation correctly',
        () {
      final forecast = DailyForecast(
        date: DateTime(2026, 9, 23),
        weatherCode: 61,
        minimumTemperature: 12.5,
        maximumTemperature: 21.0,
        precipitationProbability: 75.0,
        windSpeedMax: 18.5,
      );

      expect(forecast.condition, equals('Yağmurlu'));
      expect(forecast.emoji, equals('🌧️'));
      expect(forecast.minimumTemperature, equals(12.5));
      expect(forecast.maximumTemperature, equals(21.0));
      expect(forecast.precipitationProbability, equals(75.0));
      expect(forecast.windSpeedMax, equals(18.5));
    });

    test('AppStrings.weekdayShort translates today and weekdays across locales',
        () async {
      final now = DateTime.now();

      // TR
      await AppLocaleController.setLocale(const Locale('tr'));
      expect(AppStrings.weekdayShort(now), equals('Bugün'));
      expect(AppStrings.get('weather_5day_forecast'),
          equals('5 Günlük Doğa & Kamp Tahmini'));

      // EN
      await AppLocaleController.setLocale(const Locale('en'));
      expect(AppStrings.weekdayShort(now), equals('Today'));
      expect(AppStrings.get('weather_5day_forecast'),
          equals('5-Day Nature & Camp Forecast'));

      // AR
      await AppLocaleController.setLocale(const Locale('ar'));
      expect(AppStrings.weekdayShort(now), equals('اليوم'));
      expect(AppStrings.get('weather_5day_forecast'),
          equals('توقعات 5 أيام للطبيعة والتخييم'));

      // Reset
      await AppLocaleController.setLocale(const Locale('tr'));
    });

    testWidgets(
        'DetailScreen weather card renders 5-day forecast strip and rain chances',
        (tester) async {
      final now = DateTime.now();
      final snapshot = WeatherSnapshot(
        resolvedLocation: 'Bolu, Yedigöller',
        temperature: 18.0,
        apparentTemperature: 17.5,
        humidity: 65,
        windSpeed: 12,
        visibilityKm: 10,
        uvIndex: 4,
        minimumTemperature: 9,
        maximumTemperature: 22,
        weatherCode: 1,
        isDay: true,
        dailyForecast: [
          DailyForecast(
            date: now,
            weatherCode: 1,
            minimumTemperature: 9,
            maximumTemperature: 22,
            precipitationProbability: 10,
            windSpeedMax: 12,
          ),
          DailyForecast(
            date: now.add(const Duration(days: 1)),
            weatherCode: 61,
            minimumTemperature: 8,
            maximumTemperature: 16,
            precipitationProbability: 85,
            windSpeedMax: 20,
          ),
          DailyForecast(
            date: now.add(const Duration(days: 2)),
            weatherCode: 0,
            minimumTemperature: 10,
            maximumTemperature: 23,
            precipitationProbability: 0,
            windSpeedMax: 8,
          ),
          DailyForecast(
            date: now.add(const Duration(days: 3)),
            weatherCode: 2,
            minimumTemperature: 11,
            maximumTemperature: 24,
            precipitationProbability: 15,
            windSpeedMax: 10,
          ),
          DailyForecast(
            date: now.add(const Duration(days: 4)),
            weatherCode: 3,
            minimumTemperature: 12,
            maximumTemperature: 20,
            precipitationProbability: 30,
            windSpeedMax: 14,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Detail5DayForecastStrip(
              forecasts: snapshot.dailyForecast,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bugün'), findsOneWidget);
      // High rain day check (85%)
      expect(find.text('💧85%'), findsOneWidget);
      expect(find.text('💧10%'), findsOneWidget);
      // Emojis
      expect(find.text('🌧️'), findsOneWidget);
      expect(find.text('☀️'), findsOneWidget);
      // Temperatures
      expect(find.text('22°'), findsOneWidget);
      expect(find.text('9°'), findsOneWidget);
    });
  });

  testWidgets(
      'DetailScreen field conditions renders 6 core items with truthful verified and unknown statuses',
      (tester) async {
    const place = Place(
      'Saha Test Yeri',
      'Bolu',
      'Doğa Alanı',
      4.6,
      Icons.place_rounded,
      [Color(0xFF315F45), Color(0xFF9BBF82)],
      null,
      verificationStatus: VerificationStatus.verified,
      facilities: PlaceFacilities(
        values: {
          'drinking_water': true,
          'toilets': true,
          'parking': true,
          'tents': true,
        },
        nearbyDistances: {
          'parking': 120,
        },
      ),
      features: ['Ulaşım: Binek araç'],
    );

    await tester.pumpWidget(MaterialApp(
      home: DetailScreen(
        place: place,
        favorite: false,
        onFavorite: () {},
      ),
    ));

    expect(find.text('Saha Koşulları & İhtiyaçlar'), findsOneWidget);
    expect(find.text('İçme Suyu'), findsWidgets);
    expect(find.text('Tuvalet'), findsWidgets);
    expect(find.text('Otopark'), findsWidgets);
    expect(find.text('Piknik & Kamp'), findsOneWidget);
    expect(find.text('Araç Erişimi & Yol'), findsOneWidget);
    expect(find.text('Son Yürüme Mesafesi'), findsOneWidget);
    expect(find.text('Binek araç'), findsOneWidget);
    expect(find.text('Otoparktan ~120 m'), findsOneWidget);
    expect(find.text('Doğrulandı'), findsWidgets);
  });

  group('PlacePublicationStandard publication threshold and rates', () {
    test('high quality place meets publication threshold', () {
      const place = Place(
        'Sülüklü Göl',
        'Bolu',
        'Göl',
        4.8,
        Icons.water_outlined,
        [Color(0xFF287890), Color(0xFF8DD1C9)],
        'https://example.com/suluklu.jpg',
        description:
            'Bolu Mudurnu civarında zengin bitki örtüsüne sahip doğa harikası göl.',
        latitude: 40.55,
        longitude: 30.88,
        verificationStatus: VerificationStatus.verified,
        facilities: PlaceFacilities(values: {'drinking_water': true}),
      );

      expect(PlacePublicationStandard.meetsThreshold(place), isTrue);
    });

    test('place missing photo or description fails publication threshold', () {
      const photoLess = Place(
        'Fotoğralsız Nokta',
        'Bolu',
        'Kanyon',
        4.0,
        Icons.terrain,
        [Color(0xFF287890), Color(0xFF8DD1C9)],
        null,
        description: 'Uzun bir açıklama metni var ama fotoğrafı yok.',
        latitude: 40.5,
        longitude: 31.5,
        verificationStatus: VerificationStatus.verified,
      );

      const descLess = Place(
        'Açıklamasız Nokta',
        'Bolu',
        'Şelale',
        4.0,
        Icons.water,
        [Color(0xFF287890), Color(0xFF8DD1C9)],
        'https://example.com/selale.jpg',
        description: 'Kısa',
        latitude: 40.5,
        longitude: 31.5,
        verificationStatus: VerificationStatus.verified,
      );

      expect(PlacePublicationStandard.meetsThreshold(photoLess), isFalse);
      expect(PlacePublicationStandard.meetsThreshold(descLess), isFalse);
    });

    test('publicationRate calculates percentage accurately for provinces', () {
      const qualityPlace = Place(
        'Gölcük Tabiat Parkı',
        'Bolu',
        'Tabiat Parkı',
        4.9,
        Icons.forest,
        [Color(0xFF287890), Color(0xFF8DD1C9)],
        'https://example.com/golcuk.jpg',
        description:
            'Yapay gölet etrafında çam ormanlarıyla kaplı eşsiz tabiat parkı.',
        latitude: 40.65,
        longitude: 31.62,
        verificationStatus: VerificationStatus.verified,
      );
      const incompletePlace = Place(
        'Taslak Nokta',
        'Bolu',
        'Doğa Noktası',
        0,
        Icons.place,
        [Color(0xFF287890), Color(0xFF8DD1C9)],
        null,
      );

      final rate = PlacePublicationStandard.publicationRate(
          [qualityPlace, incompletePlace]);
      expect(rate, 0.5);

      final stats = PlacePublicationStandard.provinceStats(
          [qualityPlace, incompletePlace]);
      expect(stats['Bolu']?.total, 2);
      expect(stats['Bolu']?.published, 1);
      expect(stats['Bolu']?.rate, 0.5);
    });
  });

  group('Phase U5 verification tests', () {
    testWidgets(
        'DetailScreen stays overflow-free across 320-430 px phone widths',
        (tester) async {
      final place = Place(
        'Yedigöller Milli Parkı',
        'Bolu',
        'Milli Park',
        4.9,
        Icons.forest,
        [Color(0xFF287890), Color(0xFF8DD1C9)],
        'https://example.com/yedigoller.jpg',
        description:
            'Yedigöller havzası zengin bitki örtüsü ve gölleriyle ünlüdür.',
        latitude: 40.94,
        longitude: 31.74,
        verificationStatus: VerificationStatus.verified,
        updatedAt: DateTime(2026, 9, 20),
        facilities: PlaceFacilities(values: {
          'drinking_water': true,
          'toilets': true,
          'parking': true,
          'camping': true,
        }),
      );

      for (final width in [320.0, 360.0, 375.0, 390.0, 412.0, 430.0]) {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData.light(),
          home: DetailScreen(
            place: place,
            favorite: false,
            onFavorite: () {},
          ),
        ));
        await tester.pump();

        expect(find.byType(DetailScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets(
        'Profile screen renders Feedback, Terms & Privacy and AppLegalLinks is configured',
        (tester) async {
      expect(AppLegalLinks.supportEmail, 'dogadayim.destek@gmail.com');
      expect(AppLegalLinks.privacyPolicyUrl, isNotEmpty);
      expect(AppLegalLinks.termsOfServiceUrl, isNotEmpty);

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: FigmaProfileScreen(onOpen: (_) {}),
        ),
      ));
      await tester.pump();

      expect(find.text(AppStrings.get('profile_feedback'), skipOffstage: false),
          findsOneWidget);
      expect(
          find.text(AppStrings.get('profile_privacy_policy'),
              skipOffstage: false),
          findsOneWidget);
      expect(find.text(AppStrings.get('profile_terms'), skipOffstage: false),
          findsOneWidget);
    });

    testWidgets(
        'DetailScreen and PrivacyPolicyScreen stay overflow-free on tablet and wide widths',
        (tester) async {
      final place = Place(
        'Yedigöller Milli Parkı',
        'Bolu',
        'Milli Park',
        4.9,
        Icons.forest,
        [Color(0xFF287890), Color(0xFF8DD1C9)],
        'https://example.com/yedigoller.jpg',
        description:
            'Yedigöller havzası zengin bitki örtüsü ve gölleriyle ünlüdür.',
        latitude: 40.94,
        longitude: 31.74,
        verificationStatus: VerificationStatus.verified,
        updatedAt: DateTime(2026, 9, 20),
        facilities: PlaceFacilities(values: {
          'drinking_water': true,
          'toilets': true,
          'parking': true,
          'camping': true,
        }),
      );

      for (final width in [768.0, 1024.0]) {
        tester.view.physicalSize = Size(width, 1024);
        tester.view.devicePixelRatio = 1;

        await tester.pumpWidget(MaterialApp(
          theme: ThemeData.light(),
          home: DetailScreen(
            place: place,
            favorite: false,
            onFavorite: () {},
          ),
        ));
        await tester.pump();
        expect(find.byType(DetailScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const MaterialApp(
          home: PrivacyPolicyScreen(),
        ));
        await tester.pump();
        expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      }

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('NatureArt fallback renders gracefully when place has no photo',
        (tester) async {
      const place = Place(
        'Fotoğralsız Nokta',
        'Bolu',
        'Şelale',
        4.0,
        Icons.water,
        [Color(0xFF287890), Color(0xFF8DD1C9)],
        null,
      );

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: NatureArt(place: place, radius: 12),
        ),
      ));
      await tester.pump();

      expect(find.byType(NatureArt), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('goodness map uses a responsive fitted overview on a phone',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const MaterialApp(
        home: GoodnessMovementScreen(),
      ));
      await tester.pump();

      expect(find.bySemanticsLabel("Türkiye'nin 81 il haritası"), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
