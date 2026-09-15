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
    this.author,
    this.licenseUrl,
    this.attribution,
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
        author: (data['author'] ?? data['artist'])?.toString(),
        licenseUrl: data['license_url']?.toString(),
        attribution: data['attribution']?.toString(),
      );

  final String url;
  final String source;
  final String? sourcePageUrl;
  final String? license;
  final String? identityGrade;
  final String? qualityGrade;
  final String? matchMethod;
  final String? reuseStatus;
  final String? author;
  final String? licenseUrl;
  final String? attribution;
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

class RegionalResearchPlaces {
  RegionalResearchPlaces._();

  static Future<List<Place>>? _future;
  static const _genericNames = {'piknik alani', 'kamp alani', 'camping', 'bungalows'};

  static List<Place> decodeRecords(List<dynamic> rows) {
    final places = <Place>[];
    for (final value in rows) {
      if (value is! Map) continue;
      final row = Map<String, dynamic>.from(value);
      final id = row['id']?.toString().trim() ?? '';
      final name = row['name']?.toString().trim() ?? '';
      final province = row['province']?.toString().trim() ?? '';
      final latitude = row['latitude'];
      final longitude = row['longitude'];
      if (id.isEmpty || name.isEmpty || province.isEmpty ||
          _genericNames.contains(AddPlaceQualityService.normalizeName(name)) ||
          latitude is! num || longitude is! num || !latitude.isFinite ||
          !longitude.isFinite || latitude.abs() > 90 || longitude.abs() > 180) {
        continue;
      }
      final subtype = row['subtype']?.toString();
      final mainCategory = row['main_category']?.toString();
      places.add(Place(
        name,
        province,
        taxonomyDisplayLabel(
          fallback: row['category']?.toString() ?? 'Doğa Noktası',
          mainCategory: mainCategory,
          subtype: subtype,
        ),
        0,
        Icons.place_rounded,
        const [Color(0xFF315F45), Color(0xFF9BBF82)],
        null,
        description: row['description']?.toString() ?? '',
        latitude: latitude.toDouble(),
        longitude: longitude.toDouble(),
        sourceId: 'research:${id}',
        source: PlaceSource.osm,
        verificationStatus: VerificationStatus.verified,
        mainCategory: mainCategory,
        subtype: subtype,
      ));
    }
    return places;
  }

  static Future<List<Place>> load() => _future ??= _load();

  static Future<List<Place>> _load() async {
    final raw = await rootBundle.loadString('assets/data/akdeniz_research_places.json');
    return decodeRecords(jsonDecode(raw) as List);
  }

  static Future<List<Place>> merge(List<Place> existing) async {
    final result = [...existing];
    for (final place in await load()) {
      final duplicate = result.any((candidate) =>
          candidate.sourceId == place.sourceId ||
          (AddPlaceQualityService.normalizeName(candidate.name) ==
                  AddPlaceQualityService.normalizeName(place.name) &&
              candidate.hasCoordinates &&
              NearbyPlacesService.calculateDistanceKm(
                    candidate.latitude!, candidate.longitude!,
                    place.latitude!, place.longitude!,
                  ) <=
                  .75));
      if (!duplicate) result.add(place);
    }
    return result;
  }
}

class ResearchPhotoPlaces {
  static Future<List<Place>>? _future;
  static Future<List<Map<String, dynamic>>>? _records;
  static Future<List<Map<String, dynamic>>> records() => _records ??= readRecords(
    remote: () async {
      final rows = await Supabase.instance.client.from('research_photo_places')
          .select('payload').order('id').limit(1000).timeout(const Duration(seconds: 8));
      return rows.map((row) => row['payload']).toList();
    },
    fallback: () async => jsonDecode(await rootBundle.loadString('assets/data/research_photo_places.json')) as List,
  );

  static Future<List<Map<String, dynamic>>> readRecords({
    required Future<List<dynamic>> Function() remote,
    required Future<List<dynamic>> Function() fallback,
  }) async {
    List<Map<String, dynamic>> accepted(List<dynamic> rows) {
      final result = <Map<String, dynamic>>[];
      for (final value in rows) {
        if (value is! Map) continue;
        final row = Map<String, dynamic>.from(value);
        final lat = row['latitude'], lon = row['longitude'];
        if (row['id'] is! String || row['name'] is! String ||
            lat is! num || lon is! num || !lat.isFinite || !lon.isFinite ||
            lat.abs() > 90 || lon.abs() > 180 || row['photos'] is! List) continue;
        final photos = (row['photos'] as List).where((p) => p is Map &&
          p['photo_quality_status'] == 'approved' && p['license_verified'] == true &&
          const ['A', 'B'].contains(p['confidence_level']) &&
          const ['author', 'license', 'license_url', 'description_url', 'original_url'].every(
            (key) => p[key] is String && (p[key] as String).trim().isNotEmpty) &&
          Uri.tryParse(p['original_url'])?.scheme == 'https').toList();
        if (photos.isNotEmpty) result.add({...row, 'photos': photos});
      }
      return result;
    }
    try {
      final rows = accepted(await remote());
      if (rows.isNotEmpty) return rows;
    } catch (_) {
      // The bundled package keeps places available when the server is offline.
    }
    return accepted(await fallback());
  }
  static Future<List<Place>> load() => _future ??= _load();
  static Future<List<Place>> _load() async {
    final rows = await records();
    return rows.map((row) {
      final data = Map<String, dynamic>.from(row as Map);
      final enrichment = PlaceEnrichment.fromJson(data);
      return Place(data['name'] as String, data['province'] as String? ?? '',
        taxonomyDisplayLabel(fallback: 'Doğa Noktası', subtype: data['subtype']),
        0, Icons.place_rounded, const [Color(0xFF315F45), Color(0xFF9BBF82)],
        enrichment.primaryPhoto?.url,
        latitude: enrichment.latitude, longitude: enrichment.longitude,
        sourceId: 'research:${data['id']}', source: PlaceSource.osm,
        verificationStatus: VerificationStatus.community,
        mainCategory: data['main_category'], subtype: data['subtype']);
    }).toList();
  }
  static Future<List<Place>> merge(List<Place> existing) async {
    final result = [...existing];
    for (final place in await load()) {
      final duplicate = result.any((p) => p.sourceId == place.sourceId ||
        (AddPlaceQualityService.normalizeName(p.name) == AddPlaceQualityService.normalizeName(place.name) &&
          p.hasCoordinates && NearbyPlacesService.calculateDistanceKm(p.latitude!, p.longitude!, place.latitude!, place.longitude!) <= .75));
      if (!duplicate) result.add(place);
    }
    return result;
  }
}

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
      final records = (await compute(_decodePlaceEnrichment, raw)).map((r) =>
          PlaceEnrichment(name: r.name, latitude: r.latitude, longitude: r.longitude,
            aboutText: r.aboutText, aboutSources: r.aboutSources, amenities: r.amenities,
            amenitiesStatus: r.amenitiesStatus, photos: const <PlacePhotoInfo>[])).toList();
      final photoRecords = (await ResearchPhotoPlaces.records()).map(PlaceEnrichment.fromJson).toList();
      for (final photoRecord in photoRecords) {
        final position = records.indexWhere((r) =>
            AddPlaceQualityService.normalizeName(r.name) == AddPlaceQualityService.normalizeName(photoRecord.name) &&
            r.latitude == photoRecord.latitude && r.longitude == photoRecord.longitude);
        if (position < 0) {
          records.add(photoRecord);
        } else {
          final old = records[position];
          records[position] = PlaceEnrichment(name: old.name, latitude: old.latitude,
            longitude: old.longitude, aboutText: old.aboutText, aboutSources: old.aboutSources,
            amenities: old.amenities, amenitiesStatus: old.amenitiesStatus, photos: photoRecord.photos);
        }
      }
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
