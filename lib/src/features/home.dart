part of '../../main.dart';

class _HomeHeaderButton extends StatelessWidget {
  const _HomeHeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
            side: const BorderSide(color: Color(0xFFE2DED6)),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadii.medium),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(icon, color: green, size: 19),
            ),
          ),
        ),
      );
}

// ignore: unused_element
class _DailyNatureQuoteBoard extends StatelessWidget {
  const _DailyNatureQuoteBoard({required this.onMessages});

  final VoidCallback onMessages;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 78),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 3,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB6C9A7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      '“${dailyNatureQuote()}”',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: Color(0xFF5F645A),
                        fontSize: 15.5,
                        height: 1.38,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                        letterSpacing: .05,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 13),
            Row(
              children: [
                _HomeHeaderButton(
                  icon: Icons.forum_outlined,
                  tooltip: 'Topluluk mesajları',
                  onTap: onMessages,
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                    border: Border.all(color: const Color(0xFFE2DED6)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x10000000), blurRadius: 8),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Center(
                        child: Icon(Icons.notifications_none_rounded,
                            color: green, size: 19),
                      ),
                      Positioned(
                        right: 7,
                        top: 7,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFB84D),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: green,
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                  ),
                  child: const Text(
                    'K',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

final _homeCategories = placeTaxonomy;

class FigmaHomeScreen extends StatefulWidget {
  const FigmaHomeScreen({
    super.key,
    required this.onOpen,
    required this.onSearch,
    required this.onMessages,
    this.onExploreMap,
    this.onAddPlace,
    this.onRequestLocation,
  });
  final ValueChanged<Place> onOpen;
  final VoidCallback onSearch;
  final VoidCallback onMessages;
  final VoidCallback? onExploreMap;
  final VoidCallback? onAddPlace;
  final VoidCallback? onRequestLocation;

  @override
  State<FigmaHomeScreen> createState() => _FigmaHomeScreenState();
}

class _FigmaHomeScreenState extends State<FigmaHomeScreen> {
  String? selectedCategory;

  int get userPlacesRevision => Object.hashAll(
        UserPlacesController.places.value.map((place) => place.sourceId),
      );
  int get nearbyRevision => NearbyPlacesService.revision.value;

  @override
  void initState() {
    super.initState();
    UserPlacesController.places.addListener(_refreshUserPlaces);
    SupabasePlacesController.places.addListener(_refreshUserPlaces);
    NearbyPlacesService.revision.addListener(_refreshNearbyPlaces);
    WeatherService.revision.addListener(_refreshRecommendations);
  }

  @override
  void dispose() {
    UserPlacesController.places.removeListener(_refreshUserPlaces);
    SupabasePlacesController.places.removeListener(_refreshUserPlaces);
    NearbyPlacesService.revision.removeListener(_refreshNearbyPlaces);
    WeatherService.revision.removeListener(_refreshRecommendations);
    super.dispose();
  }

  void _refreshUserPlaces() {
    if (mounted) setState(() {});
  }

  void _refreshNearbyPlaces() {
    if (mounted) setState(() {});
  }

  void _refreshRecommendations() {
    if (mounted) setState(() {});
  }

  void selectCategory(String category) => setState(() {
        selectedCategory = selectedCategory == category ? null : category;
      });

  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            ValueListenableBuilder<bool>(
              valueListenable:
                  HomeWeatherLocationController.isResolvingLocation,
              builder: (_, isResolvingLocation, __) =>
                  ValueListenableBuilder<WeatherTarget>(
                valueListenable: HomeWeatherLocationController.current,
                builder: (_, target, __) => _HomePremiumHeader(
                  target: target,
                  isResolvingLocation: isResolvingLocation,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Semantics(
              label: 'Yer ara',
              button: true,
              child: GestureDetector(
                onTap: widget.onSearch,
                child: AbsorbPointer(
                  child: AppSearchField(onFilterTap: widget.onSearch),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: AppControlSizes.minimumTouchTarget,
              child: ScrollConfiguration(
                behavior: const _MouseDragScrollBehavior(),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _homeCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final category = _homeCategories[index];
                    return AppCategoryChip(
                      label: category.label,
                      icon: _categoryIcon(category.key),
                      selected: selectedCategory == category.key,
                      onSelected: (_) => selectCategory(category.key),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<WeatherTarget>(
              valueListenable: HomeWeatherLocationController.current,
              builder: (_, target, __) => _TodayRecommendationsSection(
                key: ValueKey(
                  'recommendations:${target.cacheKey}:$userPlacesRevision:$nearbyRevision:${WeatherService.revision.value}:$selectedCategory',
                ),
                target: target,
                preferredCategory: selectedCategory,
                onOpen: widget.onOpen,
                onExploreMap: widget.onExploreMap,
              ),
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<WeatherTarget>(
              valueListenable: HomeWeatherLocationController.current,
              builder: (_, target, __) => _NearbyPlacesSection(
                key: ValueKey(
                    'nearby:${target.cacheKey}:$userPlacesRevision:$nearbyRevision'),
                target: target,
                preferredCategory: selectedCategory,
                onOpen: widget.onOpen,
                onExploreMap: widget.onExploreMap,
                onRequestLocation: widget.onRequestLocation,
              ),
            ),
          ],
        ),
      );
}

IconData _categoryIcon(String category) => switch (category) {
      'water' => Icons.water_drop_outlined,
      'mountain_terrain' => Icons.terrain_outlined,
      'natural_formation' => Icons.landscape_outlined,
      'nature_area' => Icons.park_outlined,
      'camp_caravan' => Icons.terrain_outlined,
      'route_activity' => Icons.hiking_outlined,
      'discovery_point' => Icons.explore_outlined,
      'wildlife' => Icons.forest_outlined,
      _ => Icons.category_outlined,
    };

class _HomePremiumHeader extends StatelessWidget {
  const _HomePremiumHeader({
    required this.target,
    required this.isResolvingLocation,
  });

  final WeatherTarget target;
  final bool isResolvingLocation;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 370;
          return Row(
            children: [
              const Icon(Icons.park_rounded,
                  color: AppColors.primary, size: AppIconSizes.large),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Doğadayım',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppTypography.brand.copyWith(fontSize: compact ? 32 : 36),
                ),
              ),
              Container(
                constraints: BoxConstraints(maxWidth: compact ? 112 : 138),
                height: AppControlSizes.minimumTouchTarget,
                padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.textPrimary, size: AppIconSizes.small),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        isResolvingLocation
                            ? 'Konum belirleniyor'
                            : target.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label.copyWith(fontSize: 14),
                      ),
                    ),
                    if (!isResolvingLocation && !compact) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: AppIconSizes.small),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      );
}

// ignore: unused_element
class _RealFeaturedPlace extends StatelessWidget {
  const _RealFeaturedPlace({
    required this.target,
    required this.onOpen,
    required this.onExploreMap,
  });

  final WeatherTarget target;
  final ValueChanged<Place> onOpen;
  final VoidCallback? onExploreMap;

  @override
  Widget build(BuildContext context) {
    final seen = <String>{};
    final candidates = <Place>[
      ...UserPlacesController.places.value,
      ...SupabasePlacesController.places.value,
      ...NearbyPlacesService.availableNow(target),
    ].where((place) {
      final key = place.sourceId ??
          '${place.name.toLowerCase()}:${place.latitude}:${place.longitude}';
      return seen.add(key);
    }).toList(growable: false);
    if (candidates.isEmpty) {
      return _EmptyPlacesCard(
        message: 'Henüz gösterilebilecek gerçek bir doğa noktası yok.',
        actionLabel: 'Haritada keşfet',
        actionIcon: Icons.map_outlined,
        onAction: onExploreMap ?? () {},
        onRefresh: () => unawaited(NearbyPlacesService.refresh(target)),
      );
    }
    final place = candidates.first;
    return _HeroPlace(place: place, onTap: () => onOpen(place));
  }
}

class _TodayRecommendationsSection extends StatelessWidget {
  const _TodayRecommendationsSection({
    super.key,
    required this.target,
    required this.preferredCategory,
    required this.onOpen,
    required this.onExploreMap,
  });

  final WeatherTarget target;
  final String? preferredCategory;
  final ValueChanged<Place> onOpen;
  final VoidCallback? onExploreMap;

  @override
  Widget build(BuildContext context) {
    final hasLocation = target.usesCoordinates;
    final available = NearbyPlacesService.availableNow(target);

    final candidates = <Place>[
      ...SupabasePlacesController.places.value,
      ...UserPlacesController.places.value,
      ...available,
    ].where(_isTodayTripCandidate);
    final recommendations = RecommendationService.rank(
      places: candidates,
      weather: WeatherService.availableNow(target),
      hasUserLocation: hasLocation,
      preferredCategory: preferredCategory,
    ).take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Bugün sana uygun',
          actionLabel: 'Tümünü gör',
          onAction: onExploreMap,
        ),
        const SizedBox(height: 16),
        if (recommendations.isEmpty)
          _EmptyPlacesCard(
            message: 'Şu an için uygun bir öneri bulunamadı.',
            actionLabel: 'Haritada keşfet',
            actionIcon: Icons.map_outlined,
            onAction: onExploreMap ?? () {},
            onRefresh: () => unawaited(NearbyPlacesService.refresh(target)),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 12) / 2;
              return SizedBox(
                height: 228,
                child: ScrollConfiguration(
                  behavior: const _MouseDragScrollBehavior(),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: recommendations.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, index) {
                      final recommendation = recommendations[index];
                      return _RecommendationCard(
                        width: cardWidth,
                        recommendation: recommendation,
                        showDistance: target.usesCoordinates,
                        onTap: () => onOpen(recommendation.place),
                      );
                    },
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

bool _isTodayTripCandidate(Place place) {
  return !place.isUtility;
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.recommendation,
    required this.onTap,
    required this.width,
    required this.showDistance,
  });

  final PlaceRecommendation recommendation;
  final VoidCallback onTap;
  final double width;
  final bool showDistance;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: AppPlaceHeroCard(
          place: recommendation.place,
          onTap: onTap,
          showDistance: showDistance,
        ),
      );
}

class _MouseDragScrollBehavior extends MaterialScrollBehavior {
  const _MouseDragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class _CommunitySuggestionsSection extends StatefulWidget {
  const _CommunitySuggestionsSection({
    required this.target,
    required this.onOpen,
  });

  final WeatherTarget target;
  final ValueChanged<Place> onOpen;

  @override
  State<_CommunitySuggestionsSection> createState() =>
      _CommunitySuggestionsSectionState();
}

class _CommunitySuggestionsSectionState
    extends State<_CommunitySuggestionsSection> {
  late Future<List<RankedCommunitySuggestion>> future;

  @override
  void initState() {
    super.initState();
    future = CommunitySuggestionsService.rankedFor(widget.target);
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FigmaSectionTitle('Topluluk Önerileri'),
          const SizedBox(height: 9),
          FutureBuilder<List<RankedCommunitySuggestion>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _CompactSectionLoading();
              }

              if (snapshot.hasError || (snapshot.data?.isEmpty ?? true)) {
                return Container(
                  height: 100,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.large),
                  ),
                  child: const Text(
                    'Konumuna göre topluluk önerileri şu anda alınamadı.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: Color(0xFF77736C),
                      fontSize: 11.5,
                    ),
                  ),
                );
              }

              final ranked = snapshot.data!;
              return SizedBox(
                height: 190,
                child: ScrollConfiguration(
                  behavior: const _MouseDragScrollBehavior(),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: ranked.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, index) {
                      final item = ranked[index];
                      return _CommunityCard(
                        suggestion: item.suggestion,
                        distanceKm: item.distanceKm,
                        width: 184,
                        onTap: () => widget.onOpen(item.suggestion.place),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      );
}

class _CategoryFeaturedSection extends StatefulWidget {
  const _CategoryFeaturedSection({
    required this.target,
    required this.mainCategory,
    required this.subtype,
    required this.label,
    required this.onOpen,
    required this.onExploreMap,
  });

  final WeatherTarget target;
  final String mainCategory;
  final String? subtype;
  final String label;
  final ValueChanged<Place> onOpen;
  final VoidCallback? onExploreMap;

  @override
  State<_CategoryFeaturedSection> createState() =>
      _CategoryFeaturedSectionState();
}

class _CategoryFeaturedSectionState extends State<_CategoryFeaturedSection> {
  late Future<List<Place>> future;
  double radiusKm = NearbyPlacesService.queryRadiusKm.toDouble();

  @override
  void initState() {
    super.initState();
    future = NearbyPlacesService.fetch(widget.target);
  }

  void retry() => setState(() {
        future = NearbyPlacesService.refresh(widget.target);
      });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FigmaSectionTitle(
            'Yakındaki ${widget.label}',
            action: '${radiusKm.round()} km içinde',
          ),
          const SizedBox(height: 8),
          Container(
            height: 48,
            padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.large),
              border: Border.all(color: const Color(0xFFE7E3DA)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  '1',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: Color(0xFF8A8680),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: green,
                      inactiveTrackColor: const Color(0xFFDDE5D7),
                      thumbColor: green,
                      overlayColor: green.withValues(alpha: .12),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 15,
                      ),
                    ),
                    child: Slider(
                      value: radiusKm,
                      min: 1,
                      max: NearbyPlacesService.queryRadiusKm.toDouble(),
                      divisions: NearbyPlacesService.queryRadiusKm - 1,
                      label: '${radiusKm.round()} km',
                      onChanged: (value) => setState(() => radiusKm = value),
                    ),
                  ),
                ),
                Text(
                  '${NearbyPlacesService.queryRadiusKm} km',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: Color(0xFF8A8680),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 7),
                Container(
                  width: 48,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: mint,
                    borderRadius: BorderRadius.circular(AppRadii.large),
                  ),
                  child: Text(
                    '${radiusKm.round()} km',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      color: green,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          FutureBuilder<List<Place>>(
            future: future,
            initialData: NearbyPlacesService.availableNow(widget.target),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const _CompactSectionLoading();
              }

              if (snapshot.hasError) {
                return Container(
                  height: 112,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.large),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Konuma göre kategori sonuçları alınamadı.',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            color: Color(0xFF66625C),
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                      TextButton(onPressed: retry, child: const Text('Yenile')),
                    ],
                  ),
                );
              }

              final results = (snapshot.data ?? const <Place>[]).where((place) {
                final taxonomy = place.resolvedTaxonomy;
                return taxonomy.mainCategory == widget.mainCategory &&
                    (widget.subtype == null ||
                        taxonomy.subtype == widget.subtype) &&
                    (place.distanceKm ?? double.infinity) <= radiusKm;
              }).toList(growable: false);
              if (results.isEmpty) {
                return _EmptyPlacesCard(
                  message:
                      '${radiusKm.round()} km çevrende kayıtlı ${widget.label.toLowerCase()} bulunamadı.',
                  actionLabel: 'Haritada keşfet',
                  actionIcon: Icons.map_outlined,
                  onAction: widget.onExploreMap ?? retry,
                  onRefresh: retry,
                );
              }

              return SizedBox(
                height: 190,
                child: ScrollConfiguration(
                  behavior: const _MouseDragScrollBehavior(),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, index) => _SmallPhotoCard(
                      place: results[index],
                      width: 184,
                      kindBelow: true,
                      onTap: () => widget.onOpen(results[index]),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
}

class _NearbyPlacesSection extends StatefulWidget {
  const _NearbyPlacesSection({
    super.key,
    required this.target,
    required this.preferredCategory,
    required this.onOpen,
    required this.onExploreMap,
    required this.onRequestLocation,
  });

  final WeatherTarget target;
  final String? preferredCategory;
  final ValueChanged<Place> onOpen;
  final VoidCallback? onExploreMap;
  final VoidCallback? onRequestLocation;

  @override
  State<_NearbyPlacesSection> createState() => _NearbyPlacesSectionState();
}

class _NearbyPlacesSectionState extends State<_NearbyPlacesSection> {
  late Future<List<Place>> future;

  @override
  void initState() {
    super.initState();
    future = widget.target.usesCoordinates
        ? NearbyPlacesService.fetch(widget.target)
        : Future.value(const <Place>[]);
  }

  void retry() => setState(() {
        future = widget.target.usesCoordinates
            ? NearbyPlacesService.refresh(widget.target)
            : Future.value(const <Place>[]);
      });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'Yakınındaki yerler',
            actionLabel: 'Tümünü gör',
            onAction: widget.onExploreMap,
          ),
          const SizedBox(height: 12),
          if (!widget.target.usesCoordinates)
            _LocationRequiredNearbyCard(
              onRequestLocation: widget.onRequestLocation ??
                  () => unawaited(HomeWeatherLocationController
                      .requestAndUseDeviceLocation()),
            )
          else
            FutureBuilder<List<Place>>(
              future: future,
              initialData: NearbyPlacesService.availableNow(widget.target),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const _CompactSectionLoading();
                }

                if (snapshot.hasError) {
                  return Container(
                    height: 122,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadii.large),
                      border: Border.all(color: const Color(0xFFE8E4DC)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_off_outlined,
                            color: Color(0xFF77736C), size: 25),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Yakındaki doğa noktaları şu anda alınamadı.',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              color: Color(0xFF66625C),
                              fontSize: 11.5,
                              height: 1.35,
                            ),
                          ),
                        ),
                        TextButton(
                            onPressed: retry, child: const Text('Yenile')),
                      ],
                    ),
                  );
                }

                final nearby = NearbyPlacesService.filterNearbyPlaces(
                  target: widget.target,
                  places: NearbyPlacesService.availableNow(widget.target),
                  preferredCategory: widget.preferredCategory,
                );
                if (nearby.isEmpty) {
                  return _EmptyPlacesCard(
                    message: '${NearbyPlacesService.queryRadiusKm} km çevrende '
                        'henüz kayıtlı bir doğa noktası yok.',
                    actionLabel: 'Haritada keşfet',
                    actionIcon: Icons.map_outlined,
                    onAction: widget.onExploreMap ?? retry,
                    onRefresh: retry,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...nearby.take(6).map(
                          (place) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: AppCompactPlaceCard(
                              place: place,
                              onTap: () => widget.onOpen(place),
                            ),
                          ),
                        ),
                  ],
                );
              },
            ),
        ],
      );
}

class _LocationRequiredNearbyCard extends StatelessWidget {
  const _LocationRequiredNearbyCard({required this.onRequestLocation});

  final VoidCallback onRequestLocation;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.medium),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadii.medium),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_off_outlined,
                color: AppColors.textSecondary, size: AppIconSizes.large),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Text(
                'Yakınındaki yerleri görmek için konum izni ver.',
                style: AppTypography.metadata.copyWith(fontSize: 13),
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            TextButton(
              onPressed: onRequestLocation,
              child: const Text('Konumu Aç'),
            ),
          ],
        ),
      );
}

class _LatestPlacesSection extends StatefulWidget {
  const _LatestPlacesSection({
    required this.target,
    required this.onOpen,
    required this.onAddPlace,
  });

  final WeatherTarget target;
  final ValueChanged<Place> onOpen;
  final VoidCallback? onAddPlace;

  @override
  State<_LatestPlacesSection> createState() => _LatestPlacesSectionState();
}

class _LatestPlacesSectionState extends State<_LatestPlacesSection> {
  late Future<List<Place>> future;

  @override
  void initState() {
    super.initState();
    future = NearbyPlacesService.fetchLatest(widget.target);
  }

  void retry() => setState(() {
        future = NearbyPlacesService.refresh(widget.target).then(
          (_) => NearbyPlacesService.availableLatestNow(widget.target),
        );
      });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FigmaSectionTitle('Yeni Eklenen'),
          const SizedBox(height: 8),
          FutureBuilder<List<Place>>(
            future: future,
            initialData: NearbyPlacesService.availableLatestNow(widget.target),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const _CompactSectionLoading();
              }

              if (snapshot.hasError) {
                return Container(
                  height: 86,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.large),
                    border: Border.all(color: const Color(0xFFE8E4DC)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Güncel yer kayıtları alınamadı.',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            color: Color(0xFF66625C),
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                      TextButton(onPressed: retry, child: const Text('Yenile')),
                    ],
                  ),
                );
              }

              final latest =
                  NearbyPlacesService.availableLatestNow(widget.target)
                      .where((place) => !isPlaceAmenity(place))
                      .toList(growable: false);
              if (latest.isEmpty) {
                return _EmptyPlacesCard(
                  height: 116,
                  message:
                      'Bu çevrede henüz yeni eklenmiş bir doğa noktası yok.',
                  actionLabel: 'İlk yeri sen ekle',
                  actionIcon: Icons.add_location_alt_outlined,
                  onAction: widget.onAddPlace ?? retry,
                  onRefresh: retry,
                );
              }

              return Column(
                children: [
                  ...latest.map(
                    (place) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PlaceRow(
                        place: place,
                        onTap: () => widget.onOpen(place),
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Son OSM güncellenme tarihine göre sıralandı',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: Color(0xFF98938B),
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      );
}

class _CompactSectionLoading extends StatelessWidget {
  const _CompactSectionLoading();

  @override
  Widget build(BuildContext context) => Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .72),
          borderRadius: BorderRadius.circular(AppRadii.large),
          border: Border.all(color: const Color(0xFFEAE6DE)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE9EDE5),
                borderRadius: BorderRadius.circular(AppRadii.large),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 138,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3E1DB),
                      borderRadius: BorderRadius.circular(AppRadii.large),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 88,
                    height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECE9E3),
                      borderRadius: BorderRadius.circular(AppRadii.large),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _EmptyPlacesCard extends StatelessWidget {
  const _EmptyPlacesCard({
    required this.message,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
    required this.onRefresh,
    this.height = 152,
  });

  final String message;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;
  final VoidCallback onRefresh;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.large),
          border: Border.all(color: const Color(0xFFE8E4DC)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Outfit',
                color: Color(0xFF77736C),
                fontSize: 11.5,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: onAction,
                  icon: Icon(actionIcon, size: 16),
                  label: Text(actionLabel),
                  style: TextButton.styleFrom(
                    foregroundColor: green,
                    backgroundColor: mint,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                TextButton(
                  onPressed: onRefresh,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF68645E),
                    textStyle: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Tekrar dene'),
                ),
              ],
            ),
          ],
        ),
      );
}

class _HomeWeatherCard extends StatefulWidget {
  const _HomeWeatherCard({
    required this.target,
    required this.isResolvingLocation,
  });

  final WeatherTarget target;
  final bool isResolvingLocation;

  @override
  State<_HomeWeatherCard> createState() => _HomeWeatherCardState();
}

class _HomeWeatherCardState extends State<_HomeWeatherCard> {
  Future<WeatherSnapshot>? future;

  @override
  void initState() {
    super.initState();
    if (!widget.isResolvingLocation) {
      future = WeatherService.fetchTarget(widget.target);
    }
  }

  @override
  void didUpdateWidget(covariant _HomeWeatherCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isResolvingLocation && !widget.isResolvingLocation) {
      future = WeatherService.fetchTarget(widget.target);
    }
  }

  void retry() => setState(() {
        future = WeatherService.fetchTarget(
          widget.target,
          forceRefresh: true,
        );
      });

  @override
  Widget build(BuildContext context) => Container(
        height: 140,
        padding: const EdgeInsets.fromLTRB(18, 14, 16, 11),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF174A0D), Color(0xFF4AA62B)],
          ),
          borderRadius: BorderRadius.circular(AppRadii.large),
          boxShadow: const [
            BoxShadow(
              color: Color(0x382B751A),
              blurRadius: 17,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: FutureBuilder<WeatherSnapshot>(
          future: future,
          builder: (context, snapshot) {
            if (widget.isResolvingLocation) {
              return const _ResolvingLocationWeatherContent();
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Row(children: [
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.1,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 11),
                Text(
                  '${widget.target.label} hava durumu alınıyor...',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ]);
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Row(children: [
                const Icon(Icons.cloud_off_outlined,
                    color: Colors.white, size: 27),
                const SizedBox(width: 11),
                const Expanded(
                  child: Text(
                    'Hava durumu alınamadı.',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: retry,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Yenile', style: TextStyle(fontSize: 10)),
                ),
              ]);
            }

            final weather = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.target.label.toUpperCase()}  •  ŞU AN',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .25,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, 4),
                      child: Text(
                        '${weather.temperature.round()}°',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          color: Colors.white,
                          fontSize: 42,
                          height: .95,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        weather.condition,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(weather.emoji,
                        style: const TextStyle(fontSize: 39, height: 1)),
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _weatherIsIdeal(weather)
                                  ? const Color(0xFF72E2B3)
                                  : const Color(0xFFFFD166),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _weatherOutdoorMessage(weather),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                color: Colors.white,
                                fontSize: 9.2,
                                height: 1.15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _HomeWeatherMetric(
                        '💧', '${weather.humidity.round()}%', 'Nem'),
                    const SizedBox(width: 6),
                    _HomeWeatherMetric(
                        '〰', '${weather.windSpeed.round()}km/s', 'Rüzgâr'),
                    const SizedBox(width: 6),
                    _HomeWeatherMetric(
                        '☀️', weather.uvIndex.round().toString(), 'UV'),
                  ],
                ),
              ],
            );
          },
        ),
      );
}

class _ResolvingLocationWeatherContent extends StatelessWidget {
  const _ResolvingLocationWeatherContent();

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(AppRadii.large),
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konum belirleniyor',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Hava durumu birazdan bulunduğun yere göre güncellenecek.',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.white70,
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

class _HomeWeatherMetric extends StatelessWidget {
  const _HomeWeatherMetric(this.icon, this.value, this.label);

  final String icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 12.5, height: 1)),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontSize: 10,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Outfit',
                color: Colors.white70,
                fontSize: 8.5,
                height: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}

bool _weatherIsIdeal(WeatherSnapshot weather) =>
    weather.weatherCode <= 3 && weather.windSpeed < 35 && weather.uvIndex < 8;

String _weatherOutdoorMessage(WeatherSnapshot weather) =>
    _weatherIsIdeal(weather)
        ? 'Doğaya çıkmak için ideal bir gün'
        : 'Doğaya çıkmak için ideal bir gün olmayabilir';

String _weatherUvValue(double value) {
  final level = value < 3
      ? 'Düşük'
      : value < 6
          ? 'Orta'
          : value < 8
              ? 'Yüksek'
              : 'Çok yüksek';
  return '${value.round()} $level';
}

class _HomeAdBanner extends StatelessWidget {
  const _HomeAdBanner();

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Reklam alanı',
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.medium),
            border: Border.all(color: AppColors.border),
          ),
          // TODO(admob): Gerçek reklam bağlantısında bu içeriği AdWidget ile değiştir.
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: mint,
                  borderRadius: BorderRadius.circular(AppRadii.small),
                ),
                child: const Icon(
                  Icons.campaign_outlined,
                  color: green,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SPONSORLU',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: Color(0xFF7D8C73),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .8,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Reklam alanı',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.small),
                ),
                child: const Text(
                  'Reklam',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: Color(0xFF8A8680),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _FigmaSectionTitle extends StatelessWidget {
  const _FigmaSectionTitle(this.title, {this.action});
  final String title;
  final String? action;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 19,
                    height: 1.12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -.2,
                    color: ink))),
        if (action != null)
          Text(action!,
              style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3A6B1E)))
      ]);
}

// ignore: unused_element
class _MiniCategory extends StatelessWidget {
  const _MiniCategory(
    this.icon,
    this.label,
    this.color,
    this.background, {
    required this.selected,
    required this.onTap,
  });
  final String icon;
  final String label;
  final Color color;
  final Color background;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: '$label kategorisini göster',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.medium),
          child: SizedBox(
            width: 70,
            child: Column(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: selected ? green : background,
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                  border: Border.all(
                    color: selected ? green : color.withValues(alpha: .08),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 8.5,
                  height: 1.05,
                  color: selected ? green : const Color(0xFF5A5650),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ]),
          ),
        ),
      );
}

class _HeroPlace extends StatelessWidget {
  const _HeroPlace({required this.place, required this.onTap});
  final Place place;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
          height: 195,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.large),
              border: Border.all(color: AppColors.border)),
          child: Stack(fit: StackFit.expand, children: [
            NatureArt(place: place, radius: 0, showKind: false),
            const DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC000000)]))),
            Positioned(
                left: 14,
                top: 12,
                child: Row(children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                          color: const Color(0xFFC4622D),
                          borderRadius: BorderRadius.circular(AppRadii.large)),
                      child: const Text('ÖNE ÇIKAN',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w700))),
                  const SizedBox(width: 6),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                          color: const Color(0xCC3A6B1E),
                          borderRadius: BorderRadius.circular(AppRadii.large)),
                      child: Text(place.kind.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w700)))
                ])),
            Positioned(
                left: 15,
                right: 15,
                bottom: 13,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.name,
                          style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: Colors.white,
                              fontSize: 20,
                              height: 1.08,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -.25)),
                      Text(place.location,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 9)),
                      const SizedBox(height: 7),
                      Row(children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFB22D), size: 13),
                        Text(' ${place.rating}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700)),
                        const Spacer(),
                      ])
                    ]))
          ])));
}

class _SmallPhotoCard extends StatelessWidget {
  const _SmallPhotoCard({
    required this.place,
    required this.onTap,
    this.kindBelow = false,
    this.width = 154,
  });
  final Place place;
  final VoidCallback onTap;
  final bool kindBelow;
  final double width;
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
          width: width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.medium),
              border: Border.all(color: AppColors.border)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Stack(fit: StackFit.expand, children: [
              NatureArt(place: place, radius: 0, showKind: !kindBelow),
              if (kindBelow)
                Positioned(
                    left: 9,
                    bottom: 8,
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF5F7EF),
                            borderRadius:
                                BorderRadius.circular(AppRadii.small)),
                        child: Text(place.kind,
                            style: const TextStyle(
                                color: green,
                                fontSize: 7.5,
                                fontWeight: FontWeight.w600)))),
              if (kindBelow)
                const Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                        radius: 13,
                        backgroundColor: Color(0x88000000),
                        child: Icon(Icons.favorite_border_rounded,
                            color: Colors.white, size: 15)))
            ])),
            Padding(
                padding: const EdgeInsets.fromLTRB(9, 7, 9, 8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13.5,
                              height: 1.1,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Expanded(
                          child: Text(
                            place.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: Color(0xFF8A8680),
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (place.distanceKm != null) ...[
                          const Icon(Icons.near_me_rounded,
                              size: 12, color: green),
                          const SizedBox(width: 3),
                          Text(
                            '${place.distanceKm!.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: green,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ] else ...[
                          const Icon(Icons.star_rounded,
                              size: 13, color: Color(0xFFFFA000)),
                          Text('${place.rating}',
                              style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ])
                    ]))
          ])));
}

class _CommunityCard extends StatelessWidget {
  const _CommunityCard({
    required this.suggestion,
    required this.distanceKm,
    required this.onTap,
    this.width = 184,
  });

  final CommunitySuggestion suggestion;
  final double distanceKm;
  final VoidCallback onTap;
  final double width;

  String get distanceLabel => distanceKm < 100
      ? '${distanceKm.toStringAsFixed(1)} km'
      : '${distanceKm.round()} km';

  String get categoryEmoji {
    if (suggestion.place.kind.contains('Göl')) return '🌊';
    if (suggestion.place.kind.contains('Yürüyüş')) return '🥾';
    if (suggestion.place.kind.contains('Kamp')) return '🏕️';
    return '🌿';
  }

  Color get categoryColor {
    if (suggestion.place.kind.contains('Göl')) return const Color(0xFF3478B8);
    if (suggestion.place.kind.contains('Yürüyüş')) {
      return const Color(0xFFA56228);
    }
    if (suggestion.place.kind.contains('Kamp')) {
      return const Color(0xFFC5672A);
    }
    return green;
  }

  Color get categoryBackground {
    if (suggestion.place.kind.contains('Göl')) return const Color(0xFFEDF6FC);
    if (suggestion.place.kind.contains('Yürüyüş')) {
      return const Color(0xFFFFF4E7);
    }
    if (suggestion.place.kind.contains('Kamp')) {
      return const Color(0xFFFFF0E8);
    }
    return mint;
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.large),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 142,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NatureArt(
                      place: suggestion.place,
                      radius: 0,
                      showKind: false,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xD9000000)],
                          stops: [.34, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 9,
                      right: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xB8000000),
                          borderRadius: BorderRadius.circular(AppRadii.large),
                        ),
                        child: Text(
                          '👥 ${suggestion.recommendationCount} kişi önerdi',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            color: Colors.white,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 10,
                      bottom: 54,
                      child: _CommunityAvatars(),
                    ),
                    Positioned(
                      left: 10,
                      right: 8,
                      bottom: 27,
                      child: Text(
                        suggestion.place.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          color: Colors.white,
                          fontSize: 15,
                          height: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      right: 8,
                      bottom: 10,
                      child: Text(
                        '${suggestion.place.location} · $distanceLabel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          color: Color(0xFFE8E8E3),
                          fontSize: 9,
                          height: 1,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: categoryBackground,
                            borderRadius: BorderRadius.circular(AppRadii.large),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(categoryEmoji,
                                  style:
                                      const TextStyle(fontSize: 9, height: 1)),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  suggestion.place.kind,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    color: categoryColor,
                                    fontSize: 9,
                                    height: 1,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFA000), size: 14),
                      Text(
                        ' ${suggestion.place.rating}',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          color: ink,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        ' (0)',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          color: Color(0xFF8A8680),
                          fontSize: 8.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _CommunityAvatars extends StatelessWidget {
  const _CommunityAvatars();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 52,
        height: 22,
        child: Stack(
          children: const [
            _CommunityAvatar(left: 0, letter: 'A', color: Color(0xFF4B8A38)),
            _CommunityAvatar(left: 14, letter: 'B', color: Color(0xFFD36B45)),
            _CommunityAvatar(left: 28, letter: 'C', color: Color(0xFF3C8DB6)),
          ],
        ),
      );
}

class _CommunityAvatar extends StatelessWidget {
  const _CommunityAvatar({
    required this.left,
    required this.letter,
    required this.color,
  });

  final double left;
  final String letter;
  final Color color;

  @override
  Widget build(BuildContext context) => Positioned(
        left: left,
        child: Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Text(
            letter,
            style: const TextStyle(
              fontFamily: 'Outfit',
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}

class _PlaceRow extends StatelessWidget {
  const _PlaceRow({required this.place, required this.onTap});
  final Place place;
  final VoidCallback onTap;

  String get categoryEmoji {
    if (place.kind.contains('Su Kaynağı')) return '💧';
    if (place.kind.contains('Doğal Kaynak') || place.kind.contains('Şelale')) {
      return '🌊';
    }
    if (place.kind.contains('Göl')) return '🏞️';
    if (place.kind.contains('Kamp')) return '🏕️';
    if (place.kind.contains('Piknik')) return '🌿';
    if (place.kind.contains('Yürüyüş')) return '🥾';
    if (place.kind.contains('Seyir')) return '🔭';
    if (place.kind.contains('Mağara')) return '🪨';
    if (place.kind.contains('Karavan')) return '🚐';
    if (place.kind.contains('Milli Park')) return '🌲';
    return '🌿';
  }

  Color get categoryColor {
    if (place.kind.contains('Göl') || place.kind.contains('Kaynak')) {
      return const Color(0xFF3478B8);
    }
    if (place.kind.contains('Kamp')) return const Color(0xFFC5672A);
    if (place.kind.contains('Mağara')) return const Color(0xFF887A70);
    if (place.kind.contains('Karavan')) return const Color(0xFFC08332);
    return const Color(0xFF39751E);
  }

  String get distance {
    if (place.distanceKm != null) {
      return '${place.distanceKm!.toStringAsFixed(1)} km';
    }
    return 'Mesafe bilgisi yok';
  }

  String get updatedLabel {
    final date = place.updatedAt;
    if (date == null) return 'OSM';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
          height: 82,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.large),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 10,
                    offset: Offset(0, 3))
              ]),
          child: Row(children: [
            SizedBox(
                width: 62,
                child: NatureArt(place: place, radius: 13, showKind: false)),
            const SizedBox(width: 13),
            Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Flexible(
                        child: Text(place.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 13.5,
                                height: 1.1,
                                fontWeight: FontWeight.w600))),
                    const SizedBox(width: 6),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                            color: mint,
                            borderRadius:
                                BorderRadius.circular(AppRadii.medium)),
                        child: const Text('YENİ',
                            style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 8,
                                color: green,
                                fontWeight: FontWeight.w700)))
                  ]),
                  const SizedBox(height: 7),
                  Row(children: [
                    Text(categoryEmoji,
                        style: const TextStyle(fontSize: 12, height: 1)),
                    const SizedBox(width: 3),
                    Flexible(
                        child: Text(place.kind,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 10.5,
                                height: 1,
                                color: categoryColor,
                                fontWeight: FontWeight.w600))),
                    const Text('  ·  ',
                        style:
                            TextStyle(fontSize: 10, color: Color(0xFFAAA59E))),
                    Flexible(
                        child: Text(place.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 10.5,
                                height: 1,
                                color: Color(0xFF8A8680))))
                  ])
                ])),
            const SizedBox(width: 8),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (place.sourceId != null)
                Row(children: [
                  const Icon(Icons.update_rounded, color: green, size: 13),
                  const SizedBox(width: 3),
                  Text(updatedLabel,
                      style: const TextStyle(
                          fontFamily: 'Outfit',
                          color: green,
                          fontSize: 9,
                          fontWeight: FontWeight.w600)),
                ])
              else
                Row(children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFFFA000), size: 15),
                  Text(' ${place.rating}',
                      style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700)),
                  const Text(' (0)',
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 9,
                          color: Color(0xFF8A8680)))
                ]),
              const SizedBox(height: 8),
              Text(distance,
                  style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 9.5,
                      color: Color(0xFF8A8680)))
            ]),
            const SizedBox(width: 4)
          ])));
}
