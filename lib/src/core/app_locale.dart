part of '../../main.dart';

// ---------------------------------------------------------------------------
// AppLocaleController  —  Dil seçimini SharedPreferences'ta kalıcı tutar.
// ---------------------------------------------------------------------------

class AppLanguageOption {
  final Locale locale;
  final String label;
  final String nativeLabel;
  final String flag;

  const AppLanguageOption({
    required this.locale,
    required this.label,
    required this.nativeLabel,
    required this.flag,
  });
}

class AppLocaleController {
  AppLocaleController._();

  static const _key = 'app_locale';
  static final ValueNotifier<Locale> current =
      ValueNotifier<Locale>(const Locale('tr'));

  static const List<Locale> supported = [
    Locale('tr'),
    Locale('en'),
    Locale('ar'),
  ];

  static const List<AppLanguageOption> options = [
    AppLanguageOption(
      locale: Locale('tr'),
      label: 'Türkçe',
      nativeLabel: 'Türkçe',
      flag: '🇹🇷',
    ),
    AppLanguageOption(
      locale: Locale('en'),
      label: 'İngilizce',
      nativeLabel: 'English',
      flag: '🇬🇧',
    ),
    AppLanguageOption(
      locale: Locale('ar'),
      label: 'Arapça',
      nativeLabel: 'العربية',
      flag: '🇸🇦',
    ),
  ];

  static bool get isArabic => current.value.languageCode == 'ar';
  static bool get isRtl => isArabic;
  static TextDirection get textDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null) {
      final locale = supported.firstWhere(
        (l) => l.languageCode == code,
        orElse: () => const Locale('tr'),
      );
      current.value = locale;
    }
  }

  static Future<void> setLocale(Locale locale) async {
    current.value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}

// ---------------------------------------------------------------------------
// AppStrings  —  Merkezi çeviri sözlüğü (TR / EN / AR).
// ---------------------------------------------------------------------------

class AppStrings {
  AppStrings._();

  static String get(String key) {
    final code = AppLocaleController.current.value.languageCode;
    return (_map[key]?[code]) ?? (_map[key]?['tr']) ?? key;
  }

  static String of(BuildContext context, String key) => get(key);

  static String category(String? key) {
    if (key == null) return '';
    final code = AppLocaleController.current.value.languageCode;
    return (_categories[key]?[code]) ?? (_categories[key]?['tr']) ?? key;
  }

  static String subtype(String? key) {
    if (key == null) return '';
    final code = AppLocaleController.current.value.languageCode;
    return (_subtypes[key]?[code]) ?? (_subtypes[key]?['tr']) ?? key;
  }

  static String facility(String? key) {
    if (key == null) return '';
    final normalized = key.startsWith('nearby_') ? key.substring(7) : key;
    final code = AppLocaleController.current.value.languageCode;
    return (_facilities[normalized]?[code]) ??
        (_facilities[normalized]?['tr']) ??
        (_facilities[key]?[code]) ??
        (_facilities[key]?['tr']) ??
        key;
  }

  static String addPlaceOption(String? key) {
    if (key == null) return '';
    final code = AppLocaleController.current.value.languageCode;
    return (_addPlaceOptions[key]?[code]) ??
        (_addPlaceOptions[key]?['tr']) ??
        key;
  }

  static String weekdayShort(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return get('weather_today');
    }
    return get('weekday_${date.weekday}');
  }

  static const Map<String, Map<String, String>> _categories = {
    'camp': {
      'tr': 'Kamp',
      'en': 'Camp',
      'ar': 'تخييم',
    },
    'caravan': {
      'tr': 'Karavan',
      'en': 'Caravan',
      'ar': 'كرفان',
    },
    'lake': {
      'tr': 'Göl',
      'en': 'Lake',
      'ar': 'بحيرة',
    },
    'waterfall': {
      'tr': 'Şelale',
      'en': 'Waterfall',
      'ar': 'شلال',
    },
    'canyon_valley': {
      'tr': 'Kanyon & Vadi',
      'en': 'Canyon & Valley',
      'ar': 'وادي وأخدود',
    },
    'cave': {
      'tr': 'Mağara',
      'en': 'Cave',
      'ar': 'كهف',
    },
    'national_park': {
      'tr': 'Millî / Doğa Parkı',
      'en': 'National / Nature Park',
      'ar': 'حديقة وطنية وطبيعية',
    },
    'local_service': {
      'tr': 'Mobil Servis',
      'en': 'Mobile Service',
      'ar': 'الخدمات المتنقلة',
    },
  };

  static const Map<String, Map<String, String>> _subtypes = {
    'local_service': {
      'tr': 'Mobil Servis',
      'en': 'Mobile Service',
      'ar': 'الخدمة المتنقلة',
    },
    'service_roadside': {
      'tr': 'Çekici / Yol Yardım',
      'en': 'Towing / Roadside Assistance',
      'ar': 'سحب وإنقاذ المركبات',
    },
    'service_maintenance': {
      'tr': 'Yıllık Bakım',
      'en': 'Annual Maintenance',
      'ar': 'الصيانة الدورية',
    },
    'service_gas': {
      'tr': 'Gaz Tesisatı',
      'en': 'Gas System & LPG',
      'ar': 'تمديدات الغاز',
    },
    'service_hvac': {
      'tr': 'Isıtma & Soğutma',
      'en': 'Heating & Cooling (HVAC)',
      'ar': 'التدفئة والتكييف',
    },
    'service_electric': {
      'tr': 'Elektrik & Enerji',
      'en': 'Electric & Solar Energy',
      'ar': 'الكهرباء والطاقة الشمسية',
    },
    'service_plumbing': {
      'tr': 'Su & Tesisat',
      'en': 'Water & Plumbing',
      'ar': 'تمديدات المياه والسباكة',
    },
    'service_bodywork': {
      'tr': 'Nem & Gövde',
      'en': 'Moisture & Bodywork',
      'ar': 'العزل وهيكل الكرفان',
    },
    'service_chassis_brakes': {
      'tr': 'Şasi & Fren',
      'en': 'Chassis & Brakes',
      'ar': 'الشاسيه والفرامل والإطارات',
    },
    'service_parts': {
      'tr': 'Montaj & Parça',
      'en': 'Assembly & Spare Parts',
      'ar': 'التركيب وقطع الغيار',
    },
    'service_inspection': {
      'tr': 'Muayene',
      'en': 'Vehicle Inspection',
      'ar': 'الفحص والمعاينة',
    },
    'lake': {'tr': 'Göl', 'en': 'Lake', 'ar': 'بحيرة'},
    'waterfall': {'tr': 'Şelale', 'en': 'Waterfall', 'ar': 'شلال'},
    'stream': {'tr': 'Dere', 'en': 'Stream', 'ar': 'جدول'},
    'river': {'tr': 'Nehir', 'en': 'River', 'ar': 'نهر'},
    'spring': {'tr': 'Pınar/Kaynak', 'en': 'Spring', 'ar': 'نبع مائي'},
    'natural_pool': {
      'tr': 'Doğal Havuz',
      'en': 'Natural Pool',
      'ar': 'مسبح طبيعي'
    },
    'mountain': {'tr': 'Dağ', 'en': 'Mountain', 'ar': 'جبل'},
    'peak': {'tr': 'Zirve', 'en': 'Peak', 'ar': 'قمة'},
    'hill': {'tr': 'Tepe', 'en': 'Hill', 'ar': 'تلة'},
    'plateau': {'tr': 'Yayla', 'en': 'Plateau', 'ar': 'هضبة'},
    'plateau_landform': {'tr': 'Plato', 'en': 'Plateau', 'ar': 'سهل مرتفع'},
    'valley': {'tr': 'Vadi', 'en': 'Valley', 'ar': 'وادي'},
    'canyon': {'tr': 'Kanyon', 'en': 'Canyon', 'ar': 'واد سحيق'},
    'cave': {'tr': 'Mağara', 'en': 'Cave', 'ar': 'كهف'},
    'sinkhole': {'tr': 'Obruk', 'en': 'Sinkhole', 'ar': 'حفرة انهدامية'},
    'travertine': {
      'tr': 'Traverten',
      'en': 'Travertine',
      'ar': 'مصاطب الترافرتين'
    },
    'fairy_chimney': {
      'tr': 'Peribacası',
      'en': 'Fairy Chimney',
      'ar': 'مداخن الجنيات'
    },
    'natural_arch': {
      'tr': 'Doğal Kemer',
      'en': 'Natural Arch',
      'ar': 'قوس طبيعي'
    },
    'forest': {'tr': 'Orman', 'en': 'Forest', 'ar': 'غابة'},
    'national_park': {
      'tr': 'Milli Park',
      'en': 'National Park',
      'ar': 'حديقة وطنية'
    },
    'nature_park': {
      'tr': 'Tabiat Parkı',
      'en': 'Nature Park',
      'ar': 'منتزه طبيعي'
    },
    'wetland': {'tr': 'Sulak Alan', 'en': 'Wetland', 'ar': 'أراضٍ رطبة'},
    'protected_area': {
      'tr': 'Korunan Alan',
      'en': 'Protected Area',
      'ar': 'منطقة محمية'
    },
    'picnic_area': {
      'tr': 'Mesire/Piknik Alanı',
      'en': 'Picnic Area',
      'ar': 'منطقة تنزه'
    },
    'camp_site': {'tr': 'Kamp Alanı', 'en': 'Campsite', 'ar': 'موقع تخييم'},
    'caravan_site': {
      'tr': 'Karavan Alanı',
      'en': 'Caravan Site',
      'ar': 'موقع كرفانات'
    },
    'hiking': {'tr': 'Yürüyüş', 'en': 'Hiking', 'ar': 'مشي جبلي'},
    'trekking': {'tr': 'Trekking', 'en': 'Trekking', 'ar': 'مسير'},
    'cycling': {'tr': 'Bisiklet', 'en': 'Cycling', 'ar': 'ركوب الدراجات'},
    'climbing': {'tr': 'Tırmanış', 'en': 'Climbing', 'ar': 'تسلق'},
    'canoe': {'tr': 'Kano', 'en': 'Canoe', 'ar': 'قوارب الكانو'},
    'viewpoint': {'tr': 'Seyir Noktası', 'en': 'Viewpoint', 'ar': 'مطل'},
    'sunset_viewpoint': {
      'tr': 'Gün Batımı',
      'en': 'Sunset Viewpoint',
      'ar': 'مطل الغروب'
    },
    'photo_spot': {
      'tr': 'Fotoğraf Noktası',
      'en': 'Photo Spot',
      'ar': 'موقع تصوير'
    },
    'stargazing': {
      'tr': 'Yıldız Gözlem',
      'en': 'Stargazing',
      'ar': 'مراقبة النجوم'
    },
    'birdwatching': {
      'tr': 'Kuş Gözlem',
      'en': 'Birdwatching',
      'ar': 'مراقبة الطيور'
    },
    'wildlife_observation': {
      'tr': 'Yaban Hayatı Gözlem',
      'en': 'Wildlife Observation',
      'ar': 'رصد الحياة البرية'
    },
    'endemic_flora': {
      'tr': 'Endemik Bitki',
      'en': 'Endemic Flora',
      'ar': 'نباتات مستوطنة'
    },
    'monument_tree': {
      'tr': 'Anıt Ağaç',
      'en': 'Monument Tree',
      'ar': 'شجرة معمرة'
    },
    'toilet': {'tr': 'WC', 'en': 'Restroom', 'ar': 'دورة مياه'},
    'drinking_water': {
      'tr': 'İçme Suyu',
      'en': 'Drinking Water',
      'ar': 'مياه شرب'
    },
    'water_fountain': {'tr': 'Çeşme', 'en': 'Fountain', 'ar': 'ينبوع'},
  };

  static const Map<String, Map<String, String>> _facilities = {
    'toilets': {'tr': 'Tuvalet', 'en': 'Restroom', 'ar': 'دورة مياه'},
    'drinking_water': {
      'tr': 'İçme Suyu',
      'en': 'Drinking Water',
      'ar': 'مياه شرب'
    },
    'parking': {'tr': 'Otopark', 'en': 'Parking', 'ar': 'موقف سيارات'},
    'shower': {'tr': 'Duş', 'en': 'Shower', 'ar': 'دش استحمام'},
    'electricity': {'tr': 'Elektrik', 'en': 'Electricity', 'ar': 'كهرباء'},
    'picnic_allowed': {
      'tr': 'Piknik İzni',
      'en': 'Picnic Allowed',
      'ar': 'التنزه مسموح'
    },
    'picnic_facility': {
      'tr': 'Piknik Alanı',
      'en': 'Picnic Area',
      'ar': 'منطقة تنزه'
    },
    'picnic_table_nearby': {
      'tr': 'Piknik Masası',
      'en': 'Picnic Table',
      'ar': 'طاولة نزهة'
    },
    'bbq_allowed': {
      'tr': 'Mangal İzni',
      'en': 'BBQ Allowed',
      'ar': 'الشواء مسموح'
    },
    'bbq_facility': {
      'tr': 'Mangal Alanı',
      'en': 'BBQ Area',
      'ar': 'منطقة شواء'
    },
    'open_fire_allowed': {
      'tr': 'Açık Ateş İzni',
      'en': 'Campfire Allowed',
      'ar': 'إشعال النار مسموح'
    },
    'firepit_facility': {
      'tr': 'Ateş Yakma Alanı',
      'en': 'Firepit Area',
      'ar': 'مكان إشعال النار'
    },
    'tents': {'tr': 'Çadır', 'en': 'Tent', 'ar': 'خيمة'},
    'caravans': {'tr': 'Karavan', 'en': 'Caravan', 'ar': 'كرفان'},
    'dump_station': {
      'tr': 'Atık Boşaltma',
      'en': 'Waste Dump',
      'ar': 'تفريغ النفايات'
    },
  };

  static const Map<String, Map<String, String>> _addPlaceOptions = {
    // Kategoriler
    'Şelale': {'tr': 'Şelale', 'en': 'Waterfall', 'ar': 'شلال'},
    'Göl': {'tr': 'Göl', 'en': 'Lake', 'ar': 'بحيرة'},
    'Kanyon': {'tr': 'Kanyon', 'en': 'Canyon', 'ar': 'واد سحيق'},
    'Kamp Alanı': {'tr': 'Kamp Alanı', 'en': 'Campsite', 'ar': 'موقع تخييم'},
    'Milli Park': {
      'tr': 'Milli Park',
      'en': 'National Park',
      'ar': 'حديقة وطنية'
    },
    'Tabiat Parkı': {
      'tr': 'Tabiat Parkı',
      'en': 'Nature Park',
      'ar': 'منتزه طبيعي'
    },
    'Yayla': {'tr': 'Yayla', 'en': 'Plateau', 'ar': 'هضبة'},
    'Piknik': {'tr': 'Piknik', 'en': 'Picnic', 'ar': 'تنزه'},
    'Yürüyüş': {'tr': 'Yürüyüş', 'en': 'Hiking', 'ar': 'مشي جبلي'},
    'Koy ve Plaj': {
      'tr': 'Koy ve Plaj',
      'en': 'Bay & Beach',
      'ar': 'خليج وشاطئ'
    },
    'Seyir Noktası': {'tr': 'Seyir Noktası', 'en': 'Viewpoint', 'ar': 'مطل'},
    'Mağara': {'tr': 'Mağara', 'en': 'Cave', 'ar': 'كهف'},
    'Karavan': {'tr': 'Karavan', 'en': 'Caravan', 'ar': 'كرفان'},
    'WC': {'tr': 'WC', 'en': 'Restroom', 'ar': 'دورة مياه'},

    // Çevre Yapısı
    'Ormanlık': {'tr': 'Ormanlık', 'en': 'Forested', 'ar': 'غابات'},
    'Göl kıyısı': {'tr': 'Göl kıyısı', 'en': 'Lakeside', 'ar': 'شاطئ بحيرة'},
    'Sahil': {'tr': 'Sahil', 'en': 'Seaside', 'ar': 'ساحلي'},
    'Dağlık': {'tr': 'Dağlık', 'en': 'Mountainous', 'ar': 'جبلي'},
    'Açık alan': {'tr': 'Açık alan', 'en': 'Open Area', 'ar': 'مساحة مفتوحة'},

    // Ulaşım
    'Binek araç': {
      'tr': 'Binek araç',
      'en': 'Standard Car',
      'ar': 'سيارة ركاب'
    },
    'Arazi aracı': {
      'tr': 'Arazi aracı',
      'en': '4x4 / Off-Road',
      'ar': 'سيارة دفع رباعي'
    },
    'Yalnızca yürüyerek': {
      'tr': 'Yalnızca yürüyerek',
      'en': 'Walking Only',
      'ar': 'مشياً على الأقدام فقط'
    },
    'Toplu taşıma': {
      'tr': 'Toplu taşıma',
      'en': 'Public Transit',
      'ar': 'المواصلات العامة'
    },

    // Olanaklar ve Uyarılar
    'Otopark': {'tr': 'Otopark', 'en': 'Parking', 'ar': 'موقف سيارات'},
    'Tuvalet': {'tr': 'Tuvalet', 'en': 'Restroom', 'ar': 'دورة مياه'},
    'İçme suyu': {'tr': 'İçme suyu', 'en': 'Drinking Water', 'ar': 'مياه شرب'},
    'Çeşme': {'tr': 'Çeşme', 'en': 'Fountain', 'ar': 'سبيل مياه'},
    'Duş': {'tr': 'Duş', 'en': 'Shower', 'ar': 'دش استحمام'},
    'Büfe / Market': {
      'tr': 'Büfe / Market',
      'en': 'Shop / Market',
      'ar': 'بقالة / متجر'
    },
    'Ücretli': {'tr': 'Ücretli', 'en': 'Fee / Paid', 'ar': 'مدفوع / بأجر'},
    'Çadır uygun': {
      'tr': 'Çadır uygun',
      'en': 'Tent Friendly',
      'ar': 'مناسب للخيام'
    },
    'Karavan uygun': {
      'tr': 'Karavan uygun',
      'en': 'Caravan Friendly',
      'ar': 'مناسب للكرفان'
    },
    'Piknik masası': {
      'tr': 'Piknik masası',
      'en': 'Picnic Table',
      'ar': 'طاولة نزهة'
    },
    'Mobil sinyal': {
      'tr': 'Mobil sinyal',
      'en': 'Mobile Signal',
      'ar': 'تغطية اتصال'
    },
    'Engelli erişimi': {
      'tr': 'Engelli erişimi',
      'en': 'Accessible',
      'ar': 'ميسر لذوي الإعاقة'
    },
    'Evcil hayvan': {
      'tr': 'Evcil hayvan',
      'en': 'Pet Friendly',
      'ar': 'صديق للحيوانات'
    },
    'Ateş yasak': {
      'tr': 'Ateş yasak',
      'en': 'No Open Fire',
      'ar': 'ممنوع إشعال النار'
    },
    'Yaban hayvanı riski': {
      'tr': 'Yaban hayvanı riski',
      'en': 'Wildlife Risk',
      'ar': 'خطر حيوانات برية'
    },
  };

  static const Map<String, Map<String, String>> _map = {
    // ── Sekme adları ──────────────────────────────────────────────────────
    'tab_discover': {
      'tr': 'Keşfet',
      'en': 'Discover',
      'ar': 'اكتشف',
    },
    'tab_map': {
      'tr': 'Harita',
      'en': 'Map',
      'ar': 'الخريطة',
    },
    'tab_community': {
      'tr': 'Topluluk',
      'en': 'Community',
      'ar': 'المجتمع',
    },
    'tab_goodness': {
      'tr': 'İyilik',
      'en': 'Goodness',
      'ar': 'إحسان',
    },
    'tab_favorites': {
      'tr': 'Favoriler',
      'en': 'Favorites',
      'ar': 'المفضلة',
    },
    'tab_profile': {
      'tr': 'Profil',
      'en': 'Profile',
      'ar': 'الملف',
    },
    'tab_add_place': {
      'tr': 'Yer Ekle',
      'en': 'Add Place',
      'ar': 'إضافة مكان',
    },
    'select_language_title': {
      'tr': 'Dil Seçin',
      'en': 'Select Language',
      'ar': 'اختر اللغة',
    },
    'language_changed_toast': {
      'tr': 'Dil güncellendi',
      'en': 'Language updated',
      'ar': 'تم تحديث اللغة',
    },

    // ── Arama ─────────────────────────────────────────────────────────────
    'search_hint': {
      'tr': 'Yer ara…',
      'en': 'Search places…',
      'ar': 'ابحث عن مكان…',
    },
    'search_no_result': {
      'tr': 'Sonuç bulunamadı',
      'en': 'No results found',
      'ar': 'لا توجد نتائج',
    },
    'search_input_hint': {
      'tr': 'Şelale, göl, kamp alanı...',
      'en': 'Waterfall, lake, campsite...',
      'ar': 'شلال، بحيرة، موقع تخييم...',
    },
    'recent_searches': {
      'tr': 'Son aramalar',
      'en': 'Recent searches',
      'ar': 'عمليات البحث الأخيرة',
    },
    'clear_searches': {
      'tr': 'Temizle',
      'en': 'Clear',
      'ar': 'مسح',
    },

    // ── Ana sayfa ─────────────────────────────────────────────────────────
    'home_greeting': {
      'tr': 'Merhaba',
      'en': 'Hello',
      'ar': 'مرحباً',
    },
    'home_nearby': {
      'tr': 'Yakınımdaki Yerler',
      'en': 'Nearby Places',
      'ar': 'أماكن قريبة',
    },
    'home_recommended': {
      'tr': 'Önerilen',
      'en': 'Recommended',
      'ar': 'مُوصى به',
    },
    'home_explore_by_category': {
      'tr': 'Kategoriyle keşfet',
      'en': 'Explore by category',
      'ar': 'استكشف حسب الفئة',
    },
    'home_for_you_today': {
      'tr': 'Bugün sana uygun',
      'en': 'Handpicked for Today',
      'ar': 'مناسب لك اليوم',
    },
    'home_see_all': {
      'tr': 'Tümünü gör',
      'en': 'See all',
      'ar': 'عرض الكل',
    },
    'home_nearby_places': {
      'tr': 'Yakınındaki yerler',
      'en': 'Nearby places',
      'ar': 'أماكن قريبة منك',
    },
    'home_community_recommendations': {
      'tr': 'Topluluk Önerileri',
      'en': 'Community Recommendations',
      'ar': 'توصيات المجتمع',
    },
    'home_search_hint': {
      'tr': 'Keşfetmek istediğin yeri ara...',
      'en': 'Search places to explore...',
      'ar': 'ابحث عن مكان لاكتشافه...',
    },
    'home_locating': {
      'tr': 'Konum belirleniyor',
      'en': 'Locating...',
      'ar': 'جاري تحديد الموقع...',
    },
    'my_location': {
      'tr': 'Bulunduğu alan',
      'en': 'Current Area',
      'ar': 'المنطقة الحالية',
    },
    'home_explore_map': {
      'tr': 'Haritada keşfet',
      'en': 'Explore on map',
      'ar': 'استكشف على الخريطة',
    },
    'home_no_recommendations': {
      'tr': 'Şu an için uygun bir öneri bulunamadı.',
      'en': 'No recommendations found right now.',
      'ar': 'لم يتم العثور على اقتراحات حالياً.',
    },
    'home_community_error': {
      'tr': 'Konumuna göre topluluk önerileri şu anda alınamadı.',
      'en': 'Could not retrieve community recommendations.',
      'ar': 'تعذر جلب اقتراحات المجتمع حالياً.',
    },
    'home_location_required_title': {
      'tr': 'Yakındaki yerler için konum gerekli',
      'en': 'Location required for nearby places',
      'ar': 'الموقع مطلوب للأماكن القريبة',
    },
    'home_location_permission_needed': {
      'tr': 'Yakınındaki yerleri görmek için konum izni ver.',
      'en': 'Allow location access to see nearby places.',
      'ar': 'اسمح بالوصول إلى الموقع لرؤية الأماكن القريبة.',
    },
    'home_location_permission_required': {
      'tr': 'Konum izni gerekli',
      'en': 'Location required',
      'ar': 'إذن الموقع مطلوب',
    },
    'home_open_location': {
      'tr': 'Konumu Aç',
      'en': 'Enable Location',
      'ar': 'تفعيل الموقع',
    },
    'home_newly_added': {
      'tr': 'Yeni Eklenen',
      'en': 'Newly Added',
      'ar': 'المضاف حديثاً',
    },
    'home_newly_added_sub': {
      'tr': 'Son OSM güncellenme tarihine göre sıralandı',
      'en': 'Sorted by latest OSM update date',
      'ar': 'مرتب حسب تاريخ آخر تحديث لـ OSM',
    },
    'home_new_badge': {
      'tr': 'YENİ',
      'en': 'NEW',
      'ar': 'جديد',
    },
    'search_button': {
      'tr': 'Ara',
      'en': 'Search',
      'ar': 'بحث',
    },
    'search_recent_searches': {
      'tr': 'Son Aramalar',
      'en': 'Recent Searches',
      'ar': 'عمليات البحث الأخيرة',
    },
    'search_clear': {
      'tr': 'Temizle',
      'en': 'Clear',
      'ar': 'مسح',
    },
    'search_no_recent': {
      'tr': 'Henüz son arama yok.',
      'en': 'No recent searches yet.',
      'ar': 'لا توجد عمليات بحث أخيرة.',
    },
    'search_no_results': {
      'tr': 'Bu aramaya uygun bir yer bulunamadı.',
      'en': 'No places found matching this search.',
      'ar': 'لم يتم العثور على مكان يطابق هذا البحث.',
    },
    'search_results_for': {
      'tr': 'sonuç',
      'en': 'results',
      'ar': 'نتائج',
    },
    'nature_spot': {
      'tr': 'Doğa Noktası',
      'en': 'Nature Spot',
      'ar': 'نقطة طبيعية',
    },

    // ── Detay ekranı & Bilgi Kartları ─────────────────────────────────────
    'detail_navigate': {
      'tr': 'Yol Tarifi',
      'en': 'Directions',
      'ar': 'الاتجاهات',
    },
    'detail_review': {
      'tr': 'Değerlendir',
      'en': 'Review',
      'ar': 'تقييم',
    },
    'detail_share': {
      'tr': 'Paylaş',
      'en': 'Share',
      'ar': 'مشاركة',
    },
    'detail_add_photo': {
      'tr': 'Fotoğraf Ekle',
      'en': 'Add Photo',
      'ar': 'إضافة صورة',
    },
    'detail_about': {
      'tr': 'Hakkında',
      'en': 'About',
      'ar': 'عن المكان',
    },
    'detail_facilities': {
      'tr': 'Olanaklar',
      'en': 'Facilities',
      'ar': 'المرافق',
    },
    'detail_reviews': {
      'tr': 'Değerlendirmeler',
      'en': 'Reviews',
      'ar': 'التقييمات',
    },
    'detail_photos': {
      'tr': 'Fotoğraflar',
      'en': 'Photos',
      'ar': 'الصور',
    },
    'detail_nearby': {
      'tr': 'Yakında',
      'en': 'Nearby',
      'ar': 'قريب',
    },
    'detail_nearby_title': {
      'tr': 'Buraya Yakın Yerler',
      'en': 'Places Near Here',
      'ar': 'أماكن قريبة من هنا',
    },
    'detail_weather_title': {
      'tr': 'Bölge Havası',
      'en': 'Regional Weather',
      'ar': 'طقس المنطقة',
    },
    'detail_nav_start': {
      'tr': 'Navigasyonu Başlat',
      'en': 'Start Navigation',
      'ar': 'بدء التنقل',
    },
    'detail_write_review': {
      'tr': 'Değerlendirme Yaz',
      'en': 'Write Review',
      'ar': 'كتابة تقييم',
    },
    'detail_recommend_community': {
      'tr': 'Topluluk ile Öner',
      'en': 'Recommend to Community',
      'ar': 'التوصية للمجتمع',
    },
    'detail_helpful': {
      'tr': 'Faydalı',
      'en': 'Helpful',
      'ar': 'مفيد',
    },
    'detail_reply': {
      'tr': 'Yanıtla',
      'en': 'Reply',
      'ar': 'رد',
    },
    'detail_view_all': {
      'tr': 'Tümünü Gör',
      'en': 'See All',
      'ar': 'عرض الكل',
    },
    'detail_view_photos': {
      'tr': 'Görüntüle',
      'en': 'View',
      'ar': 'عرض',
    },
    'detail_no_reviews_yet': {
      'tr': 'Henüz değerlendirme yok',
      'en': 'No reviews yet',
      'ar': 'لا توجد تقييمات بعد',
    },
    'detail_photo_count_label': {
      'tr': 'fotoğraf',
      'en': 'photos',
      'ar': 'صور',
    },
    'card_coordinates': {
      'tr': 'KOORDİNATLAR',
      'en': 'COORDINATES',
      'ar': 'الإحداثيات',
    },
    'card_data_source': {
      'tr': 'VERİ KAYNAĞI',
      'en': 'DATA SOURCE',
      'ar': 'مصدر البيانات',
    },
    'card_record_type': {
      'tr': 'KAYIT MODELİ',
      'en': 'RECORD TYPE',
      'ar': 'نوع السجل',
    },
    'card_last_updated': {
      'tr': 'SON GÜNCELLEME',
      'en': 'LAST UPDATED',
      'ar': 'آخر تحديث',
    },
    'card_place_type': {
      'tr': 'Yer Türü',
      'en': 'Place Type',
      'ar': 'نوع المكان',
    },
    'card_arrival_time': {
      'tr': 'Ortalama Varış Süresi',
      'en': 'Estimated Arrival',
      'ar': 'وقت الوصول المتوقع',
    },
    'card_road_distance': {
      'tr': 'Yol Mesafesi',
      'en': 'Road Distance',
      'ar': 'مسافة الطريق',
    },
    'card_crow_distance': {
      'tr': 'Kuş Uçuşu',
      'en': 'Direct Distance',
      'ar': 'مسافة مباشرة',
    },
    'card_distance': {
      'tr': 'Mesafe',
      'en': 'Distance',
      'ar': 'المسافة',
    },
    'card_calculating': {
      'tr': 'Hesaplanıyor',
      'en': 'Calculating…',
      'ar': 'جاري الحساب…',
    },
    'card_route_not_found': {
      'tr': 'Rota bulunamadı',
      'en': 'Route not found',
      'ar': 'تعذر إيجاد مسار',
    },
    'card_no_coordinates': {
      'tr': 'Koordinat yok',
      'en': 'No coordinates',
      'ar': 'لا توجد إحداثيات',
    },
    'card_no_date': {
      'tr': 'Tarih bilgisi yok',
      'en': 'No date info',
      'ar': 'لا توجد معلومات تاريخ',
    },
    'card_location_required': {
      'tr': 'Konum gerekli',
      'en': 'Location required',
      'ar': 'الموقع مطلوب',
    },
    'card_no_description': {
      'tr': 'Bu yer için kayıtlı bir açıklama henüz eklenmemiş.',
      'en': 'No description has been added for this place yet.',
      'ar': 'لم تتم إضافة وصف لهذا المكان بعد.',
    },
    'card_no_photos': {
      'tr': 'Bu yer için gerçek bir fotoğraf henüz eklenmemiş.',
      'en': 'No real photos added for this place yet.',
      'ar': 'لم تتم إضافة صور حقيقية لهذا المكان بعد.',
    },
    'card_no_reviews': {
      'tr': 'Bu yer için henüz gerçek bir değerlendirme yapılmamış.',
      'en': 'No reviews yet for this place.',
      'ar': 'لم يُكتب أي تقييم حقيقي لهذا المكان بعد.',
    },
    'card_no_facilities': {
      'tr': 'Bu yer için doğrulanmış olanak bulunamadı.',
      'en': 'No verified facilities found for this place.',
      'ar': 'لم يتم العثور على مرافق موثقة لهذا المكان.',
    },
    'card_no_facilities_yet': {
      'tr': 'Bu yer için doğrulanmış olanak bilgisi henüz yok.',
      'en': 'No verified facility info for this place yet.',
      'ar': 'لا توجد معلومات مرافق موثقة حتى الآن.',
    },
    'detail_field_conditions': {
      'tr': 'Saha Koşulları & İhtiyaçlar',
      'en': 'Field Conditions & Essentials',
      'ar': 'الظروف الميدانية والاحتياجات',
    },
    'field_drinking_water': {
      'tr': 'İçme Suyu',
      'en': 'Drinking Water',
      'ar': 'مياه الشرب',
    },
    'field_toilets': {
      'tr': 'Tuvalet',
      'en': 'Restroom',
      'ar': 'دورة مياه',
    },
    'field_parking': {
      'tr': 'Otopark',
      'en': 'Parking',
      'ar': 'موقف سيارات',
    },
    'field_picnic_camp': {
      'tr': 'Piknik & Kamp',
      'en': 'Picnic & Camp',
      'ar': 'تنزه وتخييم',
    },
    'field_road_access': {
      'tr': 'Araç Erişimi & Yol',
      'en': 'Road & Vehicle Access',
      'ar': 'وصول المركبات والطرق',
    },
    'field_walking_distance': {
      'tr': 'Son Yürüme Mesafesi',
      'en': 'Final Walking Distance',
      'ar': 'مسافة المشي الأخيرة',
    },
    'field_status_verified': {
      'tr': 'Doğrulandı',
      'en': 'Verified',
      'ar': 'موثق',
    },
    'field_status_community': {
      'tr': 'Topluluk bildirimi',
      'en': 'Community reported',
      'ar': 'إبلاغ مجتمعي',
    },
    'field_status_absent': {
      'tr': 'Mevcut değil',
      'en': 'Not available',
      'ar': 'غير متوفر',
    },
    'field_status_unknown': {
      'tr': 'Bilinmiyor',
      'en': 'Unknown',
      'ar': 'غير معروف',
    },
    'source_osm': {
      'tr': 'OpenStreetMap verisi',
      'en': 'OpenStreetMap data',
      'ar': 'بيانات OpenStreetMap',
    },
    'source_community': {
      'tr': 'Topluluk katkısı',
      'en': 'Community contribution',
      'ar': 'مساهمة المجتمع',
    },
    'source_supabase': {
      'tr': 'Doğadayım kaydı',
      'en': 'Doğadayım record',
      'ar': 'سجل Doğadayım',
    },
    'trust_verified': {
      'tr': 'Doğrulanmış',
      'en': 'Verified',
      'ar': 'موثق',
    },
    'trust_verified_compact': {
      'tr': 'Doğrulandı',
      'en': 'Verified',
      'ar': 'موثق',
    },
    'trust_community': {
      'tr': 'Topluluk katkısı',
      'en': 'Community contribution',
      'ar': 'مساهمة مجتمعية',
    },
    'trust_community_compact': {
      'tr': 'Topluluk',
      'en': 'Community',
      'ar': 'مجتمع',
    },
    'trust_unverified': {
      'tr': 'Henüz incelenmedi',
      'en': 'Not yet reviewed',
      'ar': 'لم يتم التحقق',
    },
    'trust_unverified_compact': {
      'tr': 'İncelenmedi',
      'en': 'Unverified',
      'ar': 'غير مدقق',
    },
    'share_prepared': {
      'tr': 'Paylaşım bağlantısı hazırlandı.',
      'en': 'Share link prepared.',
      'ar': 'تم تجهيز رابط المشاركة.',
    },
    'nav_select_app': {
      'tr': 'Navigasyon uygulamasını seç',
      'en': 'Select navigation app',
      'ar': 'اختر تطبيق الملاحة',
    },
    'nav_google_smart': {
      'tr': 'Google Haritalar (Önerilen)',
      'en': 'Google Maps (Recommended)',
      'ar': 'خرائط جوجل (موصى به)',
    },
    'nav_google_smart_desc': {
      'tr': 'Resmi giriş ve tabela noktasına yönlendirir',
      'en': 'Navigates to official entrance and signs',
      'ar': 'يوجه إلى المدخل الرسمي واللوحات',
    },
    'nav_google_coord': {
      'tr': 'Google Haritalar (GPS Koordinatı)',
      'en': 'Google Maps (GPS Coordinates)',
      'ar': 'خرائط جوجل (إحداثيات GPS)',
    },
    'nav_google_coord_desc': {
      'tr': 'Doğrudan ham koordinat noktasına rota açar',
      'en': 'Opens route directly to raw coordinates',
      'ar': 'يفتح المسار مباشرة إلى الإحداثيات',
    },
    'nav_apple': {
      'tr': 'Apple Haritalar',
      'en': 'Apple Maps',
      'ar': 'خرائط آبل',
    },
    'nav_apple_desc': {
      'tr': 'Apple Maps ile aç',
      'en': 'Open with Apple Maps',
      'ar': 'فتح باستخدام خرائط آبل',
    },
    'nav_yandex': {
      'tr': 'Yandex Haritalar',
      'en': 'Yandex Maps',
      'ar': 'خرائط ياندكس',
    },
    'nav_yandex_desc': {
      'tr': 'Yandex Maps ile aç',
      'en': 'Open with Yandex Maps',
      'ar': 'فتح باستخدام خرائط ياندكس',
    },
    'nav_copy_coords': {
      'tr': 'Koordinatları Kopyala',
      'en': 'Copy Coordinates',
      'ar': 'نسخ الإحداثيات',
    },
    'nav_coords_copied': {
      'tr': 'Koordinatlar panoya kopyalandı.',
      'en': 'Coordinates copied to clipboard.',
      'ar': 'تم نسخ الإحداثيات إلى الحافظة.',
    },

    // ── Hava Durumu ───────────────────────────────────────────────────────
    'weather_clear': {
      'tr': 'Açık',
      'en': 'Clear',
      'ar': 'صافٍ',
    },
    'weather_mostly_clear': {
      'tr': 'Çoğunlukla Açık',
      'en': 'Mostly Clear',
      'ar': 'صافٍ غالباً',
    },
    'weather_partly_cloudy': {
      'tr': 'Parçalı Bulutlu',
      'en': 'Partly Cloudy',
      'ar': 'غائم جزئياً',
    },
    'weather_overcast': {
      'tr': 'Kapalı',
      'en': 'Overcast',
      'ar': 'غائم كلياً',
    },
    'weather_foggy': {
      'tr': 'Sisli',
      'en': 'Foggy',
      'ar': 'ضبابي',
    },
    'weather_drizzle': {
      'tr': 'Çisenti',
      'en': 'Drizzle',
      'ar': 'رذاذ',
    },
    'weather_rainy': {
      'tr': 'Yağmurlu',
      'en': 'Rainy',
      'ar': 'ممطر',
    },
    'weather_snowy': {
      'tr': 'Karlı',
      'en': 'Snowy',
      'ar': 'مثلج',
    },
    'weather_heavy_rain': {
      'tr': 'Sağanak Yağışlı',
      'en': 'Heavy Rain',
      'ar': 'أمطار غزيرة',
    },
    'weather_heavy_snow': {
      'tr': 'Kar Sağanaklı',
      'en': 'Heavy Snow',
      'ar': 'ثلوج كثيفة',
    },
    'weather_thunderstorm': {
      'tr': 'Gök Gürültülü',
      'en': 'Thunderstorm',
      'ar': 'عواصف رعدية',
    },
    'weather_variable': {
      'tr': 'Değişken',
      'en': 'Variable',
      'ar': 'متقلب',
    },
    'weather_humidity': {
      'tr': 'Nem',
      'en': 'Humidity',
      'ar': 'الرطوبة',
    },
    'weather_wind': {
      'tr': 'Rüzgâr',
      'en': 'Wind',
      'ar': 'الرياح',
    },
    'weather_uv': {
      'tr': 'UV',
      'en': 'UV',
      'ar': 'الأشعة',
    },
    'weather_visibility': {
      'tr': 'Görüş',
      'en': 'Visibility',
      'ar': 'الرؤية',
    },
    'weather_feels_like': {
      'tr': 'Hissedilen',
      'en': 'Feels like',
      'ar': 'المحسوسة',
    },
    'weather_now': {
      'tr': 'ŞU AN',
      'en': 'NOW',
      'ar': 'الآن',
    },
    'weather_ideal_outdoor': {
      'tr': 'Doğaya çıkmak için ideal bir gün',
      'en': 'Great day for outdoor adventures',
      'ar': 'يوم مثالي للخروج إلى الطبيعة',
    },
    'weather_not_ideal_outdoor': {
      'tr': 'Doğaya çıkmak için ideal bir gün olmayabilir',
      'en': 'Outdoor conditions may not be ideal',
      'ar': 'قد لا تكون الأجواء مثالية للخروج',
    },
    'weather_uv_low': {
      'tr': 'Düşük',
      'en': 'Low',
      'ar': 'منخفض',
    },
    'weather_uv_moderate': {
      'tr': 'Orta',
      'en': 'Moderate',
      'ar': 'متوسط',
    },
    'weather_uv_high': {
      'tr': 'Yüksek',
      'en': 'High',
      'ar': 'مرتفع',
    },
    'weather_uv_very_high': {
      'tr': 'Çok yüksek',
      'en': 'Very high',
      'ar': 'مرتفع جداً',
    },
    'weather_5day_forecast': {
      'tr': '5 Günlük Doğa & Kamp Tahmini',
      'en': '5-Day Nature & Camp Forecast',
      'ar': 'توقعات 5 أيام للطبيعة والتخييم',
    },
    'weather_today': {
      'tr': 'Bugün',
      'en': 'Today',
      'ar': 'اليوم',
    },
    'weather_rain_chance': {
      'tr': 'Yağış',
      'en': 'Rain',
      'ar': 'هطول',
    },
    'weekday_1': {
      'tr': 'Pzt',
      'en': 'Mon',
      'ar': 'إثنين',
    },
    'weekday_2': {
      'tr': 'Sal',
      'en': 'Tue',
      'ar': 'ثلاثاء',
    },
    'weekday_3': {
      'tr': 'Çar',
      'en': 'Wed',
      'ar': 'أربعاء',
    },
    'weekday_4': {
      'tr': 'Per',
      'en': 'Thu',
      'ar': 'خميس',
    },
    'weekday_5': {
      'tr': 'Cum',
      'en': 'Fri',
      'ar': 'جمعة',
    },
    'weekday_6': {
      'tr': 'Cmt',
      'en': 'Sat',
      'ar': 'سبت',
    },
    'weekday_7': {
      'tr': 'Paz',
      'en': 'Sun',
      'ar': 'أحد',
    },

    // ── Harita ────────────────────────────────────────────────────────────
    'all': {
      'tr': 'Tümü',
      'en': 'All',
      'ar': 'الكل',
    },
    'map_search_places': {
      'tr': 'Haritada yer ara',
      'en': 'Search places on map',
      'ar': 'بحث عن أماكن في الخريطة',
    },
    'map_search_in': {
      'tr': 'içinde ara',
      'en': 'search in',
      'ar': 'بحث في',
    },
    'map_selected_place': {
      'tr': 'Seçili yer',
      'en': 'Selected place',
      'ar': 'المكان المحدد',
    },
    'map_prev_place': {
      'tr': 'Önceki yer',
      'en': 'Previous place',
      'ar': 'المكان السابق',
    },
    'map_next_place': {
      'tr': 'En yakın sonraki yer',
      'en': 'Next nearest place',
      'ar': 'المكان التالي الأقرب',
    },
    'map_close_card': {
      'tr': 'Kartı kapat',
      'en': 'Close card',
      'ar': 'إغلاق البطاقة',
    },
    'map_show_on_map': {
      'tr': 'Haritada göster',
      'en': 'Show on map',
      'ar': 'عرض على الخريطة',
    },
    'map_view_details': {
      'tr': 'Detayları gör',
      'en': 'View details',
      'ar': 'عرض التفاصيل',
    },
    'map_layer_title': {
      'tr': 'Harita Katmanı',
      'en': 'Map Layer',
      'ar': 'طبقة الخريطة',
    },
    'map_layer_desc': {
      'tr': 'Kullanmak istediğin harita taban stilini seç.',
      'en': 'Select your preferred map base style.',
      'ar': 'اختر نمط طبقة الخريطة المناسب.',
    },
    'map_standard': {
      'tr': 'Standart',
      'en': 'Standard',
      'ar': 'قياسي',
    },
    'map_satellite': {
      'tr': 'Uydu',
      'en': 'Satellite',
      'ar': 'قمر صناعي',
    },
    'map_topo': {
      'tr': 'Topo / Doğa',
      'en': 'Topo / Nature',
      'ar': 'تضاريس / طبيعة',
    },
    'map_topo_subtitle': {
      'tr': 'Yükselti & Rota',
      'en': 'Elevation & Routes',
      'ar': 'ارتفاع ومسارات',
    },
    'map_offline_title': {
      'tr': 'Çevrimdışı harita',
      'en': 'Offline map',
      'ar': 'خرائط بدون إنترنت',
    },

    // ── Favoriler & Profil ────────────────────────────────────────────────
    'favorites_title': {
      'tr': 'Favorilerim',
      'en': 'My Favorites',
      'ar': 'المفضلة',
    },
    'favorites_saved_count': {
      'tr': 'yer kaydedildi',
      'en': 'places saved',
      'ar': 'أماكن محفوظة',
    },
    'favorites_saved_tab': {
      'tr': 'Kaydedilenler',
      'en': 'Saved',
      'ar': 'المحفوظات',
    },
    'favorites_collections_tab': {
      'tr': 'Koleksiyonlar',
      'en': 'Collections',
      'ar': 'المجموعات',
    },
    'favorites_new_collection': {
      'tr': 'Yeni Koleksiyon',
      'en': 'New Collection',
      'ar': 'مجموعة جديدة',
    },
    'favorites_categorize': {
      'tr': 'Yerlerini kategorize et',
      'en': 'Categorize your places',
      'ar': 'صنّف أماكنك المفضلة',
    },
    'favorites_no_collections': {
      'tr': 'Henüz oluşturulmuş bir koleksiyon yok.',
      'en': 'No collections created yet.',
      'ar': 'لم يتم إنشاء أي مجموعة بعد.',
    },
    'favorites_no_saved': {
      'tr': 'Henüz Kaydedilen Yer Yok',
      'en': 'No Saved Places Yet',
      'ar': 'لا توجد أماكن محفوظة بعد',
    },
    'favorites_no_saved_desc': {
      'tr': 'Beğendiğin yerleri kaydet, her zaman bulabilirsin.',
      'en': 'Save places you like, you can always find them here.',
      'ar': 'احفظ الأماكن التي تعجبك لتجدها دائماً هنا.',
    },
    'profile_title': {
      'tr': 'Profil',
      'en': 'Profile',
      'ar': 'الملف الشخصي',
    },
    'profile_nature_explorer': {
      'tr': 'Doğa Kaşifi',
      'en': 'Nature Explorer',
      'ar': 'مستكشف الطبيعة',
    },
    'profile_contributions': {
      'tr': 'katkı',
      'en': 'contributions',
      'ar': 'مساهمات',
    },
    'profile_my_contributions': {
      'tr': 'Katkılarım',
      'en': 'My Contributions',
      'ar': 'مساهماتي',
    },
    'profile_no_contributions': {
      'tr': 'Henüz yer eklemediniz',
      'en': 'No places added yet',
      'ar': 'لم تضف أي مكان بعد',
    },
    'profile_share_places': {
      'tr': 'Doğada keşfettiğin yerleri toplulukla paylaş.',
      'en': 'Share places you discovered in nature with the community.',
      'ar': 'شارك الأماكن التي اكتشفتها في الطبيعة مع المجتمع.',
    },
    'profile_add_first_place': {
      'tr': 'İlk Yerini Ekle',
      'en': 'Add Your First Place',
      'ar': 'أضف أول مكان لك',
    },
    'profile_community_chat': {
      'tr': 'Topluluk Sohbeti',
      'en': 'Community Chat',
      'ar': 'دردشة المجتمع',
    },
    'profile_language': {
      'tr': 'Dil',
      'en': 'Language',
      'ar': 'اللغة',
    },
    'profile_language_subtitle': {
      'tr': 'Uygulama dilini seç',
      'en': 'Select app language',
      'ar': 'اختر لغة التطبيق',
    },
    'profile_theme': {
      'tr': 'Karanlık Mod',
      'en': 'Dark Mode',
      'ar': 'الوضع الداكن',
    },
    'profile_logout': {
      'tr': 'Çıkış Yap',
      'en': 'Log Out',
      'ar': 'تسجيل الخروج',
    },
    'profile_delete_account': {
      'tr': 'Hesabı Sil',
      'en': 'Delete Account',
      'ar': 'حذف الحساب',
    },
    'profile_privacy_policy': {
      'tr': 'Gizlilik Politikası',
      'en': 'Privacy Policy',
      'ar': 'سياسة الخصوصية',
    },
    'profile_terms': {
      'tr': 'Kullanım Koşulları',
      'en': 'Terms of Service',
      'ar': 'شروط الخدمة',
    },
    'profile_feedback': {
      'tr': 'Geri Bildirim ve Destek',
      'en': 'Feedback & Support',
      'ar': 'الملاحظات والدعم',
    },
    'profile_default_user_name': {
      'tr': 'Doğadayım Kullanıcısı',
      'en': 'Doğadayım User',
      'ar': 'مستخدم دوغاداييم',
    },
    'profile_guest_user': {
      'tr': 'Misafir Kaşif',
      'en': 'Guest Explorer',
      'ar': 'مستكشف زائر',
    },
    'profile_guest_subtitle': {
      'tr': 'Doğayı keşfetmek için misafir modundasın',
      'en': 'You are exploring nature in guest mode',
      'ar': 'أنت في وضع الضيف لاستكشاف الطبيعة',
    },
    'guest_auth_title': {
      'tr': 'Giriş Yapmalısın',
      'en': 'Sign In Required',
      'ar': 'تسجيل الدخول مطلوب',
    },
    'guest_auth_message': {
      'tr':
          'Bu özelliği kullanabilmek ve topluluğa katkı sağlamak için lütfen giriş yap veya hesap oluştur.',
      'en':
          'Please sign in or create an account to use this feature and contribute to the community.',
      'ar':
          'يرجى تسجيل الدخول أو إنشاء حساب لاستخدام هذه الميزة والمساهمة في المجتمع.',
    },
    'guest_auth_btn_login': {
      'tr': 'Giriş Yap / Kayıt Ol',
      'en': 'Sign In / Register',
      'ar': 'تسجيل الدخول / إنشاء حساب',
    },
    'guest_auth_btn_continue': {
      'tr': 'Keşfetmeye Devam Et',
      'en': 'Continue Exploring',
      'ar': 'متابعة الاستكشاف',
    },
    'guest_add_place_prompt': {
      'tr':
          'Doğa noktası eklemek ve topluluğa katkı sağlamak için lütfen giriş yapın.',
      'en':
          'Please sign in to add nature spots and contribute to the community.',
      'ar': 'يرجى تسجيل الدخول لإضافة مواقع طبيعية والمساهمة في المجتمع.',
    },
    'guest_review_prompt': {
      'tr': 'Değerlendirme ve yorum yazabilmek için lütfen giriş yapın.',
      'en': 'Please sign in to rate and write reviews.',
      'ar': 'يرجى تسجيل الدخول للتقييم وكتابة الآراء.',
    },
    'guest_goodness_prompt': {
      'tr': 'İyilik Harekâtı\'na katkı ekleyebilmek için lütfen giriş yapın.',
      'en': 'Please sign in to add contributions to the Goodness Movement.',
      'ar': 'يرجى تسجيل الدخول لإضافة مساهمات إلى حركة الخير.',
    },
    'guest_chat_prompt': {
      'tr': 'Sohbete katılıp mesaj yazabilmek için lütfen giriş yapın.',
      'en': 'Please sign in to join the chat and send messages.',
      'ar': 'يرجى تسجيل الدخول للمشاركة في الدردشة وإرسال الرسائل.',
    },
    'guest_emergency_request_prompt': {
      'tr': 'Acil yardım çağrısı açabilmek için lütfen giriş yapın.',
      'en': 'Please sign in to create an emergency help request.',
      'ar': 'يرجى تسجيل الدخول لإنشاء طلب مساعدة طارئة.',
    },
    'guest_emergency_accept_prompt': {
      'tr':
          'Yardım çağrısını kabul edip iletişim bilgilerine erişmek için lütfen giriş yapın.',
      'en':
          'Please sign in to accept the help request and access contact info.',
      'ar': 'يرجى تسجيل الدخول لقبول طلب المساعدة والوصول إلى معلومات الاتصال.',
    },

    // ── Topluluk Sohbeti ──────────────────────────────────────────────────
    'community_chats_title': {
      'tr': 'Topluluk Sohbetleri',
      'en': 'Community Chats',
      'ar': 'محادثات المجتمع',
    },
    'community_chats_subtitle': {
      'tr': 'Doğayı bilenlere sor',
      'en': 'Ask Those Who Know Nature',
      'ar': 'اسأل خبراء الطبيعة',
    },
    'community_chats_desc': {
      'tr':
          'Merak ettiğin konuya ait odayı seç; bölgeyi bilen doğaseverlerle konuş.',
      'en':
          'Choose a room for your topic; chat with nature lovers who know the area.',
      'ar': 'اختر غرفة لموضوعك؛ وتحدث مع عشاق الطبيعة الذين يعرفون المنطقة.',
    },
    'community_chat_tile_subtitle': {
      'tr': 'Soru sor, deneyimini paylaş',
      'en': 'Ask questions, share experiences',
      'ar': 'اطرح الأسئلة وشارك تجاربك',
    },
    'community_chat_preview_banner': {
      'tr':
          'Tasarım önizlemesi · Mesajlar henüz diğer kullanıcılara gönderilmez.',
      'en': 'Design preview · Messages are not sent to other users yet.',
      'ar': 'معاينة التصميم · لا يتم إرسال الرسائل للمستخدمين الآخرين بعد.',
    },
    'community_chat_no_messages': {
      'tr': 'Henüz mesaj yok',
      'en': 'No messages yet',
      'ar': 'لا توجد رسائل بعد',
    },
    'community_chat_first_message_prompt': {
      'tr': 'hakkında ilk soruyu sen yaz.',
      'en': 'Be the first to ask about',
      'ar': 'كن أول من يسأل عن',
    },
    'community_chat_input_hint': {
      'tr': 'Topluluğa sor...',
      'en': 'Ask the community...',
      'ar': 'اسأل المجتمع...',
    },

    // ── Alan Ekle ─────────────────────────────────────────────────────────
    'add_place_title': {
      'tr': 'Alan Ekle',
      'en': 'Add Place',
      'ar': 'إضافة مكان',
    },
    'add_place_banner': {
      'tr':
          'Bildiğin bir doğa noktasını ekleyerek haritanın toplulukla büyümesine yardımcı olabilirsin.',
      'en':
          'Help the map grow with the community by adding a nature spot you know.',
      'ar': 'ساعد الخريطة على النمو مع المجتمع بإضافة مكان طبيعي تعرفه.',
    },
    'add_place_name_label': {
      'tr': 'Alan ismi *',
      'en': 'Place name *',
      'ar': 'اسم المكان *',
    },
    'add_place_name_hint': {
      'tr': 'Örn. Kapuzbaşı Şelaleleri',
      'en': 'e.g. Kapuzbaşı Waterfalls',
      'ar': 'مثال: شلالات كابوزباشي',
    },
    'add_place_desc_label': {
      'tr': 'Açıklama *',
      'en': 'Description *',
      'ar': 'الوصف *',
    },
    'add_place_desc_hint': {
      'tr': 'Alanı, ulaşımı ve bilinmesi gerekenleri kısaca anlat.',
      'en': 'Briefly describe the area, access, and things to know.',
      'ar': 'صف المكان والوصول والمعلومات الهامة باختصار.',
    },
    'add_place_location_title': {
      'tr': 'Konum Seç *',
      'en': 'Select Location *',
      'ar': 'اختر الموقع *',
    },
    'add_place_location_hint': {
      'tr': 'Haritada noktayı işaretle',
      'en': 'Mark the point on the map',
      'ar': 'حدد النقطة على الخريطة',
    },
    'add_place_photo_title': {
      'tr': 'Fotoğraf Ekle',
      'en': 'Add Photo',
      'ar': 'إضافة صور',
    },
    'add_place_photo_hint_max': {
      'tr': 'En fazla 6 fotoğraf',
      'en': 'Up to 6 photos',
      'ar': 'حتى 6 صور',
    },
    'add_place_photos_selected': {
      'tr': 'fotoğraf seçildi',
      'en': 'photos selected',
      'ar': 'صور محددة',
    },
    'add_place_category_title': {
      'tr': 'Kategori Seç *',
      'en': 'Select Category *',
      'ar': 'اختر الفئة *',
    },
    'add_place_environment_title': {
      'tr': 'Çevre Yapısı',
      'en': 'Environment',
      'ar': 'البيئة المحيطة',
    },
    'add_place_transport_title': {
      'tr': 'Ulaşım',
      'en': 'Access & Transport',
      'ar': 'المواصلات والوصول',
    },
    'add_place_facilities_title': {
      'tr': 'Olanaklar ve Uyarılar',
      'en': 'Facilities & Notices',
      'ar': 'المرافق والتنبيهات',
    },
    'add_place_submit': {
      'tr': 'Gönder',
      'en': 'Submit',
      'ar': 'إرسال',
    },
    'add_place_saving': {
      'tr': 'Kaydediliyor...',
      'en': 'Saving...',
      'ar': 'جارٍ الحفظ...',
    },
    'add_place_use_current_location': {
      'tr': 'Mevcut konumumu kullan',
      'en': 'Use my current location',
      'ar': 'استخدم موقعي الحالي',
    },
    'add_place_search_location_hint': {
      'tr': 'İl, ilçe veya yer ara',
      'en': 'Search city, district or place',
      'ar': 'ابحث عن مدينة، منطقة أو مكان',
    },
    'add_place_duplicate_title': {
      'tr': 'Bu konumda benzer bir yer zaten var',
      'en': 'A similar place already exists at this location',
      'ar': 'يوجد مكان مشابه بالفعل في هذا الموقع',
    },
    'add_place_btn_back': {
      'tr': 'Geri dön',
      'en': 'Go Back',
      'ar': 'الرجوع',
    },
    'add_place_btn_contribute': {
      'tr': 'Bilgi/fotoğraf ekle',
      'en': 'Add Info/Photos',
      'ar': 'إضافة معلومات/صور',
    },
    'add_place_btn_view_existing': {
      'tr': 'Mevcut yeri görüntüle',
      'en': 'View Existing Place',
      'ar': 'عرض المكان الحالي',
    },
    'add_place_btn_create_anyway': {
      'tr': 'Yine de oluştur',
      'en': 'Create Anyway',
      'ar': 'إنشاء على أي حال',
    },
    'add_place_validation_category': {
      'tr': 'Bir ana kategori seç.',
      'en': 'Select a main category.',
      'ar': 'اختر فئة رئيسية.',
    },
    'add_place_validation_location': {
      'tr': 'Haritadan geçerli bir konum seç.',
      'en': 'Select a valid location from the map.',
      'ar': 'اختر موقعاً صالحاً من الخريطة.',
    },
    'add_place_submitted_waiting': {
      'tr':
          'Yer gönderildi ve yönetici onayı bekliyor. Şimdilik yalnızca sen görebilirsin.',
      'en':
          'Place submitted and awaiting approval. Only visible to you for now.',
      'ar': 'تم إرسال المكان وهو بانتظار الموافقة. يظهر لك فقط حالياً.',
    },
    'add_place_saved_offline_login': {
      'tr':
          'Yer cihazına kaydedildi. Giriş yaptığında onay için otomatik gönderilecek.',
      'en': 'Saved to device. Will be submitted for approval once you sign in.',
      'ar': 'تم الحفظ على الجهاز. سيتم الإرسال للموافقة عند تسجيل الدخول.',
    },
    'add_place_saved_offline_net': {
      'tr':
          'Yer cihazına kaydedildi. İnternet geldiğinde onay için otomatik gönderilecek.',
      'en': 'Saved to device. Will be submitted for approval when connected.',
      'ar': 'تم الحفظ على الجهاز. سيتم الإرسال للموافقة عند الاتصال بالإنترنت.',
    },

    // ── Konum İzni Dialog ─────────────────────────────────────────────────
    'location_dialog_title': {
      'tr': 'Konum İzni Gerekli',
      'en': 'Location Permission Required',
      'ar': 'إذن الموقع مطلوب',
    },
    'location_dialog_desc': {
      'tr':
          'Bulunduğun bölgenin güncel hava durumunu ve yakındaki doğa noktalarını gösterebilmemiz için konum iznine ihtiyacımız var.',
      'en':
          'We need location permission to show local weather and nearby nature spots.',
      'ar':
          'نحتاج إلى إذن الموقع لعرض حالة الطقس الحالية والأماكن الطبيعية القريبة منك.',
    },
    'location_dialog_not_now': {
      'tr': 'Şimdi Değil',
      'en': 'Not Now',
      'ar': 'ليس الآن',
    },
    'location_dialog_allow': {
      'tr': 'İzin Ver',
      'en': 'Allow',
      'ar': 'سماح',
    },
    'location_dialog_later': {
      'tr': 'Daha Sonra',
      'en': 'Later',
      'ar': 'لاحقاً',
    },

    // ── Genel ─────────────────────────────────────────────────────────────
    'general_cancel': {
      'tr': 'İptal',
      'en': 'Cancel',
      'ar': 'إلغاء',
    },
    'general_confirm': {
      'tr': 'Onayla',
      'en': 'Confirm',
      'ar': 'تأكيد',
    },
    'general_save': {
      'tr': 'Kaydet',
      'en': 'Save',
      'ar': 'حفظ',
    },
    'general_close': {
      'tr': 'Kapat',
      'en': 'Close',
      'ar': 'إغلاق',
    },
    'general_loading': {
      'tr': 'Yükleniyor…',
      'en': 'Loading…',
      'ar': 'جارٍ التحميل…',
    },
    'general_error': {
      'tr': 'Bir hata oluştu',
      'en': 'An error occurred',
      'ar': 'حدث خطأ',
    },
    'general_no_connection': {
      'tr': 'İnternet bağlantısı yok',
      'en': 'No internet connection',
      'ar': 'لا يوجد اتصال بالإنترنت',
    },
    'general_retry': {
      'tr': 'Tekrar Dene',
      'en': 'Retry',
      'ar': 'أعد المحاولة',
    },
  };
}
