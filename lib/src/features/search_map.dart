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
    return Scaffold(
      backgroundColor: AppColors.background,
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
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Şelale, göl, kamp alanı...',
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
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.large),
                        borderSide: const BorderSide(color: green)),
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
                child: const Text('Ara'),
              ),
              const SizedBox(width: 4),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal',
                      style:
                          TextStyle(color: green, fontWeight: FontWeight.w600)))
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
                            label: Text('${item.$1}  ${item.$2}'),
                            selected: filter == item.$2,
                            onSelected: (_) => setState(() => filter = item.$2),
                            labelStyle: const TextStyle(fontSize: 10),
                            backgroundColor: Colors.white,
                            selectedColor: const Color(0xFFF0F7E9),
                            side: BorderSide(
                                color: filter == item.$2
                                    ? green
                                    : const Color(0xFFE1DED6)),
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
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF8A8680))),
              const SizedBox(height: 10),
              if (results.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 34),
                  alignment: Alignment.center,
                  child: const Text('Bu aramaya uygun bir yer bulunamadı.',
                      style: TextStyle(color: Color(0xFF8A8680), fontSize: 12)),
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
                const Expanded(child: _SearchHeading('Son Aramalar')),
                if (recentSearches.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(recentSearches.clear),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 28),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Temizle',
                        style: TextStyle(
                            color: green,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  )
              ]),
              const SizedBox(height: 8),
              if (recentSearches.isEmpty)
                Container(
                  height: 58,
                  alignment: Alignment.centerLeft,
                  child: const Text('Henüz son arama yok.',
                      style: TextStyle(color: Color(0xFF9A968E), fontSize: 11)),
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
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontFamily: 'Outfit', fontSize: 17, fontWeight: FontWeight.w600));
}

class _RecentSearch extends StatelessWidget {
  const _RecentSearch(this.text, {required this.onTap});
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
            height: 48,
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE5E2DB)))),
            child: Row(children: [
              Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: const Color(0xFFEDEBE5),
                      borderRadius: BorderRadius.circular(AppRadii.large)),
                  child: const Icon(Icons.history_rounded,
                      size: 15, color: Color(0xFF9A968E))),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
              const Icon(Icons.north_east_rounded,
                  size: 13, color: Color(0xFF9A968E))
            ])),
      );
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
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.large),
      child: Container(
          height: 72,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.large),
              boxShadow: const [
                BoxShadow(color: Color(0x0E000000), blurRadius: 8)
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
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${place.kind}  ·  ${place.location}',
                      style: const TextStyle(
                          color: Color(0xFF8A8680), fontSize: 8)),
                  const SizedBox(height: 4),
                  Text('⭐ ${place.rating}  ·  ${_userDistanceLabel(place)}',
                      style: const TextStyle(fontSize: 8))
                ])),
            const Icon(Icons.chevron_right_rounded,
                size: 17, color: Color(0xFF9A968E))
          ])));
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
}

final _mapCategories = <_MapCategoryStyle>[
  const _MapCategoryStyle(
      'all', '✦', 'Tümü', Color(0xFF1B3A0A), Color(0xFFEAF2E3)),
  ...placeTaxonomy.map((item) => _MapCategoryStyle(
        item.key,
        item.emoji,
        item.label,
        item.foreground,
        item.background,
      )),
  const _MapCategoryStyle(
      'toilet', '🚻', 'WC', Color(0xFF68747B), Color(0xFFEEF1F2)),
  const _MapCategoryStyle('drinking_water', '🚰', 'İçme Suyu',
      Color(0xFF4A8EC4), Color(0xFFEBF4FB)),
  const _MapCategoryStyle(
      'water_fountain', '⛲', 'Çeşme', Color(0xFF287A9B), Color(0xFFE6F5FA)),
];

bool _matchesMapFilter(Place place, String filterLabel, String? subtype) {
  if (filterLabel == 'Tümü') return true;
  final style = _mapCategories.firstWhere(
    (item) => item.label == filterLabel,
    orElse: () => _mapCategories.first,
  );
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
  const _MapCluster({required this.center, required this.placeIndexes});

  final LatLng center;
  final List<int> placeIndexes;
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.onOpen});

  final ValueChanged<Place> onOpen;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const initialCenter = LatLng(39.0, 35.2);
  static const initialZoom = 5.4;
  final mapController = MapController();
  late final TileProvider tileProvider = OfflineMapTiles.createTileProvider();
  late List<Place> _mapPlaces;
  int? selectedIndex;
  String selectedFilter = 'Tümü';
  String? selectedSubtype;
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
      for (final index in indexes) {
        final point = coordinateFor(index);
        latitude += point.latitude;
        longitude += point.longitude;
      }
      return _MapCluster(
        center: LatLng(latitude / indexes.length, longitude / indexes.length),
        placeIndexes: List.unmodifiable(indexes),
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
      Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
            side: const BorderSide(color: AppColors.border),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadii.medium),
            child: SizedBox(
              width: 43,
              height: 43,
              child: Icon(icon, size: 20, color: green),
            ),
          ),
        ),
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
                  fontSize: 19,
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
                  color: Color(0xFF686E69),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
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
                      color: const Color(0xFFDDE8E3),
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
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.dogadagezi.dogada_gezi',
                            maxNativeZoom: 19,
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
                                  width: 58,
                                  height: 58,
                                  child: _MapClusterMarker(
                                    count: cluster.placeIndexes.length,
                                    onTap: () => openCluster(cluster),
                                  ),
                                );
                              }
                              final index = cluster.placeIndexes.single;
                              final selected = selectedIndex == index;
                              return Marker(
                                point: cluster.center,
                                width: selected ? 70 : 54,
                                height: selected ? 74 : 54,
                                child: _MapMarker(
                                  place: mapPlaces[index],
                                  selected: selected,
                                  onTap: () => selectPlace(mapPlaces[index]),
                                ),
                              );
                            }).toList(growable: false),
                          ),
                          if (selectedPlace != null)
                            MarkerLayer(markers: [
                              Marker(
                                point: coordinateFor(selectedIndex!),
                                width: 70,
                                height: 74,
                                child: _MapMarker(
                                    place: selectedPlace,
                                    selected: true,
                                    onTap: () => selectPlace(selectedPlace)),
                              )
                            ]),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: sheetHeight == 0 ? 18 : sheetHeight + 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .88),
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                    ),
                    child: const Text(
                      '© OpenStreetMap contributors',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: Color(0xFF5E625B),
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  top: 12,
                  child: Material(
                    color: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.large),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: InkWell(
                      onTap: searchPlace,
                      borderRadius: BorderRadius.circular(AppRadii.large),
                      child: SizedBox(
                        height: 52,
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Icon(Icons.search_rounded, color: green, size: 21),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                selectedFilter == 'Tümü'
                                    ? 'Haritada yer ara'
                                    : '$selectedFilter içinde ara',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  color: Color(0xFF77736C),
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                            Semantics(
                              label: 'Harita filtreleri',
                              child: Icon(Icons.tune_rounded,
                                  color: Color(0xFF77736C), size: 20),
                            ),
                            const SizedBox(width: 16),
                          ],
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
                          final selected = selectedFilter == category.label;
                          return Material(
                            color: selected ? green : Colors.white,
                            elevation: 0,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            child: InkWell(
                              onTap: () => setState(() {
                                selectedFilter = category.label;
                                selectedSubtype = null;
                                selectedIndex = null;
                                _selectionHistory.clear();
                                _clusterCache = null;
                              }),
                              borderRadius:
                                  BorderRadius.circular(AppRadii.pill),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 11, vertical: 7),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.pill),
                                  border: Border.all(
                                    color: selected
                                        ? green
                                        : const Color(0xFFE2E0DA),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _mapIconForCategory(category.key),
                                      size: 16,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      category.label,
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        color: selected ? Colors.white : ink,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
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
                      .firstWhere((item) => item.label == selectedFilter,
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
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: category.subtypes.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 7),
                        itemBuilder: (_, index) {
                          final subtype =
                              index == 0 ? null : category.subtypes[index - 1];
                          final selected = selectedSubtype == subtype?.key;
                          return ChoiceChip(
                            label: Text(subtype?.label ?? 'Tümü'),
                            selected: selected,
                            onSelected: (_) => setState(() {
                              selectedSubtype = selected ? null : subtype?.key;
                              selectedIndex = null;
                              _selectionHistory.clear();
                              _clusterCache = null;
                            }),
                          );
                        },
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

class _MapLocationChip extends StatelessWidget {
  const _MapLocationChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: 'Konumuma dön',
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: Container(
              height: 40,
              constraints: const BoxConstraints(maxWidth: 178),
              padding: const EdgeInsets.symmetric(horizontal: 11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: const Border.fromBorderSide(AppBorders.thin),
                boxShadow: AppShadows.soft,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: AppColors.primary, size: 16),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.metadata.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary, size: 16),
                ],
              ),
            ),
          ),
        ),
      );
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
  Widget build(BuildContext context) => Material(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          child: Column(children: [
            Row(children: [
              IconButton(
                  tooltip: 'Önceki yer',
                  onPressed: onPrevious,
                  icon: const Icon(Icons.chevron_left_rounded)),
              const Expanded(
                  child: Text('Seçili yer',
                      style: TextStyle(
                          color: Color(0xFFB65B23),
                          fontWeight: FontWeight.w600))),
              IconButton(
                  tooltip: 'En yakın sonraki yer',
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right_rounded)),
              IconButton(
                  tooltip: 'Kartı kapat',
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded)),
            ]),
            AppMapPreviewCard(
                place: place, onTap: () => onOpen(place), prominent: true),
          ]),
        ),
      );
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFF2375D8),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: const [
              BoxShadow(color: Color(0x55000000), blurRadius: 8),
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
      };
}

class _MapClusterMarker extends StatelessWidget {
  const _MapClusterMarker({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Center(
          child: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
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
  });

  final Place place;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUtility = isUtilitySubtype(place.resolvedTaxonomy.subtype);
    final fill = selected || !isUtility ? AppColors.primary : AppColors.surface;
    final iconColor =
        selected || !isUtility ? AppColors.onPrimary : AppColors.primary;
    return Semantics(
      label: 'Haritada ${place.name}',
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: selected ? 1.16 : 1,
          child: selected
              ? Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 70,
                      color: Color(0xFFB65B23),
                      shadows: [
                        Shadow(color: Color(0x44000000), blurRadius: 10),
                      ],
                    ),
                    Positioned(
                      top: 9,
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB65B23),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: _MapPlaceSymbol(
                            place: place, color: AppColors.onPrimary, size: 23),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: fill,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isUtility ? AppColors.primary : Colors.white,
                        width: isUtility ? 2 : 3,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x44000000),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _MapPlaceSymbol(
                        place: place, color: iconColor, size: 24),
                  ),
                ),
        ),
      ),
    );
  }
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
    final found = matches();
    if (found.isEmpty) {
      return Center(
        child: Text(
          category == 'Tümü'
              ? 'Aramana uygun bir yer bulunamadı.'
              : '$category kategorisinde gösterilecek yer bulunamadı.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF77736C)),
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
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.large),
          ),
          leading: CircleAvatar(
            backgroundColor: mint,
            child: Icon(place.icon, color: green, size: 20),
          ),
          title: Text(place.name,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            '${place.kind} · ${place.location} · ${_userDistanceLabel(place)}',
          ),
          trailing: const Icon(Icons.north_west_rounded, size: 17),
        );
      },
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
