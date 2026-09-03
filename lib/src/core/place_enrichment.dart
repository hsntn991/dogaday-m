part of '../../main.dart';

class PlaceAboutSource {
  const PlaceAboutSource({
    required this.name,
    this.url,
    this.license,
  });

  factory PlaceAboutSource.fromJson(Map<String, dynamic> data) =>
      PlaceAboutSource(
        name: data['source']?.toString().trim().isNotEmpty == true
            ? data['source'].toString().trim()
            : 'Bilgi kaynağı',
        url: data['source_url']?.toString().trim(),
        license: data['license']?.toString().trim(),
      );

  final String name;
  final String? url;
  final String? license;
}

class PlaceAmenityInfo {
  const PlaceAmenityInfo({
    required this.type,
    required this.label,
    this.distanceMeters,
    this.name,
    this.source,
    this.sourceUrl,
  });

  factory PlaceAmenityInfo.fromJson(Map<String, dynamic> data) =>
      PlaceAmenityInfo(
        type: data['type']?.toString() ?? '',
        label: data['label']?.toString().trim().isNotEmpty == true
            ? data['label'].toString().trim()
            : data['type']?.toString() ?? 'Olanak',
        distanceMeters: (data['distance_m'] as num?)?.round(),
        name: data['name']?.toString().trim(),
        source: data['source']?.toString().trim(),
        sourceUrl: data['source_url']?.toString().trim(),
      );

  final String type;
  final String label;
  final int? distanceMeters;
  final String? name;
  final String? source;
  final String? sourceUrl;
}

class PlacePhotoInfo {
  const PlacePhotoInfo({
    required this.url,
    required this.source,
    this.sourcePageUrl,
    this.license,
    this.identityGrade,
    this.qualityGrade,
    this.matchMethod,
    this.reuseStatus,
  });

  factory PlacePhotoInfo.fromJson(Map<String, dynamic> data) => PlacePhotoInfo(
        url: (data['thumb_url'] ??
                data['large_image_url'] ??
                data['webformat_url'] ??
                data['original_url'] ??
                '')
            .toString()
            .trim(),
        source: data['source']?.toString().trim() ?? '',
        sourcePageUrl: (data['description_url'] ??
                data['pixabay_page_url'] ??
                data['source_url'])
            ?.toString()
            .trim(),
        license: data['license']?.toString().trim(),
        identityGrade: data['identity_grade']?.toString().toUpperCase(),
        qualityGrade: data['quality_grade']?.toString().toUpperCase(),
        matchMethod: data['match_method']?.toString().toLowerCase(),
        reuseStatus: data['reuse_status']?.toString().toLowerCase(),
      );

  final String url;
  final String source;
  final String? sourcePageUrl;
  final String? license;
  final String? identityGrade;
  final String? qualityGrade;
  final String? matchMethod;
  final String? reuseStatus;
}

class PlacePhotoPolicy {
  PlacePhotoPolicy._();

  static bool galleryEligible(PlacePhotoInfo photo) {
    if (photo.url.isEmpty) return false;
    if (_isPixabay(photo)) {
      return const {'A', 'B'}.contains(photo.identityGrade) &&
          const {'Q1', 'Q2'}.contains(photo.qualityGrade);
    }
    final source = photo.source.toLowerCase();
    if (photo.matchMethod == 'direct' ||
        source.contains('openstreetmap') ||
        source.contains('wikidata') ||
        source.contains('wikimedia') ||
        source.contains('commons')) {
      return true;
    }
    final license = photo.license?.toLowerCase() ?? '';
    return photo.reuseStatus?.startsWith('allowed') == true ||
        license.contains('creative commons') ||
        license.startsWith('cc ') ||
        license.contains('public domain');
  }

  static bool primaryEligible(PlacePhotoInfo photo) {
    if (!galleryEligible(photo)) return false;
    return !_isPixabay(photo) || photo.qualityGrade == 'Q1';
  }

  static List<PlacePhotoInfo> ordered(Iterable<PlacePhotoInfo> photos) {
    final result = photos.where(galleryEligible).toList(growable: false);
    result.sort((a, b) => _priority(a).compareTo(_priority(b)));
    return result;
  }

  static PlacePhotoInfo? primary(Iterable<PlacePhotoInfo> photos) {
    for (final photo in ordered(photos)) {
      if (primaryEligible(photo)) return photo;
    }
    return null;
  }

  static bool _isPixabay(PlacePhotoInfo photo) =>
      photo.source.toLowerCase().contains('pixabay');

  static int _priority(PlacePhotoInfo photo) {
    final source = photo.source.toLowerCase();
    if (photo.matchMethod == 'direct' ||
        source.contains('openstreetmap') ||
        source.contains('wikidata')) {
      return 0;
    }
    if (source.contains('wikimedia') || source.contains('commons')) return 1;
    if (_isPixabay(photo)) return 2;
    return 3;
  }
}

class PlaceEnrichment {
  const PlaceEnrichment({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.aboutText,
    required this.aboutSources,
    required this.amenities,
    required this.amenitiesStatus,
    required this.photos,
  });

  factory PlaceEnrichment.fromJson(Map<String, dynamic> data) {
    final photos = (data['photos'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => PlacePhotoInfo.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
    return PlaceEnrichment(
      name: data['name']?.toString() ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      aboutText: data['about_text']?.toString().trim() ?? '',
      aboutSources: (data['about_sources'] as List? ?? const [])
          .whereType<Map>()
          .map((item) =>
              PlaceAboutSource.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      amenities: (data['app_amenities'] as List? ?? const [])
          .whereType<Map>()
          .map((item) =>
              PlaceAmenityInfo.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      amenitiesStatus: data['amenities_status']?.toString() ?? '',
      photos: PlacePhotoPolicy.ordered(photos),
    );
  }

  final String name;
  final double? latitude;
  final double? longitude;
  final String aboutText;
  final List<PlaceAboutSource> aboutSources;
  final List<PlaceAmenityInfo> amenities;
  final String amenitiesStatus;
  final List<PlacePhotoInfo> photos;

  PlacePhotoInfo? get primaryPhoto => PlacePhotoPolicy.primary(photos);
}

List<PlaceEnrichment> _decodePlaceEnrichment(String raw) => (jsonDecode(raw)
        as List)
    .whereType<Map>()
    .map((item) => PlaceEnrichment.fromJson(Map<String, dynamic>.from(item)))
    .toList(growable: false);

class PlaceEnrichmentService {
  PlaceEnrichmentService._();

  static Future<Map<String, List<PlaceEnrichment>>>? _indexFuture;

  static Future<PlaceEnrichment?> find(Place place) async {
    if (!place.hasCoordinates) return null;
    final index = await (_indexFuture ??= _loadIndex());
    final candidates =
        index[AddPlaceQualityService.normalizeName(place.name)] ??
            const <PlaceEnrichment>[];
    PlaceEnrichment? closest;
    var closestDistance = double.infinity;
    for (final candidate in candidates) {
      if (candidate.latitude == null || candidate.longitude == null) continue;
      final distance = NearbyPlacesService.calculateDistanceKm(
        place.latitude!,
        place.longitude!,
        candidate.latitude!,
        candidate.longitude!,
      );
      if (distance <= .75 && distance < closestDistance) {
        closest = candidate;
        closestDistance = distance;
      }
    }
    return closest;
  }

  static Future<Map<String, List<PlaceEnrichment>>> _loadIndex() async {
    try {
      final raw = await rootBundle
          .loadString('assets/data/marmara_place_enrichment.json');
      final records = await compute(_decodePlaceEnrichment, raw);
      final index = <String, List<PlaceEnrichment>>{};
      for (final record in records) {
        final key = AddPlaceQualityService.normalizeName(record.name);
        index.putIfAbsent(key, () => <PlaceEnrichment>[]).add(record);
      }
      return index;
    } catch (_) {
      return const <String, List<PlaceEnrichment>>{};
    }
  }
}
