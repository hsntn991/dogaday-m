import 'package:dogada_gezi/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final resolutions = <String, Size>{
    'phone': const Size(360, 800),
    'large_phone': const Size(430, 932),
    'small_tablet_portrait': const Size(600, 960),
    'ipad_portrait': const Size(834, 1194),
    'ipad_landscape': const Size(1194, 834),
    'android_tablet_landscape': const Size(1280, 800),
  };

  final samplePlace = Place(
    'Yedigöller Milli Parkı',
    'Bolu',
    'Milli Park',
    4.9,
    Icons.forest,
    const [Color(0xFF287890), Color(0xFF8DD1C9)],
    'https://example.com/yedigoller.jpg',
    description: 'Yedigöller havzası zengin bitki örtüsü ve gölleriyle ünlüdür.',
    latitude: 40.94,
    longitude: 31.74,
    verificationStatus: VerificationStatus.verified,
    updatedAt: DateTime(2026, 9, 20),
    facilities: const PlaceFacilities(values: {
      'drinking_water': true,
      'toilets': true,
      'parking': true,
      'camping': true,
    }),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppLocaleController.setLocale(const Locale('tr'));
    AppThemeController.mode.value = ThemeMode.light;
  });

  group('Tablet Responsiveness - 6 Resolutions Quality Control', () {
    for (final entry in resolutions.entries) {
      final name = entry.key;
      final size = entry.value;

      testWidgets('DetailScreen stays overflow-free on $name (${size.width}x${size.height})',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: DetailScreen(
              place: samplePlace,
              favorite: false,
              onFavorite: () {},
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(DetailScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('GoodnessMovementScreen stays overflow-free on $name (${size.width}x${size.height})',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: const GoodnessMovementScreen(),
          ),
        );
        await tester.pump();

        expect(find.byType(GoodnessMovementScreen), findsOneWidget);
        expect(find.text('İyilik Harekâtı'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('CommunityChatHubScreen stays overflow-free on $name (${size.width}x${size.height})',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: const CommunityChatHubScreen(),
          ),
        );
        await tester.pump();

        expect(find.byType(CommunityChatHubScreen), findsOneWidget);
        expect(find.text(AppStrings.get('community_chats_title')), findsAtLeastNWidgets(1));
        expect(tester.takeException(), isNull);
      });

      testWidgets('AddPlaceScreen stays overflow-free on $name (${size.width}x${size.height})',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: const AddPlaceScreen(),
          ),
        );
        await tester.pump();

        expect(find.byType(AddPlaceScreen), findsOneWidget);
        expect(find.text(AppStrings.get('add_place_title')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('DetailScreen and GoodnessScreen adapt to Dark Mode on Tablet Landscape',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      AppThemeController.mode.value = ThemeMode.dark;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: DetailScreen(
            place: samplePlace,
            favorite: true,
            onFavorite: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(DetailScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const GoodnessMovementScreen(),
        ),
      );
      await tester.pump();
      expect(find.byType(GoodnessMovementScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('CommunityChatHubScreen master-detail active chat switching in landscape',
        (tester) async {
      tester.view.physicalSize = const Size(1194, 834);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const CommunityChatHubScreen(),
        ),
      );
      await tester.pump();

      expect(find.byType(CommunityChatRoomScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
