part of '../../main.dart';

class FigmaSearchScreen extends StatefulWidget {
  const FigmaSearchScreen({super.key, required this.onOpen});
  final ValueChanged<Place> onOpen;
  @override
  State<FigmaSearchScreen> createState() => _FigmaSearchScreenState();
}

class _FigmaSearchScreenState extends State<FigmaSearchScreen> {
  final controller = TextEditingController();
  String query = '';
  String filter = 'Tümü';
  final recentSearches = <String>[];

  static final categories = <(IconData, String, String)>[
    ...placeTaxonomy
        .map((item) => (item.icon, item.label, 'Alt türleri keşfet')),
  ];

  @override
  void initState() {
    super.initState();
    HomeWeatherLocationController.current.addListener(_refreshLocation);
  }

  void _refreshLocation() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    HomeWeatherLocationController.current.removeListener(_refreshLocation);
    controller.dispose();
    super.dispose();
  }

  void selectSearch(String text) {
    controller.text = text;
    controller.selection = TextSelection.collapsed(offset: text.length);
    setState(() => query = text);
  }

  void addRecent(String text) {
    final value = text.trim();
    if (value.isEmpty) return;
    setState(() {
      recentSearches.remove(value);
      recentSearches.insert(0, value);
      if (recentSearches.length > 4) recentSearches.removeLast();
    });
  }

  void submitSearch() {
    final value = controller.text.trim();
    addRecent(value);
    FocusScope.of(context).unfocus();
    setState(() => query = value);
  }

  static String _normalize(String s) =>
      s.trim().replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

  @override
  Widget build(BuildContext context) {
    final realPlaces = <Place>[
      ...SupabasePlacesController.places.value,
      ...UserPlacesController.places.value,
    ]
        .where((place) => !isNonNatureCandidateName(
              place.name,
              subtype: place.resolvedTaxonomy.subtype,
              mainCategory: place.resolvedTaxonomy.mainCategory,
            ))
        .toList(growable: false);
    final trimmedQuery = _normalize(query);

    // Yer adı / konum / tür araması
    final placeResults = trimmedQuery.isEmpty
        ? <Place>[]
        : (realPlaces.where((p) {
            if (!_matchesMapFilter(p, filter, null)) return false;
            final target = _normalize('${p.name} ${p.location} ${p.kind}');
            return target.contains(trimmedQuery);
          }).toList()
          ..sort((a, b) {
            final aName = _normalize(a.name);
            final bName = _normalize(b.name);
            final aLoc = _normalize(a.location);
            final bLoc = _normalize(b.location);
            int score(String name, String loc) {
              if (name.startsWith(trimmedQuery)) return 0;
              if (name.contains(trimmedQuery)) return 1;
              if (loc.startsWith(trimmedQuery)) return 2;
              if (loc.contains(trimmedQuery)) return 3;
              return 4;
            }

            final cmp = score(aName, aLoc).compareTo(score(bName, bLoc));
            if (cmp != 0) return cmp;
            return a.name.compareTo(b.name);
          }));

    // Kullanıcı adı araması: contributorName içeren yerler
    // Yer adı aramasından farklı olan kayıtları göster
    final placeResultIds = placeResults.map((p) => p.sourceId).toSet();
    final contributorResults = trimmedQuery.isEmpty
        ? <Place>[]
        : (realPlaces.where((p) {
            final contributor = _normalize(p.contributorName ?? '');
            return contributor.isNotEmpty &&
                contributor.contains(trimmedQuery) &&
                !placeResultIds.contains(p.sourceId);
          }).toList()
          ..sort((a, b) => a.name.compareTo(b.name)));

    // contributorResults varsa hangi kullanıcı adları eşleşti
    final matchedContributors = contributorResults
        .map((p) => p.contributorName?.trim() ?? '')
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList();

    final filterItems = <(IconData, String)>[
      (Icons.explore_rounded, 'Tümü'),
      ...categories.map((category) => (category.$1, category.$2)),
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkSurfaceDeep : AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          children: [
            Row(children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  onChanged: (value) => setState(() => query = value),
                  onSubmitted: (_) => submitSearch(),
                  style: TextStyle(
                    fontSize: AppFontSizes.body,
                    color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: filter == 'Tümü'
                        ? AppStrings.get('search_input_hint')
                        : '$filter kategorisinde ara...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: green,
                      size: 20,
                    ),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              controller.clear();
                              setState(() => query = '');
                            },
                            icon: const Icon(Icons.close_rounded, size: 18)),
                    filled: true,
                    fillColor:
                        isDark ? AppColors.darkSurfaceMuted : Colors.white,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.large),
                        borderSide: BorderSide(
                            color: isDark ? AppColors.darkBorder : green)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.large),
                        borderSide: const BorderSide(color: green, width: 1.4)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: submitSearch,
                style: FilledButton.styleFrom(
                  backgroundColor: green,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  minimumSize: const Size(54, 50),
                ),
                child: Text(AppStrings.get('search_button')),
              ),
              const SizedBox(width: 4),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppStrings.get('general_cancel'),
                      style: const TextStyle(
                          color: green, fontWeight: FontWeight.w600)))
            ]),
            const SizedBox(height: 12),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: filterItems
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item.$1,
                                  size: 15,
                                  color: filter == item.$2
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary),
                                ),
                                const SizedBox(width: 5),
                                Text(item.$2,
                                    style: TextStyle(
                                        fontSize: AppFontSizes.caption,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : Colors.black87)),
                              ],
                            ),
                            selected: filter == item.$2,
                            onSelected: (_) => setState(() => filter = item.$2),
                            labelStyle: TextStyle(
                                fontSize: AppFontSizes.caption,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : Colors.black87),
                            backgroundColor: isDark
                                ? AppColors.darkSurfaceMuted
                                : Colors.white,
                            selectedColor: isDark
                                ? AppColors.darkPrimarySoft
                                : AppColors.primarySoft,
                            side: BorderSide(
                                color: filter == item.$2
                                    ? green
                                    : isDark
                                        ? AppColors.darkBorder
                                        : AppColors.border),
                            visualDensity: VisualDensity.compact,
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 22),
            if (trimmedQuery.isNotEmpty) ...[
              // Yer sonuçları
              if (placeResults.isNotEmpty) ...[
                Text(
                  filter == 'Tümü'
                      ? '${placeResults.length} yer "${query.trim()}" için'
                      : '${placeResults.length} yer · $filter',
                  style: TextStyle(
                    fontSize: AppFontSizes.caption,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                ...placeResults.map((place) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: _SearchResultCard(
                        place: place,
                        onTap: () {
                          addRecent(place.name);
                          widget.onOpen(place);
                        },
                      ),
                    )),
              ],
              // Kullanıcı sonuçları
              if (contributorResults.isNotEmpty) ...[
                if (placeResults.isNotEmpty) const SizedBox(height: 18),
                Row(children: [
                  const Icon(Icons.person_rounded, size: 15, color: green),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${matchedContributors.join(', ')} tarafından eklenenler',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: AppFontSizes.title,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? AppColors.darkTextPrimary : Colors.black87,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                ...contributorResults.map((place) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: _SearchResultCard(
                        place: place,
                        onTap: () {
                          addRecent(place.contributorName ?? place.name);
                          widget.onOpen(place);
                        },
                      ),
                    )),
              ],
              // Hiç sonuç yok
              if (placeResults.isEmpty && contributorResults.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 34),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.travel_explore_outlined,
                        size: 42,
                        color: isDark
                            ? AppColors.darkTextSecondary.withValues(alpha: 0.4)
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppStrings.get('search_no_results'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          fontSize: AppFontSizes.caption,
                        ),
                      ),
                    ],
                  ),
                ),
            ] else ...[
              if (recentSearches.isNotEmpty) ...[
                Row(children: [
                  Expanded(
                    child: _SearchHeading(
                      AppStrings.get('search_recent_searches'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(recentSearches.clear),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 28),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      AppStrings.get('search_clear'),
                      style: const TextStyle(
                        color: green,
                        fontSize: AppFontSizes.caption,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                ...recentSearches.map((text) => _RecentSearch(
                      text,
                      onTap: () => selectSearch(text),
                    )),
                const SizedBox(height: 22),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 48,
                        color: isDark
                            ? AppColors.darkTextSecondary.withValues(alpha: 0.3)
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        filter == 'Tümü'
                            ? 'Aramak istediğin doğa noktasını veya şehri yaz'
                            : '$filter kategorisinde aramak istediğin yeri yaz',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          fontSize: AppFontSizes.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const _HomeAdBanner(),
            ]
          ],
        ),
      ),
    );
  }
}

class _SearchHeading extends StatelessWidget {
  const _SearchHeading(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(text,
        style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: AppFontSizes.title,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : Colors.black87));
  }
}

class _RecentSearch extends StatelessWidget {
  const _RecentSearch(this.text, {required this.onTap});
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
        onTap: onTap,
        child: Container(
            height: 48,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color:
                            isDark ? AppColors.darkBorder : AppColors.border))),
            child: Row(children: [
              Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceMuted
                          : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppRadii.large)),
                  child: Icon(Icons.history_rounded,
                      size: 15,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary)),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(text,
                      style: TextStyle(
                          fontSize: AppFontSizes.caption,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary))),
              Icon(Icons.north_east_rounded,
                  size: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textTertiary)
            ])));
  }
}

String _userDistanceLabel(Place place) {
  final target = HomeWeatherLocationController.current.value;
  double? distanceKm;
  if (target.usesCoordinates && place.hasCoordinates) {
    distanceKm = NearbyPlacesService.calculateDistanceKm(
      target.latitude!,
      target.longitude!,
      place.latitude!,
      place.longitude!,
    );
  } else {
    distanceKm = place.distanceKm;
  }
  if (distanceKm == null || !distanceKm.isFinite) {
    return 'Mesafe bilgisi yok';
  }
  if (distanceKm < 1) return '${(distanceKm * 1000).round()} m';
  return '${distanceKm.toStringAsFixed(distanceKm < 10 ? 1 : 0)} km';
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.place, required this.onTap});
  final Place place;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: '${place.name}, ${place.kind}, detayları gör',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.large),
        child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.large),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadow08, blurRadius: 8)
                ]),
            child: Row(children: [
              SizedBox(
                  width: 58,
                  child: NatureArt(place: place, radius: 11, showKind: false)),
              const SizedBox(width: 11),
              Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(place.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                            fontSize: AppFontSizes.caption,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('${place.kind}  ·  ${place.location}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            fontSize: AppFontSizes.caption)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                            '⭐ ${place.rating}  ·  ${_userDistanceLabel(place)}',
                            style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                                fontSize: AppFontSizes.caption)),
                        const SizedBox(width: 6),
                        AppPlaceTrustBadge(place: place, compact: true),
                      ],
                    ),
                  ])),
              Icon(Icons.chevron_right_rounded,
                  size: 17,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textTertiary)
            ])),
      ),
    );
  }
}

class _MapCategoryStyle {
  const _MapCategoryStyle(
    this.key,
    this.emoji,
    this.label,
    this.foreground,
    this.background,
  );

  final String key;
  final String emoji;
  final String label;
  final Color foreground;
  final Color background;

  String get localizedLabel {
    if (key == 'all') return AppStrings.get('all');
    if (key == 'water_amenities') return 'Su';
    if (key == 'toilet') return AppStrings.subtype('toilet');
    if (key == 'drinking_water') return AppStrings.subtype('drinking_water');
    if (key == 'water_fountain') return AppStrings.subtype('water_fountain');
    return AppStrings.category(key);
  }
}

final _mapCategories = <_MapCategoryStyle>[
  const _MapCategoryStyle(
      'all', '✦', 'Tümü', AppColors.primary, AppColors.primarySoft),
  ...placeTaxonomy.map((item) => _MapCategoryStyle(
        item.key,
        item.emoji,
        item.label,
        item.foreground,
        item.background,
      )),
  const _MapCategoryStyle(
    'water_amenities',
    'Su',
    'Su',
    AppColors.categoryWater,
    AppColors.primarySoft,
  ),
  const _MapCategoryStyle(
    'toilet',
    'WC',
    'WC',
    AppColors.categoryUtility,
    AppColors.surfaceMuted,
  ),
];

bool _matchesMapFilter(Place place, String filterKey, String? subtype) {
  if (filterKey == 'all' ||
      filterKey == 'Tümü' ||
      filterKey == AppStrings.get('all')) {
    return true;
  }
  final style = _mapCategories.firstWhere(
    (item) =>
        item.key == filterKey ||
        item.label == filterKey ||
        item.localizedLabel == filterKey,
    orElse: () => _mapCategories.first,
  );
  if (style.key == 'all') return true;
  final taxonomy = place.resolvedTaxonomy;
  if (style.key == 'water_amenities') {
    return taxonomy.subtype == 'drinking_water' ||
        taxonomy.subtype == 'water_fountain';
  }
  if (isUtilitySubtype(style.key)) return taxonomy.subtype == style.key;
  if (style.key == 'local_service') {
    final matchesCategory = taxonomy.mainCategory == 'local_service' ||
        taxonomy.subtype == 'local_service' ||
        (taxonomy.subtype != null &&
            taxonomy.subtype!.startsWith('service_')) ||
        place.isMobileService ||
        place.kind.toLowerCase().contains('servis') ||
        place.kind.toLowerCase().contains('işletme') ||
        place.kind.toLowerCase().contains('isletme');
    if (!matchesCategory) return false;
    if (subtype != null && subtype.isNotEmpty) {
      return taxonomy.subtype == subtype;
    }
    return true;
  }
  return taxonomy.mainCategory == style.key &&
      (subtype == null || taxonomy.subtype == subtype);
}

bool isPlaceMeaningfullyNearViewport(
  LatLng place,
  LatLngBounds visibleBounds,
) {
  final latitudeMargin = (visibleBounds.north - visibleBounds.south) * .35;
  final longitudeMargin = (visibleBounds.east - visibleBounds.west) * .35;
  return place.latitude >= visibleBounds.south - latitudeMargin &&
      place.latitude <= visibleBounds.north + latitudeMargin &&
      place.longitude >= visibleBounds.west - longitudeMargin &&
      place.longitude <= visibleBounds.east + longitudeMargin;
}

bool _isPlaceNearClusterViewport(LatLng place, LatLngBounds visibleBounds) {
  final latitudeMargin = (visibleBounds.north - visibleBounds.south) * .08;
  final longitudeMargin = (visibleBounds.east - visibleBounds.west) * .08;
  return place.latitude >= visibleBounds.south - latitudeMargin &&
      place.latitude <= visibleBounds.north + latitudeMargin &&
      place.longitude >= visibleBounds.west - longitudeMargin &&
      place.longitude <= visibleBounds.east + longitudeMargin;
}

class _MapCluster {
  const _MapCluster({
    required this.center,
    required this.placeIndexes,
    this.dominantCategory,
    this.isMixed = false,
  });

  final LatLng center;
  final List<int> placeIndexes;
  final String? dominantCategory;
  final bool isMixed;
}

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.onOpen,
    this.onUserInteraction,
    this.bottomNavigationVisible,
  });

  final ValueChanged<Place> onOpen;
  final VoidCallback? onUserInteraction;
  final ValueNotifier<bool>? bottomNavigationVisible;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

enum _MapStyle { standart, uydu, topo }

class _MapScreenState extends State<MapScreen> {
  static const initialCenter = LatLng(39.0, 35.2);
  static const initialZoom = 5.4;
  final mapController = MapController();
  late final TileProvider tileProvider = OfflineMapTiles.createTileProvider();
  late List<Place> _mapPlaces;
  int? selectedIndex;
  String selectedFilter = 'Tümü';
  String? selectedSubtype;
  _MapStyle _mapStyle = _MapStyle.standart;
  StreamSubscription<DeviceCoordinates>? _locationSubscription;
  LatLng? _liveUserCoordinate;
  double _mapZoom = initialZoom;
  LatLngBounds? _visibleBounds;
  LatLngBounds? _pendingVisibleBounds;
  Timer? _cameraUpdateTimer;
  List<_MapCluster>? _clusterCache;
  double? _clusterZoomBucket;
  String? _clusterFilter;
  List<Place>? _viewportPlaces;
  bool _isViewportLoading = false;
  bool _viewportNeedsSearch = false;
  String? _viewportError;
  int _viewportRequestToken = 0;
  bool _isMapReady = false;
  MapRegionFocus? _pendingRegionFocus;
  // Arama, açık bölgenin dışından da sonuç döndürebilir. Seçilen sonucu
  // kamera/veri yenilenirken kaybetmemek için geçici olarak haritada tutarız.
  Place? _searchFocusedPlace;
  // Bölge görünümü varsayılandır: kullanıcı bir alanı açıkça seçene kadar
  // harita sade kalır. Tüm Türkiye görünümü ise bilinçli bir tercih olmalıdır.
  bool _isAllRegionsMode = false;
  bool _hasOpenedRegion = false;

  List<Place> buildMapPlaces() {
    final usesRegionalExplorer =
        MapViewportPointsService.regionalExplorerEnabled;
    if (usesRegionalExplorer &&
        !_isAllRegionsMode &&
        !_hasOpenedRegion &&
        UserPlacesController.places.value.isEmpty &&
        _searchFocusedPlace == null) {
      return const <Place>[];
    }
    final useViewportPoints = usesRegionalExplorer &&
        MapViewportPointsService.enabled &&
        !_isAllRegionsMode &&
        _viewportPlaces != null;
    final remotePlaces =
        (usesRegionalExplorer && !_isAllRegionsMode && !_hasOpenedRegion)
            ? const <Place>[]
            : (useViewportPoints
                ? _viewportPlaces!
                : SupabasePlacesController.places.value);
    final bounds = _visibleBounds;
    final seen = <String>{};
    final combined = <Place>[
      ...UserPlacesController.places.value,
      ...remotePlaces,
      if (selectedFilter == 'local_service') ...SampleMobileServices.samples,
      if (_searchFocusedPlace != null) _searchFocusedPlace!,
    ].where((place) {
      final key = place.sourceId ??
          '${place.name.toLowerCase()}:${place.latitude}:${place.longitude}';
      final isFocusedSearchResult = _isFocusedSearchResult(place);
      return place.hasCoordinates &&
          !isNonNatureCandidateName(
            place.name,
            subtype: place.resolvedTaxonomy.subtype,
            mainCategory: place.resolvedTaxonomy.mainCategory,
          ) &&
          AddPlaceQualityService.isValidCoordinate(
            place.latitude,
            place.longitude,
          ) &&
          // Yardımcı tesisler bölge keşfinde de görünür; yakın ölçekte ise
          // kümeden ayrılıp tekil, seçilebilir simgelere dönüşür.
          (isFocusedSearchResult ||
              !place.isUtility ||
              _mapZoom >= MapViewportPointsService.auxiliaryMinZoom) &&
          // RPC hazır olmadan da eski veriyle ekran dışındaki binlerce nokta
          // çizilmez. Bu, işlev kapatıldığında dahi güvenli bir yerel yedektir.
          (_isAllRegionsMode ||
              isFocusedSearchResult ||
              bounds == null ||
              (place.latitude! >= bounds.south &&
                  place.latitude! <= bounds.north &&
                  place.longitude! >= bounds.west &&
                  place.longitude! <= bounds.east)) &&
          seen.add(key);
    }).toList(growable: false);
    if (useViewportPoints ||
        _isAllRegionsMode ||
        !MapViewportPointsService.enabled) {
      return combined;
    }
    return combined.take(MapViewportPointsService.maxPoints).toList(
          growable: false,
        );
  }

  List<Place> get mapPlaces => _mapPlaces;

  bool _isFocusedSearchResult(Place place) {
    final focused = _searchFocusedPlace;
    if (focused == null) return false;
    return (focused.sourceId != null && focused.sourceId == place.sourceId) ||
        (focused.name == place.name &&
            focused.latitude == place.latitude &&
            focused.longitude == place.longitude);
  }

  /// Kamera/veri yenilenirken önceki seçimin indeksi artık listede olmayabilir.
  /// Bu yüzden ekran, doğrudan liste indeksi yerine bu güvenli erişimi kullanır.
  int? get validSelectedIndex {
    final index = selectedIndex;
    if (index == null || index < 0 || index >= mapPlaces.length) return null;
    return index;
  }

  Place? get selectedMapPlace {
    final index = validSelectedIndex;
    return index == null ? null : mapPlaces[index];
  }

  List<Place> get nearbyPreviewPlaces {
    final target = HomeWeatherLocationController.current.value;
    if (!target.usesCoordinates ||
        HomeWeatherLocationController.isApproximateLocation.value) {
      return const [];
    }
    return NearbyPlacesService.filterNearbyPlaces(
      target: target,
      places: mapPlaces,
    );
  }

  LatLng coordinateFor(int index) {
    final place = mapPlaces[index];
    return LatLng(place.latitude!, place.longitude!);
  }

  List<_MapCluster> get markerClusters {
    final zoomBucket = (_mapZoom * 2).round() / 2;
    final cached = _clusterCache;
    if (cached != null &&
        _clusterZoomBucket == zoomBucket &&
        _clusterFilter == '$selectedFilter:$selectedSubtype') {
      return cached;
    }
    final visibleIndexes = <int>[
      for (var index = 0; index < mapPlaces.length; index++)
        if (index != selectedIndex &&
            isVisible(mapPlaces[index]) &&
            (_visibleBounds == null ||
                _isPlaceNearClusterViewport(
                  coordinateFor(index),
                  _visibleBounds!,
                )))
          index,
    ];

    // İl ölçeğinde sayı balonları yerine türü anlatan küçük küme ikonları
    // kullanılır. Kullanıcı biraz yaklaştığında tekil pinlere geçilir;
    // böylece ekran, Gümüşhane gibi yoğun alanlarda da temiz kalır.
    final renderAsIndividualPins =
        MapViewportPointsService.regionalExplorerEnabled &&
            _hasOpenedRegion &&
            !_isAllRegionsMode &&
            _mapZoom >= MapViewportPointsService.compactPinsMinZoom;
    if (renderAsIndividualPins ||
        _mapZoom >= MapViewportPointsService.amenityMinZoom) {
      final individual = visibleIndexes
          .map(
            (index) => _MapCluster(
              center: coordinateFor(index),
              placeIndexes: List<int>.unmodifiable(<int>[index]),
              dominantCategory: mapPlaces[index].resolvedTaxonomy.subtype ??
                  mapPlaces[index].resolvedTaxonomy.mainCategory,
            ),
          )
          .toList(growable: false);
      _clusterCache = individual;
      _clusterZoomBucket = zoomBucket;
      _clusterFilter = '$selectedFilter:$selectedSubtype';
      return individual;
    }

    var latitudeCellSize = 180 / math.pow(2, zoomBucket);
    var longitudeCellSize = latitudeCellSize;
    final bounds = _visibleBounds;
    if (bounds != null) {
      final latitudeSpan = math.max(bounds.north - bounds.south, .0001);
      final longitudeSpan = math.max(bounds.east - bounds.west, .0001);
      final targetClusterCount = switch (zoomBucket) {
        <= 6 => 4,
        <= 8 => 6,
        <= 10 => 12,
        <= 12 => 24,
        <= 14 => 42,
        _ => 64,
      };
      final aspectRatio = (longitudeSpan / latitudeSpan).clamp(.5, 2.0);
      final columns = math.max(
        1,
        math.sqrt(targetClusterCount * aspectRatio).round(),
      );
      final rows = math.max(1, (targetClusterCount / columns).ceil());
      latitudeCellSize = latitudeSpan / rows;
      longitudeCellSize = longitudeSpan / columns;
    }

    final grouped = <String, List<int>>{};
    for (final index in visibleIndexes) {
      final point = coordinateFor(index);
      final taxonomy = mapPlaces[index].resolvedTaxonomy;
      // WC, içme suyu ve ana doğa türleri aynı coğrafi kümede birbirine
      // karışmaz. Böylece "69" yerine WC ikonu + 69 gibi anlaşılır kümeler
      // oluşur; kullanıcı hangi türün sayıldığını doğrudan görür.
      final layerKey = taxonomy.subtype ?? taxonomy.mainCategory ?? 'other';
      final key = '${(point.latitude / latitudeCellSize).floor()}:'
          '${(point.longitude / longitudeCellSize).floor()}:$layerKey';
      grouped.putIfAbsent(key, () => <int>[]).add(index);
    }
    final clusters = grouped.values.map((indexes) {
      var latitude = 0.0;
      var longitude = 0.0;
      final categoryCounts = <String, int>{};
      for (final index in indexes) {
        final point = coordinateFor(index);
        latitude += point.latitude;
        longitude += point.longitude;
        final taxonomy = mapPlaces[index].resolvedTaxonomy;
        final cat = taxonomy.subtype ?? taxonomy.mainCategory;
        if (cat != null) {
          categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
        }
      }
      String? dominant;
      var maxCount = 0;
      for (final entry in categoryCounts.entries) {
        if (entry.value > maxCount) {
          maxCount = entry.value;
          dominant = entry.key;
        }
      }
      final isDominant =
          dominant != null && maxCount >= (indexes.length * 0.40);
      return _MapCluster(
        center: LatLng(latitude / indexes.length, longitude / indexes.length),
        placeIndexes: List.unmodifiable(indexes),
        dominantCategory: isDominant ? dominant : null,
        isMixed: !isDominant,
      );
    }).toList(growable: false);
    _clusterCache = clusters;
    _clusterZoomBucket = zoomBucket;
    _clusterFilter = '$selectedFilter:$selectedSubtype';
    return clusters;
  }

  @override
  void initState() {
    super.initState();
    _mapPlaces = buildMapPlaces();
    UserPlacesController.places.addListener(_refreshUserPlaces);
    SupabasePlacesController.places.addListener(_refreshRemotePlaces);
    HomeWeatherLocationController.current.addListener(_refreshUserLocation);
    MapFocusController.focusedPlace.addListener(_onMapFocusRequested);
    MapRegionFocusController.focusedRegion
        .addListener(_onMapRegionFocusRequested);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_startLiveLocation());
        if (MapFocusController.focusedPlace.value != null) {
          _onMapFocusRequested();
        }
        if (MapRegionFocusController.focusedRegion.value != null) {
          _onMapRegionFocusRequested();
        }
      }
    });
  }

  Future<void> _startLiveLocation() async {
    try {
      if (!HomeWeatherLocationController.current.value.usesCoordinates ||
          HomeWeatherLocationController.isApproximateLocation.value) {
        await HomeWeatherLocationController.requestAndUseDeviceLocation();
      }
      if (!mounted) return;
      await _locationSubscription?.cancel();
      _locationSubscription = DeviceLocationService.watchPosition().listen(
        (coordinates) {
          if (!mounted) return;
          setState(() {
            _liveUserCoordinate = coordinates.isApproximate
                ? null
                : LatLng(coordinates.latitude, coordinates.longitude);
          });
        },
        onError: (_) {},
      );
    } catch (_) {
      // Konum izni yoksa harita çalışmaya devam eder; kullanıcı daha sonra
      // konum düğmesinden tekrar deneyebilir.
    }
  }

  void _refreshUserPlaces() {
    _reloadPlaces();
  }

  void _refreshRemotePlaces() {
    _reloadPlaces();
  }

  void _reloadPlaces() {
    if (!mounted) return;
    setState(() {
      _mapPlaces = buildMapPlaces();
      selectedIndex = null;
      _selectionHistory.clear();
      _clusterCache = null;
    });
  }

  Future<void> _loadViewportPoints({bool userInitiated = false}) async {
    if (!MapViewportPointsService.enabled || _visibleBounds == null) return;
    if (_isViewportLoading) return;
    final requestToken = ++_viewportRequestToken;
    final requestedBounds = _visibleBounds!;
    final requestedZoom = _mapZoom;
    final filterTypes = switch (selectedFilter) {
      'Tümü' || 'all' || 'local_service' => null,
      'water_amenities' => <String>['drinking_water', 'water_fountain'],
      final key => <String>[key],
    };
    setState(() {
      _hasOpenedRegion = true;
      _isViewportLoading = true;
      _viewportError = null;
    });
    try {
      final loaded = await MapViewportPointsService.fetch(
        bounds: requestedBounds,
        zoom: requestedZoom,
        filterTypes: filterTypes,
      );
      if (!mounted || requestToken != _viewportRequestToken) return;
      setState(() {
        _viewportPlaces = loaded;
        _viewportNeedsSearch = false;
        _isViewportLoading = false;
        _mapPlaces = buildMapPlaces();
        selectedIndex = null;
        _selectionHistory.clear();
        _clusterCache = null;
      });
    } catch (_) {
      if (!mounted || requestToken != _viewportRequestToken) return;
      setState(() {
        _isViewportLoading = false;
        _viewportError = 'Bu alan için yerler şu an yüklenemedi.';
      });
      if (userInitiated) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Bu alan yüklenemedi. Bağlantını kontrol edip tekrar dene.'),
        ));
      }
    }
  }

  void _refreshUserLocation() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cameraUpdateTimer?.cancel();
    _locationSubscription?.cancel();
    UserPlacesController.places.removeListener(_refreshUserPlaces);
    SupabasePlacesController.places.removeListener(_refreshRemotePlaces);
    HomeWeatherLocationController.current.removeListener(_refreshUserLocation);
    MapFocusController.focusedPlace.removeListener(_onMapFocusRequested);
    MapRegionFocusController.focusedRegion
        .removeListener(_onMapRegionFocusRequested);
    mapController.dispose();
    super.dispose();
  }

  void _onMapFocusRequested() {
    final target = MapFocusController.focusedPlace.value;
    if (target == null || !mounted) return;
    MapFocusController.clear();
    if (!target.hasCoordinates) return;

    _mapPlaces = buildMapPlaces();
    selectPlace(target);
  }

  void _onMapRegionFocusRequested() {
    final region = MapRegionFocusController.focusedRegion.value;
    if (region == null || !mounted) return;
    MapRegionFocusController.clear();

    // FlutterMap henüz hazır değilken yapılan move çağrısı önceki kameranın
    // ekranda kalmasına neden olabiliyordu. İsteği saklayıp onMapReady'de
    // uygularsak seçilen il her zaman doğru merkezden açılır.
    _pendingRegionFocus = region;
    if (_isMapReady) _applyPendingRegionFocus();
  }

  void _applyPendingRegionFocus() {
    _isMapReady = true;
    final region = _pendingRegionFocus;
    if (region == null || !mounted) return;
    _pendingRegionFocus = null;
    _applyRegionFocus(region);
  }

  void _applyRegionFocus(MapRegionFocus region) {
    // Eski alanın asenkron isteği yeni ilin verisini ezemez.
    _viewportRequestToken++;

    // Bir il seçildiğinde önce eski alanın verisini ve seçimini temizleriz.
    // Böylece Konya'dan Antalya'ya geçen kullanıcı, önceki bölgenin
    // marker'larını yeni bölgede görmez.
    setState(() {
      _isAllRegionsMode = false;
      _hasOpenedRegion = false;
      _viewportPlaces = null;
      _isViewportLoading = false;
      _viewportNeedsSearch = false;
      _viewportError = null;
      selectedFilter = 'Tümü';
      selectedSubtype = null;
      selectedIndex = null;
      _selectionHistory.clear();
      _clusterCache = null;
      _mapPlaces = buildMapPlaces();
    });
    mapController.move(region.center, region.zoom);

    // MapController yeni görünür sınırları bir sonraki frame'de hesaplar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _visibleBounds = mapController.camera.visibleBounds;
        _mapZoom = mapController.camera.zoom;
      });
      unawaited(_loadViewportPoints(userInitiated: true));
    });
  }

  bool isVisible(Place place) {
    return _matchesMapFilter(place, selectedFilter, selectedSubtype);
  }

  final List<int> _selectionHistory = [];

  void previousPlace() {
    while (_selectionHistory.isNotEmpty) {
      final index = _selectionHistory.removeLast();
      if (index >= 0 && index < mapPlaces.length) {
        selectPlace(mapPlaces[index], keepHistory: true);
        return;
      }
    }
  }

  void nextPlace() {
    final current = validSelectedIndex;
    if (current == null) return;
    final candidates = [
      for (var i = 0; i < mapPlaces.length; i++)
        if (i != current &&
            !_selectionHistory.contains(i) &&
            isVisible(mapPlaces[i]))
          i,
    ];
    if (candidates.isEmpty) return;
    double distance(int i) => NearbyPlacesService.calculateDistanceKm(
        mapPlaces[current].latitude!,
        mapPlaces[current].longitude!,
        mapPlaces[i].latitude!,
        mapPlaces[i].longitude!);
    candidates.sort((a, b) => distance(a).compareTo(distance(b)));
    _selectionHistory.add(current);
    selectPlace(mapPlaces[candidates.first], keepHistory: true);
  }

  bool get hasNextPlace =>
      validSelectedIndex != null &&
      mapPlaces.asMap().entries.any((entry) =>
          entry.key != validSelectedIndex &&
          !_selectionHistory.contains(entry.key) &&
          isVisible(entry.value));

  void selectPlace(Place place, {bool keepHistory = false}) {
    if (!place.hasCoordinates) return;
    var index = mapPlaces.indexWhere((item) =>
        item.name == place.name &&
        item.latitude == place.latitude &&
        item.longitude == place.longitude);
    if (index < 0) {
      _searchFocusedPlace = place;
      _mapPlaces = buildMapPlaces();
      index = mapPlaces.indexWhere((item) =>
          item.name == place.name &&
          item.latitude == place.latitude &&
          item.longitude == place.longitude);
    }
    if (index < 0) return;
    setState(() {
      if (!keepHistory) _selectionHistory.clear();
      selectedIndex = index;
      _clusterCache = null;
    });
    mapController.move(
        coordinateFor(index), math.max(mapController.camera.zoom, 12.0),
        offset: const Offset(0, -100));
  }

  void handleMapPositionChanged(MapCamera camera, bool hasGesture) {
    final currentSelection = validSelectedIndex;
    final nextZoomBucket = (camera.zoom * 2).round() / 2;
    final currentZoomBucket = (_mapZoom * 2).round() / 2;
    final shouldClearSelection = hasGesture &&
        currentSelection != null &&
        !isPlaceMeaningfullyNearViewport(
          coordinateFor(currentSelection),
          camera.visibleBounds,
        );
    if (shouldClearSelection) {
      setState(() {
        selectedIndex = null;
        _selectionHistory.clear();
        _clusterCache = null;
      });
    }
    if (!hasGesture &&
        _visibleBounds != null &&
        nextZoomBucket == currentZoomBucket) {
      return;
    }
    _pendingVisibleBounds = camera.visibleBounds;
    _cameraUpdateTimer?.cancel();
    _cameraUpdateTimer = Timer(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      final shouldLoadInitial = MapViewportPointsService.enabled &&
          !MapViewportPointsService.regionalExplorerEnabled &&
          _viewportPlaces == null &&
          !hasGesture;
      setState(() {
        _mapZoom = camera.zoom;
        _visibleBounds = _pendingVisibleBounds;
        if (hasGesture &&
            MapViewportPointsService.enabled &&
            (!_isAllRegionsMode ||
                !MapViewportPointsService.regionalExplorerEnabled)) {
          _viewportNeedsSearch = true;
        }
        _clusterCache = null;
        _mapPlaces = buildMapPlaces();
      });
      if (shouldLoadInitial) unawaited(_loadViewportPoints());
    });
  }

  void openCluster(_MapCluster cluster) {
    setState(() {
      selectedIndex = null;
      _selectionHistory.clear();
      _clusterCache = null;
    });
    final nextZoom = math.min(_mapZoom + 2, 18).toDouble();
    mapController.move(cluster.center, nextZoom);
  }

  Future<void> searchPlace() async {
    final result = await showSearch<Place?>(
      context: context,
      delegate: _MapPlaceSearchDelegate(
        category: selectedFilter,
        subtype: selectedSubtype,
      ),
    );
    if (result != null && mounted) selectPlace(result);
  }

  void _selectMapFilter(String filterKey) {
    setState(() {
      selectedFilter = filterKey;
      selectedSubtype = null;
      selectedIndex = null;
      _selectionHistory.clear();
      _clusterCache = null;
      _viewportNeedsSearch = true;
      _mapPlaces = buildMapPlaces();
    });
    if (!MapViewportPointsService.regionalExplorerEnabled || _hasOpenedRegion) {
      unawaited(_loadViewportPoints(userInitiated: true));
    }
  }

  void _toggleAllRegionsMode() {
    final enableAllRegions = !_isAllRegionsMode;
    setState(() {
      _isAllRegionsMode = enableAllRegions;
      _hasOpenedRegion = false;
      _viewportPlaces = null;
      _viewportNeedsSearch = false;
      _viewportError = null;
      selectedFilter = 'Tümü';
      selectedSubtype = null;
      selectedIndex = null;
      _selectionHistory.clear();
      _clusterCache = null;
      _mapPlaces = buildMapPlaces();
    });
    if (enableAllRegions) {
      // Genel görünüm eski bölgenin sınırını kullanmaz; ülke çerçevesine
      // dönerek kümelerin tek bir yerde toplanmasını engeller.
      mapController.move(initialCenter, initialZoom);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_isAllRegionsMode) return;
        setState(() {
          _visibleBounds = mapController.camera.visibleBounds;
          _mapZoom = mapController.camera.zoom;
          _clusterCache = null;
          _mapPlaces = buildMapPlaces();
        });
      });
    }
  }

  void zoom(double factor) {
    final camera = mapController.camera;
    final nextZoom =
        (camera.zoom + (factor > 1 ? 1 : -1)).clamp(4.0, 18.0).toDouble();
    mapController.move(camera.center, nextZoom);
  }

  LatLng? get userCoordinate {
    if (_liveUserCoordinate != null) return _liveUserCoordinate;
    final target = HomeWeatherLocationController.current.value;
    if (!target.usesCoordinates ||
        HomeWeatherLocationController.isApproximateLocation.value) {
      return null;
    }
    return LatLng(target.latitude!, target.longitude!);
  }

  Future<void> centerOnUserLocation() async {
    try {
      final coordinates =
          await HomeWeatherLocationController.requestAndUseDeviceLocation();
      if (coordinates.isApproximate) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Bilgisayar kesin konumu veremedi. Yaklaşık konum haritada işaretlenmedi.',
          ),
        ));
        return;
      }
      _liveUserCoordinate = LatLng(
        coordinates.latitude,
        coordinates.longitude,
      );
      mapController.move(_liveUserCoordinate!, 12.8);
      unawaited(_startLiveLocation());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Konumun alınamadı. Konum iznini kontrol et.'),
      ));
    }
  }

  Widget mapControl({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) =>
      GlassIconButton(
        icon: icon,
        tooltip: tooltip,
        onTap: onTap,
        size: 43,
        iconSize: 20,
        iconColor: green,
        blur: 0,
        color: Colors.white.withValues(alpha: 0.82),
        borderColor: Colors.white.withValues(alpha: 0.90),
        borderWidth: 1.2,
        borderRadius: BorderRadius.circular(AppRadii.medium),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow08,
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      );

  void showOfflineMapInfo() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 4, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Çevrimdışı harita',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: AppFontSizes.heading,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Haritada görüntülediğin bölgeler cihazına otomatik kaydedilir. '
                'İnternet olmadığında kaydedilmiş harita parçaları, yerler ve '
                'kendi eklediğin noktalar görünmeye devam eder.',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: AppColors.textSecondary,
                  fontSize: AppFontSizes.label,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLayerPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.get('map_layer_title'),
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: AppFontSizes.title,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.get('map_layer_desc'),
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: AppFontSizes.caption,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildLayerOption(
                        style: _MapStyle.standart,
                        title: AppStrings.get('map_standard'),
                        subtitle: 'OpenStreetMap',
                        icon: Icons.map_outlined,
                        isDark: isDark,
                        onTap: () {
                          setState(() => _mapStyle = _MapStyle.standart);
                          setSheetState(() {});
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildLayerOption(
                        style: _MapStyle.uydu,
                        title: AppStrings.get('map_satellite'),
                        subtitle: 'Esri World',
                        icon: Icons.satellite_alt_rounded,
                        isDark: isDark,
                        onTap: () {
                          setState(() => _mapStyle = _MapStyle.uydu);
                          setSheetState(() {});
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildLayerOption(
                        style: _MapStyle.topo,
                        title: AppStrings.get('map_topo'),
                        subtitle: AppStrings.get('map_topo_subtitle'),
                        icon: Icons.terrain_rounded,
                        isDark: isDark,
                        onTap: () {
                          setState(() => _mapStyle = _MapStyle.topo);
                          setSheetState(() {});
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLayerOption({
    required _MapStyle style,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = _mapStyle == style;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.large),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkPrimarySoft : AppColors.primarySoft)
                : (isDark
                    ? AppColors.darkSurfaceMuted
                    : AppColors.surfaceMuted),
            borderRadius: BorderRadius.circular(AppRadii.large),
            border: Border.all(
              color: isSelected
                  ? green
                  : (isDark ? AppColors.darkBorder : AppColors.border),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 26,
                color: isSelected
                    ? green
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: AppFontSizes.caption,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? AppColors.darkPrimaryLight : green)
                      : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: AppFontSizes.caption,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigationVisibility = widget.bottomNavigationVisible;
    if (navigationVisibility == null) {
      return _buildMapPage(context, bottomNavigationVisible: false);
    }
    return ValueListenableBuilder<bool>(
      valueListenable: navigationVisibility,
      builder: (context, bottomNavigationVisible, _) => _buildMapPage(
        context,
        bottomNavigationVisible: bottomNavigationVisible,
      ),
    );
  }

  Widget _buildMapPage(
    BuildContext context, {
    required bool bottomNavigationVisible,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mapBottomInset = bottomNavigationVisible ? 96.0 : 18.0;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscapeTablet =
              constraints.maxWidth >= AppBreakpoints.tabletLandscapeMin;
          final isPortraitTablet = !isLandscapeTablet &&
              constraints.maxWidth >= AppBreakpoints.tabletPortraitMin;

          if (isLandscapeTablet) {
            return _buildLandscapeLayout(
              context,
              constraints,
              isDark,
              mapBottomInset: mapBottomInset,
            );
          }
          return _buildStandardMapLayout(
            context,
            constraints,
            isDark,
            isTablet: isPortraitTablet,
            mapBottomInset: mapBottomInset,
          );
        },
      ),
    );
  }

  Widget _buildFlutterMap(bool isDark) {
    final selectedPlace = selectedMapPlace;
    // Bölgesel keşifte uzak ölçekte sayısız tür kümeleri, yakın ölçekte
    // tekil pinler kullanılır. Bu, haritayı hem okunur hem seçilebilir tutar.
    final renderAsIndividualPins =
        MapViewportPointsService.regionalExplorerEnabled &&
            _hasOpenedRegion &&
            !_isAllRegionsMode &&
            _mapZoom >= MapViewportPointsService.compactPinsMinZoom;
    final useClusterMarkers = !renderAsIndividualPins &&
        _mapZoom < MapViewportPointsService.amenityMinZoom;
    return RepaintBoundary(
      child: Listener(
        onPointerDown: (_) => widget.onUserInteraction?.call(),
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: initialZoom,
            minZoom: 4,
            maxZoom: 18,
            cameraConstraint: CameraConstraint.containLatitude(),
            onMapReady: _applyPendingRegionFocus,
            onPositionChanged: handleMapPositionChanged,
            onTap: (_, __) {
              if (selectedIndex != null) {
                setState(() {
                  selectedIndex = null;
                  _selectionHistory.clear();
                  _clusterCache = null;
                });
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: switch (_mapStyle) {
                _MapStyle.standart =>
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                _MapStyle.uydu =>
                  'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                _MapStyle.topo =>
                  'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
              },
              subdomains: _mapStyle == _MapStyle.topo
                  ? const ['a', 'b', 'c']
                  : const ['a'],
              userAgentPackageName: 'com.dogadagezi.dogada_gezi',
              maxNativeZoom: _mapStyle == _MapStyle.topo ? 17 : 19,
              panBuffer: 2,
              tileProvider: tileProvider,
            ),
            MarkerLayer(
              markers: [
                if (userCoordinate != null)
                  Marker(
                    point: userCoordinate!,
                    width: 54,
                    height: 54,
                    child: const _UserLocationMarker(),
                  ),
              ],
            ),
            MarkerLayer(
              markers: markerClusters.map((cluster) {
                if (useClusterMarkers && cluster.placeIndexes.length > 1) {
                  final count = cluster.placeIndexes.length;
                  final markerWidth =
                      count >= 1000 ? 76.0 : (count >= 100 ? 68.0 : 60.0);
                  return Marker(
                    point: cluster.center,
                    width: markerWidth,
                    height: AppControlSizes.minimumTouchTarget,
                    alignment: Alignment.center,
                    child: _MapClusterMarker(
                      cluster: cluster,
                      showCount: false,
                      onTap: () => openCluster(cluster),
                    ),
                  );
                }
                final index = cluster.placeIndexes.single;
                final selected = selectedIndex == index;
                final showLabel = _mapZoom >= 11.5;
                return Marker(
                  point: cluster.center,
                  width: selected ? 130 : (showLabel ? 96 : 52),
                  height: selected ? 74 : (showLabel ? 52 : 46),
                  alignment: Alignment.bottomCenter,
                  child: _MapMarker(
                    place: mapPlaces[index],
                    selected: selected,
                    showLabel: showLabel,
                    sizeScale: _markerScaleForZoom(_mapZoom),
                    onTap: () => selectPlace(mapPlaces[index]),
                  ),
                );
              }).toList(growable: false),
            ),
            if (selectedPlace != null)
              MarkerLayer(markers: [
                Marker(
                  point: coordinateFor(validSelectedIndex!),
                  width: 130,
                  height: 74,
                  alignment: Alignment.bottomCenter,
                  child: _MapMarker(
                    place: selectedPlace,
                    selected: true,
                    showLabel: true,
                    sizeScale: _markerScaleForZoom(_mapZoom),
                    onTap: () => selectPlace(selectedPlace),
                  ),
                )
              ]),
          ],
        ),
      ),
    );
  }

  Widget _buildAttribution(bool isDark) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(AppRadii.medium),
      blur: 0,
      color: AppColors.surface,
      borderColor: AppColors.border,
      boxShadow: const [],
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      child: Text(
        switch (_mapStyle) {
          _MapStyle.standart => '© OpenStreetMap contributors',
          _MapStyle.uydu => '© Esri, Maxar, Earthstar',
          _MapStyle.topo => '© OpenTopoMap, OSM contributors',
        },
        style: TextStyle(
          fontFamily: 'Outfit',
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          fontSize: AppFontSizes.caption,
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(AppRadii.large),
      blur: 8,
      color: AppColors.surface,
      darkColor: AppColors.darkGlass,
      borderColor: AppColors.border,
      darkBorderColor: Colors.white.withValues(alpha: 0.14),
      borderWidth: 1.2,
      boxShadow: [
        BoxShadow(
          color: isDark ? AppColors.shadow33 : AppColors.shadow08,
          blurRadius: 18,
          offset: const Offset(0, 4),
        ),
      ],
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: searchPlace,
          borderRadius: BorderRadius.circular(AppRadii.large),
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.search_rounded,
                  color: isDark ? AppColors.darkPrimaryLight : green,
                  size: 21,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedFilter == 'Tümü' || selectedFilter == 'all'
                        ? AppStrings.get('map_search_places')
                        : ' ',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textSecondary,
                      fontSize: AppFontSizes.label,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Semantics(
                  label: 'Harita filtreleri',
                  child: Icon(
                    Icons.tune_rounded,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(bool isDark) {
    return SizedBox(
      height: 44,
      child: ScrollConfiguration(
        behavior: const _MapCategoryScrollBehavior(),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: _mapCategories.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 7),
          itemBuilder: (_, index) {
            if (index == 0) {
              return _MapLocationChip(
                label: HomeWeatherLocationController.current.value.label,
                onTap: centerOnUserLocation,
              );
            }
            final category = _mapCategories[index - 1];
            final selected = selectedFilter == category.label ||
                selectedFilter == category.key;
            final chipContent = Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(
                  color: selected ? green : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _mapIconForCategory(category.key),
                    size: 16,
                    color: selected
                        ? Colors.white
                        : (isDark
                            ? AppColors.darkPrimaryLight
                            : AppColors.primary),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category.localizedLabel,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: selected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextPrimary : ink),
                      fontSize: AppFontSizes.caption,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );

            if (selected) {
              return GlassContainer(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                blur: 0,
                color: green,
                darkColor: AppColors.darkPrimary.withValues(alpha: 0.95),
                borderColor: green,
                borderWidth: 1.2,
                boxShadow: const [],
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectMapFilter(category.key),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: chipContent,
                  ),
                ),
              );
            }

            return GlassContainer(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              blur: 0,
              color: AppColors.surface,
              borderColor: AppColors.border,
              borderWidth: 1,
              boxShadow: const [],
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _selectMapFilter(category.key),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: chipContent,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget? _buildSubtypeRow(bool isDark) {
    final cat = placeCategoryByKey(
      _mapCategories
          .firstWhere(
            (item) =>
                item.key == selectedFilter || item.label == selectedFilter,
            orElse: () => _mapCategories.first,
          )
          .key,
    );
    if (cat == null || cat.subtypes.length <= 1) return null;

    return SizedBox(
      height: 36,
      child: ScrollConfiguration(
        behavior: const _MapCategoryScrollBehavior(),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: cat.subtypes.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 7),
          itemBuilder: (_, index) {
            final subtype = index == 0 ? null : cat.subtypes[index - 1];
            final isSelected = selectedSubtype == subtype?.key;
            return GlassContainer(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              blur: 0,
              color: isSelected ? green : AppColors.surface,
              darkColor: isSelected
                  ? AppColors.darkPrimary.withValues(alpha: 0.95)
                  : AppColors.darkSurfaceMuted.withValues(alpha: 0.90),
              borderColor: isSelected ? green : AppColors.border,
              darkBorderColor: isSelected
                  ? Colors.white.withValues(alpha: 0.30)
                  : Colors.white.withValues(alpha: 0.14),
              borderWidth: 1,
              boxShadow: const [],
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() {
                    selectedSubtype = isSelected ? null : subtype?.key;
                    selectedIndex = null;
                    _selectionHistory.clear();
                    _clusterCache = null;
                  }),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      subtype?.localizedLabel ?? AppStrings.get('all'),
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: AppFontSizes.caption,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.darkTextPrimary : ink),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapControls(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mapControl(
          icon: Icons.my_location_rounded,
          tooltip: 'Konumum',
          onTap: centerOnUserLocation,
        ),
        const SizedBox(height: 8),
        mapControl(
          icon: Icons.layers_rounded,
          tooltip: 'Harita Stili',
          onTap: _showLayerPicker,
        ),
        const SizedBox(height: 8),
        GlassIconButton(
          icon: Icons.warning_amber_rounded,
          tooltip: 'Yardım çağrıları',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const EmergencyHelpMapScreen(),
            ),
          ),
          size: 43,
          iconSize: 20,
          iconColor: AppColors.error,
          blur: 0,
          color: Colors.white.withValues(alpha: 0.82),
          borderColor: AppColors.error.withValues(alpha: 0.35),
          borderWidth: 1.2,
          borderRadius: BorderRadius.circular(AppRadii.medium),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow08,
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        const SizedBox(height: 8),
        mapControl(
          icon: Icons.offline_pin_outlined,
          tooltip: 'Çevrimdışı harita',
          onTap: showOfflineMapInfo,
        ),
      ],
    );
  }

  Widget _buildServiceFloatingButton(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final selected = await Navigator.push<String?>(
            context,
            MaterialPageRoute(
              builder: (_) => const MobileServiceHubScreen(),
            ),
          );
          if (selected != null && mounted) {
            setState(() {
              selectedFilter = 'local_service';
              selectedSubtype = selected;
              _mapPlaces = buildMapPlaces();
              selectedIndex = null;
              _selectionHistory.clear();
              _clusterCache = null;
            });
            final matching = mapPlaces
                .where(
                  (p) =>
                      p.isMobileService &&
                      (selected == 'service_roadside' ||
                          p.resolvedTaxonomy.subtype == selected),
                )
                .toList();
            if (matching.isNotEmpty && matching.first.hasCoordinates) {
              mapController.move(
                LatLng(matching.first.latitude!, matching.first.longitude!),
                13,
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 7, 8, 7),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFE89F2A),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD97706).withValues(alpha: 0.22),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Servis',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFFFDE68A)
                      : const Color(0xFF8B4D08),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.handyman_rounded,
                  color: Color(0xFFD97706),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverySheet(Place selectedPlace, double sheetHeight) {
    return _MapDiscoverySheet(
      place: selectedPlace,
      onClose: () => setState(() {
        selectedIndex = null;
        _clusterCache = null;
        _selectionHistory.clear();
      }),
      onPrevious: _selectionHistory.isEmpty ? null : previousPlace,
      onNext: hasNextPlace ? nextPlace : null,
      onOpen: widget.onOpen,
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    BoxConstraints constraints,
    bool isDark, {
    required double mapBottomInset,
  }) {
    final selectedPlace = selectedMapPlace;
    final visiblePlaces = mapPlaces.where(isVisible).toList(growable: false);

    return Row(
      children: [
        // Sol %68: Harita
        Expanded(
          flex: 68,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRect(
                  child: ColoredBox(
                    color:
                        isDark ? AppColors.darkSurface : AppColors.surfaceMuted,
                    child: _buildFlutterMap(isDark),
                  ),
                ),
              ),
              if (MapViewportPointsService.enabled)
                Positioned(
                  top: MapViewportPointsService.regionalExplorerEnabled
                      ? 12
                      : 124,
                  left: 0,
                  right: 0,
                  child: Center(child: _buildSearchThisAreaButton(isDark)),
                ),
              Positioned(
                left: 12,
                bottom: mapBottomInset,
                child: _buildAttribution(isDark),
              ),
              Positioned(
                right: 14,
                bottom: mapBottomInset,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildMapControls(context, isDark),
                    const SizedBox(height: 10),
                    _buildServiceFloatingButton(context, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Ayrım çizgisi
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        // Sağ %32: Arama, filtreler, seçili yer kartı ve yakın yer listesi
        Expanded(
          flex: 32,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: _buildSearchBar(isDark),
                ),
                if (!MapViewportPointsService.regionalExplorerEnabled) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _buildCategoryRow(isDark),
                  ),
                  if (_buildSubtypeRow(isDark) case final subtypeWidget?)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                      child: subtypeWidget,
                    ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                    child: _buildMapModeControl(isDark),
                  ),
                  if (_hasOpenedRegion && !_isAllRegionsMode) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _buildCategoryRow(isDark),
                    ),
                    if (_buildSubtypeRow(isDark) case final subtypeWidget?)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                        child: subtypeWidget,
                      ),
                  ],
                ],
                const SizedBox(height: 8),
                if (selectedPlace != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      height: 248,
                      child: _buildDiscoverySheet(selectedPlace, 248),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.explore_outlined,
                        size: 16,
                        color: isDark
                            ? AppColors.darkPrimaryLight
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Keşif Noktaları ()',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: AppFontSizes.caption,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: visiblePlaces.isEmpty
                      ? Center(
                          child: Text(
                            'Bu filtreye uygun yer bulunamadı.',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: AppFontSizes.label,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                          itemCount: visiblePlaces.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final place = visiblePlaces[index];
                            final isCardSelected = selectedPlace == place;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.large),
                                border: isCardSelected
                                    ? Border.all(
                                        color:
                                            AppColors.accentOrangeOf(context),
                                        width: 1.8,
                                      )
                                    : null,
                              ),
                              child: AppCompactPlaceCard(
                                place: place,
                                onTap: () => selectPlace(place),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchThisAreaButton(bool isDark) {
    final usesRegionalExplorer =
        MapViewportPointsService.regionalExplorerEnabled;
    final isOpeningFirstRegion = usesRegionalExplorer && !_hasOpenedRegion;
    final shouldShow = MapViewportPointsService.enabled &&
        !_isAllRegionsMode &&
        (isOpeningFirstRegion ||
            _viewportNeedsSearch ||
            _isViewportLoading ||
            _viewportError != null);
    if (!shouldShow) return const SizedBox.shrink();
    final retry = _viewportError != null;
    final label = retry
        ? 'Bu alanı tekrar yükle'
        : isOpeningFirstRegion
            ? 'Bu bölgeyi aç'
            : 'Bu alanda ara';
    return Semantics(
      button: true,
      label: label,
      child: FilledButton.icon(
        onPressed: _isViewportLoading
            ? null
            : () => unawaited(_loadViewportPoints(userInitiated: true)),
        icon: _isViewportLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(retry ? Icons.refresh_rounded : Icons.search_rounded),
        label: Text(retry
            ? 'Tekrar dene'
            : isOpeningFirstRegion
                ? 'Bu bölgeyi aç'
                : 'Bu alanda ara'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(164, AppControlSizes.minimumTouchTarget),
          backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          elevation: 3,
          shadowColor: AppColors.shadow33,
          shape: const StadiumBorder(),
        ),
      ),
    );
  }

  Widget _buildMapModeControl(bool isDark) {
    final allRegions = _isAllRegionsMode;
    final label = allRegions ? 'Bölge görünümüne dön' : 'Tüm bölgeleri aç';
    return Semantics(
      button: true,
      label: label,
      child: OutlinedButton.icon(
        onPressed: _toggleAllRegionsMode,
        icon: Icon(
          allRegions ? Icons.map_outlined : Icons.public_rounded,
          size: 18,
        ),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppControlSizes.minimumTouchTarget),
          foregroundColor:
              isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          elevation: 2,
          shadowColor: AppColors.shadow33,
          shape: const StadiumBorder(),
        ),
      ),
    );
  }

  Widget _buildStandardMapLayout(
    BuildContext context,
    BoxConstraints constraints,
    bool isDark, {
    required bool isTablet,
    required double mapBottomInset,
  }) {
    final selectedPlace = selectedMapPlace;
    final sheetHeight = selectedPlace == null ? 0.0 : 248.0;
    final showRegionalFilters =
        MapViewportPointsService.regionalExplorerEnabled &&
            _hasOpenedRegion &&
            !_isAllRegionsMode;

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRect(
            child: ColoredBox(
              color: isDark ? AppColors.darkSurface : AppColors.surfaceMuted,
              child: _buildFlutterMap(isDark),
            ),
          ),
        ),
        Positioned(
          left: 8,
          bottom: sheetHeight == 0
              ? mapBottomInset
              : sheetHeight + mapBottomInset + 12,
          child: _buildAttribution(isDark),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 12,
          child: isTablet
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: _buildSearchBar(isDark),
                  ),
                )
              : _buildSearchBar(isDark),
        ),
        Positioned(
          left: 12,
          right: 12,
          top: 72,
          child: MapViewportPointsService.regionalExplorerEnabled
              ? Center(child: _buildMapModeControl(isDark))
              : (isTablet
                  ? Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: _buildCategoryRow(isDark),
                      ),
                    )
                  : _buildCategoryRow(isDark)),
        ),
        if (showRegionalFilters)
          Positioned(
            left: 12,
            right: 12,
            top: 124,
            child: isTablet
                ? Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: _buildCategoryRow(isDark),
                    ),
                  )
                : _buildCategoryRow(isDark),
          ),
        if (!MapViewportPointsService.regionalExplorerEnabled ||
            showRegionalFilters)
          if (_buildSubtypeRow(isDark) case final subtypeWidget?)
            Positioned(
              left: 12,
              right: 12,
              top: showRegionalFilters ? 171 : 119,
              child: isTablet
                  ? Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: subtypeWidget,
                      ),
                    )
                  : subtypeWidget,
            ),
        if (MapViewportPointsService.enabled)
          Positioned(
            top: MapViewportPointsService.regionalExplorerEnabled
                ? (showRegionalFilters
                    ? (_buildSubtypeRow(isDark) == null ? 172 : 216)
                    : 124)
                : (_buildSubtypeRow(isDark) == null ? 124 : 168),
            left: 0,
            right: 0,
            child: Center(child: _buildSearchThisAreaButton(isDark)),
          ),
        Positioned(
          right: 14,
          bottom: sheetHeight == 0
              ? mapBottomInset
              : sheetHeight + mapBottomInset + 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMapControls(context, isDark),
              const SizedBox(height: 10),
              _buildServiceFloatingButton(context, isDark),
            ],
          ),
        ),
        if (selectedPlace != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: mapBottomInset,
            height: sheetHeight,
            child: isTablet
                ? Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: _buildDiscoverySheet(selectedPlace, sheetHeight),
                    ),
                  )
                : _buildDiscoverySheet(selectedPlace, sheetHeight),
          ),
      ],
    );
  }
}

class _MapLocationChip extends StatelessWidget {
  const _MapLocationChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: 'Konumuma dön',
      child: GlassContainer(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        blur: 0,
        color: AppColors.surface,
        darkColor: AppColors.darkGlass,
        borderColor: AppColors.border,
        darkBorderColor: Colors.white.withValues(alpha: 0.14),
        borderWidth: 1,
        boxShadow: const [],
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: Container(
              height: 40,
              constraints: const BoxConstraints(maxWidth: 178),
              padding: const EdgeInsets.symmetric(horizontal: 11),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_rounded,
                      color: isDark
                          ? AppColors.darkPrimaryLight
                          : AppColors.primary,
                      size: 16),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.metadataOf(context).copyWith(
                        color: AppColors.textPrimaryOf(context),
                        fontSize: AppFontSizes.caption,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      size: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapDiscoverySheet extends StatelessWidget {
  const _MapDiscoverySheet({
    required this.place,
    required this.onOpen,
    required this.onClose,
    required this.onPrevious,
    required this.onNext,
  });
  final Place place;
  final ValueChanged<Place> onOpen;
  final VoidCallback onClose;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      blur: 0,
      color: AppColors.surface,
      darkColor: AppColors.darkGlass,
      border: Border(
        top: BorderSide(
          color:
              isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.border,
          width: 1,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? AppColors.shadow80 : AppColors.shadow08,
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ],
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
          const SizedBox(height: 4),
          Row(children: [
            IconButton(
                tooltip: AppStrings.get('map_prev_place'),
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left_rounded)),
            Expanded(
                child: Text(AppStrings.get('map_selected_place'),
                    style: TextStyle(
                        color: AppColors.accentOrangeOf(context),
                        fontWeight: FontWeight.w600))),
            IconButton(
                tooltip: AppStrings.get('map_next_place'),
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right_rounded)),
            IconButton(
                tooltip: AppStrings.get('map_close_card'),
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded)),
          ]),
          const AppSectionDivider(),
          const SizedBox(height: 8),
          AppMapPreviewCard(
            place: place,
            onTap: () => onOpen(place),
            prominent: false,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: FilledButton.icon(
              onPressed: () => onOpen(place),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text(
                AppStrings.get('map_view_details'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSizes.caption,
                ),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                backgroundColor:
                    isDark ? AppColors.darkPrimary : AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.categoryWater,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: const [
              BoxShadow(color: AppColors.shadow33, blurRadius: 8),
            ],
          ),
        ),
      );
}

class _MapCategoryScrollBehavior extends MaterialScrollBehavior {
  const _MapCategoryScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        ...super.dragDevices,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class _MapClusterMarker extends StatelessWidget {
  const _MapClusterMarker({
    required this.cluster,
    required this.onTap,
    this.showCount = true,
  });

  final _MapCluster cluster;
  final VoidCallback onTap;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    final count = cluster.placeIndexes.length;
    final category = cluster.dominantCategory;
    // Uzakta karma noktalar sade bir küme olarak kalır. Aynı kategori baskınsa
    // kümenin rengi de simgesiyle eşleşir; yaklaştıkça tekil ikonlara geçilir.
    final markerColor = category == null
        ? AppColors.clusterMarker
        : _markerColorForCategory(
            category,
            category,
            isUtility: isUtilitySubtype(category),
          );
    final semanticLabel = category == null
        ? '$count doğa noktası'
        : '$count ${_mapCategoryLabel(category)} noktası';
    return Semantics(
      label: semanticLabel,
      button: true,
      container: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: markerColor,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.clusterMarkerShadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: !showCount
              ? Icon(
                  category == null
                      ? Icons.explore_rounded
                      : _mapIconForCategory(category),
                  size: 17,
                  color: Colors.white,
                )
              : category == null
                  ? Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppFontSizes.label,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _mapIconForCategory(category),
                          size: 15,
                          color: Colors.white,
                        ),
                        Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

String _mapCategoryLabel(String key) {
  if (isUtilitySubtype(key)) return AppStrings.subtype(key);
  for (final category in _mapCategories) {
    if (category.key == key) return category.localizedLabel;
  }
  return AppStrings.get('all');
}

// A consistent rounded-stroke pictogram family for landforms absent from
// Material Icons (waterfall_chart is a chart, not a natural waterfall).
class _MapPlaceSymbol extends StatelessWidget {
  const _MapPlaceSymbol(
      {required this.place, required this.color, required this.size});
  final Place place;
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) {
    final subtype = place.resolvedTaxonomy.subtype;
    if (const [
      'waterfall',
      'canyon',
      'mountain',
      'peak',
      'camp_site',
      'water_fountain',
      'drinking_water',
      'viewpoint',
      'sunset_viewpoint'
    ].contains(subtype)) {
      return CustomPaint(
          size: Size.square(size), painter: _LandmarkPainter(subtype!, color));
    }
    return Icon(_mapIconForPlace(place), color: color, size: size);
  }
}

class _LandmarkPainter extends CustomPainter {
  const _LandmarkPainter(this.kind, this.color);
  final String kind;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final pen = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    void line(List<Offset> points) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, pen);
    }

    switch (kind) {
      case 'waterfall':
        line(const [Offset(2, 5), Offset(8, 5), Offset(8, 15)]);
        line(const [Offset(12, 4), Offset(12, 17)]);
        line(const [Offset(16, 5), Offset(16, 15)]);
        line(const [Offset(16, 5), Offset(21, 5)]);
        canvas.drawPath(
            Path()
              ..moveTo(3, 19)
              ..quadraticBezierTo(6, 16, 9, 19)
              ..quadraticBezierTo(12, 22, 15, 19)
              ..quadraticBezierTo(18, 16, 21, 19),
            pen);
      case 'canyon':
        line(const [
          Offset(2, 3),
          Offset(7, 7),
          Offset(5, 12),
          Offset(9, 17),
          Offset(9, 21)
        ]);
        line(const [
          Offset(22, 3),
          Offset(17, 7),
          Offset(19, 12),
          Offset(15, 17),
          Offset(15, 21)
        ]);
        line(const [
          Offset(12, 9),
          Offset(11, 13),
          Offset(13, 17),
          Offset(12, 22)
        ]);
      case 'mountain':
      case 'peak':
        line(const [
          Offset(2, 21),
          Offset(12, 3),
          Offset(22, 21),
          Offset(2, 21)
        ]);
        line(const [
          Offset(8, 10),
          Offset(11, 12),
          Offset(13, 9),
          Offset(16, 11)
        ]);
      case 'camp_site':
        line(const [
          Offset(2, 21),
          Offset(12, 4),
          Offset(22, 21),
          Offset(2, 21)
        ]);
        line(const [Offset(7, 21), Offset(12, 12), Offset(17, 21)]);
        line(const [Offset(10, 2), Offset(14, 7)]);
      case 'water_fountain':
      case 'drinking_water':
        line(const [
          Offset(3, 11),
          Offset(3, 7),
          Offset(15, 7),
          Offset(18, 10),
          Offset(18, 12)
        ]);
        line(const [Offset(9, 7), Offset(9, 3)]);
        line(const [Offset(6, 3), Offset(12, 3)]);
        canvas.drawPath(
            Path()
              ..moveTo(18, 15)
              ..quadraticBezierTo(13, 21, 18, 21)
              ..quadraticBezierTo(23, 21, 18, 15),
            pen);
      case 'viewpoint':
      case 'sunset_viewpoint':
        canvas.drawCircle(const Offset(6, 16), 4, pen);
        canvas.drawCircle(const Offset(18, 16), 4, pen);
        line(const [Offset(2, 15), Offset(5, 5), Offset(8, 5), Offset(10, 15)]);
        line(const [
          Offset(14, 15),
          Offset(16, 5),
          Offset(19, 5),
          Offset(22, 15)
        ]);
        line(const [Offset(10, 12), Offset(14, 12)]);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LandmarkPainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.color != color;
}

/// Uzakta noktalar fark edilsin; yaklaştıkça daha çok nokta üst üste
/// binmeden seçilebilsin. Ölçek ekran pikselinde kasıtlı olarak ters yönde
/// değişir; P4N'deki keşif davranışını takip eder.
double _markerScaleForZoom(double zoom) {
  if (zoom <= 7) return 1.10;
  if (zoom <= 9) return .93;
  if (zoom <= 11) return .82;
  return .70;
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.place,
    required this.selected,
    required this.onTap,
    this.showLabel = false,
    this.sizeScale = 1,
  });

  final Place place;
  final bool selected;
  final VoidCallback onTap;
  final bool showLabel;
  final double sizeScale;

  @override
  Widget build(BuildContext context) {
    final isUtility = isUtilitySubtype(place.resolvedTaxonomy.subtype);
    final taxonomy = place.resolvedTaxonomy;
    // Kategoriye göre renk
    final catColor = _markerColorForCategory(
      taxonomy.mainCategory,
      taxonomy.subtype,
      isUtility: isUtility,
    );
    final markerSize = (isUtility ? 20.0 : 27.0) * sizeScale;
    final symbolSize = (isUtility ? 10.0 : 13.0) * sizeScale;

    return Semantics(
      label: 'Haritada ${place.name}',
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Yer adı etiketi (zoom ≥ 13 veya seçili)
            if (showLabel || selected)
              Container(
                constraints: const BoxConstraints(maxWidth: 100),
                margin: const EdgeInsets.only(bottom: 3),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow20,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  place.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: AppFontSizes.caption,
                    fontWeight: FontWeight.w600,
                    color: selected ? catColor : AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),

            // Marker dairesi
            AnimatedScale(
              duration: const Duration(milliseconds: 180),
              scale: selected ? 1.18 : 1.0,
              child: selected
                  ? Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 46,
                          color: catColor,
                          shadows: const [
                            Shadow(color: AppColors.shadow33, blurRadius: 8),
                          ],
                        ),
                        Positioned(
                          top: 4,
                          child: Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: catColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: _MapPlaceSymbol(
                                place: place, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      width: markerSize,
                      height: markerSize,
                      decoration: BoxDecoration(
                        color: isUtility ? Colors.white : catColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isUtility ? catColor : Colors.white,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: _MapPlaceSymbol(
                        place: place,
                        color: isUtility ? catColor : Colors.white,
                        size: symbolSize,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _markerColorForCategory(
  String? mainCategory,
  String? subtype, {
  bool isUtility = false,
}) {
  if (isUtility) return AppColors.categoryUtility;
  if (mainCategory == 'local_service') return const Color(0xFFD97706);
  return switch (mainCategory) {
    'lake' || 'waterfall' => AppColors.categoryWater,
    'canyon_valley' || 'cave' => AppColors.categoryFormation,
    'national_park' => AppColors.categoryNature,
    'camp' || 'caravan' => AppColors.categoryCamp,
    _ => AppColors.clusterMarker,
  };
}

IconData _mapIconForCategory(String key) => switch (key) {
      'all' => Icons.explore_rounded,
      'camp' => Icons.cabin_rounded,
      'caravan' => Icons.rv_hookup_rounded,
      'lake' => Icons.water_rounded,
      'waterfall' => Icons.waterfall_chart_rounded,
      'canyon_valley' => Icons.terrain_rounded,
      'cave' => Icons.landscape_rounded,
      'national_park' => Icons.forest_rounded,
      'toilet' => Icons.wc_outlined,
      'drinking_water' => Icons.water_drop_outlined,
      'water_fountain' => Icons.water_rounded,
      'water_amenities' => Icons.water_drop_outlined,
      'local_service' => Icons.handyman_rounded,
      _ => Icons.place_outlined,
    };

IconData _mapIconForPlace(Place place) {
  final taxonomy = place.resolvedTaxonomy;
  if (taxonomy.mainCategory == 'local_service' ||
      taxonomy.subtype == 'local_service' ||
      place.isMobileService ||
      place.kind.toLowerCase().contains('servis') ||
      place.kind.toLowerCase().contains('işletme') ||
      place.kind.toLowerCase().contains('isletme')) {
    if (taxonomy.subtype != null && taxonomy.subtype != 'local_service') {
      return iconForCategoryKey(taxonomy.subtype);
    }
    return Icons.handyman_rounded;
  }
  return switch (taxonomy.subtype ?? taxonomy.mainCategory) {
    'waterfall' => Icons.waterfall_chart_rounded,
    'lake' ||
    'river' ||
    'stream' ||
    'spring' ||
    'natural_pool' =>
      Icons.water_drop_outlined,
    'mountain' ||
    'peak' ||
    'hill' ||
    'plateau' ||
    'plateau_landform' ||
    'valley' =>
      Icons.terrain_rounded,
    'canyon' ||
    'cave' ||
    'sinkhole' ||
    'travertine' ||
    'fairy_chimney' ||
    'natural_arch' =>
      Icons.landscape_rounded,
    'forest' ||
    'national_park' ||
    'nature_park' ||
    'wetland' ||
    'protected_area' ||
    'picnic_area' =>
      Icons.park_outlined,
    'camp_site' || 'caravan_site' => Icons.cabin_outlined,
    'hiking' ||
    'trekking' ||
    'cycling' ||
    'climbing' ||
    'canoe' =>
      Icons.directions_walk_rounded,
    'viewpoint' ||
    'sunset_viewpoint' ||
    'photo_spot' ||
    'stargazing' =>
      Icons.visibility_outlined,
    'toilet' => Icons.wc_outlined,
    'drinking_water' || 'water_fountain' => Icons.water_drop_outlined,
    _ => place.icon,
  };
}

class _MapPlaceSearchDelegate extends SearchDelegate<Place?> {
  _MapPlaceSearchDelegate({required this.category, this.subtype})
      : super(
          searchFieldLabel: category == 'Tümü'
              ? 'Tüm yerlerde ara'
              : '$category kategorisinde ara',
          keyboardType: TextInputType.text,
        );

  final String category;
  final String? subtype;

  List<Place> matches() {
    final normalized =
        query.trim().replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();
    if (normalized.isEmpty) return const <Place>[];

    final searchPlaces = <Place>[
      ...SupabasePlacesController.places.value,
      ...UserPlacesController.places.value,
    ].where((place) {
      return _matchesMapFilter(place, category, subtype);
    });

    final filtered = searchPlaces.where((place) {
      final target = '${place.name} ${place.location} ${place.kind}'
          .replaceAll('İ', 'i')
          .replaceAll('I', 'ı')
          .toLowerCase();
      return target.contains(normalized);
    }).toList();

    filtered.sort((a, b) {
      final aName =
          a.name.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();
      final bName =
          b.name.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();
      final aLoc =
          a.location.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();
      final bLoc =
          b.location.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

      int score(String name, String loc) {
        if (name.startsWith(normalized)) return 0;
        if (name.contains(normalized)) return 1;
        if (loc.startsWith(normalized)) return 2;
        if (loc.contains(normalized)) return 3;
        return 4;
      }

      final cmp = score(aName, aLoc).compareTo(score(bName, bLoc));
      if (cmp != 0) return cmp;
      return a.name.compareTo(b.name);
    });

    return filtered;
  }

  Widget results(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_rounded,
                size: 52,
                color: isDark
                    ? AppColors.darkTextSecondary.withValues(alpha: 0.35)
                    : AppColors.textTertiary,
              ),
              const SizedBox(height: 14),
              Text(
                category == 'Tümü'
                    ? 'Aramak istediğin doğa noktasını veya şehri yaz'
                    : '$category kategorisinde aramak istediğin yeri yaz',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontSize: AppFontSizes.body,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final found = matches();
    if (found.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.travel_explore_outlined,
                size: 48,
                color: isDark
                    ? AppColors.darkTextSecondary.withValues(alpha: 0.35)
                    : AppColors.textTertiary,
              ),
              const SizedBox(height: 12),
              Text(
                category == 'Tümü'
                    ? '"$normalized" ile eşleşen bir yer bulunamadı.'
                    : '$category kategorisinde "$normalized" ile eşleşen yer bulunamadı.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontSize: AppFontSizes.body,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: found.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final place = found[index];
        return ListTile(
          onTap: () => close(context, place),
          tileColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.large),
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: isDark ? AppColors.darkPrimarySoft : mint,
            child: Icon(
              place.icon,
              color: isDark ? AppColors.darkPrimaryLight : green,
              size: 20,
            ),
          ),
          title: Text(
            place.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : Colors.black87,
            ),
          ),
          subtitle: Text(
            '${place.kind} · ${place.location} · ${_userDistanceLabel(place)}',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              fontSize: AppFontSizes.caption,
            ),
          ),
          trailing: Icon(
            Icons.north_east_rounded,
            size: 17,
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
          ),
        );
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return theme.copyWith(
      scaffoldBackgroundColor:
          isDark ? AppColors.darkSurfaceDeep : AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.darkTextPrimary : Colors.black87,
        ),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          fontSize: AppFontSizes.title,
        ),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          tooltip: 'Ara',
          onPressed: () => showResults(context),
          icon: const Icon(Icons.search_rounded),
        ),
        if (query.isNotEmpty)
          IconButton(
            onPressed: () => query = '',
            icon: const Icon(Icons.close_rounded),
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back_rounded),
      );

  @override
  Widget buildResults(BuildContext context) => results(context);

  @override
  Widget buildSuggestions(BuildContext context) => results(context);
}
