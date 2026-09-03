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
  final recentSearches = <String>[
    'Düden Şelalesi',
    'Karagöl',
    'Uludağ',
    'Likya Yolu',
  ];

  static const categories = [
    ('💧', 'Su Kaynağı', 'İçme suyu kaynakları'),
    ('🌊', 'Doğal Kaynak', 'Soğuk ve temiz kaynaklar'),
    ('🌊', 'Şelale', 'Doğal şelaleler'),
    ('🏞️', 'Göl', 'Doğal göl ve göletler'),
    ('🏕️', 'Kamp Alanı', 'Kamp ve bungalov'),
    ('🌿', 'Piknik', 'Piknik alanları'),
    ('🥾', 'Yürüyüş', 'Doğa yürüyüş rotaları'),
    ('🔭', 'Seyir Noktası', 'Panoramik manzaralar'),
    ('🪨', 'Mağara', 'Doğal mağaralar'),
    ('🚐', 'Karavan', 'Karavan dostu alanlar'),
  ];

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final results = places
        .where((p) =>
            (filter == 'Tümü' || p.kind == filter) &&
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
                  onSubmitted: addRecent,
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
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: green)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: green, width: 1.4)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
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
              const _SearchHeading('🔥 Trend Aramalar'),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _TrendChip('Cappadocia viewpoints', onTap: selectSearch),
                _TrendChip('Karagöl mağarası', onTap: selectSearch),
                _TrendChip('Kaçkar dağı rotaları', onTap: selectSearch),
                _TrendChip('Pamukkale travertenleri', onTap: selectSearch),
              ]),
              const SizedBox(height: 25),
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
                      borderRadius: BorderRadius.circular(9)),
                  child: const Icon(Icons.history_rounded,
                      size: 15, color: Color(0xFF9A968E))),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
              const Icon(Icons.north_east_rounded,
                  size: 13, color: Color(0xFF9A968E))
            ])),
      );
}

class _TrendChip extends StatelessWidget {
  const _TrendChip(this.text, {required this.onTap});
  final String text;
  final ValueChanged<String> onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => onTap(text),
        borderRadius: BorderRadius.circular(20),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E2DB))),
            child: Text(text, style: const TextStyle(fontSize: 10))),
      );
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.place, required this.onTap});
  final Place place;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
          height: 72,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
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
                  Text('⭐ ${place.rating}  ·  8.4 km',
                      style: const TextStyle(fontSize: 8))
                ])),
            const Icon(Icons.chevron_right_rounded,
                size: 17, color: Color(0xFF9A968E))
          ])));
}

class _MapCategoryStyle {
  const _MapCategoryStyle(
    this.emoji,
    this.label,
    this.foreground,
    this.background,
  );

  final String emoji;
  final String label;
  final Color foreground;
  final Color background;
}

const _mapCategories = <_MapCategoryStyle>[
  _MapCategoryStyle('✦', 'Tümü', Color(0xFF1B3A0A), Color(0xFFEAF2E3)),
  _MapCategoryStyle('💧', 'Su Kaynağı', Color(0xFF4A8EC4), Color(0xFFEBF4FB)),
  _MapCategoryStyle('🌊', 'Doğal Kaynak', Color(0xFF2A8FA3), Color(0xFFE8F4FA)),
  _MapCategoryStyle('🌊', 'Şelale', Color(0xFF3789BD), Color(0xFFE9F3FB)),
  _MapCategoryStyle('🏞️', 'Göl', Color(0xFF3D8A64), Color(0xFFEDF5EA)),
  _MapCategoryStyle('🏕️', 'Kamp Alanı', Color(0xFFC26431), Color(0xFFFBF0EA)),
  _MapCategoryStyle('🌿', 'Piknik', Color(0xFF5A8A1E), Color(0xFFEEF4E6)),
  _MapCategoryStyle('🥾', 'Yürüyüş', Color(0xFF9A6427), Color(0xFFFBF2E8)),
  _MapCategoryStyle(
      '🔭', 'Seyir Noktası', Color(0xFF7056A6), Color(0xFFF2EEF9)),
  _MapCategoryStyle('🪨', 'Mağara', Color(0xFF746A62), Color(0xFFF0EEF1)),
  _MapCategoryStyle('🚐', 'Karavan', Color(0xFFB96F7A), Color(0xFFFBEAF0)),
];

_MapCategoryStyle _mapStyleFor(String kind) {
  final normalized = kind.toLowerCase();
  if (normalized.contains('su kaynağı')) return _mapCategories[1];
  if (normalized.contains('doğal kaynak')) return _mapCategories[2];
  if (normalized.contains('şelale')) return _mapCategories[3];
  if (normalized.contains('göl')) return _mapCategories[4];
  if (normalized.contains('kamp')) return _mapCategories[5];
  if (normalized.contains('piknik')) return _mapCategories[6];
  if (normalized.contains('yürüyüş') || normalized.contains('milli park')) {
    return _mapCategories[7];
  }
  if (normalized.contains('seyir')) return _mapCategories[8];
  if (normalized.contains('mağara')) return _mapCategories[9];
  if (normalized.contains('karavan')) return _mapCategories[10];
  return _mapCategories.first;
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
  int? selectedIndex = 0;
  String selectedFilter = 'Tümü';

  List<Place> get mapPlaces {
    final seen = <String>{};
    return <Place>[
      ...UserPlacesController.places.value,
      ...SupabasePlacesController.places.value,
      ...places,
    ].where((place) {
      final key = place.sourceId ??
          '${place.name.toLowerCase()}:${place.latitude}:${place.longitude}';
      return place.hasCoordinates && seen.add(key);
    }).toList(growable: false);
  }

  LatLng coordinateFor(int index) {
    final place = mapPlaces[index];
    return LatLng(place.latitude!, place.longitude!);
  }

  @override
  void initState() {
    super.initState();
    UserPlacesController.places.addListener(_refreshUserPlaces);
    HomeWeatherLocationController.current.addListener(_refreshUserLocation);
  }

  void _refreshUserPlaces() {
    if (mounted) setState(() => selectedIndex = 0);
  }

  void _refreshUserLocation() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    UserPlacesController.places.removeListener(_refreshUserPlaces);
    HomeWeatherLocationController.current.removeListener(_refreshUserLocation);
    mapController.dispose();
    super.dispose();
  }

  bool isVisible(Place place) {
    if (selectedFilter == 'Tümü') return true;
    return _mapStyleFor(place.kind).label == selectedFilter;
  }

  void selectPlace(Place place) {
    var index = mapPlaces.indexWhere((item) => item.name == place.name);
    if (index < 0) index = 0;
    setState(() {
      selectedIndex = index;
      selectedFilter = 'Tümü';
    });
    mapController.move(coordinateFor(index), 10.2);
  }

  void handleMapPositionChanged(MapCamera camera, bool hasGesture) {
    final currentSelection = selectedIndex;
    if (!hasGesture || currentSelection == null) return;
    if (isPlaceMeaningfullyNearViewport(
      coordinateFor(currentSelection),
      camera.visibleBounds,
    )) {
      return;
    }
    setState(() => selectedIndex = null);
  }

  Future<void> searchPlace() async {
    final result = await showSearch<Place?>(
      context: context,
      delegate: _MapPlaceSearchDelegate(),
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
    final target = HomeWeatherLocationController.current.value;
    if (!target.usesCoordinates) return null;
    return LatLng(target.latitude!, target.longitude!);
  }

  Future<void> centerOnUserLocation() async {
    try {
      final target = HomeWeatherLocationController.current.value;
      if (!target.usesCoordinates) {
        await HomeWeatherLocationController.requestAndUseDeviceLocation();
      }
      final point = userCoordinate;
      if (point != null) mapController.move(point, 12.8);
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

  @override
  Widget build(BuildContext context) => SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
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
                          markers: List.generate(mapPlaces.length, (index) {
                            if (!isVisible(mapPlaces[index])) return null;
                            final selected = selectedIndex == index;
                            return Marker(
                              point: coordinateFor(index),
                              width: selected ? 142 : 54,
                              height: selected ? 88 : 54,
                              child: _MapMarker(
                                place: mapPlaces[index],
                                selected: selected,
                                onTap: () =>
                                    setState(() => selectedIndex = index),
                              ),
                            );
                          }).whereType<Marker>().toList(growable: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 8,
                bottom: 118,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .88),
                    borderRadius: BorderRadius.circular(7),
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
                top: 14,
                child: Material(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: InkWell(
                    onTap: searchPlace,
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          SizedBox(width: 15),
                          Icon(Icons.search_rounded, color: green, size: 21),
                          SizedBox(width: 10),
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
                          Icon(Icons.tune_rounded,
                              color: Color(0xFF77736C), size: 19),
                          SizedBox(width: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                top: 73,
                child: SizedBox(
                  height: 44,
                  child: ScrollConfiguration(
                    behavior: const _MapCategoryScrollBehavior(),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      itemCount: _mapCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 7),
                      itemBuilder: (_, index) {
                        final category = _mapCategories[index];
                        final selected = selectedFilter == category.label;
                        return Material(
                          color: selected ? green : Colors.white,
                          elevation: 0,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          child: InkWell(
                            onTap: () => setState(() {
                              selectedFilter = category.label;
                              selectedIndex = null;
                            }),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            child: Container(
                              padding: EdgeInsets.fromLTRB(
                                  selected ? 12 : 5, 5, 11, 5),
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
                                  if (!selected || index != 0) ...[
                                    Container(
                                      width: 29,
                                      height: 29,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? Colors.white
                                            : category.background,
                                        borderRadius: BorderRadius.circular(
                                            AppRadii.small),
                                      ),
                                      child: Text(category.emoji,
                                          style: const TextStyle(fontSize: 15)),
                                    ),
                                    const SizedBox(width: 7),
                                  ],
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
              Positioned(
                right: 14,
                bottom: 132,
                child: Column(
                  children: [
                    mapControl(
                      icon: Icons.add_rounded,
                      tooltip: 'Yakınlaştır',
                      onTap: () => zoom(1.25),
                    ),
                    const SizedBox(height: 8),
                    mapControl(
                      icon: Icons.remove_rounded,
                      tooltip: 'Uzaklaştır',
                      onTap: () => zoom(.8),
                    ),
                    const SizedBox(height: 8),
                    mapControl(
                      icon: Icons.my_location_rounded,
                      tooltip: 'Konumum',
                      onTap: centerOnUserLocation,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: selectedIndex == null
                    ? const SizedBox.shrink()
                    : CompactPlaceCard(
                        place: mapPlaces[selectedIndex!],
                        onTap: () => widget.onOpen(mapPlaces[selectedIndex!]),
                      ),
              ),
            ],
          ),
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
    final category = _mapStyleFor(place.kind);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: selected ? 1.12 : 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                color: category.background,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: selected ? green : Colors.white,
                  width: selected ? 2.5 : 3,
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
              child: Text(category.emoji, style: const TextStyle(fontSize: 22)),
            ),
            if (selected) ...[
              const SizedBox(height: 5),
              Container(
                constraints: const BoxConstraints(maxWidth: 122),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xF7FFFFFF),
                  borderRadius: BorderRadius.circular(AppRadii.small),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  place.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: ink,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MapPlaceSearchDelegate extends SearchDelegate<Place?> {
  _MapPlaceSearchDelegate()
      : super(
          searchFieldLabel: 'Şelale, göl veya kamp alanı ara',
          keyboardType: TextInputType.text,
        );

  List<Place> matches() {
    final normalized = query.trim().toLowerCase();
    final searchPlaces = <Place>[
      ...SupabasePlacesController.places.value,
      ...UserPlacesController.places.value,
      ...places,
    ];
    if (normalized.isEmpty) return searchPlaces;
    return searchPlaces
        .where((place) => '${place.name} ${place.location} ${place.kind}'
            .toLowerCase()
            .contains(normalized))
        .toList(growable: false);
  }

  Widget results(BuildContext context) {
    final found = matches();
    if (found.isEmpty) {
      return const Center(child: Text('Bu aramaya uygun yer bulunamadı.'));
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
            borderRadius: BorderRadius.circular(15),
          ),
          leading: CircleAvatar(
            backgroundColor: mint,
            child: Icon(place.icon, color: green, size: 20),
          ),
          title: Text(place.name,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('${place.kind} · ${place.location}'),
          trailing: const Icon(Icons.north_west_rounded, size: 17),
        );
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
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
