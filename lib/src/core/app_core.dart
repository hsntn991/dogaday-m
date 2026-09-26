part of '../../main.dart';

abstract final class AppColors {
  // ── Light palette ──────────────────────────────────────────────────────────
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF7F8F6);
  static const border = Color(0xFFE1E5E1);
  static const primary = Color(0xFF0F5A35);
  static const primaryPressed = Color(0xFF0B482A);
  static const primarySoft = Color(0xFFEAF3ED);
  static const textPrimary = Color(0xFF151515);
  static const textSecondary = Color(0xFF68706A);
  static const textTertiary = Color(0xFF8A928C);
  static const onPrimary = Color(0xFFFFFFFF);
  static const error = Color(0xFFB42318);
  static const errorSoft = Color(0xFFFFF1EF);
  static const errorBorder = Color(0xFFE59A91);
  static const disabled = Color(0xFFC5CBC6);

  /// Seçili harita marker / turuncu vurgu rengi (açık mod)
  static const accentOrange = Color(0xFFB65B23);

  /// Yıldız ve değerlendirme kehribar sarısı
  static const rating = Color(0xFFFFA000);

  /// Bekleyen onay / uyarı tonları
  static const warningSoft = Color(0xFFFFF1D6);
  static const warningBorder = Color(0xFFE7B45D);
  static const warningText = Color(0xFF8B5D13);

  /// İyilik Harekâtı'nın il haritası her iki temada da aynı, okunabilir
  /// illüstrasyon görünümünü korur.
  static const goodnessMapBackground = Color(0xFFF7F2E9);
  static const goodnessMapBorder = Color(0xFFCEBDA7);

  // ── Dark palette ───────────────────────────────────────────────────────────
  static const darkBackground = Color(0xFF0D120F);
  static const darkSurface = Color(0xFF151C18);
  static const darkSurfaceMuted = Color(0xFF1D2621);
  static const darkBorder = Color(0xFF303A34);
  static const darkPrimary = Color(0xFF2E8A57);
  static const darkPrimarySoft = Color(0xFF1A3324);
  static const darkTextPrimary = Color(0xFFF1F5F2);
  static const darkTextSecondary = Color(0xFFAAB4AD);
  static const darkTextTertiary = Color(0xFF7E8A82);

  /// Açık yeşil vurgu — koyu mod ikonlar ve aktif chip'ler
  static const darkPrimaryLight = Color(0xFF8FD8A8);

  /// Seçili harita marker / turuncu vurgu rengi (koyu mod)
  static const darkAccentOrange = Color(0xFFE89A6C);

  /// Koyu mod acil durum / hata yumuşak zemin rengi
  static const darkErrorSoft = Color(0xFF3A211D);

  // ── Harita Kategori Renkleri (marker dairesi dolgu) ────────────────────────
  /// Su kategorisi marker rengi
  static const categoryWater = Color(0xFF1E7EC8);

  /// Dağ & Arazi marker rengi
  static const categoryMountain = Color(0xFF617A4A);

  /// Doğal Oluşum marker rengi
  static const categoryFormation = Color(0xFF8B6547);

  /// Doğa Alanı marker rengi
  static const categoryNature = Color(0xFF2E7D52);

  /// Kamp & Karavan marker rengi
  static const categoryCamp = Color(0xFFBF5B20);

  /// Rota & Aktivite marker rengi
  static const categoryRoute = Color(0xFFB07D1A);

  /// Keşif Noktası marker rengi
  static const categoryDiscovery = Color(0xFF7B5EA7);

  /// Yaban Hayatı marker rengi
  static const categoryWildlife = Color(0xFF3E8A70);

  /// Tesis/WC/Su yardımcı marker rengi
  static const categoryUtility = Color(0xFF607D8B);

  /// Harita küme marker rengi
  static const clusterMarker = Color(0xFF1E7044);

  /// Harita küme marker gölgesi
  static const clusterMarkerShadow = Color(0x401E7044);

  // ── Kategori Yumuşak Zemin Renkleri (chip ve kart arka planları) ───────────
  static const categoryWaterSoft = Color(0xFFE8F4FA);
  static const categoryMountainSoft = Color(0xFFF0F4EB);
  static const categoryFormationSoft = Color(0xFFF3EEE8);
  static const categoryNatureSoft = Color(0xFFEAF3EC);
  static const categoryCampSoft = Color(0xFFFBF0EA);
  static const categoryRouteSoft = Color(0xFFFBF5EA);
  static const categoryDiscoverySoft = Color(0xFFF2EEF9);
  static const categoryWildlifeSoft = Color(0xFFEDF4E8);

  // ── Gölge sabitleri ────────────────────────────────────────────────────────
  /// Hafif kart gölgesi
  static const shadow08 = Color(0x14000000);

  /// İnce etiket gölgesi
  static const shadow20 = Color(0x33000000);

  /// Normal kart gölgesi
  static const shadow26 = Color(0x44000000);

  /// Belirgin gölge
  static const shadow33 = Color(0x55000000);

  /// Yarı saydam buton zemin gölgesi (%40)
  static const shadow40 = Color(0x66000000);

  /// Koyu overlay/modal
  static const shadow80 = Color(0xCC000000);

  // ── Overlay / cam renkleri ─────────────────────────────────────────────────
  /// Koyu mod cam panel (GlassContainer darkColor)
  static const darkGlass = Color(0xF0151C18);

  /// Koyu mod cam panel yeşil tonu (GlassContainer varsayılan darkColor)
  static const darkGlassTint = Color(0x331E2D23);

  /// Koyu mod derin panel arka plan
  static const darkSurfaceDeep = Color(0xFF0F1512);

  // ── Hava durumu kartı degrade & gölge ─────────────────────────────────────
  static const weatherGradientStart = Color(0xFF174A0D);
  static const weatherGradientEnd = Color(0xFF4AA62B);
  static const weatherCardShadow = Color(0x382B751A);

  // ── Kart degrade paletleri ────────────────────────────────────────────────
  static const defaultGradientStart = Color(0xFF315F45);
  static const defaultGradientEnd = Color(0xFF9BBF82);
  static const defaultGradient = [defaultGradientStart, defaultGradientEnd];
  static const waterfallGradient = [Color(0xFF287890), Color(0xFF8DD1C9)];
  static const lakeGradient = [Color(0xFF2B86A6), Color(0xFFB8E7E8)];
  static const campGradient = [Color(0xFF715642), Color(0xFFC9A678)];
  static const caveGradient = [Color(0xFF4D4540), Color(0xFF9B8E82)];

  // ── Marka ve Onboarding token'ları ─────────────────────────────────────────
  /// Google marka mavisi
  static const brandGoogle = Color(0xFF4285F4);

  /// Onboarding slayt gradyan overlay tonları
  static const onboardingGreen = Color(0x55304A2B);
  static const onboardingWater = Color(0x554E260E);
  static const onboardingCamp = Color(0x55462A17);

  // ── Theme-aware helpers ────────────────────────────────────────────────────
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surfaceOf(BuildContext context) =>
      isDark(context) ? darkSurface : surface;

  static Color surfaceMutedOf(BuildContext context) =>
      isDark(context) ? darkSurfaceMuted : surfaceMuted;

  static Color borderOf(BuildContext context) =>
      isDark(context) ? darkBorder : border;

  static Color textPrimaryOf(BuildContext context) =>
      isDark(context) ? darkTextPrimary : textPrimary;

  static Color textSecondaryOf(BuildContext context) =>
      isDark(context) ? darkTextSecondary : textSecondary;

  static Color textTertiaryOf(BuildContext context) =>
      isDark(context) ? darkTextTertiary : textTertiary;

  static Color backgroundOf(BuildContext context) =>
      isDark(context) ? darkBackground : background;

  static Color accentOrangeOf(BuildContext context) =>
      isDark(context) ? darkAccentOrange : accentOrange;

  static Color primaryLightOf(BuildContext context) =>
      isDark(context) ? darkPrimaryLight : primarySoft;

  static Color errorSoftOf(BuildContext context) =>
      isDark(context) ? darkErrorSoft : errorSoft;
}

abstract final class AppRadii {
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double hero = 20;
  static const double pill = 999;
}

abstract final class AppSpacing {
  static const double xxSmall = 4;
  static const double xSmall = 4;
  static const double small = 8;
  static const double compact = 12;
  static const double medium = 16;
  static const double large = 20;
  static const double xLarge = 24;
  static const double section = 32;
}

abstract final class AppBorders {
  static const thin = BorderSide(color: AppColors.border);
  static const focused = BorderSide(color: AppColors.primary, width: 1.4);
  static const error = BorderSide(color: AppColors.error);

  static BorderSide thinOf(BuildContext context) =>
      BorderSide(color: AppColors.borderOf(context));
}

abstract final class AppShadows {
  static const soft = <BoxShadow>[
    BoxShadow(color: AppColors.shadow08, blurRadius: 14, offset: Offset(0, 4)),
  ];
  static const darkSoft = <BoxShadow>[
    BoxShadow(color: AppColors.shadow20, blurRadius: 14, offset: Offset(0, 4)),
  ];

  static List<BoxShadow> softOf(BuildContext context) =>
      AppColors.isDark(context) ? darkSoft : soft;
}

abstract final class AppIconSizes {
  static const double small = 18;
  static const double medium = 22;
  static const double large = 28;
}

abstract final class AppControlSizes {
  static const double button = 52;
  static const double minimumTouchTarget = 48;
}

abstract final class AppFontSizes {
  /// 24px: Büyük ekran/hero başlıkları
  static const double display = 24.0;

  /// 20px: Sayfa ve ana bölüm başlıkları
  static const double heading = 20.0;

  /// 16px: Kart başlıkları, modal başlıkları
  static const double title = 16.0;

  /// 14px: Ana gövde metinleri, form inputları
  static const double body = 14.0;

  /// 13px: Butonlar, çipler, sekmeler, vurgulu etiketler
  static const double label = 13.0;

  /// 11.5px: Metadata, sayaçlar, rozetler, ikincil bilgi (erişilebilir alt sınır)
  static const double caption = 11.5;
}

abstract final class AppTypography {
  static const brand = TextStyle(
    fontFamily: 'Fraunces',
    fontSize: AppFontSizes.display,
    color: AppColors.primary,
    fontWeight: FontWeight.w600,
    letterSpacing: -.7,
  );

  /// 1. Seviye — Display (24px)
  static const display = TextStyle(
    fontFamily: 'Outfit',
    fontSize: AppFontSizes.display,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
    letterSpacing: -.4,
  );

  /// 2. Seviye — Heading (20px)
  static const heading = TextStyle(
    fontFamily: 'Outfit',
    fontSize: AppFontSizes.heading,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
    letterSpacing: -.25,
  );

  /// 3. Seviye — Title (16px)
  static const title = TextStyle(
    fontFamily: 'Outfit',
    fontSize: AppFontSizes.title,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w600,
    letterSpacing: -.15,
  );

  /// 4. Seviye — Body (14px)
  static const body = TextStyle(
    fontFamily: 'Outfit',
    fontSize: AppFontSizes.body,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// 5. Seviye — Label (13px)
  static const label = TextStyle(
    fontFamily: 'Outfit',
    fontSize: AppFontSizes.label,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w600,
    letterSpacing: .05,
  );

  /// 6. Seviye — Caption (11.5px) (7.5-9px yerine standart erişilebilir alt sınır)
  static const caption = TextStyle(
    fontFamily: 'Outfit',
    fontSize: AppFontSizes.caption,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w400,
  );

  /// Geriye uyumluluk için metadata (caption ile eşdeğer)
  static const metadata = caption;

  static TextStyle displayOf(BuildContext context) =>
      display.copyWith(color: AppColors.textPrimaryOf(context));
  static TextStyle headingOf(BuildContext context) =>
      heading.copyWith(color: AppColors.textPrimaryOf(context));
  static TextStyle titleOf(BuildContext context) =>
      title.copyWith(color: AppColors.textPrimaryOf(context));
  static TextStyle bodyOf(BuildContext context) =>
      body.copyWith(color: AppColors.textPrimaryOf(context));
  static TextStyle labelOf(BuildContext context) =>
      label.copyWith(color: AppColors.textPrimaryOf(context));
  static TextStyle captionOf(BuildContext context) =>
      caption.copyWith(color: AppColors.textSecondaryOf(context));
  static TextStyle metadataOf(BuildContext context) => captionOf(context);
}

class AppThemeController {
  AppThemeController._();

  static const _storageKey = 'app_user_dark_mode_preference';
  static final mode = ValueNotifier<ThemeMode>(ThemeMode.light);

  static bool get isDark => mode.value == ThemeMode.dark;

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    // İlk defa indiren kullanıcı uygulamayı dark modda değil normal (açık) modda görür.
    // Kullanıcı profil ayarlarından kendisi açıkça değiştirdiğinde bu tercih korunur.
    final userChoice = preferences.getBool(_storageKey);
    mode.value = userChoice == true ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> setDark(bool enabled) async {
    mode.value = enabled ? ThemeMode.dark : ThemeMode.light;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_storageKey, enabled);
  }

  static Future<void> reset() async {
    mode.value = ThemeMode.light;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }
}

abstract final class AppLegalLinks {
  /// Google Play ve uygulama içi kullanım için Gizlilik Politikası URL'i.
  /// Derleme anında --dart-define=PRIVACY_POLICY_URL=https://... ile ezilebilir.
  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: 'https://dogadayim.github.io/dogadayim-privacy/',
  );

  /// Kullanım Koşulları URL'i.
  /// Derleme anında --dart-define=TERMS_OF_SERVICE_URL=https://... ile ezilebilir.
  static const String termsOfServiceUrl = String.fromEnvironment(
    'TERMS_OF_SERVICE_URL',
    defaultValue: 'https://dogadayim.github.io/dogadayim-privacy/terms.html',
  );

  /// Kullanıcı destek ve geri bildirim e-posta adresi.
  static const String supportEmail = 'dogadayim.destek@gmail.com';

  static Future<void> openPrivacyPolicy(BuildContext context) async {
    if (!context.mounted) return;
    await Navigator.of(context).push<void>(MaterialPageRoute(
      builder: (_) => const PrivacyPolicyScreen(),
    ));
  }

  static Future<void> openTermsOfService(BuildContext context) async {
    final uri = Uri.tryParse(termsOfServiceUrl);
    if (uri != null && isSafeExternalUrl(uri)) {
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    }
    if (context.mounted) {
      await Navigator.of(context).push<void>(MaterialPageRoute(
        builder: (_) => const PrivacyPolicyScreen(),
      ));
    }
  }

  /// Kullanıcı geri bildirim ve hata bildirimi kanalı.
  static Future<void> openFeedback(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: <String, String>{
        'subject': 'Doğadayım Geri Bildirim ve Destek',
      },
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
    } catch (_) {}
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geri bildirim ve destek için: $supportEmail'),
        ),
      );
    }
  }
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

String canonicalPlaceCategory(String value) {
  final taxonomy = taxonomyFromLegacy(value);
  return taxonomyDisplayLabel(
    fallback: value.trim().isEmpty ? 'Doğa Noktası' : value.trim(),
    mainCategory: taxonomy.mainCategory,
    subtype: taxonomy.subtype,
  );
}

bool isPlaceAmenity(Place place) => place.isUtility;

class Place {
  const Place(
    this.name,
    this.location,
    String kind,
    this.rating,
    this.icon,
    this.colors,
    this.image, {
    this.description = '',
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.sourceId,
    this.updatedAt,
    this.source = PlaceSource.curated,
    this.verificationStatus = VerificationStatus.unverified,
    this.features = const <String>[],
    this.mainCategory,
    this.subtype,
    this.facilities = const PlaceFacilities(),
    this.googlePhotoSearchUrl,
  }) : _legacyKind = kind;
  final String name, location, description;
  final String _legacyKind;

  String get kind => taxonomyDisplayLabel(
        fallback: _legacyKind,
        mainCategory: mainCategory,
        subtype: subtype,
      );
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
  final List<String> features;
  final String? mainCategory;
  final String? subtype;
  final PlaceFacilities facilities;
  final String? googlePhotoSearchUrl;

  ({String? mainCategory, String? subtype}) get resolvedTaxonomy {
    final legacy = taxonomyFromLegacy(_legacyKind);
    final resolvedSubtype = subtype ?? legacy.subtype;
    return (
      mainCategory: isUtilitySubtype(resolvedSubtype)
          ? null
          : mainCategory ?? legacy.mainCategory,
      subtype: resolvedSubtype,
    );
  }

  String get displayKind => taxonomyDisplayLabel(
        fallback: kind,
        mainCategory: resolvedTaxonomy.mainCategory,
        subtype: resolvedTaxonomy.subtype,
      );

  bool get isUtility => isUtilitySubtype(resolvedTaxonomy.subtype);

  bool get hasCoordinates => latitude != null && longitude != null;

  WeatherTarget get weatherTarget => hasCoordinates
      ? WeatherTarget.coordinates(
          latitude: latitude!,
          longitude: longitude!,
          label: name,
        )
      : WeatherTarget.city(location);

  String? get roadAccess {
    for (final f in features) {
      if (f.startsWith('Ulaşım: ')) return f.substring(8).trim();
    }
    return null;
  }
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
    if (ContentSafetyService.isBlocked(input)) {
      return 'Siyasi, hakaret içeren veya uygunsuz bir ad kullanılamaz.';
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
    if (ContentSafetyService.isBlocked(input)) {
      return 'Siyasi, hakaret içeren veya uygunsuz bir açıklama kullanılamaz.';
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
    final taxonomy = taxonomyFromLegacy(value);
    if (taxonomy.subtype != null) return taxonomy.subtype!;
    if (taxonomy.mainCategory != null) return taxonomy.mainCategory!;
    final normalized = normalizeName(value);
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

abstract final class ContentSafetyService {
  static const _blockedTerms = <String>{
    'amk',
    'amina',
    'aptal',
    'gerizekali',
    'gavat',
    'ibne',
    'kahpe',
    'orospu',
    'pezevenk',
    'pic',
    'salak',
    'serefsiz',
    'sikik',
    'siktir',
    'yarrak',
  };

  static const _politicalPhrases = <String>{
    'cumhurbaskani',
    'basbakan',
    'milletvekili',
    'siyasiparti',
    'partilideri',
    'genelbaskan',
    'iktidarpartisi',
    'muhalefetpartisi',
  };

  static bool isBlocked(String input) {
    final normalized = AddPlaceQualityService.normalizeName(input)
        .replaceAll('0', 'o')
        .replaceAll('1', 'i')
        .replaceAll('3', 'e')
        .replaceAll('4', 'a')
        .replaceAll('5', 's');
    final words = normalized.split(' ').where((word) => word.isNotEmpty);
    if (words.any(_blockedTerms.contains)) return true;
    final compact = normalized.replaceAll(' ', '');
    return _blockedTerms.any(compact.contains) ||
        _politicalPhrases.any(compact.contains);
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
            canonicalPlaceCategory(
              data['kind']?.toString() ?? 'Doğa Noktası',
            ),
            0,
            Icons.place_rounded,
            AppColors.defaultGradient,
            data['image']?.toString(),
            description: data['description']?.toString() ?? '',
            latitude: (data['latitude'] as num?)?.toDouble(),
            longitude: (data['longitude'] as num?)?.toDouble(),
            sourceId: data['sourceId']?.toString(),
            updatedAt: DateTime.tryParse(data['updatedAt']?.toString() ?? ''),
            source: _sourceFromStorage(data['source']),
            verificationStatus:
                _verificationFromStorage(data['verificationStatus']),
            mainCategory: data['mainCategory']?.toString(),
            subtype: data['subtype']?.toString(),
            facilities: PlaceFacilities.fromJson(data['facilities']),
            features: (data['features'] as List?)
                    ?.map((item) => item.toString())
                    .toList(growable: false) ??
                const <String>[],
          );
        })
        .where((place) => place.hasCoordinates)
        .toList(growable: false);
  }

  static Future<void> add(Place place) async {
    places.value = <Place>[place, ...places.value];
    await _persist();
  }

  static Future<void> removeWhere(bool Function(Place place) test) async {
    final updated = places.value.where((place) => !test(place)).toList();
    if (updated.length == places.value.length) return;
    places.value = updated;
    await _persist();
  }

  static Future<void> clear() async {
    places.value = const <Place>[];
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }

  static Future<void> _persist() async {
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
                'features': item.features,
                'mainCategory': item.resolvedTaxonomy.mainCategory,
                'subtype': item.resolvedTaxonomy.subtype,
                'facilities': item.facilities.toJson(),
              }))
          .toList(growable: false),
    );
  }
}

enum SubmissionSyncResult { sent, queued, signInRequired }

class PlaceSubmissionController {
  PlaceSubmissionController._();

  static const _queueKey = 'pending_place_submission_ids_v1';
  static Future<void>? _syncInFlight;

  static bool get _hasAuthenticatedUser {
    try {
      return Supabase.instance.client.auth.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  static Future<SubmissionSyncResult> enqueueAndSync(Place place) async {
    final sourceId = place.sourceId;
    if (sourceId == null || sourceId.isEmpty) {
      return SubmissionSyncResult.queued;
    }
    final preferences = await SharedPreferences.getInstance();
    final queued = preferences.getStringList(_queueKey)?.toSet() ?? <String>{};
    queued.add(sourceId);
    await preferences.setStringList(_queueKey, queued.toList(growable: false));

    if (!_hasAuthenticatedUser) {
      return SubmissionSyncResult.signInRequired;
    }
    try {
      await _submit(place);
      await _removeFromQueue(sourceId);
      return SubmissionSyncResult.sent;
    } catch (_) {
      return SubmissionSyncResult.queued;
    }
  }

  static Future<void> syncPending() =>
      _syncInFlight ??= _syncPendingInternal().whenComplete(() {
        _syncInFlight = null;
      });

  static Future<void> _syncPendingInternal() async {
    if (!_hasAuthenticatedUser) return;
    final preferences = await SharedPreferences.getInstance();
    final queued = preferences.getStringList(_queueKey) ?? const <String>[];
    for (final sourceId in queued) {
      Place? place;
      for (final candidate in UserPlacesController.places.value) {
        if (candidate.sourceId == sourceId) {
          place = candidate;
          break;
        }
      }
      if (place == null) {
        await _removeFromQueue(sourceId);
        continue;
      }
      try {
        await _submit(place);
        await _removeFromQueue(sourceId);
      } catch (_) {
        // Ağ veya sunucu geçici olarak hazır değilse sonraki açılışta denenir.
      }
    }
    try {
      await _reconcileSubmittedPlaces();
    } catch (_) {
      // Ağ yoksa veya oturum sorgulanamıyorsa local kayıtlar korunur.
    }
  }

  static Future<void> _reconcileSubmittedPlaces() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    final preferences = await SharedPreferences.getInstance();
    final queued = preferences.getStringList(_queueKey)?.toSet() ?? <String>{};
    final rows = await client
        .from('place_submissions')
        .select('client_reference, status')
        .eq('submitted_by', user.id);
    final statuses = <String, String>{
      for (final row in rows)
        if ((row['client_reference']?.toString().trim() ?? '').isNotEmpty)
          row['client_reference'].toString(): row['status']?.toString() ?? '',
    };

    await UserPlacesController.removeWhere((place) {
      final sourceId = place.sourceId;
      if (place.source != PlaceSource.user ||
          sourceId == null ||
          !sourceId.startsWith('user-') ||
          queued.contains(sourceId)) {
        return false;
      }
      final status = statuses[sourceId];
      return status == null || status == 'approved' || status == 'rejected';
    });
  }

  static Future<void> _removeFromQueue(String sourceId) async {
    final preferences = await SharedPreferences.getInstance();
    final queued = preferences.getStringList(_queueKey)?.toSet() ?? <String>{};
    if (!queued.remove(sourceId)) return;
    await preferences.setStringList(_queueKey, queued.toList(growable: false));
  }

  static Future<void> clearQueue() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_queueKey);
  }

  static Future<void> _submit(Place place) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    final sourceId = place.sourceId;
    if (user == null || sourceId == null || !place.hasCoordinates) {
      throw StateError('Başvuru için oturum ve geçerli konum gerekli.');
    }

    final existing = await client
        .from('place_submissions')
        .select('id, photo_paths')
        .eq('submitted_by', user.id)
        .eq('client_reference', sourceId)
        .maybeSingle();
    final existingPhotos = (existing?['photo_paths'] as List?) ?? const [];
    if (existing != null &&
        (place.image == null ||
            place.image!.isEmpty ||
            existingPhotos.isNotEmpty)) {
      return;
    }

    String submissionId;
    if (existing != null) {
      submissionId = existing['id'].toString();
    } else {
      final categoryName = _databaseCategoryName(place.kind);
      final category = await client
          .from('categories')
          .select('id')
          .eq('name', categoryName)
          .maybeSingle();
      final categoryId = category?['id'];
      if (categoryId == null) {
        throw StateError(
            '$categoryName kategorisi Supabase içinde bulunamadı.');
      }

      final location = _locationParts(place.location);
      final taxonomy = place.resolvedTaxonomy;
      final facilities = <String, bool>{};
      for (final entry in place.facilities.values.entries) {
        if (entry.value != null) facilities[entry.key] = entry.value!;
      }
      final environmentTags = place.features
          .where((item) => item.startsWith('Çevre: '))
          .map((item) => item.substring('Çevre: '.length))
          .toList(growable: false);
      final featureTags = place.features
          .where((item) =>
              !item.startsWith('Çevre: ') && !item.startsWith('Ulaşım: '))
          .toList(growable: false);
      String? roadAccess;
      for (final item in place.features) {
        if (item.startsWith('Ulaşım: ')) {
          roadAccess = item.substring('Ulaşım: '.length);
          break;
        }
      }

      final inserted = await client
          .from('place_submissions')
          .insert({
            'submitted_by': user.id,
            'client_reference': sourceId,
            'category_id': categoryId,
            'name': place.name.trim(),
            'description': place.description.trim(),
            'city': location.city,
            'district': location.district,
            'location_label': place.location.trim(),
            'latitude': place.latitude,
            'longitude': place.longitude,
            'environment_tags': environmentTags,
            'features': featureTags,
            'road_access': roadAccess,
            'photo_paths': const <String>[],
            'main_category': taxonomy.mainCategory,
            'subtype': taxonomy.subtype,
            'facilities': facilities,
            'status': 'pending',
          })
          .select('id')
          .single();
      submissionId = inserted['id'].toString();
    }

    final image = place.image;
    if (image == null || image.isEmpty) return;
    final bytes = await PlacePhotoStorage.readPersistedPhoto(image);
    if (bytes == null || bytes.isEmpty) return;
    if (bytes.length > 8 * 1024 * 1024) {
      throw StateError('Fotoğraf 8 MB sınırını aşıyor.');
    }
    final photoType = _photoType(image);
    final path = '${user.id}/$submissionId/primary${photoType.extension}';
    await client.storage.from('place-submissions').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: photoType.contentType,
          ),
        );
    try {
      await client.rpc(
        'attach_submission_photo',
        params: {'p_submission_id': submissionId, 'p_path': path},
      );
    } catch (_) {
      try {
        await client.storage.from('place-submissions').remove([path]);
      } catch (_) {
        // RPC başarısız olursa sahipsiz dosyayı temizlemek için en iyi çaba.
      }
      rethrow;
    }
  }

  static String _databaseCategoryName(String category) => switch (category) {
        'Piknik' => 'Piknik Alanı',
        'Yürüyüş' => 'Yürüyüş Rotası',
        'Karavan' => 'Karavan Alanı',
        _ => category,
      };

  static ({String city, String? district}) _locationParts(String label) {
    final isCoordinate =
        RegExp(r'^-?\d+[.,]\d+\s*,\s*-?\d+[.,]\d+$').hasMatch(label.trim());
    if (label.trim().isEmpty || isCoordinate) {
      return (city: 'Belirtilmedi', district: null);
    }
    final parts = label
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty && part.toLowerCase() != 'türkiye')
        .toList(growable: false);
    if (parts.isEmpty) return (city: 'Belirtilmedi', district: null);
    final city =
        parts.last.length > 80 ? parts.last.substring(0, 80) : parts.last;
    final district = parts.length > 1 ? parts[parts.length - 2] : null;
    return (city: city, district: district);
  }

  static ({String extension, String contentType}) _photoType(String value) {
    final lower = value.toLowerCase();
    if (lower.startsWith('data:image/png') || lower.endsWith('.png')) {
      return (extension: '.png', contentType: 'image/png');
    }
    if (lower.startsWith('data:image/webp') || lower.endsWith('.webp')) {
      return (extension: '.webp', contentType: 'image/webp');
    }
    if (lower.startsWith('data:image/heic') || lower.endsWith('.heic')) {
      return (extension: '.heic', contentType: 'image/heic');
    }
    return (extension: '.jpg', contentType: 'image/jpeg');
  }
}

class SupabasePlacesController {
  SupabasePlacesController._();

  static const _storageKey = 'supabase_places_cache_v1';
  static final places = ValueNotifier<List<Place>>(<Place>[]);

  // Isolate-safe helper: sadece JSON string -> Map decode eder.
  // Place nesneleri main isolate'ta olusturuluyor cunke IconData ve Color
  // (dart:ui) isolate mesaj kanalindan gecemez.
  static List<Map<String, dynamic>> _decodeCacheRecords(
    List<String> records,
  ) {
    final result = <Map<String, dynamic>>[];
    for (final record in records) {
      try {
        final data = jsonDecode(record);
        if (data is Map<String, dynamic>) result.add(data);
      } catch (_) {
        // Bozuk JSON: kayit atlanir, mevcut davranis korunur.
      }
    }
    return result;
  }

  // Test accessor: exposes _decodeCacheRecords for unit testing without compute().
  @visibleForTesting
  static List<Map<String, dynamic>> decodeCacheRecordsForTest(
    List<String> records,
  ) =>
      _decodeCacheRecords(records);

  static Future<List<Place>> _readCachedPlaces() async {
    final preferences = await SharedPreferences.getInstance();
    final rawRecords =
        preferences.getStringList(_storageKey) ?? const <String>[];
    final decoded = await compute(_decodeCacheRecords, rawRecords);
    return decoded
        .map((data) {
          try {
            return Place(
              data['name']?.toString() ?? 'Doğa Noktası',
              data['location']?.toString() ?? '',
              canonicalPlaceCategory(
                data['kind']?.toString() ?? 'Doğa Noktası',
              ),
              0,
              Icons.place_rounded,
              AppColors.defaultGradient,
              data['image']?.toString(),
              description: data['description']?.toString() ?? '',
              latitude: (data['latitude'] as num?)?.toDouble(),
              longitude: (data['longitude'] as num?)?.toDouble(),
              sourceId: data['sourceId']?.toString(),
              updatedAt: DateTime.tryParse(data['updatedAt']?.toString() ?? ''),
              source: PlaceSource.curated,
              verificationStatus: data['verificationStatus'] == 'community'
                  ? VerificationStatus.community
                  : data['verificationStatus'] == 'verified' ||
                          data['isVerified'] == true
                      ? VerificationStatus.verified
                      : VerificationStatus.unverified,
              mainCategory: data['mainCategory']?.toString(),
              subtype: data['subtype']?.toString(),
              facilities: PlaceFacilities.fromJson(data['facilities']),
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<Place>()
        .where(
            (place) => place.verificationStatus == VerificationStatus.verified)
        .toList(growable: false);
  }

  static Future<void> loadCached() async {
    places.value = await _readCachedPlaces();
  }

  static Future<void> refresh() async {
    try {
      await load();
    } catch (_) {
      // İnternet yoksa cihazdaki son başarılı liste görünür kalır.
    }
  }

  // Önbellek + araştırma verisi birleşimi tek places.value atamasıyla yapılır,
  // böylece listener'lar gereksiz yere 3 kez tetiklenmez.
  static Future<void> loadCachedAndRefresh() async {
    try {
      final cached = await _readCachedPlaces();
      places.value = await RegionalResearchPlaces.merge(
        await ResearchPhotoPlaces.merge(cached),
      );
    } finally {
      await refresh();
    }
  }

  static Future<void> load() async {
    const pageSize = 1000;
    final rows = <Map<String, dynamic>>[];
    for (var from = 0;; from += pageSize) {
      final page = await Supabase.instance.client
          .from('places')
          .select(
            'id, name, short_description, description, city, district, '
            'latitude, longitude, is_verified, updated_at, main_category, '
            'subtype, name_tr, verification_level, publish_status, '
            'categories(name), place_facilities(*)',
          )
          .eq('is_active', true)
          .eq('is_verified', true)
          .eq('publish_status', 'publish')
          .order('name')
          .order('id')
          .range(from, from + pageSize - 1);
      rows.addAll(page.map((row) => Map<String, dynamic>.from(row)));
      if (page.length < pageSize) break;
    }

    final loadedPlaces = <Place>[];

    for (final row in rows) {
      final data = row;

      final categoryData = data['categories'];
      final categoryName =
          categoryData is Map ? categoryData['name']?.toString() : null;

      final city = data['city']?.toString().trim() ?? '';
      final district = data['district']?.toString().trim() ?? '';

      final location = district.isNotEmpty ? '$district, $city' : city;

      final shortDescription =
          data['short_description']?.toString().trim() ?? '';

      final description = data['description']?.toString().trim() ?? '';
      final turkishName = data['name_tr']?.toString().trim() ?? '';
      final verificationLevel = data['verification_level']?.toString();

      loadedPlaces.add(
        Place(
          turkishName.isNotEmpty
              ? turkishName
              : data['name']?.toString() ?? 'Doğa Noktası',
          location,
          canonicalPlaceCategory(categoryName ?? 'Doğa Noktası'),
          0,
          Icons.place_rounded,
          const [
            AppColors.defaultGradientStart,
            AppColors.defaultGradientEnd,
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
          verificationStatus: verificationLevel == 'community'
              ? VerificationStatus.community
              : verificationLevel == 'verified' || data['is_verified'] == true
                  ? VerificationStatus.verified
                  : VerificationStatus.unverified,
          mainCategory: data['main_category']?.toString(),
          subtype: data['subtype']?.toString(),
          facilities: PlaceFacilities.fromJson(data['place_facilities']),
        ),
      );
    }

    places.value = await RegionalResearchPlaces.merge(
      await ResearchPhotoPlaces.merge(loadedPlaces),
    );

    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _storageKey,
      places.value
          .map((place) => jsonEncode({
                'name': place.name,
                'location': place.location,
                'kind': place.kind,
                'description': place.description,
                'image': place.image,
                'latitude': place.latitude,
                'longitude': place.longitude,
                'sourceId': place.sourceId,
                'updatedAt': place.updatedAt?.toIso8601String(),
                'isVerified':
                    place.verificationStatus == VerificationStatus.verified,
                'verificationStatus': place.verificationStatus.name,
                'mainCategory': place.resolvedTaxonomy.mainCategory,
                'subtype': place.resolvedTaxonomy.subtype,
                'facilities': place.facilities.toJson(),
              }))
          .toList(growable: false),
    );

    debugPrint(
      'SUPABASE PLACES: ${places.value.length} yer modele dönüştürüldü',
    );
  }
}

class OfflineMapTiles {
  OfflineMapTiles._();

  static MapCachingProvider? _cache;

  static Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      final directory = await getApplicationSupportDirectory();
      _cache = BuiltInMapCachingProvider.getOrCreateInstance(
        cacheDirectory: '${directory.path}/offline_map',
        maxCacheSize: 350 * 1024 * 1024,
        overrideFreshAge: const Duration(days: 180),
      );
    } catch (_) {
      // Desteklenmeyen platformda flutter_map varsayılan önbelleğe döner.
    }
  }

  static TileProvider createTileProvider() => NetworkTileProvider(
        cachingProvider: _cache,
        silenceExceptions: true,
      );
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

class UserReviewRecord {
  const UserReviewRecord({
    required this.id,
    required this.placeKey,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.content,
    required this.createdAt,
    this.recommended,
    this.recommendationReasons = const <String>[],
  });

  final String id;
  final String placeKey;
  final String userId;
  final String userName;
  final int rating;
  final String content;
  final DateTime createdAt;
  final bool? recommended;
  final List<String> recommendationReasons;

  ReviewEntry toEntry() {
    final cleanName = userName.trim().isNotEmpty ? userName.trim() : 'Sen';
    final initial = cleanName.characters.first.toUpperCase();
    return ReviewEntry(
      id: id,
      initial: initial,
      color: green,
      name: cleanName,
      timeLabel: _formatTimeLabel(createdAt),
      createdAt: createdAt,
      content: content,
      rating: rating,
      helpfulCount: 0,
    );
  }

  static String _formatTimeLabel(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 2) return 'Şimdi';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    if (diff.inDays < 30) return '${diff.inDays} gün önce';
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    return '$day.$month.${dateTime.year}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'placeKey': placeKey,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'recommended': recommended,
        'recommendationReasons': recommendationReasons,
      };

  factory UserReviewRecord.fromJson(Map<String, dynamic> json) {
    return UserReviewRecord(
      id: json['id']?.toString() ?? '',
      placeKey: json['placeKey']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? 'Sen',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      content: json['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      recommended: json['recommended'] as bool?,
      recommendationReasons: (json['recommendationReasons'] as List?)
              ?.map((e) => e.toString())
              .toList(growable: false) ??
          const <String>[],
    );
  }
}

class UserReviewsController {
  UserReviewsController._();

  static const _storageKey = 'user_place_reviews_v1';
  static final reviews =
      ValueNotifier<List<UserReviewRecord>>(<UserReviewRecord>[]);

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final records = preferences.getStringList(_storageKey) ?? const <String>[];
    reviews.value = records
        .map((record) {
          try {
            final data = jsonDecode(record) as Map<String, dynamic>;
            return UserReviewRecord.fromJson(data);
          } catch (_) {
            return null;
          }
        })
        .whereType<UserReviewRecord>()
        .toList(growable: false);
  }

  static String placeKey(Place place) {
    final sourceId = place.sourceId?.trim();
    if (sourceId != null && sourceId.isNotEmpty) {
      return sourceId;
    }
    final name = place.name.trim().toLowerCase();
    final lat =
        place.latitude != null ? place.latitude!.toStringAsFixed(4) : '';
    final lon =
        place.longitude != null ? place.longitude!.toStringAsFixed(4) : '';
    return '$name:$lat:$lon';
  }

  static bool _matches(UserReviewRecord r, Place place) {
    final targetSourceId = place.sourceId?.trim();
    if (targetSourceId != null &&
        targetSourceId.isNotEmpty &&
        r.placeKey == targetSourceId) {
      return true;
    }
    final pKey = placeKey(place);
    if (r.placeKey == pKey) return true;

    final name = place.name.trim().toLowerCase();
    final lat =
        place.latitude != null ? place.latitude!.toStringAsFixed(4) : '';
    final lon =
        place.longitude != null ? place.longitude!.toStringAsFixed(4) : '';
    if (r.placeKey == '$name:$lat:$lon') return true;

    return false;
  }

  static List<UserReviewRecord> forPlace(Place place) {
    return reviews.value
        .where((r) => _matches(r, place))
        .toList(growable: false);
  }

  static UserReviewRecord? userReviewForPlace(Place place) {
    final list = forPlace(place);
    return list.isNotEmpty ? list.first : null;
  }

  static Future<void> saveReview({
    required Place place,
    required int rating,
    required String content,
    bool? recommended,
    List<String> reasons = const <String>[],
  }) async {
    final pKey = placeKey(place);
    User? user;
    try {
      user = Supabase.instance.client.auth.currentUser;
    } catch (_) {}
    final metadata = user?.userMetadata;
    final fullName = (metadata?['full_name']?.toString() ??
            metadata?['name']?.toString() ??
            metadata?['display_name']?.toString() ??
            '')
        .trim();
    final email = user?.email?.trim() ?? '';
    final displayName = fullName.isNotEmpty
        ? fullName
        : (email.isNotEmpty ? email.split('@').first : 'Sen');

    final record = UserReviewRecord(
      id: 'rev-${DateTime.now().microsecondsSinceEpoch}',
      placeKey: pKey,
      userId: user?.id ?? 'local_user',
      userName: displayName,
      rating: rating,
      content: content.trim(),
      createdAt: DateTime.now(),
      recommended: recommended,
      recommendationReasons: reasons,
    );

    final updated =
        reviews.value.where((r) => !_matches(r, place)).toList(growable: true);
    updated.insert(0, record);
    reviews.value = updated;
    await _persist();
  }

  static Future<void> clear() async {
    reviews.value = const <UserReviewRecord>[];
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }

  static Future<void> _persist() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _storageKey,
      reviews.value
          .map((item) => jsonEncode(item.toJson()))
          .toList(growable: false),
    );
  }
}

String weatherConditionLabel(int weatherCode) {
  if (weatherCode == 0) return AppStrings.get('weather_clear');
  if (weatherCode == 1) return AppStrings.get('weather_mostly_clear');
  if (weatherCode == 2) return AppStrings.get('weather_partly_cloudy');
  if (weatherCode == 3) return AppStrings.get('weather_overcast');
  if (weatherCode == 45 || weatherCode == 48) {
    return AppStrings.get('weather_foggy');
  }
  if (weatherCode >= 51 && weatherCode <= 57) {
    return AppStrings.get('weather_drizzle');
  }
  if (weatherCode >= 61 && weatherCode <= 67) {
    return AppStrings.get('weather_rainy');
  }
  if (weatherCode >= 71 && weatherCode <= 77) {
    return AppStrings.get('weather_snowy');
  }
  if (weatherCode >= 80 && weatherCode <= 82) {
    return AppStrings.get('weather_heavy_rain');
  }
  if (weatherCode >= 85 && weatherCode <= 86) {
    return AppStrings.get('weather_heavy_snow');
  }
  if (weatherCode >= 95) return AppStrings.get('weather_thunderstorm');
  return AppStrings.get('weather_variable');
}

String weatherEmoji(int weatherCode, {bool isDay = true}) {
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

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.minimumTemperature,
    required this.maximumTemperature,
    this.precipitationProbability,
    this.windSpeedMax,
  });

  final DateTime date;
  final int weatherCode;
  final double minimumTemperature;
  final double maximumTemperature;
  final double? precipitationProbability;
  final double? windSpeedMax;

  String get condition => weatherConditionLabel(weatherCode);
  String get emoji => weatherEmoji(weatherCode);
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
    this.dailyForecast = const <DailyForecast>[],
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
  final List<DailyForecast> dailyForecast;

  String get condition => weatherConditionLabel(weatherCode);
  String get emoji => weatherEmoji(weatherCode, isDay: isDay);
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

  static const unavailableLabel = 'Konum izni gerekli';
  static final current =
      ValueNotifier<WeatherTarget>(const WeatherTarget.city('İstanbul'));
  static final isResolvingLocation = ValueNotifier<bool>(false);
  static final isApproximateLocation = ValueNotifier<bool>(false);

  static void useManualCity(String city) {
    final value = city.trim();
    if (value.isNotEmpty) {
      isApproximateLocation.value = false;
      current.value = WeatherTarget.city(value);
    }
  }

  static void useDeviceCoordinates({
    required double latitude,
    required double longitude,
    String label = 'Konumum',
    bool isApproximate = false,
  }) {
    isApproximateLocation.value = isApproximate;
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
        isApproximate: coordinates.isApproximate,
      );
      return coordinates;
    } catch (_) {
      useFallbackCity();
      rethrow;
    } finally {
      isResolvingLocation.value = false;
    }
  }

  static void useFallbackCity() {
    isApproximateLocation.value = false;
    current.value = const WeatherTarget.city(unavailableLabel);
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
    final step = durationMinutes < 60 ? 5 : 10;
    final roundedMinutes = math.max(
      step,
      (durationMinutes / step).round() * step,
    );
    if (roundedMinutes < 60) return '$roundedMinutes dk';
    final hours = roundedMinutes ~/ 60;
    final minutes = roundedMinutes % 60;
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
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,wind_speed_10m_max',
        'timezone': 'auto',
        'forecast_days': '5',
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

    final dailyForecasts = <DailyForecast>[];
    final times = daily['time'] as List<dynamic>?;
    final codes = daily['weather_code'] as List<dynamic>?;
    final maxTemps = daily['temperature_2m_max'] as List<dynamic>?;
    final minTemps = daily['temperature_2m_min'] as List<dynamic>?;
    final precip = daily['precipitation_probability_max'] as List<dynamic>?;
    final windMax = daily['wind_speed_10m_max'] as List<dynamic>?;

    if (times != null) {
      for (var i = 0; i < times.length; i++) {
        final dateStr = times[i]?.toString() ?? '';
        final parsedDate =
            DateTime.tryParse(dateStr) ?? DateTime.now().add(Duration(days: i));
        final code =
            i < (codes?.length ?? 0) ? (codes![i] as num?)?.toInt() ?? 0 : 0;
        final maxT = i < (maxTemps?.length ?? 0)
            ? (maxTemps![i] as num?)?.toDouble() ?? 0.0
            : 0.0;
        final minT = i < (minTemps?.length ?? 0)
            ? (minTemps![i] as num?)?.toDouble() ?? 0.0
            : 0.0;
        final pProb =
            i < (precip?.length ?? 0) ? (precip![i] as num?)?.toDouble() : null;
        final wMax = i < (windMax?.length ?? 0)
            ? (windMax![i] as num?)?.toDouble()
            : null;

        dailyForecasts.add(DailyForecast(
          date: parsedDate,
          weatherCode: code,
          minimumTemperature: minT,
          maximumTemperature: maxT,
          precipitationProbability: pProb,
          windSpeedMax: wMax,
        ));
      }
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
      dailyForecast: dailyForecasts,
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
  static String? _lastMergedTargetKey;
  static List<Place>? _lastUserPlacesRef;
  static List<Place>? _lastSupabasePlacesRef;
  static int _lastMergedRevision = -1;
  static List<Place>? _lastMergedResult;
  static String? _lastFilteredKey;
  static List<Place>? _lastFilteredPlacesRef;
  static List<Place>? _lastFilteredResult;

  static int get queryRadiusMeters => _radiusMeters;
  static int get queryRadiusKm => _radiusMeters ~/ 1000;
  static Duration get maxOverpassDuration => _maxOverpassDuration;

  static String cacheRegionKey(WeatherTarget target) {
    if (!target.usesCoordinates) {
      return 'nearby:r$_radiusMeters:unavailable';
    }
    final latitudeCell = (target.latitude! / _cacheCellDegrees).round();
    final longitudeCell = (target.longitude! / _cacheCellDegrees).round();
    return 'nearby:r$_radiusMeters:cell:$latitudeCell:$longitudeCell';
  }

  static Future<List<Place>> fetch(
    WeatherTarget target, {
    bool forceRefresh = false,
  }) {
    if (!target.usesCoordinates) return Future.value(const <Place>[]);
    final available = availableNow(target);
    _refreshInBackground(target, forceRefresh: forceRefresh);
    return Future<List<Place>>.value(available);
  }

  static Future<List<Place>> refresh(WeatherTarget target) async {
    if (!target.usesCoordinates) return const <Place>[];
    final cacheKey = cacheRegionKey(target);
    _refreshInBackground(target, forceRefresh: true);
    final request = _inFlight[cacheKey];
    if (request != null) {
      try {
        await request;
      } catch (_) {
        // Ağ yenilemesi başarısız olsa da local/cache verisi görünür kalır.
      }
    }
    return availableNow(target);
  }

  static List<Place> availableNow(WeatherTarget target) {
    if (!target.usesCoordinates) return const <Place>[];
    final targetKey = target.cacheKey;
    final userPlaces = UserPlacesController.places.value;
    final supabasePlaces = SupabasePlacesController.places.value;
    final currentRevision = revision.value;

    if (_lastMergedResult != null &&
        _lastMergedTargetKey == targetKey &&
        identical(_lastUserPlacesRef, userPlaces) &&
        identical(_lastSupabasePlacesRef, supabasePlaces) &&
        _lastMergedRevision == currentRevision) {
      return _lastMergedResult!;
    }

    final cached = _cache[cacheRegionKey(target)];
    final result = _mergeAvailablePlaces(
      target,
      cached?.places ?? const <Place>[],
    );

    _lastMergedTargetKey = targetKey;
    _lastUserPlacesRef = userPlaces;
    _lastSupabasePlacesRef = supabasePlaces;
    _lastMergedRevision = currentRevision;
    _lastMergedResult = result;

    return result;
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
    if (!target.usesCoordinates) return;
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
    if (!target.usesCoordinates) return const <Place>[];
    Iterable<Place> withDistance(Iterable<Place> places) => places
        .where((place) => place.hasCoordinates)
        .map((place) => _withTargetDistance(target, place))
        .where(
            (place) => (place.distanceKm ?? double.infinity) <= queryRadiusKm);

    final localPlaces = withDistance(UserPlacesController.places.value);
    final supabasePlaces = withDistance(SupabasePlacesController.places.value);
    final normalizedRemotePlaces = withDistance(remotePlaces);

    final merged = <Place>[
      ...localPlaces,
      ...supabasePlaces,
      ...normalizedRemotePlaces,
    ];
    final seen = <String>{};
    merged.retainWhere((place) {
      final latitude = place.latitude;
      final longitude = place.longitude;
      final key = latitude != null && longitude != null
          ? '${AddPlaceQualityService.normalizeName(place.name)}:'
              '${canonicalPlaceCategory(place.kind)}:'
              '${latitude.toStringAsFixed(4)}:${longitude.toStringAsFixed(4)}'
          : place.sourceId ?? place.name.trim().toLowerCase();
      return seen.add(key);
    });
    merged.sort((a, b) => (a.distanceKm ?? double.infinity)
        .compareTo(b.distanceKm ?? double.infinity));
    return merged;
  }

  static List<Place> filterNearbyPlaces({
    required WeatherTarget target,
    required Iterable<Place> places,
    String? preferredCategory,
  }) {
    if (!target.usesCoordinates) return const <Place>[];
    final filterKey = '${target.cacheKey}:$preferredCategory';
    if (places is List<Place> &&
        _lastFilteredResult != null &&
        identical(_lastFilteredPlacesRef, places) &&
        _lastFilteredKey == filterKey) {
      return _lastFilteredResult!;
    }
    final nearby = places
        .where((place) => place.hasCoordinates)
        .map((place) => _withTargetDistance(target, place))
        .where(
            (place) => (place.distanceKm ?? double.infinity) <= queryRadiusKm)
        .where((place) => _matchesNearbyCategory(place, preferredCategory))
        .toList()
      ..sort((a, b) => (a.distanceKm ?? double.infinity)
          .compareTo(b.distanceKm ?? double.infinity));
    if (places is List<Place>) {
      _lastFilteredPlacesRef = places;
      _lastFilteredKey = filterKey;
      _lastFilteredResult = nearby;
    }
    return nearby;
  }

  static bool _matchesNearbyCategory(Place place, String? preferredCategory) {
    if (preferredCategory == null) return !place.isUtility;
    if (isUtilitySubtype(preferredCategory)) {
      return place.resolvedTaxonomy.subtype == preferredCategory;
    }
    return !place.isUtility &&
        place.resolvedTaxonomy.mainCategory == preferredCategory;
  }

  static Place _withTargetDistance(WeatherTarget target, Place place) {
    final distance = calculateDistanceKm(
      target.latitude!,
      target.longitude!,
      place.latitude!,
      place.longitude!,
    );
    return Place(
      place.name,
      place.location,
      canonicalPlaceCategory(place.kind),
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
      features: place.features,
      mainCategory: place.resolvedTaxonomy.mainCategory,
      subtype: place.resolvedTaxonomy.subtype,
      facilities: place.facilities,
    );
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
      if (distance > _radiusMeters / 1000) continue;

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
      return AppColors.waterfallGradient;
    }
    if (kind == 'Göl') {
      return AppColors.lakeGradient;
    }
    if (kind == 'Kamp Alanı') {
      return AppColors.campGradient;
    }
    if (kind == 'Mağara') {
      return AppColors.caveGradient;
    }
    return AppColors.defaultGradient;
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

const places = <Place>[];

const communitySuggestions = <CommunitySuggestion>[];

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
