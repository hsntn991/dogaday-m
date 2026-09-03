part of '../../main.dart';

abstract final class AppColors {
  static const background = Color(0xFFFAFBFA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF5F7F5);
  static const border = Color(0xFFE2E6E2);
  static const primary = Color(0xFF1F5A35);
  static const primarySoft = Color(0xFFEDF4EF);
  static const textPrimary = Color(0xFF171A18);
  static const textSecondary = Color(0xFF69706B);
  static const textTertiary = Color(0xFF929993);
}

abstract final class AppRadii {
  static const double small = 6;
  static const double medium = 8;
  static const double large = 10;
  static const double pill = 999;
}

abstract final class AppSpacing {
  static const double xSmall = 4;
  static const double small = 8;
  static const double medium = 16;
  static const double large = 24;
  static const double xLarge = 32;
}

abstract final class AppTypography {
  static const heading = TextStyle(
    fontFamily: 'Outfit',
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w600,
    letterSpacing: -.25,
  );
  static const body = TextStyle(
    fontFamily: 'Outfit',
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w400,
  );
  static const metadata = TextStyle(
    fontFamily: 'Outfit',
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w400,
  );
}

const green = AppColors.primary;
const mint = AppColors.primarySoft;
const ink = AppColors.textPrimary;
const sand = AppColors.background;

const natureQuotes = <String>[
  'Bir patika, bazen varılacak yerden daha çok şey anlatır.',
  'Ormanın sessizliği, zihnin en temiz sesidir.',
  'Gökyüzüne bakmak, dünyaya yeniden başlamaktır.',
  'Her yürüyüş, insanı biraz daha kendine yaklaştırır.',
  'Doğada geçirilen zaman, hayattan eksilmez.',
  'Rüzgârın yönü değişir; keşfetme isteği kalır.',
  'Bir ağacın gölgesi, yolcunun en sade evidir.',
  'Dağlar uzaktan değil, yürüdükçe anlaşılır.',
  'Toprağa dokunduğunda günün ağırlığı hafifler.',
  'En güzel manzaralar, merakın bittiği yerde başlar.',
  'Su yolunu, gezgin ise kendi hikâyesini bulur.',
  'Doğa konuşmaz; yine de çok şey söyler.',
  'Yeni bir rota, yeni bir bakış demektir.',
  'Güneş her patikaya başka bir renk bırakır.',
  'Yavaşla; manzara seni bekliyor.',
  'Bir nefes orman, bir gün huzur demektir.',
  'Uzaklara gitmek bazen kendine yaklaşmaktır.',
  'Yağmurdan sonra yalnız toprak değil, insan da yenilenir.',
  'Her zirve, önce atılmış küçük bir adımdır.',
  'Göl kıyısında zaman daha sakin akar.',
  'Keşfetmek, dünyayı ilk kez görür gibi bakmaktır.',
  'Doğanın renkleri ruhun en güzel haritasıdır.',
  'Kuşların sesi, sabahın en gerçek haberidir.',
  'Bir kamp ateşi, birçok güzel hikâyeyi ısıtır.',
  'Yol uzunsa manzaranın anlatacakları da çoktur.',
  'Sessiz bir vadi, kalabalık bir zihni dinlendirir.',
  'Ayak izlerin kalsın; gerisi doğaya ait olsun.',
  'Temiz bıraktığın her yer, yeniden çağırır.',
  'Bugünün rotası, yarının en güzel anısı olabilir.',
  'Doğaya çıktığında dünya büyür, dertler küçülür.',
];

String dailyNatureQuote([DateTime? date]) {
  final now = date ?? DateTime.now();
  final today = DateTime.utc(now.year, now.month, now.day);
  final reference = DateTime.utc(2025, 1, 1);
  final dayNumber = today.difference(reference).inDays.abs();
  return natureQuotes[dayNumber % natureQuotes.length];
}

enum PlaceSource { osm, user, curated }

enum VerificationStatus { verified, community, unverified }

class Place {
  const Place(
    this.name,
    this.location,
    this.kind,
    this.rating,
    this.icon,
    this.colors,
    this.image, {
    this.description =
        'Doğanın içinde sakin, temiz ve unutulmaz bir keşif noktası.',
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.sourceId,
    this.updatedAt,
    this.source = PlaceSource.curated,
    this.verificationStatus = VerificationStatus.verified,
  });
  final String name, location, kind, description;
  final String? image;
  final double rating;
  final IconData icon;
  final List<Color> colors;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final String? sourceId;
  final DateTime? updatedAt;
  final PlaceSource source;
  final VerificationStatus verificationStatus;

  bool get hasCoordinates => latitude != null && longitude != null;

  WeatherTarget get weatherTarget => hasCoordinates
      ? WeatherTarget.coordinates(
          latitude: latitude!,
          longitude: longitude!,
          label: name,
        )
      : WeatherTarget.city(location);
}

enum PlaceDuplicateLevel { none, probable, strong }

class PlaceDuplicateMatch {
  const PlaceDuplicateMatch({
    required this.place,
    required this.level,
    required this.distanceKm,
    required this.nameSimilarity,
  });

  final Place place;
  final PlaceDuplicateLevel level;
  final double distanceKm;
  final double nameSimilarity;
}

class PlaceDuplicateAssessment {
  const PlaceDuplicateAssessment({
    this.strongMatch,
    this.probableMatches = const <PlaceDuplicateMatch>[],
  });

  final PlaceDuplicateMatch? strongMatch;
  final List<PlaceDuplicateMatch> probableMatches;

  PlaceDuplicateLevel get level => strongMatch != null
      ? PlaceDuplicateLevel.strong
      : probableMatches.isNotEmpty
          ? PlaceDuplicateLevel.probable
          : PlaceDuplicateLevel.none;
}

class AddPlaceValidationResult {
  const AddPlaceValidationResult(this.errors);

  final Map<String, String> errors;
  bool get isValid => errors.isEmpty;
}

class AddPlaceQualityService {
  AddPlaceQualityService._();

  static const minNameLength = 3;
  static const maxNameLength = 80;
  static const minDescriptionLength = 20;
  static const maxDescriptionLength = 500;
  static const maxPhotoCount = 6;

  // Aynı doğal noktanın GPS sapmasıyla yeniden işaretlenmesini yakalar.
  static const strongDuplicateDistanceKm = .12;

  // Aynı alan içindeki muhtemel kayıtları gösterir, otomatik olarak engellemez.
  static const probableDuplicateDistanceKm = .30;
  static const sameNameProbableDistanceKm = .80;

  static String normalizeName(String input) {
    var value = input
        .replaceAll('İ', 'i')
        .replaceAll('I', 'i')
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ş', 's')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
    value = value.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String? validateName(String input) {
    final trimmed = input.trim();
    final normalized = normalizeName(trimmed).replaceAll(' ', '');
    if (trimmed.isEmpty) return 'Yer adı zorunludur.';
    if (trimmed.length > maxNameLength) {
      return 'Yer adı en fazla $maxNameLength karakter olabilir.';
    }
    if (normalized.length < minNameLength ||
        normalized.split('').toSet().length < 2) {
      return 'Daha açıklayıcı bir yer adı yaz.';
    }
    return null;
  }

  static String? validateDescription(String input) {
    final trimmed = input.trim();
    final meaningful = normalizeName(trimmed).replaceAll(' ', '');
    if (trimmed.isEmpty) return 'Kısa açıklama zorunludur.';
    if (trimmed.length > maxDescriptionLength) {
      return 'Açıklama en fazla $maxDescriptionLength karakter olabilir.';
    }
    if (meaningful.length < minDescriptionLength ||
        meaningful.split('').toSet().length < 5) {
      return 'En az $minDescriptionLength karakterlik açıklayıcı bir metin yaz.';
    }
    return null;
  }

  static bool isValidCoordinate(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    if (!latitude.isFinite || !longitude.isFinite) return false;
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      return false;
    }
    return latitude.abs() > .0001 || longitude.abs() > .0001;
  }

  static AddPlaceValidationResult validate({
    required String name,
    required String? category,
    required String description,
    required double? latitude,
    required double? longitude,
  }) {
    final errors = <String, String>{};
    if (validateName(name) case final error?) errors['name'] = error;
    if (category == null || category.trim().isEmpty) {
      errors['category'] = 'Bir ana kategori seç.';
    }
    if (validateDescription(description) case final error?) {
      errors['description'] = error;
    }
    if (!isValidCoordinate(latitude, longitude)) {
      errors['location'] = 'Haritadan geçerli bir konum seç.';
    }
    return AddPlaceValidationResult(errors);
  }

  static PlaceDuplicateAssessment assessDuplicates({
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    required Iterable<Place> existingPlaces,
  }) {
    final normalizedName = normalizeName(name);
    final normalizedCategory = _canonicalCategory(category);
    PlaceDuplicateMatch? strongMatch;
    final probableMatches = <PlaceDuplicateMatch>[];
    final seenPlaces = <String>{};

    for (final place in existingPlaces) {
      if (!place.hasCoordinates ||
          !isValidCoordinate(place.latitude, place.longitude)) {
        continue;
      }
      final placeKey = place.sourceId ??
          '${normalizeName(place.name)}:'
              '${place.latitude!.toStringAsFixed(5)}:'
              '${place.longitude!.toStringAsFixed(5)}';
      if (!seenPlaces.add(placeKey)) continue;
      final categoryMatches =
          _canonicalCategory(place.kind) == normalizedCategory;
      if (!categoryMatches) continue;

      final distanceKm = NearbyPlacesService.calculateDistanceKm(
        latitude,
        longitude,
        place.latitude!,
        place.longitude!,
      );
      final similarity = _nameSimilarity(
        normalizedName,
        normalizeName(place.name),
      );
      final isStrong =
          distanceKm <= strongDuplicateDistanceKm && similarity >= .88;
      final isProbable =
          (distanceKm <= probableDuplicateDistanceKm && similarity >= .45) ||
              (distanceKm <= sameNameProbableDistanceKm && similarity >= .88);

      final match = PlaceDuplicateMatch(
        place: place,
        level: isStrong
            ? PlaceDuplicateLevel.strong
            : PlaceDuplicateLevel.probable,
        distanceKm: distanceKm,
        nameSimilarity: similarity,
      );
      if (isStrong &&
          (strongMatch == null || distanceKm < strongMatch.distanceKm)) {
        strongMatch = match;
      } else if (isProbable) {
        probableMatches.add(match);
      }
    }

    probableMatches.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return PlaceDuplicateAssessment(
      strongMatch: strongMatch,
      probableMatches: probableMatches.take(3).toList(growable: false),
    );
  }

  static String _canonicalCategory(String value) {
    final normalized = normalizeName(value);
    if (normalized.contains('kamp')) return 'kamp';
    if (normalized.contains('selale')) return 'selale';
    if (normalized.contains('su kaynagi')) return 'su kaynagi';
    if (normalized.contains('dogal kaynak')) return 'dogal kaynak';
    if (normalized.contains('gol')) return 'gol';
    if (normalized.contains('piknik')) return 'piknik';
    if (normalized.contains('yuruyus') || normalized.contains('milli park')) {
      return 'yuruyus';
    }
    if (normalized.contains('seyir')) return 'seyir';
    if (normalized.contains('magara')) return 'magara';
    if (normalized.contains('karavan')) return 'karavan';
    return normalized;
  }

  static double _nameSimilarity(String first, String second) {
    if (first == second) return 1;
    if (first.isEmpty || second.isEmpty) return 0;
    final distance = _levenshteinDistance(first, second);
    return 1 - distance / math.max(first.length, second.length);
  }

  static int _levenshteinDistance(String first, String second) {
    var previous = List<int>.generate(second.length + 1, (index) => index);
    for (var firstIndex = 1; firstIndex <= first.length; firstIndex++) {
      final current = List<int>.filled(second.length + 1, 0);
      current[0] = firstIndex;
      for (var secondIndex = 1; secondIndex <= second.length; secondIndex++) {
        final cost = first[firstIndex - 1] == second[secondIndex - 1] ? 0 : 1;
        current[secondIndex] = math.min(
          math.min(
            current[secondIndex - 1] + 1,
            previous[secondIndex] + 1,
          ),
          previous[secondIndex - 1] + cost,
        );
      }
      previous = current;
    }
    return previous.last;
  }
}

class UserPlacesController {
  UserPlacesController._();

  static const _storageKey = 'user_added_places_v1';
  static final places = ValueNotifier<List<Place>>(<Place>[]);

  static PlaceSource _sourceFromStorage(Object? value) {
    for (final item in PlaceSource.values) {
      if (item.name == value) return item;
    }
    return PlaceSource.user;
  }

  static VerificationStatus _verificationFromStorage(Object? value) {
    for (final item in VerificationStatus.values) {
      if (item.name == value) return item;
    }
    return VerificationStatus.unverified;
  }

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final records = preferences.getStringList(_storageKey) ?? const <String>[];
    places.value = records
        .map((record) {
          final data = jsonDecode(record) as Map<String, dynamic>;
          return Place(
            data['name']?.toString() ?? 'Yeni Yer',
            data['location']?.toString() ?? 'Seçilen konum',
            data['kind']?.toString() ?? 'Doğa Noktası',
            0,
            Icons.place_rounded,
            const [Color(0xFF315F45), Color(0xFF9BBF82)],
            data['image']?.toString(),
            description: data['description']?.toString() ?? '',
            latitude: (data['latitude'] as num?)?.toDouble(),
            longitude: (data['longitude'] as num?)?.toDouble(),
            sourceId: data['sourceId']?.toString(),
            updatedAt: DateTime.tryParse(data['updatedAt']?.toString() ?? ''),
            source: _sourceFromStorage(data['source']),
            verificationStatus:
                _verificationFromStorage(data['verificationStatus']),
          );
        })
        .where((place) => place.hasCoordinates)
        .toList(growable: false);
  }

  static Future<void> add(Place place) async {
    places.value = <Place>[place, ...places.value];
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _storageKey,
      places.value
          .map((item) => jsonEncode({
                'name': item.name,
                'location': item.location,
                'kind': item.kind,
                'description': item.description,
                'image': item.image,
                'latitude': item.latitude,
                'longitude': item.longitude,
                'sourceId': item.sourceId,
                'updatedAt': item.updatedAt?.toIso8601String(),
                'source': item.source.name,
                'verificationStatus': item.verificationStatus.name,
              }))
          .toList(growable: false),
    );
  }
}

class SupabasePlacesController {
  SupabasePlacesController._();

  static final places = ValueNotifier<List<Place>>(<Place>[]);

  static Future<void> load() async {
    final rows = await Supabase.instance.client
        .from('places')
        .select(
          'id, name, short_description, description, city, district, '
          'latitude, longitude, is_verified, updated_at, categories(name)',
        )
        .eq('is_active', true)
        .order('name');

    final loadedPlaces = <Place>[];

    for (final row in rows) {
      final data = Map<String, dynamic>.from(row);

      final categoryData = data['categories'];
      final categoryName =
          categoryData is Map ? categoryData['name']?.toString() : null;

      final city = data['city']?.toString().trim() ?? '';
      final district = data['district']?.toString().trim() ?? '';

      final location = district.isNotEmpty ? '$district, $city' : city;

      final shortDescription =
          data['short_description']?.toString().trim() ?? '';

      final description = data['description']?.toString().trim() ?? '';

      loadedPlaces.add(
        Place(
          data['name']?.toString() ?? 'Doğa Noktası',
          location,
          categoryName ?? 'Doğa Noktası',
          0,
          Icons.place_rounded,
          const [
            Color(0xFF315F45),
            Color(0xFF9BBF82),
          ],
          null,
          description:
              shortDescription.isNotEmpty ? shortDescription : description,
          latitude: (data['latitude'] as num?)?.toDouble(),
          longitude: (data['longitude'] as num?)?.toDouble(),
          sourceId: 'supabase:${data['id']}',
          updatedAt: DateTime.tryParse(
            data['updated_at']?.toString() ?? '',
          ),
          source: PlaceSource.curated,
          verificationStatus: data['is_verified'] == true
              ? VerificationStatus.verified
              : VerificationStatus.unverified,
        ),
      );
    }

    places.value = loadedPlaces
        .where((place) => place.hasCoordinates)
        .toList(growable: false);

    debugPrint(
      'SUPABASE PLACES: ${places.value.length} yer modele dönüştürüldü',
    );
  }
}

class CommunitySuggestion {
  const CommunitySuggestion({
    required this.place,
    required this.recommendationCount,
  });

  final Place place;
  final int recommendationCount;
}

class ReviewEntry {
  const ReviewEntry({
    required this.id,
    required this.initial,
    required this.color,
    required this.name,
    required this.timeLabel,
    required this.createdAt,
    required this.content,
    required this.rating,
    required this.helpfulCount,
  });

  final String id;
  final String initial;
  final Color color;
  final String name;
  final String timeLabel;
  final DateTime createdAt;
  final String content;
  final int rating;
  final int helpfulCount;
}

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.resolvedLocation,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.visibilityKm,
    required this.uvIndex,
    required this.minimumTemperature,
    required this.maximumTemperature,
    required this.weatherCode,
    required this.isDay,
  });

  final String resolvedLocation;
  final double temperature;
  final double apparentTemperature;
  final double humidity;
  final double windSpeed;
  final double visibilityKm;
  final double uvIndex;
  final double minimumTemperature;
  final double maximumTemperature;
  final int weatherCode;
  final bool isDay;

  String get condition {
    if (weatherCode == 0) return 'Açık';
    if (weatherCode == 1) return 'Çoğunlukla Açık';
    if (weatherCode == 2) return 'Parçalı Bulutlu';
    if (weatherCode == 3) return 'Kapalı';
    if (weatherCode == 45 || weatherCode == 48) return 'Sisli';
    if (weatherCode >= 51 && weatherCode <= 57) return 'Çisenti';
    if (weatherCode >= 61 && weatherCode <= 67) return 'Yağmurlu';
    if (weatherCode >= 71 && weatherCode <= 77) return 'Karlı';
    if (weatherCode >= 80 && weatherCode <= 82) return 'Sağanak Yağışlı';
    if (weatherCode >= 85 && weatherCode <= 86) return 'Kar Sağanaklı';
    if (weatherCode >= 95) return 'Gök Gürültülü';
    return 'Değişken';
  }

  String get emoji {
    if (weatherCode == 0) return isDay ? '☀️' : '🌙';
    if (weatherCode <= 2) return isDay ? '🌤️' : '☁️';
    if (weatherCode == 3) return '☁️';
    if (weatherCode == 45 || weatherCode == 48) return '🌫️';
    if (weatherCode >= 51 && weatherCode <= 67) return '🌧️';
    if (weatherCode >= 71 && weatherCode <= 77) return '❄️';
    if (weatherCode >= 80 && weatherCode <= 82) return '🌦️';
    if (weatherCode >= 85 && weatherCode <= 86) return '🌨️';
    if (weatherCode >= 95) return '⛈️';
    return '🌤️';
  }
}

class WeatherTarget {
  const WeatherTarget.city(this.label)
      : latitude = null,
        longitude = null;

  const WeatherTarget.coordinates({
    required this.latitude,
    required this.longitude,
    this.label = 'Konumum',
  });

  final String label;
  final double? latitude;
  final double? longitude;

  bool get usesCoordinates => latitude != null && longitude != null;

  String get cacheKey => usesCoordinates
      ? 'coord:${latitude!.toStringAsFixed(3)},${longitude!.toStringAsFixed(3)}'
      : 'city:${label.trim().toLowerCase()}';
}

class HomeWeatherLocationController {
  HomeWeatherLocationController._();

  static const fallbackCity = 'Antalya';
  static final current =
      ValueNotifier<WeatherTarget>(const WeatherTarget.city(fallbackCity));
  static final isResolvingLocation = ValueNotifier<bool>(false);

  static void useManualCity(String city) {
    final value = city.trim();
    if (value.isNotEmpty) current.value = WeatherTarget.city(value);
  }

  static void useDeviceCoordinates({
    required double latitude,
    required double longitude,
    String label = 'Konumum',
  }) {
    current.value = WeatherTarget.coordinates(
      latitude: latitude,
      longitude: longitude,
      label: label,
    );
  }

  static Future<DeviceCoordinates> requestAndUseDeviceLocation() async {
    isResolvingLocation.value = true;
    try {
      final coordinates = await DeviceLocationService.requestCurrentPosition();
      useDeviceCoordinates(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
        label: coordinates.label,
      );
      return coordinates;
    } finally {
      isResolvingLocation.value = false;
    }
  }

  static void useFallbackCity() {
    current.value = const WeatherTarget.city(fallbackCity);
  }
}

class DrivingRouteEstimate {
  const DrivingRouteEstimate({
    required this.distanceKm,
    required this.durationMinutes,
  });

  final double distanceKm;
  final int durationMinutes;

  String get distanceLabel => distanceKm < 10
      ? '${distanceKm.toStringAsFixed(1)} km'
      : '${distanceKm.toStringAsFixed(0)} km';

  String get durationLabel {
    if (durationMinutes < 60) return '$durationMinutes dk';
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return minutes == 0 ? '$hours sa' : '$hours sa $minutes dk';
  }
}

class DrivingRouteService {
  DrivingRouteService._();

  static final _cache = <String, DrivingRouteEstimate>{};

  static Future<DrivingRouteEstimate?> fetch({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  }) async {
    final key = '${fromLatitude.toStringAsFixed(4)},'
        '${fromLongitude.toStringAsFixed(4)}:'
        '${toLatitude.toStringAsFixed(4)},${toLongitude.toStringAsFixed(4)}';
    final cached = _cache[key];
    if (cached != null) return cached;

    final coordinates = '${fromLongitude.toStringAsFixed(6)},'
        '${fromLatitude.toStringAsFixed(6)};'
        '${toLongitude.toStringAsFixed(6)},${toLatitude.toStringAsFixed(6)}';
    final uri = Uri.https(
      'router.project-osrm.org',
      '/route/v1/driving/$coordinates',
      const {
        'overview': 'false',
        'alternatives': 'false',
        'steps': 'false',
      },
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic> || data['code'] != 'Ok') return null;
      final routes = data['routes'];
      if (routes is! List || routes.isEmpty || routes.first is! Map) {
        return null;
      }
      final route = routes.first as Map;
      final distanceMeters = (route['distance'] as num?)?.toDouble();
      final durationSeconds = (route['duration'] as num?)?.toDouble();
      if (distanceMeters == null || durationSeconds == null) return null;
      final estimate = DrivingRouteEstimate(
        distanceKm: distanceMeters / 1000,
        durationMinutes: math.max(1, (durationSeconds / 60).round()).toInt(),
      );
      _cache[key] = estimate;
      return estimate;
    } catch (_) {
      return null;
    }
  }
}

class WeatherService {
  WeatherService._();

  static final _cache =
      <String, ({DateTime fetchedAt, WeatherSnapshot weather})>{};
  static final revision = ValueNotifier<int>(0);

  static WeatherSnapshot? availableNow(WeatherTarget target) =>
      _cache[target.cacheKey]?.weather;

  static Future<WeatherSnapshot> fetch(
    String location, {
    bool forceRefresh = false,
  }) =>
      fetchTarget(
        WeatherTarget.city(location),
        forceRefresh: forceRefresh,
      );

  static Future<WeatherSnapshot> fetchTarget(
    WeatherTarget target, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = target.cacheKey;
    final cached = _cache[cacheKey];
    if (!forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.fetchedAt) <
            const Duration(minutes: 15)) {
      return cached.weather;
    }

    late double latitude;
    late double longitude;
    final resolvedParts = <String>{};

    if (target.usesCoordinates) {
      latitude = target.latitude!;
      longitude = target.longitude!;
      resolvedParts.add(target.label);
    } else {
      final geocodingUri = Uri.https(
        'geocoding-api.open-meteo.com',
        '/v1/search',
        {
          'name': target.label,
          'count': '1',
          'language': 'tr',
          'format': 'json',
          'countryCode': 'TR',
        },
      );
      final geocodingResponse =
          await http.get(geocodingUri).timeout(const Duration(seconds: 12));
      if (geocodingResponse.statusCode != 200) {
        throw Exception('Konum servisine ulaşılamadı.');
      }

      final geocodingData =
          jsonDecode(geocodingResponse.body) as Map<String, dynamic>;
      final results = geocodingData['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) {
        throw Exception('${target.label} için konum bulunamadı.');
      }

      final match = results.first as Map<String, dynamic>;
      latitude = (match['latitude'] as num).toDouble();
      longitude = (match['longitude'] as num).toDouble();
      if (match['name'] case final String name) resolvedParts.add(name);
      if (match['admin1'] case final String admin1) resolvedParts.add(admin1);
    }

    final forecastUri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m,visibility,uv_index',
        'daily': 'temperature_2m_max,temperature_2m_min',
        'timezone': 'auto',
        'forecast_days': '1',
      },
    );
    final forecastResponse =
        await http.get(forecastUri).timeout(const Duration(seconds: 12));
    if (forecastResponse.statusCode != 200) {
      throw Exception('Hava durumu servisine ulaşılamadı.');
    }

    final forecastData =
        jsonDecode(forecastResponse.body) as Map<String, dynamic>;
    final current = forecastData['current'] as Map<String, dynamic>?;
    final daily = forecastData['daily'] as Map<String, dynamic>?;
    if (current == null || daily == null) {
      throw Exception('Hava durumu verisi eksik geldi.');
    }

    double number(Map<String, dynamic> source, String key) =>
        (source[key] as num?)?.toDouble() ?? 0;
    double dailyNumber(String key) {
      final values = daily[key] as List<dynamic>?;
      return values == null || values.isEmpty
          ? 0
          : (values.first as num).toDouble();
    }

    final snapshot = WeatherSnapshot(
      resolvedLocation:
          resolvedParts.isEmpty ? target.label : resolvedParts.join(', '),
      temperature: number(current, 'temperature_2m'),
      apparentTemperature: number(current, 'apparent_temperature'),
      humidity: number(current, 'relative_humidity_2m'),
      windSpeed: number(current, 'wind_speed_10m'),
      visibilityKm: number(current, 'visibility') / 1000,
      uvIndex: number(current, 'uv_index'),
      minimumTemperature: dailyNumber('temperature_2m_min'),
      maximumTemperature: dailyNumber('temperature_2m_max'),
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
      isDay: (current['is_day'] as num?)?.toInt() == 1,
    );
    _cache[cacheKey] = (fetchedAt: DateTime.now(), weather: snapshot);
    revision.value++;
    return snapshot;
  }
}

class NearbyPlacesService {
  NearbyPlacesService._();

  static const _radiusMeters = 25000;
  static const _cacheCellDegrees = .05;
  static const _perEndpointTimeout = Duration(seconds: 6);
  static const _maxOverpassDuration = Duration(seconds: 10);
  static const _resultLimit = 150;
  static const _endpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];
  static final _cache = <String, ({DateTime fetchedAt, List<Place> places})>{};
  static final _inFlight = <String, Future<List<Place>>>{};
  static final revision = ValueNotifier<int>(0);

  static int get queryRadiusMeters => _radiusMeters;
  static int get queryRadiusKm => _radiusMeters ~/ 1000;
  static Duration get maxOverpassDuration => _maxOverpassDuration;

  static String cacheRegionKey(WeatherTarget target) {
    if (!target.usesCoordinates) {
      return 'nearby:r$_radiusMeters:city:${target.label.trim().toLowerCase()}';
    }
    final latitudeCell = (target.latitude! / _cacheCellDegrees).round();
    final longitudeCell = (target.longitude! / _cacheCellDegrees).round();
    return 'nearby:r$_radiusMeters:cell:$latitudeCell:$longitudeCell';
  }

  static Future<List<Place>> fetch(
    WeatherTarget target, {
    bool forceRefresh = false,
  }) {
    final available = availableNow(target);
    _refreshInBackground(target, forceRefresh: forceRefresh);
    return Future<List<Place>>.value(available);
  }

  static List<Place> availableNow(WeatherTarget target) {
    final cached = _cache[cacheRegionKey(target)];
    return _mergeAvailablePlaces(
      target,
      cached?.places ?? const <Place>[],
    );
  }

  static List<Place> availableLatestNow(WeatherTarget target) {
    final result = List<Place>.of(availableNow(target))
      ..removeWhere(
        (place) => (place.distanceKm ?? double.infinity) > queryRadiusKm,
      )
      ..sort((a, b) {
        final dateA = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateOrder = dateB.compareTo(dateA);
        if (dateOrder != 0) return dateOrder;
        return (a.distanceKm ?? double.infinity)
            .compareTo(b.distanceKm ?? double.infinity);
      });
    return result.take(4).toList(growable: false);
  }

  static void _refreshInBackground(
    WeatherTarget target, {
    required bool forceRefresh,
  }) {
    final cacheKey = cacheRegionKey(target);
    final cached = _cache[cacheKey];
    final cacheIsFresh = cached != null &&
        DateTime.now().difference(cached.fetchedAt) <
            const Duration(minutes: 30);
    if (!forceRefresh && cacheIsFresh) return;
    if (_inFlight.containsKey(cacheKey)) return;

    final request = _load(target, forceRefresh: forceRefresh);
    _inFlight[cacheKey] = request;
    unawaited(
      request.then<void>((_) {
        revision.value++;
      }).catchError((Object _) {
        // Local ve mevcut cache görünür kalır; ağ hatası ekranı bloke etmez.
      }).whenComplete(() {
        _inFlight.remove(cacheKey);
      }),
    );
  }

  static List<Place> _mergeAvailablePlaces(
    WeatherTarget target,
    List<Place> remotePlaces,
  ) {
    final localPlaces = UserPlacesController.places.value
        .where((place) => place.hasCoordinates)
        .map((place) {
      final distance = target.usesCoordinates
          ? calculateDistanceKm(
              target.latitude!,
              target.longitude!,
              place.latitude!,
              place.longitude!,
            )
          : place.distanceKm ?? 0;
      return Place(
        place.name,
        place.location,
        place.kind,
        place.rating,
        place.icon,
        place.colors,
        place.image,
        description: place.description,
        latitude: place.latitude,
        longitude: place.longitude,
        distanceKm: distance,
        sourceId: place.sourceId,
        updatedAt: place.updatedAt,
        source: place.source,
        verificationStatus: place.verificationStatus,
      );
    }).where((place) =>
            (place.distanceKm ?? double.infinity) <= queryRadiusKm + .5);

    final merged = <Place>[...localPlaces, ...remotePlaces];
    final seen = <String>{};
    merged.retainWhere((place) {
      final latitude = place.latitude;
      final longitude = place.longitude;
      final key = latitude != null && longitude != null
          ? '${place.name.trim().toLowerCase()}:${latitude.toStringAsFixed(4)}:${longitude.toStringAsFixed(4)}'
          : place.sourceId ?? place.name.trim().toLowerCase();
      return seen.add(key);
    });
    merged.sort((a, b) => (a.distanceKm ?? double.infinity)
        .compareTo(b.distanceKm ?? double.infinity));
    return merged;
  }

  static Future<List<Place>> fetchLatest(
    WeatherTarget target, {
    bool forceRefresh = false,
  }) async {
    await fetch(target, forceRefresh: forceRefresh);
    return availableLatestNow(target);
  }

  static Future<List<Place>> _load(
    WeatherTarget target, {
    required bool forceRefresh,
  }) async {
    final cacheKey = cacheRegionKey(target);
    final cached = _cache[cacheKey];
    if (!forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.fetchedAt) <
            const Duration(minutes: 30)) {
      return cached.places;
    }

    final origin = await resolveTarget(target);
    final query = '''
[out:json][timeout:6][maxsize:16777216];
(
  nwr(around:$_radiusMeters,${origin.latitude},${origin.longitude})["name"]["waterway"="waterfall"];
  nwr(around:$_radiusMeters,${origin.latitude},${origin.longitude})["name"]["natural"~"^(spring|water|cave_entrance)\$"];
  nwr(around:$_radiusMeters,${origin.latitude},${origin.longitude})["name"]["tourism"~"^(viewpoint|camp_site|caravan_site|picnic_site)\$"];
  nwr(around:$_radiusMeters,${origin.latitude},${origin.longitude})["name"]["leisure"="nature_reserve"];
  nwr(around:$_radiusMeters,${origin.latitude},${origin.longitude})["name"]["boundary"="national_park"];
  nwr(around:$_radiusMeters,${origin.latitude},${origin.longitude})["name"]["route"="hiking"];
);
out center meta qt $_resultLimit;
''';

    Object? lastError;
    final overallStopwatch = Stopwatch()..start();
    for (final endpoint in _endpoints) {
      final remaining = _maxOverpassDuration - overallStopwatch.elapsed;
      if (remaining <= Duration.zero) break;
      final requestTimeout =
          remaining < _perEndpointTimeout ? remaining : _perEndpointTimeout;
      try {
        final uri =
            Uri.parse(endpoint).replace(queryParameters: {'data': query});
        final response = await http.get(uri).timeout(requestTimeout);
        if (response.statusCode != 200) {
          lastError = Exception(
              'Konum verisi servisi ${response.statusCode} döndürdü.');
          continue;
        }
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final result = parseOverpassElements(
          decoded['elements'] as List<dynamic>? ?? const [],
          origin.latitude,
          origin.longitude,
          origin.label,
        );
        _cache[cacheKey] = (fetchedAt: DateTime.now(), places: result);
        return result;
      } catch (error) {
        lastError = error;
      }
    }
    throw Exception(
      lastError == null
          ? 'Yakındaki yerler alınamadı.'
          : 'Yakındaki yerler şu anda alınamadı. İnternet bağlantını kontrol edip tekrar dene.',
    );
  }

  static Future<({double latitude, double longitude, String label})>
      resolveTarget(WeatherTarget target) async {
    if (target.usesCoordinates) {
      return (
        latitude: target.latitude!,
        longitude: target.longitude!,
        label: target.label,
      );
    }

    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': target.label,
      'count': '1',
      'language': 'tr',
      'format': 'json',
      'countryCode': 'TR',
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception('Yakın çevre için konum belirlenemedi.');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final matches = decoded['results'] as List<dynamic>?;
    if (matches == null || matches.isEmpty) {
      throw Exception('${target.label} için koordinat bulunamadı.');
    }
    final match = matches.first as Map<String, dynamic>;
    return (
      latitude: (match['latitude'] as num).toDouble(),
      longitude: (match['longitude'] as num).toDouble(),
      label: match['name']?.toString() ?? target.label,
    );
  }

  static List<Place> parseOverpassElements(
    List<dynamic> elements,
    double originLatitude,
    double originLongitude,
    String fallbackLocation,
  ) {
    final found = <Place>[];
    final seen = <String>{};
    for (final raw in elements) {
      if (raw is! Map<String, dynamic>) continue;
      final rawTags = raw['tags'];
      if (rawTags is! Map) continue;
      final tags = Map<String, dynamic>.from(rawTags);
      final name = (tags['name:tr'] ?? tags['name'])?.toString().trim();
      if (name == null || name.isEmpty) continue;

      final center = raw['center'];
      final latitudeValue =
          raw['lat'] ?? (center is Map ? center['lat'] : null);
      final longitudeValue =
          raw['lon'] ?? (center is Map ? center['lon'] : null);
      if (latitudeValue is! num || longitudeValue is! num) continue;
      final latitude = latitudeValue.toDouble();
      final longitude = longitudeValue.toDouble();
      final distance = calculateDistanceKm(
        originLatitude,
        originLongitude,
        latitude,
        longitude,
      );
      if (distance > _radiusMeters / 1000 + .5) continue;

      final kind = _kindFor(tags);
      final uniqueKey = '$name|$kind';
      if (!seen.add(uniqueKey.toLowerCase())) continue;
      final location = _firstTag(tags, const [
            'addr:district',
            'addr:city',
            'addr:province',
            'is_in:district',
            'is_in:province',
          ]) ??
          fallbackLocation;
      final imageTag = tags['image']?.toString();
      final image =
          imageTag != null && imageTag.startsWith('http') ? imageTag : null;
      final palette = _paletteFor(kind);
      found.add(
        Place(
          name,
          location,
          kind,
          0,
          _iconFor(kind),
          palette,
          image,
          description:
              '$name, OpenStreetMap üzerinde kayıtlı bir $kind noktasıdır. Konumuna yaklaşık ${distance.toStringAsFixed(1)} km uzaklıktadır.',
          latitude: latitude,
          longitude: longitude,
          distanceKm: distance,
          sourceId: 'osm:${raw['type']}:${raw['id']}',
          updatedAt: DateTime.tryParse(raw['timestamp']?.toString() ?? ''),
          source: PlaceSource.osm,
          verificationStatus: VerificationStatus.community,
        ),
      );
    }
    found.sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));
    return found.take(_resultLimit).toList(growable: false);
  }

  static String? _firstTag(Map<String, dynamic> tags, List<String> keys) {
    for (final key in keys) {
      final value = tags[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static String _kindFor(Map<String, dynamic> tags) {
    if (tags['waterway'] == 'waterfall') return 'Şelale';
    if (tags['natural'] == 'spring') return 'Su Kaynağı';
    if (tags['natural'] == 'water') return 'Göl';
    if (tags['natural'] == 'cave_entrance') return 'Mağara';
    if (tags['tourism'] == 'viewpoint') return 'Seyir Noktası';
    if (tags['tourism'] == 'camp_site') return 'Kamp Alanı';
    if (tags['tourism'] == 'caravan_site') return 'Karavan';
    if (tags['tourism'] == 'picnic_site') return 'Piknik';
    if (tags['route'] == 'hiking') return 'Yürüyüş';
    if (tags['boundary'] == 'national_park' ||
        tags['leisure'] == 'nature_reserve') {
      return 'Yürüyüş';
    }
    return 'Doğal Kaynak';
  }

  static IconData _iconFor(String kind) {
    if (kind == 'Şelale') return Icons.waterfall_chart_rounded;
    if (kind == 'Su Kaynağı') return Icons.water_drop_rounded;
    if (kind == 'Göl') return Icons.water_rounded;
    if (kind == 'Mağara') return Icons.landscape_rounded;
    if (kind == 'Seyir Noktası') return Icons.visibility_rounded;
    if (kind == 'Kamp Alanı') return Icons.cabin_rounded;
    if (kind == 'Piknik') return Icons.park_rounded;
    return Icons.hiking_rounded;
  }

  static List<Color> _paletteFor(String kind) {
    if (kind == 'Şelale' || kind == 'Su Kaynağı') {
      return const [Color(0xFF287890), Color(0xFF8DD1C9)];
    }
    if (kind == 'Göl') {
      return const [Color(0xFF2B86A6), Color(0xFFB8E7E8)];
    }
    if (kind == 'Kamp Alanı') {
      return const [Color(0xFF715642), Color(0xFFC9A678)];
    }
    if (kind == 'Mağara') {
      return const [Color(0xFF4D4540), Color(0xFF9B8E82)];
    }
    return const [Color(0xFF315F45), Color(0xFF9BBF82)];
  }

  static double calculateDistanceKm(
    double latitudeA,
    double longitudeA,
    double latitudeB,
    double longitudeB,
  ) {
    const earthRadiusKm = 6371.0;
    double radians(double degree) => degree * math.pi / 180;
    final latitudeDifference = radians(latitudeB - latitudeA);
    final longitudeDifference = radians(longitudeB - longitudeA);
    final value =
        math.sin(latitudeDifference / 2) * math.sin(latitudeDifference / 2) +
            math.cos(radians(latitudeA)) *
                math.cos(radians(latitudeB)) *
                math.sin(longitudeDifference / 2) *
                math.sin(longitudeDifference / 2);
    return earthRadiusKm *
        2 *
        math.atan2(math.sqrt(value), math.sqrt(1 - value));
  }
}

const places = <Place>[
  Place(
    'Yedigöller Milli Parkı',
    'Bolu',
    'Milli Park',
    4.9,
    Icons.forest_rounded,
    [Color(0xFF315F45), Color(0xFF9BBF82)],
    'https://images.unsplash.com/photo-1707940096540-7ba2ab01887e?w=900&h=700&fit=crop',
    latitude: 40.94,
    longitude: 31.75,
    description:
        'Yedi gölü, yürüyüş yolları ve her mevsim değişen renkleriyle huzurlu bir doğa kaçamağı.',
  ),
  Place(
    'Kapuzbaşı Şelaleleri',
    'Kayseri',
    'Şelale',
    4.8,
    Icons.waterfall_chart_rounded,
    [Color(0xFF287890), Color(0xFF8DD1C9)],
    'https://images.unsplash.com/photo-1693921443047-c59f572a485f?w=900&h=700&fit=crop',
    latitude: 37.95,
    longitude: 35.43,
    description:
        'Kayaların içinden doğan güçlü şelaleler ve serin vadi havası seni bekliyor.',
  ),
  Place(
    'Kaçkar Yaylası',
    'Rize',
    'Yürüyüş',
    4.7,
    Icons.landscape_rounded,
    [Color(0xFF456C5B), Color(0xFFB7CFA5)],
    'https://images.unsplash.com/photo-1587923317415-8bca5f98c27b?w=900&h=700&fit=crop',
    latitude: 40.84,
    longitude: 41.16,
    description:
        'Bulutların üzerinde yürüyüş, yemyeşil yaylalar ve benzersiz Karadeniz manzaraları.',
  ),
  Place(
    'Salda Gölü',
    'Burdur',
    'Göl',
    4.6,
    Icons.water_rounded,
    [Color(0xFF2B86A6), Color(0xFFB8E7E8)],
    'https://images.unsplash.com/photo-1565694289800-16f2fdb51655?w=900&h=700&fit=crop',
    latitude: 37.55,
    longitude: 29.68,
    description:
        'Beyaz kıyıları ve turkuaz suyuyla Türkiye’nin en özel göl manzaralarından biri.',
  ),
  Place(
    'İncekum Orman Kampı',
    'Muğla',
    'Kamp',
    4.5,
    Icons.cabin_rounded,
    [Color(0xFF715642), Color(0xFFC9A678)],
    'https://images.unsplash.com/photo-1624923686627-514dd5e57bae?w=900&h=700&fit=crop',
    latitude: 36.73,
    longitude: 28.12,
    description:
        'Çam ağaçlarının altında denize yakın, sakin bir kamp deneyimi.',
  ),
];

const communitySuggestions = <CommunitySuggestion>[
  CommunitySuggestion(
    place: Place(
      'Karagöl',
      'Şavşat',
      'Göl',
      4.8,
      Icons.water_rounded,
      [Color(0xFF173E43), Color(0xFF52A8A2)],
      'https://images.unsplash.com/photo-1439853949127-fa647821eba0?w=900&h=700&fit=crop',
      latitude: 41.235,
      longitude: 42.365,
    ),
    recommendationCount: 76,
  ),
  CommunitySuggestion(
    place: Place(
      'Likya Yolu Batı',
      'Kaş',
      'Yürüyüş',
      4.9,
      Icons.hiking_rounded,
      [Color(0xFF264E35), Color(0xFF8EAD72)],
      'https://images.unsplash.com/photo-1448375240586-882707db888b?w=900&h=700&fit=crop',
      latitude: 36.202,
      longitude: 29.641,
    ),
    recommendationCount: 210,
  ),
  CommunitySuggestion(
    place: Place(
      'Çıralı Sahil Kamp',
      'Kemer',
      'Kamp Alanı',
      4.5,
      Icons.cabin_rounded,
      [Color(0xFF315F45), Color(0xFF9BBF82)],
      'https://images.unsplash.com/photo-1624923686627-514dd5e57bae?w=900&h=700&fit=crop',
      latitude: 36.417,
      longitude: 30.483,
    ),
    recommendationCount: 144,
  ),
];

class RankedCommunitySuggestion {
  const RankedCommunitySuggestion({
    required this.suggestion,
    required this.distanceKm,
  });

  final CommunitySuggestion suggestion;
  final double distanceKm;
}

class CommunitySuggestionsService {
  CommunitySuggestionsService._();

  static Future<List<RankedCommunitySuggestion>> rankedFor(
    WeatherTarget target,
  ) async {
    final origin = await NearbyPlacesService.resolveTarget(target);
    final ranked = communitySuggestions
        .where((suggestion) => suggestion.place.hasCoordinates)
        .map(
          (suggestion) => RankedCommunitySuggestion(
            suggestion: suggestion,
            distanceKm: NearbyPlacesService.calculateDistanceKm(
              origin.latitude,
              origin.longitude,
              suggestion.place.latitude!,
              suggestion.place.longitude!,
            ),
          ),
        )
        .toList(growable: false);
    ranked.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return ranked;
  }
}
