part of '../../main.dart';

class PlaceSubtypeDefinition {
  const PlaceSubtypeDefinition(this.key, this.label);

  final String key;
  final String label;
}

class PlaceCategoryDefinition {
  const PlaceCategoryDefinition({
    required this.key,
    required this.label,
    required this.emoji,
    required this.foreground,
    required this.background,
    required this.subtypes,
  });

  final String key;
  final String label;
  final String emoji;
  final Color foreground;
  final Color background;
  final List<PlaceSubtypeDefinition> subtypes;
}

const placeTaxonomy = <PlaceCategoryDefinition>[
  PlaceCategoryDefinition(
    key: 'water',
    label: 'Su',
    emoji: '💧',
    foreground: Color(0xFF357FA8),
    background: Color(0xFFE8F4FA),
    subtypes: [
      PlaceSubtypeDefinition('lake', 'Göl'),
      PlaceSubtypeDefinition('waterfall', 'Şelale'),
      PlaceSubtypeDefinition('stream', 'Dere'),
      PlaceSubtypeDefinition('river', 'Nehir'),
      PlaceSubtypeDefinition('spring', 'Pınar/Kaynak'),
      PlaceSubtypeDefinition('natural_pool', 'Doğal Havuz'),
    ],
  ),
  PlaceCategoryDefinition(
    key: 'mountain_terrain',
    label: 'Dağ & Arazi',
    emoji: '⛰️',
    foreground: Color(0xFF617A4A),
    background: Color(0xFFF0F4EB),
    subtypes: [
      PlaceSubtypeDefinition('mountain', 'Dağ'),
      PlaceSubtypeDefinition('peak', 'Zirve'),
      PlaceSubtypeDefinition('hill', 'Tepe'),
      PlaceSubtypeDefinition('plateau', 'Yayla'),
      PlaceSubtypeDefinition('plateau_landform', 'Plato'),
      PlaceSubtypeDefinition('valley', 'Vadi'),
    ],
  ),
  PlaceCategoryDefinition(
    key: 'natural_formation',
    label: 'Doğal Oluşum',
    emoji: '🪨',
    foreground: Color(0xFF6F604F),
    background: Color(0xFFF3EEE8),
    subtypes: [
      PlaceSubtypeDefinition('canyon', 'Kanyon'),
      PlaceSubtypeDefinition('cave', 'Mağara'),
      PlaceSubtypeDefinition('sinkhole', 'Obruk'),
      PlaceSubtypeDefinition('travertine', 'Traverten'),
      PlaceSubtypeDefinition('fairy_chimney', 'Peribacası'),
      PlaceSubtypeDefinition('natural_arch', 'Doğal Kemer'),
    ],
  ),
  PlaceCategoryDefinition(
    key: 'nature_area',
    label: 'Doğa Alanı',
    emoji: '🌲',
    foreground: Color(0xFF2E6D43),
    background: Color(0xFFEAF3EC),
    subtypes: [
      PlaceSubtypeDefinition('forest', 'Orman'),
      PlaceSubtypeDefinition('national_park', 'Milli Park'),
      PlaceSubtypeDefinition('nature_park', 'Tabiat Parkı'),
      PlaceSubtypeDefinition('wetland', 'Sulak Alan'),
      PlaceSubtypeDefinition('protected_area', 'Korunan Alan'),
      PlaceSubtypeDefinition('picnic_area', 'Mesire/Piknik Alanı'),
    ],
  ),
  PlaceCategoryDefinition(
    key: 'camp_caravan',
    label: 'Kamp & Karavan',
    emoji: '🏕️',
    foreground: Color(0xFFC4622D),
    background: Color(0xFFFBF0EA),
    subtypes: [
      PlaceSubtypeDefinition('camp_site', 'Kamp Alanı'),
      PlaceSubtypeDefinition('caravan_site', 'Karavan Alanı'),
    ],
  ),
  PlaceCategoryDefinition(
    key: 'route_activity',
    label: 'Rota & Aktivite',
    emoji: '🥾',
    foreground: Color(0xFF8A5C1A),
    background: Color(0xFFFBF5EA),
    subtypes: [
      PlaceSubtypeDefinition('hiking', 'Yürüyüş'),
      PlaceSubtypeDefinition('trekking', 'Trekking'),
      PlaceSubtypeDefinition('cycling', 'Bisiklet'),
      PlaceSubtypeDefinition('climbing', 'Tırmanış'),
      PlaceSubtypeDefinition('canoe', 'Kano'),
    ],
  ),
  PlaceCategoryDefinition(
    key: 'discovery_point',
    label: 'Keşif Noktası',
    emoji: '🔭',
    foreground: Color(0xFF6B4CAF),
    background: Color(0xFFF2EEF9),
    subtypes: [
      PlaceSubtypeDefinition('viewpoint', 'Seyir Noktası'),
      PlaceSubtypeDefinition('sunset_viewpoint', 'Gün Batımı'),
      PlaceSubtypeDefinition('photo_spot', 'Fotoğraf Noktası'),
      PlaceSubtypeDefinition('stargazing', 'Yıldız Gözlem'),
    ],
  ),
  PlaceCategoryDefinition(
    key: 'wildlife',
    label: 'Yaban Hayatı',
    emoji: '🦅',
    foreground: Color(0xFF49704A),
    background: Color(0xFFEDF4E8),
    subtypes: [
      PlaceSubtypeDefinition('birdwatching', 'Kuş Gözlem'),
      PlaceSubtypeDefinition('wildlife_observation', 'Yaban Hayatı Gözlem'),
      PlaceSubtypeDefinition('endemic_flora', 'Endemik Bitki'),
      PlaceSubtypeDefinition('monument_tree', 'Anıt Ağaç'),
    ],
  ),
];

const utilitySubtypes = <PlaceSubtypeDefinition>[
  PlaceSubtypeDefinition('toilet', 'WC'),
  PlaceSubtypeDefinition('drinking_water', 'İçme Suyu'),
];

({String? mainCategory, String? subtype}) taxonomyFromLegacy(String value) {
  final normalized = AddPlaceQualityService.normalizeName(value);
  if (normalized.contains('icme suyu')) {
    return (mainCategory: null, subtype: 'drinking_water');
  }
  if (normalized == 'wc' || normalized.contains('tuvalet')) {
    return (mainCategory: null, subtype: 'toilet');
  }
  if (normalized.contains('selale')) {
    return (mainCategory: 'water', subtype: 'waterfall');
  }
  if (normalized.contains('su kaynagi') ||
      normalized.contains('dogal kaynak') ||
      normalized.contains('pinar') ||
      normalized.contains('cesme') ||
      normalized.contains('hayrat')) {
    return (mainCategory: 'water', subtype: 'spring');
  }
  if (normalized.contains('gol') || normalized.contains('golet')) {
    return (mainCategory: 'water', subtype: 'lake');
  }
  if (normalized.contains('kanyon')) {
    return (mainCategory: 'natural_formation', subtype: 'canyon');
  }
  if (normalized.contains('magara')) {
    return (mainCategory: 'natural_formation', subtype: 'cave');
  }
  if (normalized.contains('milli park')) {
    return (mainCategory: 'nature_area', subtype: 'national_park');
  }
  if (normalized.contains('tabiat park')) {
    return (mainCategory: 'nature_area', subtype: 'nature_park');
  }
  if (normalized.contains('piknik') || normalized.contains('mesire')) {
    return (mainCategory: 'nature_area', subtype: 'picnic_area');
  }
  if (normalized.contains('karavan')) {
    return (mainCategory: 'camp_caravan', subtype: 'caravan_site');
  }
  if (normalized.contains('kamp')) {
    return (mainCategory: 'camp_caravan', subtype: 'camp_site');
  }
  if (normalized.contains('yuruyus') || normalized.contains('rota')) {
    return (mainCategory: 'route_activity', subtype: 'hiking');
  }
  if (normalized.contains('yayla')) {
    return (mainCategory: 'mountain_terrain', subtype: 'plateau');
  }
  if (normalized.contains('seyir') || normalized.contains('manzara')) {
    return (mainCategory: 'discovery_point', subtype: 'viewpoint');
  }
  return (mainCategory: null, subtype: null);
}

PlaceCategoryDefinition? placeCategoryByKey(String? key) {
  if (key == null) return null;
  for (final category in placeTaxonomy) {
    if (category.key == key) return category;
  }
  return null;
}

PlaceSubtypeDefinition? placeSubtypeByKey(String? key) {
  if (key == null) return null;
  for (final utility in utilitySubtypes) {
    if (utility.key == key) return utility;
  }
  for (final category in placeTaxonomy) {
    for (final subtype in category.subtypes) {
      if (subtype.key == key) return subtype;
    }
  }
  return null;
}

String taxonomyDisplayLabel({
  required String fallback,
  String? mainCategory,
  String? subtype,
}) =>
    placeSubtypeByKey(subtype)?.label ??
    placeCategoryByKey(mainCategory)?.label ??
    fallback.trim();

bool isUtilitySubtype(String? subtype) =>
    subtype == 'toilet' || subtype == 'drinking_water';

const facilityLabels = <String, String>{
  'toilets': 'Tuvalet',
  'drinking_water': 'İçme Suyu',
  'parking': 'Otopark',
  'shower': 'Duş',
  'electricity': 'Elektrik',
  'picnic_allowed': 'Piknik İzni',
  'picnic_facility': 'Piknik Alanı',
  'picnic_table_nearby': 'Piknik Masası',
  'bbq_allowed': 'Mangal İzni',
  'bbq_facility': 'Mangal Alanı',
  'open_fire_allowed': 'Açık Ateş İzni',
  'firepit_facility': 'Ateş Yakma Alanı',
  'tents': 'Çadır',
  'caravans': 'Karavan',
  'dump_station': 'Atık Boşaltma',
};

const nearbyFacilityLabels = <String, String>{
  'nearby_toilets': 'Tuvalet',
  'nearby_drinking_water': 'İçme Suyu',
  'nearby_parking': 'Otopark',
  'nearby_shower': 'Duş',
};

class PlaceFacilities {
  const PlaceFacilities({
    this.values = const <String, bool?>{},
    this.nearbyDistances = const <String, int?>{},
  });

  factory PlaceFacilities.fromJson(Object? value) {
    Map<String, dynamic>? data;
    if (value is Map) data = Map<String, dynamic>.from(value);
    if (value is List && value.isNotEmpty && value.first is Map) {
      data = Map<String, dynamic>.from(value.first as Map);
    }
    if (data == null) return const PlaceFacilities();
    return PlaceFacilities(
      values: {
        for (final key in [
          ...facilityLabels.keys,
          ...nearbyFacilityLabels.keys
        ])
          key: data[key] as bool?,
      },
      nearbyDistances: {
        for (final key in nearbyFacilityLabels.keys)
          key: (data['${key}_distance_m'] as num?)?.toInt(),
      },
    );
  }

  final Map<String, bool?> values;
  final Map<String, int?> nearbyDistances;

  bool get hasVerifiedData => values.values.any((value) => value == true);

  Map<String, dynamic> toJson() => {
        ...values,
        for (final entry in nearbyDistances.entries)
          '${entry.key}_distance_m': entry.value,
      };
}
