part of '../../main.dart';

class PlaceRecommendation {
  const PlaceRecommendation({
    required this.place,
    required this.score,
    required this.reasons,
  });

  final Place place;
  final double score;
  final List<String> reasons;

  String get suitabilityLabel {
    if (score >= 80) return 'Çok uygun';
    if (score >= 65) return 'İyi seçenek';
    return 'Keşfetmeye değer';
  }

  /// The ranking service orders reasons from strongest to weakest, so the
  /// first one is the clearest explanation to show on a compact card.
  String get primaryReason =>
      reasons.isEmpty ? 'Keşfetmeye değer bir doğa noktası' : reasons.first;
}

class RecommendationService {
  RecommendationService._();

  static const double distanceWeight = 30;
  static const double weatherWeight = 25;
  static const double accessibilityWeight = 15;
  static const double trustWeight = 10;
  static const double ratingWeight = 10;
  static const double categoryWeight = 10;
  static const double photoWeight = 15;
  static const double personalizationWeight = 25;

  static List<PlaceRecommendation> rank({
    required Iterable<Place> places,
    WeatherSnapshot? weather,
    bool hasUserLocation = true,
    String? preferredCategory,
    Set<String> favoritePlaceNames = const <String>{},
    int limit = 5,
  }) {
    final learnedCategoryKeys = _learnedCategoryKeys(
      places,
      favoritePlaceNames,
    );
    final ranked = places
        .map(
          (place) => score(
            place,
            weather: weather,
            hasUserLocation: hasUserLocation,
            preferredCategory: preferredCategory,
            favoritePlaceNames: favoritePlaceNames,
            learnedCategoryKeys: learnedCategoryKeys,
          ),
        )
        .toList(growable: false);
    ranked.sort((a, b) {
      final scoreOrder = b.score.compareTo(a.score);
      if (scoreOrder != 0) return scoreOrder;
      final distanceOrder = (a.place.distanceKm ?? double.infinity)
          .compareTo(b.place.distanceKm ?? double.infinity);
      if (distanceOrder != 0) return distanceOrder;
      return a.place.name.compareTo(b.place.name);
    });
    return ranked.take(limit).toList(growable: false);
  }

  static PlaceRecommendation score(
    Place place, {
    WeatherSnapshot? weather,
    bool hasUserLocation = true,
    String? preferredCategory,
    Set<String> favoritePlaceNames = const <String>{},
    Set<String> learnedCategoryKeys = const <String>{},
  }) {
    var weightedScore = 0.0;
    var usedWeight = 0.0;
    final reasonCandidates = <({double strength, String text})>[];

    final distance = place.distanceKm;
    if (hasUserLocation && distance != null && distance.isFinite) {
      final value = _distanceScore(distance);
      weightedScore += value * distanceWeight;
      usedWeight += distanceWeight;
      if (distance <= NearbyPlacesService.queryRadiusKm) {
        reasonCandidates.add((
          strength: value,
          text: 'Sana ${_distanceLabel(distance)} uzaklıkta',
        ));
      }
    }

    if (weather != null) {
      final value = _weatherScore(weather.weatherCode, place.kind);
      weightedScore += value * weatherWeight;
      usedWeight += weatherWeight;
      if (value >= .72) {
        reasonCandidates.add((
          strength: value,
          text: 'Bugünkü hava ${_activityLabel(place.kind)} için uygun',
        ));
      } else if (value < .45) {
        reasonCandidates.add((
          strength: .45,
          text: 'Hava koşullarını kontrol et',
        ));
      }
    }

    // Mevcut Place modelinde zorluk ve süre alanı bulunmadığı için
    // accessibilityWeight skora katılmaz; eksik veri kullanıcıyı cezalandırmaz.

    final trust = _trustScore(place);
    weightedScore += trust * trustWeight;
    usedWeight += trustWeight;

    if (place.rating > 0) {
      final rating = (place.rating / 5).clamp(0.0, 1.0);
      weightedScore += rating * ratingWeight;
      usedWeight += ratingWeight;
      if (place.rating >= 4.5) {
        reasonCandidates.add((strength: rating, text: 'Yüksek puanlı'));
      }
    }

    final requestedCategory = preferredCategory?.trim();
    if (requestedCategory != null && requestedCategory.isNotEmpty) {
      final categoryMatch = _sameCategory(place, requestedCategory);
      weightedScore += (categoryMatch ? 1 : 0) * categoryWeight;
      usedWeight += categoryWeight;
      if (categoryMatch) {
        reasonCandidates.add((strength: 1, text: 'Seçtiğin kategoriye uygun'));
      }
    }

    final normalizedFavoriteNames = favoritePlaceNames
        .map(_normalizePlaceName)
        .where((name) => name.isNotEmpty)
        .toSet();
    final isSaved =
        normalizedFavoriteNames.contains(_normalizePlaceName(place.name));
    final isSimilarToSaved = learnedCategoryKeys.contains(_categoryKey(place));
    if (isSaved || isSimilarToSaved) {
      final value = isSaved ? 1.0 : .75;
      weightedScore += value * personalizationWeight;
      usedWeight += personalizationWeight;
      reasonCandidates.add((
        strength: value,
        text: isSaved ? 'Kaydettiğin bir yer' : 'Kaydettiklerine benzer',
      ));
    }

    final hasPhoto = (place.image?.trim().isNotEmpty ?? false) ||
        (PlaceEnrichmentService.findSync(place)?.primaryPhoto != null);
    if (hasPhoto) {
      weightedScore += 1.0 * photoWeight;
      usedWeight += photoWeight;
      reasonCandidates.add((strength: 0.85, text: 'Fotoğraflı ve detaylı'));
    } else {
      usedWeight += photoWeight;
    }

    final normalized =
        usedWeight == 0 ? 50.0 : weightedScore / usedWeight * 100;
    reasonCandidates.sort((a, b) => b.strength.compareTo(a.strength));
    final reasons = <String>[];
    for (final candidate in reasonCandidates) {
      if (!reasons.contains(candidate.text)) reasons.add(candidate.text);
      if (reasons.length == 3) break;
    }
    if (reasons.isEmpty) reasons.add('Keşfetmeye değer bir doğa noktası');

    return PlaceRecommendation(
      place: place,
      score: normalized.clamp(0.0, 100.0),
      reasons: List.unmodifiable(reasons),
    );
  }

  static double _distanceScore(double distanceKm) {
    if (distanceKm <= 0) return 1;
    if (distanceKm <= 5) return 1 - (distanceKm / 5) * .08;
    if (distanceKm <= 15) return .92 - ((distanceKm - 5) / 10) * .27;
    if (distanceKm <= NearbyPlacesService.queryRadiusKm) {
      return .65 -
          ((distanceKm - 15) / (NearbyPlacesService.queryRadiusKm - 15)) * .35;
    }
    return math.max(0, .30 - (distanceKm - 25) / 75 * .30);
  }

  static double _weatherScore(int code, String kind) {
    final sensitivity = _weatherSensitivity(kind);
    double base;
    if (code <= 2) {
      base = 1;
    } else if (code == 3 || code == 45 || code == 48) {
      base = .72;
    } else if (code >= 51 && code <= 57) {
      base = .58;
    } else if (code >= 61 && code <= 67) {
      base = .30;
    } else if (code >= 71 && code <= 77) {
      base = .25;
    } else if (code >= 80 && code <= 86) {
      base = .18;
    } else if (code >= 95) {
      base = .05;
    } else {
      base = .65;
    }
    return 1 - (1 - base) * sensitivity;
  }

  static double _weatherSensitivity(String kind) {
    final value = kind.toLowerCase();
    if (value.contains('mağara') || value.contains('cave')) return .35;
    if (value.contains('yürüyüş') ||
        value.contains('seyir') ||
        value.contains('piknik') ||
        value.contains('kamp') ||
        value.contains('viewpoint') ||
        value.contains('hiking')) {
      return 1;
    }
    return .75;
  }

  static double _trustScore(Place place) {
    if (place.source == PlaceSource.curated) return .8;
    if (place.source == PlaceSource.osm) return .75;
    return .6;
  }

  static bool _sameCategory(Place place, String requested) {
    final taxonomy = place.resolvedTaxonomy;
    return taxonomy.mainCategory == requested ||
        taxonomy.subtype == requested ||
        place.displayKind.toLowerCase() == requested.toLowerCase();
  }

  /// Saved places are the explicit preference signal in the first
  /// personalization version. No data is sent to a third-party service.
  static Set<String> _learnedCategoryKeys(
    Iterable<Place> places,
    Set<String> favoritePlaceNames,
  ) {
    if (favoritePlaceNames.isEmpty) return const <String>{};
    final normalizedNames = favoritePlaceNames
        .map(_normalizePlaceName)
        .where((name) => name.isNotEmpty)
        .toSet();
    return places
        .where((place) =>
            normalizedNames.contains(_normalizePlaceName(place.name)))
        .map(_categoryKey)
        .where((key) => key.isNotEmpty)
        .toSet();
  }

  static String _categoryKey(Place place) {
    final taxonomy = place.resolvedTaxonomy;
    return (taxonomy.subtype ?? taxonomy.mainCategory ?? place.displayKind)
        .trim()
        .toLowerCase();
  }

  static String _normalizePlaceName(String value) => value.trim().toLowerCase();

  static String _distanceLabel(double distance) => distance < 1
      ? '${(distance * 1000).round()} m'
      : '${distance.toStringAsFixed(1)} km';

  static String _activityLabel(String kind) {
    final value = kind.toLowerCase();
    if (value.contains('yürüyüş')) return 'yürüyüş';
    if (value.contains('piknik')) return 'piknik';
    if (value.contains('kamp')) return 'kamp';
    return 'keşif';
  }
}
