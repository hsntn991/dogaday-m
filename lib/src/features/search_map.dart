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

  static final categories = <(String, String, String)>[
    ...placeTaxonomy
        .map((item) => (item.emoji, item.label, 'Alt türleri keşfet')),
    ('🚻', 'WC', 'Bağımsız tuvalet noktaları'),
    ('🚰', 'İçme Suyu', 'İçilebilir su noktaları'),
    ('⛲', 'Çeşme', 'Kaynak bağlantısı bulunan çeşmeler'),
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

  @override
  Widget build(BuildContext context) {
    final realPlaces = <Place>[
      ...SupabasePlacesController.places.value,
      ...UserPlacesController.places.value,
    ];
    final results = realPlaces
        .where((p) =>
            _matchesMapFilter(p, filter, null) &&
            '${p.name} ${p.location} ${p.kind}'
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();
    final filterItems = <(String, String)>[
      ('✓', 'Tümü'),
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
                    hintText: AppStrings.get('search_input_hint'),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: green, size: 20),
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
                            label: Text('${item.$1}  ${item.$2}',
                                style: TextStyle(
                                    fontSize: AppFontSizes.caption,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : Colors.black87)),
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
            if (query.isNotEmpty || filter != 'Tümü') ...[
              Text(
                  filter == 'Tümü'
                      ? '${results.length} sonuç "$query" için'
                      : '${results.length} sonuç · $filter',
                  style: TextStyle(
                      fontSize: AppFontSizes.caption,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary)),
              const SizedBox(height: 10),
              if (results.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 34),
                  alignment: Alignment.center,
                  child: Text(AppStrings.get('search_no_results'),
                      style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          fontSize: AppFontSizes.caption)),
                )
              else
                ...results.map((place) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: _SearchResultCard(
                          place: place,
                          onTap: () {
                            addRecent(place.name);
                            widget.onOpen(place);
                          }),
                    )),
            ] else ...[
              Row(children: [
                Expanded(
                    child: _SearchHeading(
                        AppStrings.get('search_recent_searches'))),
                if (recentSearches.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(recentSearches.clear),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 28),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(AppStrings.get('search_clear'),
                        style: const TextStyle(
                            color: green,
                            fontSize: AppFontSizes.caption,
                            fontWeight: FontWeight.w600)),
                  )
              ]),
              const SizedBox(height: 8),
              if (recentSearches.isEmpty)
                Container(
                  height: 58,
                  alignment: Alignment.centerLeft,
                  child: Text(AppStrings.get('search_no_recent'),
                      style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          fontSize: AppFontSizes.caption)),
                )
              else
                ...recentSearches.map((text) => _RecentSearch(
                      text,
                      onTap: () => selectSearch(text),
                    )),
              const SizedBox(height: 22),
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
      'toilet', '🚻', 'WC', AppColors.categoryUtility, AppColors.primarySoft),
  const _MapCategoryStyle('drinking_water', '🚰', 'İçme Suyu',
      AppColors.categoryWater, AppColors.primarySoft),
  const _MapCategoryStyle('water_fountain', '⛲', 'Çeşme',
      AppColors.categoryWater, AppColors.primarySoft),
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
  if (isUtilitySubtype(style.key)) return taxonomy.subtype == style.key;
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
  const MapScreen({super.key, required this.onOpen});

  final ValueChanged<Place> onOpen;

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

  List<Place> buildMapPlaces() {
    final seen = <String>{};
    return <Place>[
      ...UserPlacesController.places.value,
      ...SupabasePlacesController.places.value,
    ].where((place) {
      final key = place.sourceId ??
          '${place.name.toLowerCase()}:${place.latitude}:${place.longitude}';
      return place.hasCoordinates &&
          AddPlaceQualityService.isValidCoordinate(
            place.latitude,
            place.longitude,
          ) &&
          seen.add(key);
    }).toList(growable: false);
  }

  List<Place> get mapPlaces => _mapPlaces;

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
      final key = '${(point.latitude / latitudeCellSize).floor()}:'
          '${(point.longitude / longitudeCellSize).floor()}';
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
        final cat = mapPlaces[index].resolvedTaxonomy.mainCategory;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_startLiveLocation());
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
    mapController.dispose();
    super.dispose();
  }

  bool isVisible(Place place) {
    return _matchesMapFilter(place, selectedFilter, selectedSubtype);
  }

  final List<int> _selectionHistory = [];

  void previousPlace() {
    if (_selectionHistory.isEmpty) return;
    selectPlace(mapPlaces[_selectionHistory.removeLast()], keepHistory: true);
  }

  void nextPlace() {
    final current = selectedIndex;
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
      selectedIndex != null &&
      mapPlaces.asMap().entries.any((entry) =>
          entry.key != selectedIndex &&
          !_selectionHistory.contains(entry.key) &&
          isVisible(entry.value));

  void selectPlace(Place place, {bool keepHistory = false}) {
    final index = mapPlaces.indexWhere((item) =>
        item.name == place.name &&
        item.latitude == place.latitude &&
        item.longitude == place.longitude);
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
    final currentSelection = selectedIndex;
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
      setState(() {
        _mapZoom = camera.zoom;
        _visibleBounds = _pendingVisibleBounds;
        _clusterCache = null;
      });
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final selectedPlace =
              selectedIndex == null ? null : mapPlaces[selectedIndex!];
          final sheetHeight = selectedPlace == null ? 0.0 : 204.0;
          return Stack(
            children: [
              Positioned.fill(
                child: ClipRect(
                  child: ColoredBox(
                    color:
                        isDark ? AppColors.darkSurface : AppColors.surfaceMuted,
                    child: RepaintBoundary(
                      child: FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          initialCenter: initialCenter,
                          initialZoom: initialZoom,
                          minZoom: 4,
                          maxZoom: 18,
                          cameraConstraint: CameraConstraint.containLatitude(),
                          onPositionChanged: handleMapPositionChanged,
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
                            maxNativeZoom:
                                _mapStyle == _MapStyle.topo ? 17 : 19,
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
                              if (cluster.placeIndexes.length > 1) {
                                return Marker(
                                  point: cluster.center,
                                  width: 36,
                                  height: 36,
                                  alignment: Alignment.center,
                                  child: _MapClusterMarker(
                                    cluster: cluster,
                                    onTap: () => openCluster(cluster),
                                  ),
                                );
                              }
                              final index = cluster.placeIndexes.single;
                              final selected = selectedIndex == index;
                              final showLabel = _mapZoom >= 13.0;
                              return Marker(
                                point: cluster.center,
                                width: selected ? 130 : 110,
                                height: selected ? 74 : (showLabel ? 58 : 46),
                                alignment: Alignment.bottomCenter,
                                child: _MapMarker(
                                  place: mapPlaces[index],
                                  selected: selected,
                                  showLabel: showLabel,
                                  onTap: () => selectPlace(mapPlaces[index]),
                                ),
                              );
                            }).toList(growable: false),
                          ),
                          if (selectedPlace != null)
                            MarkerLayer(markers: [
                              Marker(
                                point: coordinateFor(selectedIndex!),
                                width: 130,
                                height: 74,
                                alignment: Alignment.bottomCenter,
                                child: _MapMarker(
                                    place: selectedPlace,
                                    selected: true,
                                    showLabel: true,
                                    onTap: () => selectPlace(selectedPlace)),
                              )
                            ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 8,
                bottom: sheetHeight == 0 ? 18 : sheetHeight + 12,
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                  blur: 10,
                  color: Colors.white.withValues(alpha: 0.75),
                  borderColor: Colors.white.withValues(alpha: 0.65),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  child: Text(
                    switch (_mapStyle) {
                      _MapStyle.standart => '© OpenStreetMap contributors',
                      _MapStyle.uydu => '© Esri, Maxar, Earthstar',
                      _MapStyle.topo => '© OpenTopoMap, OSM contributors',
                    },
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      fontSize: AppFontSizes.caption,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                top: 12,
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  blur: 8,
                  color: Colors.white.withValues(alpha: 0.72),
                  darkColor: AppColors.darkGlass,
                  borderColor: Colors.white.withValues(alpha: 0.85),
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
                            Icon(Icons.search_rounded,
                                color:
                                    isDark ? AppColors.darkPrimaryLight : green,
                                size: 21),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                selectedFilter == 'Tümü' ||
                                        selectedFilter == 'all'
                                    ? AppStrings.get('map_search_places')
                                    : '${_mapCategories.firstWhere((item) => item.key == selectedFilter || item.label == selectedFilter, orElse: () => _mapCategories.first).localizedLabel} ${AppStrings.get('map_search_in')}',
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
                              child: Icon(Icons.tune_rounded,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                  size: 20),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                top: 72,
                child: SizedBox(
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
                            label: HomeWeatherLocationController
                                .current.value.label,
                            onTap: centerOnUserLocation,
                          );
                        }
                        final category = _mapCategories[index - 1];
                        final selected = selectedFilter == category.label ||
                            selectedFilter == category.key;
                        final chipContent = Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            border: Border.all(
                              color: selected
                                  ? green
                                  : Colors.white.withValues(alpha: 0.70),
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
                                      : (isDark
                                          ? AppColors.darkTextPrimary
                                          : ink),
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
                            color: green.withValues(alpha: 0.92),
                            darkColor:
                                AppColors.darkPrimary.withValues(alpha: 0.95),
                            borderColor: Colors.white.withValues(alpha: 0.50),
                            borderWidth: 1.2,
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow26,
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => setState(() {
                                  selectedFilter = category.key;
                                  selectedSubtype = null;
                                  selectedIndex = null;
                                  _selectionHistory.clear();
                                  _clusterCache = null;
                                }),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.pill),
                                child: chipContent,
                              ),
                            ),
                          );
                        }

                        return GlassContainer(
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          blur: 0,
                          color: Colors.white.withValues(alpha: 0.82),
                          borderColor: Colors.white.withValues(alpha: 0.85),
                          borderWidth: 1.2,
                          boxShadow: AppShadows.soft,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => setState(() {
                                selectedFilter = category.key;
                                selectedSubtype = null;
                                selectedIndex = null;
                                _selectionHistory.clear();
                                _clusterCache = null;
                              }),
                              borderRadius:
                                  BorderRadius.circular(AppRadii.pill),
                              child: chipContent,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              if (placeCategoryByKey(
                _mapCategories
                    .firstWhere(
                        (item) =>
                            item.key == selectedFilter ||
                            item.label == selectedFilter,
                        orElse: () => _mapCategories.first)
                    .key,
              )
                  case final category?)
                Positioned(
                  left: 12,
                  right: 12,
                  top: 119,
                  child: SizedBox(
                    height: 36,
                    child: ScrollConfiguration(
                      behavior: const _MapCategoryScrollBehavior(),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        itemCount: category.subtypes.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 7),
                        itemBuilder: (_, index) {
                          final subtype =
                              index == 0 ? null : category.subtypes[index - 1];
                          final isSelected = selectedSubtype == subtype?.key;
                          return GlassContainer(
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            blur: 0,
                            color: isSelected
                                ? green.withValues(alpha: 0.92)
                                : Colors.white.withValues(alpha: 0.82),
                            darkColor: isSelected
                                ? AppColors.darkPrimary.withValues(alpha: 0.95)
                                : AppColors.darkSurfaceMuted
                                    .withValues(alpha: 0.90),
                            borderColor: isSelected
                                ? Colors.white.withValues(alpha: 0.50)
                                : Colors.white.withValues(alpha: 0.70),
                            darkBorderColor: isSelected
                                ? Colors.white.withValues(alpha: 0.30)
                                : Colors.white.withValues(alpha: 0.14),
                            borderWidth: 1.2,
                            boxShadow: AppShadows.soft,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => setState(() {
                                  selectedSubtype =
                                      isSelected ? null : subtype?.key;
                                  selectedIndex = null;
                                  _selectionHistory.clear();
                                  _clusterCache = null;
                                }),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.pill),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Text(
                                    subtype?.localizedLabel ??
                                        AppStrings.get('all'),
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: AppFontSizes.caption,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                              ? AppColors.darkTextPrimary
                                              : ink),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 14,
                bottom: sheetHeight == 0 ? 18 : sheetHeight + 12,
                child: Column(
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
                ),
              ),
              if (selectedPlace != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: sheetHeight,
                  child: _MapDiscoverySheet(
                    place: selectedPlace,
                    onClose: () => setState(() {
                      selectedIndex = null;
                      _clusterCache = null;
                      _selectionHistory.clear();
                    }),
                    onPrevious:
                        _selectionHistory.isEmpty ? null : previousPlace,
                    onNext: hasNextPlace ? nextPlace : null,
                    onOpen: widget.onOpen,
                  ),
                ),
            ],
          );
        },
      ),
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
        color: Colors.white.withValues(alpha: 0.82),
        darkColor: AppColors.darkGlass,
        borderColor: Colors.white.withValues(alpha: 0.85),
        darkBorderColor: Colors.white.withValues(alpha: 0.14),
        borderWidth: 1.2,
        boxShadow: AppShadows.softOf(context),
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
      blur: 16,
      color: Colors.white.withValues(alpha: 0.82),
      darkColor: AppColors.darkGlass,
      border: Border(
        top: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.90),
          width: 1.2,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? AppColors.shadow80 : AppColors.shadow08,
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ],
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Column(children: [
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
        AppMapPreviewCard(
            place: place, onTap: () => onOpen(place), prominent: true),
      ]),
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
  });

  final _MapCluster cluster;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final count = cluster.placeIndexes.length;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.clusterMarker,
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
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppFontSizes.label,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
      ),
    );
  }
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

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.place,
    required this.selected,
    required this.onTap,
    this.showLabel = false,
  });

  final Place place;
  final bool selected;
  final VoidCallback onTap;
  final bool showLabel;

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
                      width: 30,
                      height: 30,
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
                        size: 15,
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
  return switch (mainCategory) {
    'water' => AppColors.categoryWater,
    'mountain_terrain' => AppColors.categoryMountain,
    'natural_formation' => AppColors.categoryFormation,
    'nature_area' => AppColors.categoryNature,
    'camp_caravan' => AppColors.categoryCamp,
    'route_activity' => AppColors.categoryRoute,
    'discovery_point' => AppColors.categoryDiscovery,
    'wildlife' => AppColors.categoryWildlife,
    _ => AppColors.clusterMarker,
  };
}

IconData _mapIconForCategory(String key) => switch (key) {
      'all' => Icons.explore_rounded,
      'water' => Icons.water_drop_outlined,
      'mountain_terrain' => Icons.terrain_rounded,
      'natural_formation' => Icons.landscape_rounded,
      'nature_area' => Icons.park_outlined,
      'camp_caravan' => Icons.cabin_outlined,
      'route_activity' => Icons.directions_walk_rounded,
      'discovery_point' => Icons.visibility_outlined,
      'wildlife' => Icons.pets_outlined,
      'toilet' => Icons.wc_outlined,
      'drinking_water' => Icons.water_drop_outlined,
      'water_fountain' => Icons.water_rounded,
      _ => Icons.place_outlined,
    };

IconData _mapIconForPlace(Place place) {
  final taxonomy = place.resolvedTaxonomy;
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
    final normalized = query.trim().toLowerCase();
    final searchPlaces = <Place>[
      ...SupabasePlacesController.places.value,
      ...UserPlacesController.places.value,
    ].where((place) {
      return _matchesMapFilter(place, category, subtype);
    });
    if (normalized.isEmpty) return searchPlaces.toList(growable: false);
    return searchPlaces
        .where((place) => '${place.name} ${place.location} ${place.kind}'
            .toLowerCase()
            .contains(normalized))
        .toList(growable: false);
  }

  Widget results(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final found = matches();
    if (found.isEmpty) {
      return Center(
        child: Text(
          category == 'Tümü'
              ? 'Aramana uygun bir yer bulunamadı.'
              : '$category kategorisinde gösterilecek yer bulunamadı.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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
