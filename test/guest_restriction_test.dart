import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dogada_gezi/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Guest Mode & AppAuthGuard Tests', () {
    test('AppAuthGuard identifies unauthenticated state as guest', () {
      expect(AppAuthGuard.isAuthenticated, isFalse);
      expect(AppAuthGuard.isGuest, isTrue);
    });

    testWidgets('AppAuthGuard.requireAuth presents guest auth wall sheet',
        (tester) async {
      bool? result;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await AppAuthGuard.requireAuth(
                  context,
                  title: 'Özel Başlık',
                  message: 'Özel Mesaj',
                );
              },
              child: const Text('Test Guard'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Test Guard'));
      await tester.pumpAndSettle();

      // Verify the auth wall sheet appeared with title and message
      expect(find.text('Özel Başlık'), findsOneWidget);
      expect(find.text('Özel Mesaj'), findsOneWidget);
      expect(find.text(AppStrings.get('guest_auth_btn_login')), findsOneWidget);
      expect(find.text(AppStrings.get('guest_auth_btn_continue')), findsOneWidget);

      // Tap continue exploring (dismiss)
      await tester.tap(find.text(AppStrings.get('guest_auth_btn_continue')));
      await tester.pumpAndSettle();

      // Result should be false because user did not login
      expect(result, isFalse);
    });

    testWidgets('FigmaProfileScreen in guest mode renders guest UI correctly',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FigmaProfileScreen(onOpen: (_) {}),
        ),
      ));
      await tester.pump();

      // Verify guest displayName is shown
      expect(find.text(AppStrings.get('profile_guest_user')), findsOneWidget);

      // Verify guest login button is shown
      expect(find.text(AppStrings.get('guest_auth_btn_login')), findsWidgets);

      // Verify delete account button is NOT shown in guest mode
      expect(find.text(AppStrings.get('profile_delete_account')), findsNothing);

      // Verify feedback and legal links remain available
      expect(find.text(AppStrings.get('profile_feedback'), skipOffstage: false),
          findsOneWidget);
      expect(
          find.text(AppStrings.get('profile_privacy_policy'),
              skipOffstage: false),
          findsOneWidget);
      expect(find.text(AppStrings.get('profile_terms'), skipOffstage: false),
          findsOneWidget);
    });

    testWidgets('CommunityChatRoomScreen in guest mode renders locked input prompt',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: CommunityChatRoomScreen(
          category: 'Kamp & Karavan',
        ),
      ));
      await tester.pump();

      // Guest lock prompt must be visible
      expect(find.text(AppStrings.get('guest_chat_prompt')), findsOneWidget);

      // Tapping the guest prompt should trigger auth sheet
      await tester.tap(find.text(AppStrings.get('guest_chat_prompt')));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.get('guest_auth_title')), findsOneWidget);
      expect(find.text(AppStrings.get('guest_auth_btn_continue')), findsOneWidget);
    });

    testWidgets(
        'CommunityChatRoomScreen renders category-specific Q&A and prompt chips',
        (tester) async {
      // 1. Water room
      await tester.pumpWidget(const MaterialApp(
        home: CommunityChatRoomScreen(
          category: 'Su',
        ),
      ));
      await tester.pump();

      expect(find.text('Göl ve şelale çevresinde içilebilir temiz su kaynağı var mı?'),
          findsOneWidget);
      expect(find.text('Yakında içme suyu kaynağı var mı?'), findsOneWidget);

      // 2. Mountain room
      await tester.pumpWidget(const MaterialApp(
        home: CommunityChatRoomScreen(
          category: 'Dağ & Arazi',
        ),
      ));
      await tester.pump();

      expect(find.text('Zirveye ve yaylaya çıkan yol açık mı, binek araçla çıkılabilir mi?'),
          findsOneWidget);
      expect(find.text('Yayla yolu binek araca uygun mu?'), findsOneWidget);
    });

    test('LocationReverseGeocoder resolves truthful city and district names', () {
      // Pozanti coordinates -> Pozantı, Adana
      final pozanti = LocationReverseGeocoder.findNearestOfflineCity(37.4278, 34.8719);
      expect(pozanti, 'Pozantı, Adana');

      // Yenimahalle coordinates -> Yenimahalle, Ankara
      final yenimahalle = LocationReverseGeocoder.findNearestOfflineCity(39.9700, 32.7900);
      expect(yenimahalle, 'Yenimahalle, Ankara');

      // Konya coordinates -> Konya
      final konya = LocationReverseGeocoder.findNearestOfflineCity(37.8667, 32.4833);
      expect(konya, 'Konya');
    });

    testWidgets('LocationUpdateSheet renders GPS badge and update action without manual input',
        (tester) async {
      const testTarget = WeatherTarget.coordinates(
        latitude: 37.4278,
        longitude: 34.8719,
        label: 'Pozantı, Adana',
      );

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: LocationUpdateSheet(target: testTarget),
        ),
      ));
      await tester.pump();

      expect(find.text('Konum Bilgisi & Güncelleme'), findsOneWidget);
      expect(find.text('Pozantı, Adana'), findsOneWidget);
      expect(find.text('GPS Doğrulanmış'), findsOneWidget);
      expect(find.text('Konumu Güncelle'), findsOneWidget);
      // Ensure no TextField is present (no manual outside manipulation)
      expect(find.byType(TextField), findsNothing);
    });

    test('isNonNatureCandidateName eliminates false Obruk streets, mosques, and borders while preserving genuine karst sinkholes', () {
      // False records from screenshot
      expect(isNonNatureCandidateName('Yukarı Obruk Kümeevleri Sokağı', subtype: 'sinkhole'), isTrue);
      expect(isNonNatureCandidateName('Yukarı Obruk Kümeevleri Caddesi', subtype: 'sinkhole'), isTrue);
      expect(isNonNatureCandidateName('Yukarı Obruk Camii', subtype: 'sinkhole'), isTrue);
      expect(isNonNatureCandidateName('Yukarı Obruk - Özlüce mahalle sınırı', subtype: 'sinkhole'), isTrue);
      expect(isNonNatureCandidateName('Yukarı Obruk - Eğriekin mahalle sınırı', subtype: 'sinkhole'), isTrue);
      expect(isNonNatureCandidateName('Yukarı Obruk', subtype: 'sinkhole'), isTrue);
      expect(isNonNatureCandidateName('Yiğitli - Yukarı Obruk mahalle sınırı', subtype: 'sinkhole'), isTrue);

      // Genuine geological sinkholes must be kept
      expect(isNonNatureCandidateName('Kızören Obruğu', subtype: 'sinkhole'), isFalse);
      expect(isNonNatureCandidateName('Çıralı Obruğu', subtype: 'sinkhole'), isFalse);
      expect(isNonNatureCandidateName('Meyil Obruğu', subtype: 'sinkhole'), isFalse);
      expect(isNonNatureCandidateName('Obruk Gölü Tabiat Parkı', subtype: 'nature_park'), isFalse);
      expect(isNonNatureCandidateName('Cennet Cehennem Obrukları', subtype: 'sinkhole'), isFalse);
    });

    test('CommunityFacilityUpdatesController stores and updates facility status', () async {
      const place = Place(
        'Test Kanyonu',
        'Antalya',
        'Kanyon',
        4.8,
        Icons.water,
        [Colors.blue, Colors.green],
        'https://example.com/img.jpg',
        sourceId: 'canyon-1',
      );

      expect(CommunityFacilityUpdatesController.getStatus(place, 'drinking_water'), isNull);

      await CommunityFacilityUpdatesController.setStatus(
        place: place,
        facilityKey: 'drinking_water',
        value: true,
      );
      expect(CommunityFacilityUpdatesController.getStatus(place, 'drinking_water'), isTrue);

      await CommunityFacilityUpdatesController.setStatus(
        place: place,
        facilityKey: 'drinking_water',
        value: false,
      );
      expect(CommunityFacilityUpdatesController.getStatus(place, 'drinking_water'), isFalse);

      await CommunityFacilityUpdatesController.setStatus(
        place: place,
        facilityKey: 'drinking_water',
        value: null,
      );
      expect(CommunityFacilityUpdatesController.getStatus(place, 'drinking_water'), isNull);
    });

    test('CommunityPlacePhotosController stores photos and retrieves by author and place', () async {
      const place = Place(
        'Gölcük Yaylası',
        'Bolu',
        'Yayla',
        4.7,
        Icons.landscape,
        [Colors.green, Colors.teal],
        'https://example.com/golcuk.jpg',
        sourceId: 'golcuk-1',
      );

      await CommunityPlacePhotosController.addPhoto(
        place: place,
        imageUrl: 'https://example.com/custom_nature.jpg',
        authorName: 'Ahmet Gezgin',
        authorId: 'user-ahmet-123',
      );

      final placePhotos = CommunityPlacePhotosController.forPlace(place);
      expect(placePhotos.length, 1);
      expect(placePhotos.first.imageUrl, 'https://example.com/custom_nature.jpg');
      expect(placePhotos.first.authorName, 'Ahmet Gezgin');

      final authorPhotos = CommunityPlacePhotosController.byAuthor('Ahmet Gezgin');
      expect(authorPhotos.length, 1);
      expect(authorPhotos.first.placeName, 'Gölcük Yaylası');
    });

    test('UserProfileAvatarController updates and persists custom avatar', () async {
      expect(UserProfileAvatarController.avatarNotifier.value, isNull);

      await UserProfileAvatarController.setAvatar('https://example.com/avatar.jpg');
      expect(UserProfileAvatarController.avatarNotifier.value, 'https://example.com/avatar.jpg');

      await UserProfileAvatarController.setAvatar(null);
      expect(UserProfileAvatarController.avatarNotifier.value, isNull);
    });

    testWidgets('PublicUserProfileScreen renders author contributions and no private settings', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: PublicUserProfileScreen(
          authorName: 'Mert Doğa',
          authorId: 'mert-id',
          avatarUrl: null,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Mert Doğa'), findsOneWidget);
      expect(find.text('Doğa Kaşifi'), findsOneWidget);
      expect(find.text('Fotoğraf Katkıları (0)'), findsOneWidget);
      expect(find.text('Eklediği Doğa Mekanları (0)'), findsOneWidget);

      // Verify privacy: no settings, no delete account, no edit profile
      expect(find.text('Hesabı Sil'), findsNothing);
      expect(find.text('Profili Düzenle'), findsNothing);
      expect(find.text('Çıkış Yap'), findsNothing);
    });

    test('local_service businesses category is preserved and maps properly', () {
      final taxonomy = taxonomyFromLegacy('İşletme / Hizmet');
      expect(taxonomy.mainCategory, 'local_service');
      expect(taxonomy.subtype, 'local_service');

      const businessPlace = Place(
        'Ahmet Usta Demir Kaynak & Oto Lastik',
        'Pozantı, Adana',
        'İşletme / Hizmet',
        5.0,
        Icons.storefront_rounded,
        [Colors.blue, Colors.orange],
        'https://example.com/kaynakci.jpg',
        mainCategory: 'local_service',
        subtype: 'local_service',
      );

      expect(isNonNatureCandidateName(businessPlace.name, mainCategory: 'local_service'), isFalse);
    });

    test('UserReviewsController deleteReview removes the review for a place', () async {
      const place = Place(
        'Yedigöller',
        'Bolu',
        'Göl',
        4.9,
        Icons.water,
        [Colors.green, Colors.blue],
        null,
        sourceId: 'yedigoller-rev-1',
      );

      await UserReviewsController.saveReview(
        place: place,
        rating: 5,
        content: 'Harika bir yer!',
      );
      expect(UserReviewsController.userReviewForPlace(place), isNotNull);

      await UserReviewsController.deleteReview(place);
      expect(UserReviewsController.userReviewForPlace(place), isNull);
    });

    test('CommunityPlacePhotosController removePhoto removes wrongly uploaded photo', () async {
      const place = Place(
        'Abant Gölü',
        'Bolu',
        'Göl',
        4.8,
        Icons.water,
        [Colors.blue, Colors.teal],
        null,
        sourceId: 'abant-wrong-photo-1',
      );

      await CommunityPlacePhotosController.addPhoto(
        place: place,
        imageUrl: 'https://example.com/mistaken_photo.jpg',
        authorName: 'Doğa Dostu',
      );

      final photosBefore = CommunityPlacePhotosController.forPlace(place);
      expect(photosBefore.length, 1);
      final photoId = photosBefore.first.id;

      await CommunityPlacePhotosController.removePhoto(photoId);
      final photosAfter = CommunityPlacePhotosController.forPlace(place);
      expect(photosAfter, isEmpty);
    });

    test('UserSocialAccountsController saves and persists instagram, facebook, youtube', () async {
      await UserSocialAccountsController.save(
        instagram: '@dogasever',
        facebook: 'dogasever.resmi',
        youtube: '@dogadayiim',
      );

      final accounts = UserSocialAccountsController.accounts.value;
      expect(accounts.instagram, '@dogasever');
      expect(accounts.facebook, 'dogasever.resmi');
      expect(accounts.youtube, '@dogadayiim');
      expect(accounts.isNotEmpty, isTrue);

      await UserSocialAccountsController.save(
        instagram: '',
        facebook: '',
        youtube: '',
      );
      expect(UserSocialAccountsController.accounts.value.isEmpty, isTrue);
    });

    test('Place mobile service helpers extract contactPhone, workingHours and isMobileService', () {
      const servicePlace = Place(
        'Toros Karavan & Yol Yardım',
        'Antalya, Konyaaltı',
        'Çekici / Yol Yardım',
        4.9,
        Icons.local_shipping_rounded,
        [Colors.amber, Colors.orange],
        null,
        mainCategory: 'local_service',
        subtype: 'service_roadside',
        features: ['Telefon: 0532 111 22 33', 'Çalışma: 7/24 Açık', 'Hizmet: Çekici'],
      );

      expect(servicePlace.isMobileService, isTrue);
      expect(servicePlace.contactPhone, '0532 111 22 33');
      expect(servicePlace.workingHours, '7/24 Açık');

      const regularPlace = Place(
        'Düden Şelalesi',
        'Antalya',
        'Şelale',
        4.8,
        Icons.water,
        [Colors.blue, Colors.cyan],
        null,
        mainCategory: 'water',
        subtype: 'waterfall',
        features: ['Ulaşım: Asfalt yol'],
      );

      expect(regularPlace.isMobileService, isFalse);
      expect(regularPlace.contactPhone, isNull);
      expect(regularPlace.workingHours, isNull);
    });

    testWidgets('MobileServiceHubScreen renders 10 services and firm registration card', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: MobileServiceHubScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Mobil Servis'), findsOneWidget);
      expect(find.text('Hangi hizmete ihtiyacın var?'), findsOneWidget);
      expect(find.text('Çekici / Yol Yardım'), findsOneWidget);
      expect(find.text('Yıllık Bakım'), findsOneWidget);
      expect(find.text('Gaz Tesisatı'), findsOneWidget);
      expect(find.text('Isıtma & Soğutma'), findsOneWidget);
      expect(find.text('Elektrik & Enerji'), findsOneWidget);
      expect(find.text('Su & Tesisat'), findsOneWidget);
      expect(find.text('Nem & Gövde'), findsOneWidget);
      expect(find.text('Şasi & Fren'), findsOneWidget);
      expect(find.text('Montaj & Parça'), findsOneWidget);
      expect(find.text('Muayene'), findsOneWidget);
      expect(find.text('Servis veren firma mısınız?'), findsOneWidget);
      expect(find.text('Firmanızı ekleyin, inceleyip listeleyelim'), findsOneWidget);
    });
  });
}
