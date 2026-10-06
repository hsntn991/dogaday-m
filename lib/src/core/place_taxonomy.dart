part of '../../main.dart';

class PlaceSubtypeDefinition {
  const PlaceSubtypeDefinition(this.key, this.label);

  final String key;
  final String label;

  String get localizedLabel {
    final trans = AppStrings.subtype(key);
    return trans != key ? trans : label;
  }
}

class PlaceCategoryDefinition {
  const PlaceCategoryDefinition({
    required this.key,
    required this.label,
    required this.emoji,
    this.icon = Icons.nature_rounded,
    required this.foreground,
    required this.background,
    required this.subtypes,
  });

  final String key;
  final String label;
  final String emoji;
  final IconData icon;
  final Color foreground;
  final Color background;
  final List<PlaceSubtypeDefinition> subtypes;

  String get localizedLabel {
    final trans = AppStrings.category(key);
    return trans != key ? trans : label;
  }
}

const placeTaxonomy = <PlaceCategoryDefinition>[
  PlaceCategoryDefinition(
    key: 'camp',
    label: 'Kamp',
    emoji: 'K',
    icon: Icons.cabin_rounded,
    foreground: AppColors.categoryCamp,
    background: AppColors.categoryCampSoft,
    subtypes: [PlaceSubtypeDefinition('camp', 'Kamp')],
  ),
  PlaceCategoryDefinition(
    key: 'caravan',
    label: 'Karavan',
    emoji: 'K',
    icon: Icons.rv_hookup_rounded,
    foreground: AppColors.categoryCamp,
    background: AppColors.categoryCampSoft,
    subtypes: [PlaceSubtypeDefinition('caravan', 'Karavan')],
  ),
  PlaceCategoryDefinition(
    key: 'lake',
    label: 'Göl',
    emoji: 'G',
    icon: Icons.water_rounded,
    foreground: AppColors.categoryWater,
    background: AppColors.categoryWaterSoft,
    subtypes: [PlaceSubtypeDefinition('lake', 'Göl')],
  ),
  PlaceCategoryDefinition(
    key: 'waterfall',
    label: 'Şelale',
    emoji: 'Ş',
    icon: Icons.waterfall_chart_rounded,
    foreground: AppColors.categoryWater,
    background: AppColors.categoryWaterSoft,
    subtypes: [PlaceSubtypeDefinition('waterfall', 'Şelale')],
  ),
  PlaceCategoryDefinition(
    key: 'canyon_valley',
    label: 'Kanyon & Vadi',
    emoji: 'K',
    icon: Icons.terrain_rounded,
    foreground: AppColors.categoryFormation,
    background: AppColors.categoryFormationSoft,
    subtypes: [PlaceSubtypeDefinition('canyon_valley', 'Kanyon & Vadi')],
  ),
  PlaceCategoryDefinition(
    key: 'cave',
    label: 'Mağara',
    emoji: 'M',
    icon: Icons.landscape_rounded,
    foreground: AppColors.categoryFormation,
    background: AppColors.categoryFormationSoft,
    subtypes: [PlaceSubtypeDefinition('cave', 'Mağara')],
  ),
  PlaceCategoryDefinition(
    key: 'national_park',
    label: 'Millî / Doğa Parkı',
    emoji: 'P',
    icon: Icons.forest_rounded,
    foreground: AppColors.categoryNature,
    background: AppColors.categoryNatureSoft,
    subtypes: [PlaceSubtypeDefinition('national_park', 'Millî / Doğa Parkı')],
  ),
];

const localServiceCategory = PlaceCategoryDefinition(
  key: 'local_service',
  label: 'Mobil Servis',
  emoji: '🛠️',
  icon: Icons.handyman_rounded,
  foreground: Color(0xFFD97706),
  background: Color(0xFFFEF3C7),
  subtypes: [
    PlaceSubtypeDefinition('service_roadside', 'Çekici / Yol Yardım'),
    PlaceSubtypeDefinition('service_maintenance', 'Yıllık Bakım'),
    PlaceSubtypeDefinition('service_gas', 'Gaz Tesisatı'),
    PlaceSubtypeDefinition('service_hvac', 'Isıtma & Soğutma'),
    PlaceSubtypeDefinition('service_electric', 'Elektrik & Enerji'),
    PlaceSubtypeDefinition('service_plumbing', 'Su & Tesisat'),
    PlaceSubtypeDefinition('service_bodywork', 'Nem & Gövde'),
    PlaceSubtypeDefinition('service_chassis_brakes', 'Şasi & Fren'),
    PlaceSubtypeDefinition('service_parts', 'Montaj & Parça'),
    PlaceSubtypeDefinition('service_inspection', 'Muayene'),
  ],
);

const utilitySubtypes = <PlaceSubtypeDefinition>[
  PlaceSubtypeDefinition('toilet', 'WC'),
  PlaceSubtypeDefinition('drinking_water', 'İçme Suyu'),
  PlaceSubtypeDefinition('water_fountain', 'Çeşme'),
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
    return (mainCategory: 'waterfall', subtype: 'waterfall');
  }
  if (normalized.contains('cesme') || normalized.contains('hayrat')) {
    return (mainCategory: null, subtype: 'water_fountain');
  }
  if (normalized.contains('su kaynagi') ||
      normalized.contains('dogal kaynak') ||
      normalized.contains('pinar')) {
    return (mainCategory: 'water', subtype: 'spring');
  }
  if (normalized.contains('gol') || normalized.contains('golet')) {
    return (mainCategory: 'lake', subtype: 'lake');
  }
  if (normalized.contains('kanyon') || normalized.contains('vadi')) {
    return (mainCategory: 'canyon_valley', subtype: 'canyon_valley');
  }
  if (normalized.contains('magara')) {
    return (mainCategory: 'cave', subtype: 'cave');
  }
  if (normalized.contains('milli park') ||
      normalized.contains('tabiat park') ||
      normalized.contains('doga park')) {
    return (mainCategory: 'national_park', subtype: 'national_park');
  }
  if (normalized.contains('karavan')) {
    return (mainCategory: 'caravan', subtype: 'caravan');
  }
  if (normalized.contains('kamp')) {
    return (mainCategory: 'camp', subtype: 'camp');
  }
  if (normalized.contains('cekici') ||
      normalized.contains('yol yardim') ||
      normalized.contains('kurtarici') ||
      normalized.contains('oto kurtarma')) {
    return (mainCategory: 'local_service', subtype: 'service_roadside');
  }
  if (normalized.contains('yillik bakim') ||
      normalized.contains('periyodik bakim') ||
      normalized.contains('karavan bakim')) {
    return (mainCategory: 'local_service', subtype: 'service_maintenance');
  }
  if (normalized.contains('gaz tesisat') ||
      normalized.contains('tup') ||
      normalized.contains('lpg')) {
    return (mainCategory: 'local_service', subtype: 'service_gas');
  }
  if (normalized.contains('isitma') ||
      normalized.contains('sogutma') ||
      normalized.contains('klima') ||
      normalized.contains('webasto')) {
    return (mainCategory: 'local_service', subtype: 'service_hvac');
  }
  if (normalized.contains('elektrik') ||
      normalized.contains('enerji') ||
      normalized.contains('aku') ||
      normalized.contains('solar') ||
      normalized.contains('gunes panel')) {
    return (mainCategory: 'local_service', subtype: 'service_electric');
  }
  if (normalized.contains('su tesisat') ||
      normalized.contains('hidrofor') ||
      normalized.contains('su pompasi') ||
      normalized.contains('tesisat')) {
    return (mainCategory: 'local_service', subtype: 'service_plumbing');
  }
  if (normalized.contains('nem') ||
      normalized.contains('govde') ||
      normalized.contains('yalitim') ||
      normalized.contains('kaporta')) {
    return (mainCategory: 'local_service', subtype: 'service_bodywork');
  }
  if (normalized.contains('sasi') ||
      normalized.contains('fren') ||
      normalized.contains('lastik') ||
      normalized.contains('balata')) {
    return (mainCategory: 'local_service', subtype: 'service_chassis_brakes');
  }
  if (normalized.contains('montaj') ||
      normalized.contains('yedek parca') ||
      normalized.contains('parca')) {
    return (mainCategory: 'local_service', subtype: 'service_parts');
  }
  if (normalized.contains('muayene') ||
      normalized.contains('ekspertiz') ||
      normalized.contains('vize')) {
    return (mainCategory: 'local_service', subtype: 'service_inspection');
  }
  if (normalized.contains('isletme') ||
      normalized.contains('hizmet') ||
      normalized.contains('tamir') ||
      normalized.contains('kaynak') ||
      normalized.contains('ekmek') ||
      normalized.contains('firin') ||
      normalized.contains('camasir') ||
      normalized.contains('hamam') ||
      normalized.contains('servis')) {
    return (mainCategory: 'local_service', subtype: 'local_service');
  }
  return (mainCategory: null, subtype: null);
}

PlaceCategoryDefinition? placeCategoryByKey(String? key) {
  if (key == null) return null;
  if (key == 'local_service') return localServiceCategory;
  for (final category in placeTaxonomy) {
    if (category.key == key) return category;
  }
  return null;
}

IconData iconForCategoryKey(String? key) {
  if (key == null) return Icons.place_rounded;
  if (key == 'toilet') return Icons.wc_rounded;
  if (key == 'drinking_water') return Icons.water_drop_rounded;
  if (key == 'water_fountain') return Icons.water_rounded;
  if (key == 'all') return Icons.explore_rounded;
  if (key == 'local_service') return Icons.handyman_rounded;
  if (key == 'service_roadside') return Icons.local_shipping_rounded;
  if (key == 'service_maintenance') return Icons.airport_shuttle_rounded;
  if (key == 'service_gas') return Icons.local_fire_department_rounded;
  if (key == 'service_hvac') return Icons.device_thermostat_rounded;
  if (key == 'service_electric') return Icons.bolt_rounded;
  if (key == 'service_plumbing') return Icons.shower_rounded;
  if (key == 'service_bodywork') return Icons.water_drop_rounded;
  if (key == 'service_chassis_brakes') return Icons.tire_repair_rounded;
  if (key == 'service_parts') return Icons.settings_rounded;
  if (key == 'service_inspection') return Icons.fact_check_rounded;
  return placeCategoryByKey(key)?.icon ?? Icons.place_rounded;
}

PlaceSubtypeDefinition? placeSubtypeByKey(String? key) {
  if (key == null) return null;
  for (final utility in utilitySubtypes) {
    if (utility.key == key) return utility;
  }
  for (final subtype in localServiceCategory.subtypes) {
    if (subtype.key == key) return subtype;
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
}) {
  if (subtype != null) {
    final localized = AppStrings.subtype(subtype);
    if (localized != subtype) return localized;
    final def = placeSubtypeByKey(subtype);
    if (def != null) return def.label;
  }
  if (mainCategory != null) {
    final localized = AppStrings.category(mainCategory);
    if (localized != mainCategory) return localized;
    final def = placeCategoryByKey(mainCategory);
    if (def != null) return def.label;
  }
  final fallbackTrimmed = fallback.trim();
  if (fallbackTrimmed.toLowerCase() == 'doğa noktası' ||
      fallbackTrimmed.isEmpty) {
    return AppStrings.get('nature_spot');
  }
  return fallbackTrimmed;
}

bool isUtilitySubtype(String? subtype) =>
    subtype == 'toilet' ||
    subtype == 'drinking_water' ||
    subtype == 'water_fountain';

/// Doğa keşif haritasına uygun olmayan kentsel, idari, sokak/cadde, cami ve sınır eklerini tespit eder.
bool isNonNatureCandidateName(
  String name, {
  String? subtype,
  String? mainCategory,
}) {
  final normalizedName = AddPlaceQualityService.normalizeName(name);
  final normalizedSubtype = AddPlaceQualityService.normalizeName(subtype ?? '');

  // Su deposu/teras tankı gibi altyapı tesisleri bir doğa keşif noktası
  // değildir. Bu filtre, veritabanına farklı OSM adlarıyla gelmiş kayıtları
  // da kullanıcıya gösterilmeden önce tek yerde eler.
  const waterInfrastructureSubtypes = <String>{
    'water tank',
    'water tower',
    'storage tank',
    'man made water tank',
    'man made water tower',
    'covered reservoir',
    'water works',
  };
  if (waterInfrastructureSubtypes.contains(normalizedSubtype) ||
      normalizedName.contains('su deposu') ||
      normalizedName.contains('icme suyu deposu') ||
      normalizedName.contains('water tank') ||
      normalizedName.contains('water tower') ||
      normalizedName.contains('su kulesi') ||
      normalizedName.contains('terfi merkezi') ||
      normalizedName.contains('su aritma tesisi')) {
    return true;
  }

  if (mainCategory == 'local_service' ||
      subtype == 'local_service' ||
      (subtype != null && subtype.startsWith('service_'))) {
    return false;
  }
  final lower = name.toLowerCase().trim();
  if (lower.isEmpty) return false;

  // 1. Sokak, cadde, bulvar, kümeevleri vb. kentsel yol adlandırmaları
  if (lower.contains('sokağı') ||
      lower.contains('sokak') ||
      lower.contains('sok.') ||
      lower.contains('caddesi') ||
      lower.contains('cadde') ||
      lower.contains('cad.') ||
      lower.contains('bulvarı') ||
      lower.contains('bulvar') ||
      lower.contains('kümeevleri') ||
      lower.contains('küme evleri') ||
      lower.contains('kume evleri')) {
    return true;
  }

  // 2. İdari, kadastro veya mahalle sınırları
  if (lower.contains('mahalle sınırı') ||
      lower.contains('mahallesiniri') ||
      lower.contains('köy sınırı') ||
      lower.contains('ilçe sınırı') ||
      lower.contains('sınırı') ||
      lower.contains('mevkii sınırı')) {
    return true;
  }

  // 3. İbadethane ve mezarlıklar (Doğa oluşumu değildir)
  if (lower.contains('camii') ||
      lower.contains('cami') ||
      lower.contains('mescidi') ||
      lower.contains('mescit') ||
      lower.contains('mezarlığı') ||
      lower.contains('mezarlık')) {
    return true;
  }

  // 4. "Obruk" ile karışan yerleşim adları:
  // Karstik jeolojik obruk olmayan mahalle, köy ve kümeevleri yerleşimleri elenir.
  final isSinkhole = subtype == 'sinkhole' || mainCategory == 'canyon_valley';
  if (isSinkhole || lower.contains('obruk')) {
    if (lower.startsWith('yukarı obruk') ||
        lower.startsWith('aşağı obruk') ||
        lower.startsWith('orta obruk') ||
        lower.contains('obruk mahallesi') ||
        lower.contains('obruk köyü') ||
        lower == 'yukarı obruk' ||
        lower == 'aşağı obruk' ||
        lower == 'obruk') {
      return true;
    }
  }

  return false;
}

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

String facilityDisplayLabel(String key) {
  final localized = AppStrings.facility(key);
  if (localized != key) return localized;
  return facilityLabels[key] ?? nearbyFacilityLabels[key] ?? key;
}

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
