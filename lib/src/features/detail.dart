part of '../../main.dart';

bool isSafeExternalUrl(Uri? uri) =>
    uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

String? placeCoordinatesForClipboard(Place place) {
  if (!place.hasCoordinates) return null;
  return '${place.latitude!.toStringAsFixed(6)}, '
      '${place.longitude!.toStringAsFixed(6)}';
}

List<Place> filterNearbyDetailPlaces({
  required Place origin,
  required Iterable<Place> candidates,
}) {
  if (!origin.hasCoordinates) return const <Place>[];
  final seen = <String>{};
  final result = <Place>[];
  for (final place in candidates) {
    if (!place.hasCoordinates || place.isUtility) continue;
    final distance = NearbyPlacesService.calculateDistanceKm(
      origin.latitude!,
      origin.longitude!,
      place.latitude!,
      place.longitude!,
    );
    if (distance < .05 || distance > NearbyPlacesService.queryRadiusKm) {
      continue;
    }
    final key = place.sourceId ??
        '${place.name.trim().toLowerCase()}:'
            '${place.latitude!.toStringAsFixed(4)}:'
            '${place.longitude!.toStringAsFixed(4)}';
    if (!seen.add(key)) continue;
    result.add(Place(
      place.name,
      place.location,
      place.kind,
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
      mainCategory: place.resolvedTaxonomy.mainCategory,
      subtype: place.resolvedTaxonomy.subtype,
      facilities: place.facilities,
    ));
  }
  result.sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));
  return result.take(12).toList(growable: false);
}

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.place,
    required this.favorite,
    required this.onFavorite,
    this.onOpen,
    this.onShowOnMap,
  });
  final Place place;
  final bool favorite;
  final VoidCallback onFavorite;
  final ValueChanged<Place>? onOpen;
  final ValueChanged<Place>? onShowOnMap;
  @override
  State<DetailScreen> createState() => _FigmaDetailScreenState();
}

class _FigmaDetailScreenState extends State<DetailScreen> {
  late bool favorite = widget.favorite;
  late Future<WeatherSnapshot> weatherFuture;
  late Future<DrivingRouteEstimate?> drivingRouteFuture;
  final scrollController = ScrollController();
  final photoSectionKey = GlobalKey();
  final reviewsSectionKey = GlobalKey();
  final helpfulReviewIds = <String>{};
  bool collapsed = false;
  String? userReview;
  int userRating = 0;
  DateTime? userReviewCreatedAt;
  String? userReviewSocialHandle;
  String? userReviewSocialPlatform;
  bool? userRecommendation;
  List<String> userRecommendationReasons = const [];
  PlaceEnrichment? enrichment;
  List<NearbyAmenity>? nearbyAmenities;
  bool nearbyAmenitiesLoading = false;
  String? nearbyAmenitiesError;
  PlaceViewStats? placeViews;
  Timer? _dwellTimer;

  Place placeWithImage(String image) => Place(
        widget.place.name,
        widget.place.location,
        widget.place.kind,
        widget.place.rating,
        widget.place.icon,
        widget.place.colors,
        image,
        description: widget.place.description,
        latitude: widget.place.latitude,
        longitude: widget.place.longitude,
        distanceKm: widget.place.distanceKm,
        sourceId: widget.place.sourceId,
        updatedAt: widget.place.updatedAt,
        source: widget.place.source,
        verificationStatus: widget.place.verificationStatus,
        features: widget.place.features,
        mainCategory: widget.place.mainCategory,
        subtype: widget.place.subtype,
        facilities: widget.place.facilities,
      );

  Place get displayPlace {
    final enrichedImage = enrichment?.primaryPhoto?.url;
    if ((widget.place.image?.trim().isNotEmpty ?? false) ||
        enrichedImage == null ||
        enrichedImage.isEmpty) {
      return widget.place;
    }
    return placeWithImage(enrichedImage);
  }

  List<Place> get galleryPlaces {
    final urls = <String>[];
    final communityPhotos =
        CommunityPlacePhotosController.forPlace(widget.place);
    for (final cp in communityPhotos) {
      if (cp.imageUrl.isNotEmpty && !urls.contains(cp.imageUrl)) {
        urls.add(cp.imageUrl);
      }
    }
    final existing = widget.place.image?.trim();
    if (existing != null && existing.isNotEmpty && !urls.contains(existing)) {
      urls.add(existing);
    }
    for (final photo in enrichment?.photos ?? const <PlacePhotoInfo>[]) {
      if (photo.url.isNotEmpty && !urls.contains(photo.url)) {
        urls.add(photo.url);
      }
    }
    return urls.map(placeWithImage).toList(growable: false);
  }

  List<Place> get nearbyPlaces => filterNearbyDetailPlaces(
        origin: widget.place,
        candidates: [
          ...NearbyPlacesService.availableNow(widget.place.weatherTarget),
          ...SupabasePlacesController.places.value,
          ...UserPlacesController.places.value,
        ],
      );

  List<ReviewEntry> get allReviews {
    final savedRecords = UserReviewsController.forPlace(widget.place);
    final entries = <ReviewEntry>[];
    for (final r in savedRecords) {
      if (r.content.isNotEmpty) {
        entries.add(r.toEntry());
      }
    }
    if (entries.isNotEmpty) return entries;
    final now = DateTime.now();
    if (userReview == null || userReview!.isEmpty) return const <ReviewEntry>[];
    return <ReviewEntry>[
      ReviewEntry(
        id: 'user-${widget.place.name}',
        initial: 'S',
        color: green,
        name: 'Sen',
        timeLabel: 'Şimdi',
        createdAt: userReviewCreatedAt ?? now,
        content: userReview!,
        rating: userRating,
        helpfulCount: 0,
        socialHandle: userReviewSocialHandle,
        socialPlatform: userReviewSocialPlatform,
      ),
    ];
  }

  String get detailDescription {
    final aboutText = enrichment?.aboutText.trim() ?? '';
    if (aboutText.isNotEmpty) return aboutText;
    return widget.place.description.trim().isEmpty
        ? AppStrings.get('card_no_description')
        : widget.place.description.trim();
  }

  String get coordinateLabel {
    if (!widget.place.hasCoordinates) {
      return AppStrings.get('card_no_coordinates');
    }
    final latitude = widget.place.latitude!;
    final longitude = widget.place.longitude!;
    return '${latitude.abs().toStringAsFixed(5)}°${latitude >= 0 ? 'K' : 'G'}  '
        '${longitude.abs().toStringAsFixed(5)}°${longitude >= 0 ? 'D' : 'B'}';
  }

  String get sourceLabel => switch (widget.place.source) {
        PlaceSource.osm => 'OpenStreetMap',
        PlaceSource.user => AppStrings.get('source_community'),
        PlaceSource.curated => 'Doğadayım',
      };

  String get updatedAtLabel {
    final date = widget.place.updatedAt;
    if (date == null) return AppStrings.get('card_no_date');
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String get userDistanceLabel {
    final target = HomeWeatherLocationController.current.value;
    if (!target.usesCoordinates || !widget.place.hasCoordinates) {
      return AppStrings.get('card_location_required');
    }
    final distance = NearbyPlacesService.calculateDistanceKm(
      target.latitude!,
      target.longitude!,
      widget.place.latitude!,
      widget.place.longitude!,
    );
    return distance < 10
        ? '${distance.toStringAsFixed(1)} km'
        : '${distance.toStringAsFixed(0)} km';
  }

  Future<DrivingRouteEstimate?> loadDrivingRoute() async {
    if (!widget.place.hasCoordinates) {
      return null;
    }
    var target = HomeWeatherLocationController.current.value;
    try {
      final coordinates = await DeviceLocationService.requestCurrentPosition();
      target = WeatherTarget.coordinates(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
        label: coordinates.label,
      );
    } catch (_) {
      // Yeni konum alınamazsa daha önce izinle alınmış konum kullanılabilir.
    }
    if (!target.usesCoordinates) return null;
    return DrivingRouteService.fetch(
      fromLatitude: target.latitude!,
      fromLongitude: target.longitude!,
      toLatitude: widget.place.latitude!,
      toLongitude: widget.place.longitude!,
    );
  }

  String get placeSourceLabel => switch (widget.place.source) {
        PlaceSource.osm => 'OSM',
        PlaceSource.user => 'Topluluk',
        PlaceSource.curated => 'Doğadayım',
      };

  Widget journeyStats() => FutureBuilder<DrivingRouteEstimate?>(
        future: drivingRouteFuture,
        builder: (context, snapshot) {
          final route = snapshot.data;
          final waiting = snapshot.connectionState == ConnectionState.waiting;
          final hasFallbackDistance =
              userDistanceLabel != AppStrings.get('card_location_required') &&
                  userDistanceLabel.trim().isNotEmpty;
          final fallbackDistance =
              hasFallbackDistance ? '~$userDistanceLabel' : userDistanceLabel;
          final distance = route?.distanceLabel ??
              (hasFallbackDistance
                  ? fallbackDistance
                  : (waiting
                      ? AppStrings.get('card_calculating')
                      : fallbackDistance));
          final distanceTitle = route != null
              ? AppStrings.get('card_road_distance')
              : (hasFallbackDistance
                  ? AppStrings.get('card_crow_distance')
                  : (waiting
                      ? AppStrings.get('card_distance')
                      : AppStrings.get('card_crow_distance')));
          final duration = route?.durationLabel ??
              (waiting
                  ? AppStrings.get('card_calculating')
                  : AppStrings.get('card_route_not_found'));
          return Row(children: [
            stat(Icons.route_outlined, distance, distanceTitle),
            const SizedBox(width: 9),
            stat(Icons.schedule_outlined, duration,
                AppStrings.get('card_arrival_time')),
            const SizedBox(width: 9),
            stat(widget.place.icon, widget.place.kind,
                AppStrings.get('card_place_type')),
            const SizedBox(width: 9),
            stat(Icons.verified_outlined, placeSourceLabel,
                AppStrings.get('card_data_source')),
          ]);
        },
      );

  Widget tripReadinessCard(bool isDark) {
    final roadAccess = widget.place.roadAccess;
    final knownFacilities = widget.place.facilities.values.entries
        .where((entry) => entry.value == true)
        .map((entry) => facilityDisplayLabel(entry.key))
        .take(2)
        .toList(growable: false);
    final facilitiesLabel = knownFacilities.isEmpty
        ? 'Tesis bilgisi henüz eklenmedi'
        : knownFacilities.join(' · ');
    final roadLabel = roadAccess == null || roadAccess.trim().isEmpty
        ? 'Ulaşım bilgisi henüz doğrulanmadı'
        : 'Ulaşım bilgisi mevcut';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.large),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.hiking_rounded,
                size: 18,
                color: isDark ? AppColors.darkPrimaryLight : AppColors.primary,
              ),
              const SizedBox(width: 7),
              Text(
                'Gitmeden önce',
                style: AppTypography.headingOf(context).copyWith(
                  fontSize: AppFontSizes.body,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            detailDescription,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.metadataOf(context).copyWith(height: 1.35),
          ),
          const SizedBox(height: 10),
          _PlaceTrustSummary(place: widget.place),
          const SizedBox(height: 10),
          _TripReadinessFact(
            icon: Icons.route_outlined,
            label: roadLabel,
          ),
          const SizedBox(height: 6),
          _TripReadinessFact(
            icon: Icons.fact_check_outlined,
            label: facilitiesLabel,
          ),
        ],
      ),
    );
  }

  Widget facilitiesSection() {
    final facilities = widget.place.facilities;
    final enrichedAmenities = enrichment?.amenities ?? const [];
    final available = facilityLabels.keys
        .where((key) => facilities.values[key] == true)
        .map((key) => MapEntry(key, facilityDisplayLabel(key)))
        .toList(growable: false);
    final nearby = nearbyFacilityLabels.keys
        .where((key) => facilities.values[key] == true)
        .map((key) => MapEntry(key, facilityDisplayLabel(key)))
        .toList(growable: false);

    Widget chips(Iterable<MapEntry<String, String>> entries,
            {bool showDistance = false}) =>
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: entries.map((entry) {
            final distance = facilities.nearbyDistances[entry.key];
            final label = showDistance && distance != null
                ? '${entry.value} · $distance m'
                : entry.value;
            return Chip(
              avatar: const Icon(Icons.check_circle_outline_rounded,
                  size: 17, color: green),
              label: Text(label),
              backgroundColor: AppColors.primarySoft,
              side: const BorderSide(color: AppColors.border),
            );
          }).toList(growable: false),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldConditionsCard(
          place: widget.place,
          enrichment: enrichment,
        ),
        if (enrichedAmenities.isNotEmpty ||
            available.isNotEmpty ||
            nearby.isNotEmpty) ...[
          const SizedBox(height: 16),
          if (enrichedAmenities.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: enrichedAmenities.map((amenity) {
                final localizedName = facilityDisplayLabel(amenity.type);
                final display = localizedName != amenity.type
                    ? localizedName
                    : amenity.label;
                final distance = amenity.distanceMeters;
                final label =
                    distance == null ? display : '$display · $distance m';
                return Tooltip(
                  message: [amenity.name, amenity.source]
                      .whereType<String>()
                      .where((value) => value.isNotEmpty)
                      .join(' · '),
                  child: Chip(
                    avatar: const Icon(Icons.verified_outlined,
                        size: 17, color: green),
                    label: Text(label),
                    backgroundColor: AppColors.primarySoft,
                    side: const BorderSide(color: AppColors.border),
                  ),
                );
              }).toList(growable: false),
            ),
          if (enrichedAmenities.isNotEmpty &&
              (available.isNotEmpty || nearby.isNotEmpty))
            const SizedBox(height: 10),
          if (available.isNotEmpty) chips(available),
          if (nearby.isNotEmpty) ...[
            if (available.isNotEmpty) const SizedBox(height: 14),
            Text(
              AppStrings.get('detail_nearby'),
              style: const TextStyle(fontWeight: FontWeight.w700, color: green),
            ),
            const SizedBox(height: 8),
            chips(nearby, showDistance: true),
          ],
        ],
        if (widget.place.hasCoordinates) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: nearbyAmenitiesLoading ? null : loadNearbyAmenities,
              icon: nearbyAmenitiesLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.near_me_outlined),
              label: Text(
                nearbyAmenities == null
                    ? 'Yakınımda ne var?'
                    : '2 km çevresindeki olanaklar',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: green,
                side: const BorderSide(color: green),
              ),
            ),
          ),
          if (nearbyAmenities != null) ...[
            const SizedBox(height: 10),
            if (nearbyAmenities!.isEmpty)
              Text(
                '2 km çevrede kayıtlı çeşme, içme suyu veya WC bulunamadı.',
                style: AppTypography.metadataOf(context),
              )
            else
              ...nearbyAmenities!.map(
                (amenity) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    minTileHeight: 48,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    leading: Icon(amenity.icon, color: green),
                    title: Text(
                      amenity.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(amenity.typeLabel),
                    trailing: Text('${amenity.distanceMeters} m'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      side: BorderSide(color: AppColors.borderOf(context)),
                    ),
                  ),
                ),
              ),
          ],
          if (nearbyAmenitiesError != null) ...[
            const SizedBox(height: 10),
            Text(
              nearbyAmenitiesError!,
              style: AppTypography.metadataOf(context).copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget nearbyPlacesSection() {
    final nearby = nearbyPlaces;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading('Buraya Yakın Yerler'),
        const SizedBox(height: 3),
        Text(
          '${widget.place.name} merkez alınarak yakından uzağa sıralanır.',
          style: TextStyle(
            fontFamily: 'Outfit',
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
            fontSize: AppFontSizes.caption,
          ),
        ),
        const SizedBox(height: 12),
        if (nearby.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.large),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: Text(
              'Bu noktaya ${NearbyPlacesService.queryRadiusKm} km mesafede '
              'başka bir doğa noktası bulunamadı.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                fontSize: AppFontSizes.caption,
              ),
            ),
          )
        else
          SizedBox(
            height: 164,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: nearby.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) => _SmallPhotoCard(
                place: nearby[index],
                kindBelow: true,
                onTap: () => widget.onOpen?.call(nearby[index]),
              ),
            ),
          ),
      ],
    );
  }

  void refreshUserDistance() {
    if (!mounted) return;
    setState(() => drivingRouteFuture = loadDrivingRoute());
  }

  @override
  void initState() {
    super.initState();
    _loadSavedReview();
    _initPlaceViews();
    UserReviewsController.reviews.addListener(_onReviewsChanged);
    weatherFuture = widget.place.showsWeather
        ? WeatherService.fetchTarget(widget.place.weatherTarget)
        : Completer<WeatherSnapshot>().future;
    drivingRouteFuture = loadDrivingRoute();
    HomeWeatherLocationController.current.addListener(refreshUserDistance);
    NearbyPlacesService.revision.addListener(refreshNearbyPlaces);
    UserPlacesController.places.addListener(refreshNearbyPlaces);
    unawaited(NearbyPlacesService.fetch(widget.place.weatherTarget));
    unawaited(loadEnrichment());
    scrollController.addListener(() {
      final next = scrollController.offset > 250;
      if (next != collapsed) setState(() => collapsed = next);
    });
  }

  void _initPlaceViews() {
    final pKey = UserReviewsController.placeKey(widget.place);
    PlaceViewService.fetchPlaceViews(pKey).then((stats) {
      if (mounted && stats != null) {
        setState(() => placeViews = stats);
      }
    });

    _dwellTimer = Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;
      try {
        final now = DateTime.now();
        final dayKey =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final storageKey = 'view_counted_${pKey}_$dayKey';
        final prefs = await SharedPreferences.getInstance();
        final alreadyViewed = prefs.getBool(storageKey) ?? false;
        if (!alreadyViewed) {
          final updated = await PlaceViewService.recordView(pKey);
          await prefs.setBool(storageKey, true);
          if (mounted && updated != null) {
            setState(() => placeViews = updated);
          }
        }
      } catch (_) {}
    });
  }

  void _onReviewsChanged() {
    if (!mounted) return;
    _loadSavedReview();
    setState(() {});
  }

  void _loadSavedReview() {
    final saved = UserReviewsController.userReviewForPlace(widget.place);
    if (saved != null) {
      if (saved.content.isNotEmpty) {
        userReview = saved.content;
        userRating = saved.rating;
        userReviewCreatedAt = saved.createdAt;
        userReviewSocialHandle = saved.socialHandle;
        userReviewSocialPlatform = saved.socialPlatform;
      }
      if (saved.recommended != null) {
        userRecommendation = saved.recommended;
        userRecommendationReasons = saved.recommendationReasons;
      }
    }
  }

  Future<void> loadEnrichment() async {
    final result = await PlaceEnrichmentService.find(widget.place);
    if (mounted && result != null) setState(() => enrichment = result);
  }

  Future<void> loadNearbyAmenities() async {
    if (nearbyAmenitiesLoading || !widget.place.hasCoordinates) return;
    setState(() => nearbyAmenitiesLoading = true);
    try {
      final result = await NearbyAmenitiesService.fetchFor(widget.place);
      if (!mounted) return;
      setState(() {
        nearbyAmenitiesLoading = false;
        nearbyAmenities = result;
        nearbyAmenitiesError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        nearbyAmenitiesLoading = false;
        nearbyAmenitiesError =
            'Yakındaki olanaklar şu anda alınamadı. Lütfen tekrar dene.';
      });
    }
  }

  Widget aboutSourcesSection() {
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    UserReviewsController.reviews.removeListener(_onReviewsChanged);
    HomeWeatherLocationController.current.removeListener(refreshUserDistance);
    NearbyPlacesService.revision.removeListener(refreshNearbyPlaces);
    UserPlacesController.places.removeListener(refreshNearbyPlaces);
    scrollController.dispose();
    super.dispose();
  }

  void refreshNearbyPlaces() {
    if (mounted) setState(() {});
  }

  void toggleFavorite() {
    widget.onFavorite();
    setState(() => favorite = !favorite);
  }

  Future<void> copyCoordinates() async {
    final coordinates = placeCoordinatesForClipboard(widget.place);
    if (coordinates == null) return;
    await Clipboard.setData(ClipboardData(text: coordinates));
    if (mounted) message(AppStrings.get('nav_coords_copied'));
  }

  Future<void> startNavigation() async {
    if (!widget.place.hasCoordinates) {
      message('Bu yer için geçerli koordinat bulunmuyor.');
      return;
    }

    final rawName = widget.place.name.trim();
    final rawLocation = widget.place.location.trim();
    final searchTarget = rawLocation.isNotEmpty &&
            !rawName.toLowerCase().contains(rawLocation.toLowerCase())
        ? '$rawName, $rawLocation'
        : rawName;

    final provider = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surfaceOf(context),
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.large),
      ),
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.get('nav_select_app'),
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: AppColors.textPrimaryOf(context),
                  fontSize: AppFontSizes.title,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              _NavigationProviderTile(
                icon: Icons.map_outlined,
                label: 'Haritada Göster',
                subtitle: 'Uygulama içi haritada yeri görüntüle ve odakla',
                onTap: () => Navigator.pop(sheetContext, 'in_app_map'),
              ),
              _NavigationProviderTile(
                icon: Icons.place_rounded,
                label: AppStrings.get('nav_google_smart'),
                subtitle: AppStrings.get('nav_google_smart_desc'),
                onTap: () => Navigator.pop(sheetContext, 'google_smart'),
              ),
              _NavigationProviderTile(
                icon: Icons.gps_fixed_rounded,
                label: AppStrings.get('nav_google_coord'),
                subtitle: AppStrings.get('nav_google_coord_desc'),
                onTap: () => Navigator.pop(sheetContext, 'google_coord'),
              ),
              _NavigationProviderTile(
                icon: Icons.directions_outlined,
                label: AppStrings.get('nav_apple'),
                subtitle: AppStrings.get('nav_apple_desc'),
                onTap: () => Navigator.pop(sheetContext, 'apple'),
              ),
              _NavigationProviderTile(
                icon: Icons.navigation_outlined,
                label: AppStrings.get('nav_yandex'),
                subtitle: AppStrings.get('nav_yandex_desc'),
                onTap: () => Navigator.pop(sheetContext, 'yandex'),
              ),
              _NavigationProviderTile(
                icon: Icons.copy_rounded,
                label: AppStrings.get('nav_copy_coords'),
                subtitle:
                    '${widget.place.latitude!.toStringAsFixed(5)}, ${widget.place.longitude!.toStringAsFixed(5)}',
                onTap: () => Navigator.pop(sheetContext, 'copy'),
              ),
            ],
          ),
        ),
      ),
    );
    if (provider == null || !mounted) return;

    if (provider == 'in_app_map') {
      widget.onShowOnMap?.call(widget.place);
      return;
    }

    if (provider == 'copy') {
      await Clipboard.setData(
        ClipboardData(
          text: '${widget.place.latitude},${widget.place.longitude}',
        ),
      );
      if (mounted) {
        message(AppStrings.get('nav_coords_copied'));
      }
      return;
    }

    final latitude = widget.place.latitude!;
    final longitude = widget.place.longitude!;
    final destination = '$latitude,$longitude';
    final uri = switch (provider) {
      'google_smart' => Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(searchTarget)}',
        ),
      'apple' => Uri.parse(
          'https://maps.apple.com/?daddr=$destination&q=${Uri.encodeComponent(rawName)}&dirflg=d',
        ),
      'yandex' => Uri.parse(
          'https://yandex.com/maps/?rtext=~$destination&rtt=auto',
        ),
      _ => Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$destination',
        ),
    };

    if (!isSafeExternalUrl(uri)) {
      if (mounted) message('Seçilen harita uygulaması açılamadı.');
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      message('Seçilen harita uygulaması açılamadı.');
    }
  }

  void refreshWeather() {
    if (!widget.place.showsWeather) return;
    setState(() {
      weatherFuture = WeatherService.fetchTarget(
        widget.place.weatherTarget,
        forceRefresh: true,
      );
    });
  }

  void message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> scrollToPhotos() async {
    final sectionContext = photoSectionKey.currentContext;
    if (sectionContext == null) return;
    await Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
      alignment: .08,
    );
  }

  Future<void> scrollToReviews() async {
    final sectionContext = reviewsSectionKey.currentContext;
    if (sectionContext == null) return;
    await Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
      alignment: .07,
    );
  }

  Future<void> openGallery(int initialIndex) {
    if (galleryPlaces.isEmpty) return Future.value();
    return showDialog<void>(
      context: context,
      barrierColor: AppColors.shadow80,
      builder: (_) => _PhotoGalleryDialog(
        photos: galleryPlaces,
        placeName: widget.place.name,
        initialIndex: initialIndex,
      ),
    );
  }

  void toggleHelpful(String reviewId) => setState(() {
        helpfulReviewIds.contains(reviewId)
            ? helpfulReviewIds.remove(reviewId)
            : helpfulReviewIds.add(reviewId);
      });

  Future<void> openAllReviews() => showDialog<void>(
        context: context,
        barrierColor: AppColors.shadow80,
        builder: (_) => _AllReviewsDialog(
          placeName: widget.place.name,
          reviews: allReviews,
          initiallyHelpful: helpfulReviewIds,
          onHelpfulChanged: (ids) {
            if (!mounted) return;
            setState(() {
              helpfulReviewIds
                ..clear()
                ..addAll(ids);
            });
          },
        ),
      );

  Future<void> openReviewRecommendSheet({int initialTab = 0}) async {
    final allowed = await AppAuthGuard.requireAuth(
      context,
      title: AppStrings.get('guest_auth_title'),
      message: AppStrings.get('guest_review_prompt'),
    );
    if (!allowed || !mounted) return;

    final result = await showModalBottomSheet<_ContributionResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewRecommendSheet(
        placeName: widget.place.name,
        initialTab: initialTab,
        initialRating: userRating,
        initialReview: userReview ?? '',
        initialSocialHandle: userReviewSocialHandle,
        initialSocialPlatform: userReviewSocialPlatform,
      ),
    );
    if (!mounted || result == null) return;

    final hadExistingReview =
        (userReview != null && userReview!.isNotEmpty) || userRating > 0;

    if (result.isDelete) {
      setState(() {
        userReview = null;
        userRating = 0;
        userReviewCreatedAt = null;
        userReviewSocialHandle = null;
        userReviewSocialPlatform = null;
      });
      await UserReviewsController.deleteReview(widget.place);
      message('Değerlendirmeniz silindi.');
      return;
    }

    final hasReview = result.reviewText.isNotEmpty;
    final hasRec = result.reasons.isNotEmpty || !hasReview;

    setState(() {
      if (hasReview) {
        userReview = result.reviewText;
        userRating = result.rating;
        userReviewCreatedAt = DateTime.now();
        userReviewSocialHandle = result.socialHandle;
        userReviewSocialPlatform = result.socialPlatform;
      }
      if (hasRec) {
        userRecommendation = result.recommended;
        userRecommendationReasons = result.reasons;
      }
    });

    await UserReviewsController.saveReview(
      place: widget.place,
      rating: hasReview ? result.rating : userRating,
      content: hasReview ? result.reviewText : (userReview ?? ''),
      recommended: hasRec ? result.recommended : userRecommendation,
      reasons: hasRec ? result.reasons : userRecommendationReasons,
      socialHandle: result.socialHandle,
      socialPlatform: result.socialPlatform,
    );

    message(hasReview
        ? (hadExistingReview
            ? 'Değerlendirmen güncellendi.'
            : 'Değerlendirmen yayınlandı.')
        : result.recommended
            ? 'Önerin topluluğa eklendi.'
            : 'Geri bildirimin kaydedildi.');
  }

  Widget contributionActions() => Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => openReviewRecommendSheet(initialTab: 0),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: green,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.large),
                ),
              ),
              icon: Icon(
                (userReview != null && userReview!.isNotEmpty) || userRating > 0
                    ? Icons.edit_note_rounded
                    : Icons.star_outline_rounded,
                size: 18,
              ),
              label: Text(
                (userReview != null && userReview!.isNotEmpty) || userRating > 0
                    ? 'Değerlendirmeyi Düzenle'
                    : AppStrings.get('detail_write_review'),
                maxLines: 1,
                style: const TextStyle(
                    fontSize: AppFontSizes.caption,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => openReviewRecommendSheet(initialTab: 1),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: mint,
                foregroundColor: green,
                elevation: 0,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.large),
                ),
              ),
              icon: const Icon(Icons.groups_2_outlined, size: 18),
              label: Text(
                AppStrings.get('detail_recommend_community'),
                maxLines: 1,
                style: const TextStyle(
                    fontSize: AppFontSizes.caption,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );

  Widget recommendationStatus() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: userRecommendation!
              ? AppColors.primarySoft
              : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadii.large),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              userRecommendation!
                  ? Icons.recommend_rounded
                  : Icons.info_outline_rounded,
              color: userRecommendation! ? green : Colors.black45,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                userRecommendation!
                    ? 'Topluluk önerin yayınlandı${userRecommendationReasons.isEmpty ? '.' : ': ${userRecommendationReasons.join(', ')}'}'
                    : 'Topluluk geri bildirimin kaydedildi${userRecommendationReasons.isEmpty ? '.' : ': ${userRecommendationReasons.join(', ')}'}',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: AppFontSizes.caption,
                  height: 1.35,
                  color: userRecommendation!
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );

  Widget heading(String text, {String? action, VoidCallback? onAction}) =>
      Row(children: [
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: AppFontSizes.heading,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.15))),
        if (action != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(AppRadii.medium),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
              child: Text(action,
                  style: const TextStyle(
                      color: green,
                      fontSize: AppFontSizes.caption,
                      fontWeight: FontWeight.w600)),
            ),
          )
      ]);

  Widget stat(IconData icon, String value, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.large),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
          boxShadow: isDark
              ? const [BoxShadow(color: AppColors.shadow26, blurRadius: 8)]
              : const [BoxShadow(color: AppColors.shadow08, blurRadius: 8)],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            icon,
            size: 19,
            color: isDark ? AppColors.darkPrimaryLight : AppColors.primary,
          ),
          const SizedBox(height: 7),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: AppFontSizes.caption,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: AppFontSizes.caption - 1.5,
                height: 1.1,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget info(IconData icon, String label, String value,
      {VoidCallback? onCopy}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.large),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(
                icon,
                size: 17,
                color: isDark ? AppColors.darkPrimaryLight : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: AppFontSizes.caption,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onCopy != null)
                SizedBox(
                  width: AppControlSizes.minimumTouchTarget,
                  height: AppControlSizes.minimumTouchTarget,
                  child: IconButton(
                    tooltip: AppStrings.get('nav_copy_coords'),
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_outlined),
                  ),
                ),
            ]),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: AppFontSizes.caption,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget unavailableData(String message) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surfaceMutedOf(context),
          borderRadius: BorderRadius.circular(AppRadii.large),
          border: Border.all(color: AppColors.borderOf(context)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded,
                size: 19, color: AppColors.textSecondaryOf(context)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: AppColors.textSecondaryOf(context),
                  fontSize: AppFontSizes.caption,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildReviewSummary(bool isDark) => Semantics(
        button: true,
        label: 'Değerlendirmelere git',
        child: InkWell(
          onTap: scrollToReviews,
          borderRadius: BorderRadius.circular(AppRadii.large),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  allReviews.isEmpty
                      ? Icons.star_border_rounded
                      : Icons.star_rounded,
                  color: AppColors.rating,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    allReviews.isEmpty
                        ? AppStrings.get('detail_no_reviews_yet')
                        : '$userRating · 1 ${AppStrings.get('detail_review')}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppFontSizes.caption,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 17,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildSummaryAndViewsRow(bool isDark) {
    final badge = _buildViewsBadge(isDark);
    if (badge == null) {
      return _buildReviewSummary(isDark);
    }
    return Row(
      children: [
        Flexible(child: _buildReviewSummary(isDark)),
        const SizedBox(width: 8),
        badge,
      ],
    );
  }

  Widget? _buildViewsBadge(bool isDark) {
    if (placeViews == null) return null;
    final stats = placeViews!;
    if (stats.viewsTotal <= 0 && stats.views24h <= 0) return null;

    final isHot = stats.views24h >= 2;

    return Semantics(
      button: true,
      label: isHot
          ? 'Son 24 saatte ${stats.views24h} kişi inceledi'
          : '${stats.viewsTotal} görüntülenme',
      child: InkWell(
        onTap: () => _openViewsInfoSheet(context, stats),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: isHot
                ? (isDark
                    ? const Color(0xFF4C0519).withValues(alpha: 0.6)
                    : const Color(0xFFFFF1F2))
                : (isDark
                    ? AppColors.darkSurfaceMuted
                    : AppColors.surfaceMuted),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: isHot
                  ? (isDark ? const Color(0xFF9F1239) : const Color(0xFFFECDD3))
                  : (isDark ? AppColors.darkBorder : AppColors.border),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isHot) ...[
                const Text('🔥', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  'Son 24s: ${stats.views24h}',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: AppFontSizes.caption - 1,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFFFDA4AF)
                        : const Color(0xFFBE123C),
                  ),
                ),
                if (stats.viewsTotal > stats.views24h) ...[
                  Text(
                    ' · ${stats.viewsTotal}',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: AppFontSizes.caption - 1.5,
                      fontWeight: FontWeight.w600,
                      color: (isDark
                              ? const Color(0xFFFDA4AF)
                              : const Color(0xFFBE123C))
                          .withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ] else ...[
                Icon(
                  Icons.visibility_outlined,
                  size: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${stats.viewsTotal} görüntülenme',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: AppFontSizes.caption - 1,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openViewsInfoSheet(BuildContext context, PlaceViewStats stats) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadii.large)),
      ),
      builder: (ctx) => _PlaceViewsInfoSheet(
        placeName: widget.place.name,
        stats: stats,
      ),
    );
  }

  Widget _buildPhotoGallerySection(bool isDark) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            key: photoSectionKey,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.get('detail_photos'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: AppFontSizes.heading,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.15,
                    ),
                  ),
                ),
                if (galleryPlaces.isNotEmpty)
                  InkWell(
                    onTap: () => openGallery(0),
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 5),
                      child: Text(
                        AppStrings.get('detail_view_photos'),
                        style: const TextStyle(
                          color: green,
                          fontSize: AppFontSizes.caption,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () async {
                    await _openAddPhotoModal(context, widget.place);
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_a_photo_outlined,
                            size: 15, color: AppColors.primary),
                        SizedBox(width: 3),
                        Text(
                          'Ekle',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: AppFontSizes.caption,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (galleryPlaces.isEmpty)
            unavailableData(AppStrings.get('card_no_photos'))
          else
            SizedBox(
              height: 86,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: galleryPlaces.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => openGallery(i),
                  child: SizedBox(
                    width: 112,
                    child: NatureArt(
                      place: galleryPlaces[i],
                      radius: 14,
                      showKind: false,
                    ),
                  ),
                ),
              ),
            ),
          if (isSafeExternalUrl(
              Uri.tryParse(widget.place.googlePhotoSearchUrl ?? '')))
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: OutlinedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse(widget.place.googlePhotoSearchUrl!),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Google Fotoğraflarına Git'),
              ),
            ),
        ],
      );

  Widget _buildAboutSection(bool isDark) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading(AppStrings.get('detail_about')),
          const SizedBox(height: 10),
          Text(
            detailDescription,
            style: TextStyle(
              fontSize: AppFontSizes.body,
              height: 1.72,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          aboutSourcesSection(),
          const SizedBox(height: 22),
          Row(children: [
            info(Icons.explore_outlined, AppStrings.get('card_coordinates'),
                coordinateLabel,
                onCopy: widget.place.hasCoordinates ? copyCoordinates : null),
            if (widget.place.updatedAt != null) ...[
              const SizedBox(width: 10),
              info(Icons.update_rounded, AppStrings.get('card_last_updated'),
                  updatedAtLabel),
            ],
          ]),
        ],
      );

  Widget _buildReviewsSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            key: reviewsSectionKey,
            child: heading(
              AppStrings.get('detail_reviews'),
              action:
                  allReviews.isEmpty ? null : AppStrings.get('detail_view_all'),
              onAction: allReviews.isEmpty ? null : openAllReviews,
            ),
          ),
          const SizedBox(height: 12),
          contributionActions(),
          if (userRecommendation != null) ...[
            const SizedBox(height: 10),
            recommendationStatus(),
          ],
          const SizedBox(height: 14),
          if (allReviews.isEmpty) ...[
            const SizedBox(height: 14),
            unavailableData(AppStrings.get('card_no_reviews')),
          ],
          const SizedBox(height: 14),
          ...allReviews.take(3).map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ReviewCard(
                    review: entry,
                    helpful: helpfulReviewIds.contains(entry.id),
                    onHelpful: () => toggleHelpful(entry.id),
                  ),
                ),
              ),
        ],
      );

  Widget _buildLandscapeLayout(BuildContext context, bool isDark) =>
      AppResponsiveScaffoldBody(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sol (%46): Fotoğraf galerisi ve hava durumu
            Expanded(
              flex: 46,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.large),
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            NatureArt(
                              place: displayPlace,
                              radius: 0,
                              showKind: false,
                            ),
                            Positioned(
                              left: 12,
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.pill),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.photo_camera_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${galleryPlaces.length} ${AppStrings.get('detail_photo_count_label')}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: AppFontSizes.caption,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPhotoGallerySection(isDark),
                    if (widget.place.showsWeather) ...[
                      const SizedBox(height: 24),
                      heading(AppStrings.get('detail_weather_title')),
                      const SizedBox(height: 11),
                      _LiveWeatherCard(
                        place: widget.place,
                        future: weatherFuture,
                        onRetry: refreshWeather,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 28),
            // Sağ (%54): Yer adı, açıklama, mesafe, imkanlar, güven durumu ve navigasyon
            Expanded(
              flex: 54,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.place.name,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontSize: AppFontSizes.display,
                        height: 1.08,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.place.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              fontSize: AppFontSizes.caption,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryAndViewsRow(isDark),
                    const SizedBox(height: 16),
                    // Hızlı Aksiyon & Navigasyon
                    Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            button: true,
                            label: AppStrings.get('detail_nav_start'),
                            child: FilledButton.icon(
                              onPressed: startNavigation,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                backgroundColor:
                                    isDark ? AppColors.darkPrimary : green,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.large),
                                ),
                              ),
                              icon: const Icon(Icons.navigation_outlined),
                              label: Text(
                                AppStrings.get('detail_nav_start'),
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w700,
                                  fontSize: AppFontSizes.body,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (widget.place.contactPhone != null &&
                            widget.place.contactPhone!.isNotEmpty) ...[
                          _DetailActionIcon(
                            icon: Icons.phone_in_talk_rounded,
                            iconColor: const Color(0xFF059669),
                            tooltip: 'Hemen Ara',
                            onTap: () => launchUrl(
                              Uri.parse('tel:${widget.place.contactPhone}'),
                              mode: LaunchMode.externalApplication,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        _DetailActionIcon(
                          icon: favorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          iconColor: favorite ? AppColors.error : null,
                          tooltip: favorite
                              ? 'Favorilerden çıkar'
                              : 'Favorilere ekle',
                          onTap: toggleFavorite,
                        ),
                        const SizedBox(width: 8),
                        _DetailActionIcon(
                          icon: Icons.share_outlined,
                          tooltip: 'Paylaş',
                          onTap: () =>
                              message(AppStrings.get('share_prepared')),
                        ),
                        if (widget.place.hasCoordinates &&
                            widget.onShowOnMap != null) ...[
                          const SizedBox(width: 8),
                          _DetailActionIcon(
                            icon: Icons.map_outlined,
                            tooltip: 'Haritada Göster',
                            onTap: () => widget.onShowOnMap?.call(widget.place),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    journeyStats(),
                    const SizedBox(height: 16),
                    tripReadinessCard(isDark),
                    const SizedBox(height: 24),
                    _buildAboutSection(isDark),
                    const SizedBox(height: 24),
                    heading(AppStrings.get('detail_field_conditions')),
                    const SizedBox(height: 12),
                    facilitiesSection(),
                    const SizedBox(height: 24),
                    _buildReviewsSection(),
                    const SizedBox(height: 28),
                    nearbyPlacesSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildContactServiceCard(bool isDark) {
    final phone = widget.place.contactPhone;
    if (phone == null || phone.isEmpty) return const SizedBox.shrink();

    final hours = widget.place.workingHours;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.25)
            : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.40),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF059669).withValues(alpha: 0.35)
                      : const Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_in_talk_rounded,
                  color: Color(0xFF059669),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İletişim & Servis Çağrısı',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : const Color(0xFF065F46),
                      ),
                    ),
                    if (hours != null && hours.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Çalışma Saatleri: $hours',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => launchUrl(
                Uri.parse('tel:$phone'),
                mode: LaunchMode.externalApplication,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.call_rounded, size: 19),
              label: Text(
                'Hemen Ara ($phone)',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardLayout(
    BuildContext context,
    bool isDark, {
    required double expandedHeight,
    required bool isPortraitTablet,
  }) {
    final sliverBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContactServiceCard(isDark),
        _buildSummaryAndViewsRow(isDark),
        const SizedBox(height: 18),
        journeyStats(),
        const SizedBox(height: 16),
        tripReadinessCard(isDark),
        const SizedBox(height: 28),
        _buildPhotoGallerySection(isDark),
        const SizedBox(height: 28),
        _buildAboutSection(isDark),
        if (widget.place.showsWeather) ...[
          const SizedBox(height: 26),
          heading(AppStrings.get('detail_weather_title')),
          const SizedBox(height: 11),
          _LiveWeatherCard(
            place: widget.place,
            future: weatherFuture,
            onRetry: refreshWeather,
          ),
        ],
        const SizedBox(height: 27),
        heading(AppStrings.get('detail_field_conditions')),
        const SizedBox(height: 12),
        facilitiesSection(),
        const SizedBox(height: 28),
        _buildReviewsSection(),
        const SizedBox(height: 28),
        nearbyPlacesSection(),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: expandedHeight,
            pinned: true,
            backgroundColor: AppColors.surfaceOf(context),
            surfaceTintColor: Colors.transparent,
            titleSpacing: 4,
            title: collapsed
                ? Text(
                    widget.place.name,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: AppFontSizes.title,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
            leading: Center(
              child: GlassIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Geri',
                size: 40,
                iconSize: 20,
                iconColor: Colors.white,
                color: AppColors.darkGlass,
                borderColor: Colors.white.withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                blur: 12,
                onTap: () => Navigator.pop(context),
              ),
            ),
            actions: [
              GlassIconButton(
                icon: Icons.share_outlined,
                tooltip: 'Paylaş',
                size: 40,
                iconSize: 19,
                iconColor: Colors.white,
                color: AppColors.darkGlass,
                borderColor: Colors.white.withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                blur: 12,
                onTap: () => message(AppStrings.get('share_prepared')),
              ),
              const SizedBox(width: 8),
              GlassIconButton(
                icon: favorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                tooltip: favorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
                size: 40,
                iconSize: 20,
                iconColor: favorite ? AppColors.error : Colors.white,
                color: AppColors.darkGlass,
                borderColor: Colors.white.withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                blur: 12,
                onTap: toggleFavorite,
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadii.large),
                  bottomRight: Radius.circular(AppRadii.large),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NatureArt(place: displayPlace, radius: 0, showKind: false),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.shadow08,
                            Colors.transparent,
                            AppColors.shadow80,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.place.name,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: Colors.white,
                              fontSize: AppFontSizes.display,
                              height: 1.06,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 15,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.place.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: AppFontSizes.caption,
                                  ),
                                ),
                              ),
                              if (galleryPlaces.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: scrollToPhotos,
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.large),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.photo_camera_outlined,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          '  ${galleryPlaces.length} ${AppStrings.get('detail_photo_count_label')}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: AppFontSizes.caption,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 118),
              child: isPortraitTablet
                  ? Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: sliverBody,
                      ),
                    )
                  : sliverBody,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: GlassContainer(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadii.hero),
                topRight: Radius.circular(AppRadii.hero),
              ),
              blur: 16.0,
              color: Colors.white.withValues(alpha: 0.88),
              darkColor: AppColors.darkGlass,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.85),
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
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  if (widget.place.contactPhone != null &&
                      widget.place.contactPhone!.isNotEmpty) ...[
                    _DetailActionIcon(
                      icon: Icons.phone_in_talk_rounded,
                      iconColor: const Color(0xFF059669),
                      tooltip: 'Hemen Ara',
                      onTap: () => launchUrl(
                        Uri.parse('tel:${widget.place.contactPhone}'),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                    const SizedBox(width: 9),
                  ],
                  _DetailActionIcon(
                    icon: favorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    iconColor: favorite ? Colors.redAccent : null,
                    tooltip:
                        favorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
                    onTap: toggleFavorite,
                  ),
                  const SizedBox(width: 9),
                  _DetailActionIcon(
                    icon: Icons.share_outlined,
                    tooltip: 'Paylaş',
                    onTap: () => message(AppStrings.get('share_prepared')),
                  ),
                  if (widget.place.hasCoordinates &&
                      widget.onShowOnMap != null) ...[
                    const SizedBox(width: 9),
                    _DetailActionIcon(
                      icon: Icons.map_outlined,
                      tooltip: 'Haritada Göster',
                      onTap: () => widget.onShowOnMap?.call(widget.place),
                    ),
                  ],
                  const SizedBox(width: 11),
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: AppStrings.get('detail_nav_start'),
                      child: FilledButton.icon(
                        onPressed: startNavigation,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(53),
                          backgroundColor:
                              isDark ? AppColors.darkPrimary : green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.large),
                          ),
                        ),
                        icon: const Icon(Icons.navigation_outlined),
                        label: Text(AppStrings.get('detail_nav_start')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (context.isTabletLandscape) {
      return Scaffold(
        backgroundColor: AppColors.surfaceOf(context),
        appBar: AppBar(
          backgroundColor: AppColors.surfaceOf(context),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Center(
            child: GlassIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Geri',
              size: 40,
              iconSize: 20,
              iconColor: isDark ? Colors.white : AppColors.textPrimary,
              color: isDark
                  ? AppColors.darkGlass
                  : Colors.white.withValues(alpha: 0.85),
              borderColor: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadii.pill),
              blur: 12,
              onTap: () => Navigator.pop(context),
            ),
          ),
          title: Text(
            widget.place.name,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: AppFontSizes.title,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            GlassIconButton(
              icon: Icons.share_outlined,
              tooltip: 'Paylaş',
              size: 40,
              iconSize: 19,
              iconColor: isDark ? Colors.white : AppColors.textPrimary,
              color: isDark
                  ? AppColors.darkGlass
                  : Colors.white.withValues(alpha: 0.85),
              borderColor: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadii.pill),
              blur: 12,
              onTap: () => message(AppStrings.get('share_prepared')),
            ),
            const SizedBox(width: 8),
            GlassIconButton(
              icon: favorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              tooltip: favorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
              size: 40,
              iconSize: 20,
              iconColor: favorite
                  ? AppColors.error
                  : (isDark ? Colors.white : AppColors.textPrimary),
              color: isDark
                  ? AppColors.darkGlass
                  : Colors.white.withValues(alpha: 0.85),
              borderColor: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadii.pill),
              blur: 12,
              onTap: toggleFavorite,
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: _buildLandscapeLayout(context, isDark),
      );
    }

    if (context.isTabletPortrait) {
      return _buildStandardLayout(
        context,
        isDark,
        expandedHeight: 420,
        isPortraitTablet: true,
      );
    }

    return _buildStandardLayout(
      context,
      isDark,
      expandedHeight: 330,
      isPortraitTablet: false,
    );
  }
}

class _NavigationProviderTile extends StatelessWidget {
  const _NavigationProviderTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkPrimarySoft : AppColors.primarySoft,
          borderRadius: BorderRadius.circular(AppRadii.medium),
        ),
        child: Icon(
          icon,
          color: isDark ? AppColors.darkPrimaryLight : green,
          size: 21,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Outfit',
          color: isDark ? AppColors.darkTextPrimary : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: AppFontSizes.caption,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppColors.darkTextSecondary : null,
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.helpful,
    required this.onHelpful,
  });

  final ReviewEntry review;
  final bool helpful;
  final VoidCallback onHelpful;

  String get stars =>
      '${List.filled(review.rating, '★').join()}${List.filled(5 - review.rating, '☆').join()}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.large),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: isDark
            ? const [
                BoxShadow(color: AppColors.shadow26, blurRadius: 8),
              ]
            : const [
                BoxShadow(color: AppColors.shadow08, blurRadius: 8),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: review.color,
                foregroundColor: Colors.white,
                child: Text(review.initial),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            review.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: AppFontSizes.caption,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : null,
                            ),
                          ),
                        ),
                        if (review.socialHandle != null &&
                            review.socialHandle!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _ReviewSocialBadge(
                            platform: review.socialPlatform ?? 'instagram',
                            handle: review.socialHandle!,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$stars  ${review.timeLabel}',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: AppColors.rating,
                        fontSize: AppFontSizes.caption,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.content,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: AppFontSizes.body,
              height: 1.5,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Semantics(
                button: true,
                selected: helpful,
                label: helpful
                    ? 'Faydalı işaretini kaldır'
                    : 'Yorumu faydalı olarak işaretle',
                child: InkWell(
                  onTap: onHelpful,
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: helpful
                          ? (isDark
                              ? AppColors.darkPrimarySoft
                              : AppColors.primarySoft)
                          : (isDark
                              ? AppColors.darkSurfaceMuted
                              : AppColors.surfaceMuted),
                      borderRadius: BorderRadius.circular(AppRadii.large),
                      border: Border.all(
                        color: helpful
                            ? (isDark
                                ? AppColors.darkPrimary
                                : AppColors.primarySoft)
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          helpful
                              ? Icons.thumb_up_alt_rounded
                              : Icons.thumb_up_alt_outlined,
                          size: 15,
                          color: helpful ? green : AppColors.textTertiary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${AppStrings.get('detail_helpful')} (${review.helpfulCount + (helpful ? 1 : 0)})',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: AppFontSizes.caption,
                            color: helpful ? green : AppColors.textTertiary,
                            fontWeight:
                                helpful ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Text(
                AppStrings.get('detail_reply'),
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: AppFontSizes.caption,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewSocialBadge extends StatelessWidget {
  const _ReviewSocialBadge({
    required this.platform,
    required this.handle,
  });

  final String platform;
  final String handle;

  @override
  Widget build(BuildContext context) {
    final clean = handle.replaceAll('@', '').trim();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        final uri = UserSocialAccounts.resolveUri(platform, clean);
        if (uri != null) {
          launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF831843).withValues(alpha: 0.35)
              : const Color(0xFFFDF2F8),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: isDark ? const Color(0xFFBE185D) : const Color(0xFFF472B6),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 11,
              color: Color(0xFFE1306C),
            ),
            const SizedBox(width: 3),
            Text(
              '@$clean',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE1306C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceViewsInfoSheet extends StatelessWidget {
  const _PlaceViewsInfoSheet({
    required this.placeName,
    required this.stats,
  });

  final String placeName;
  final PlaceViewStats stats;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'İlgi & Görüntülenme',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: AppFontSizes.title,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : ink,
                        ),
                      ),
                      Text(
                        placeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: AppFontSizes.caption,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _buildStatTile(
                  context,
                  title: 'Son 24 Saat',
                  value: '${stats.views24h}',
                  subtitle: 'doğasever',
                  isDark: isDark,
                  isHighlight: stats.views24h >= 2,
                ),
                const SizedBox(width: 10),
                _buildStatTile(
                  context,
                  title: 'Son 7 Gün',
                  value: '${stats.views7d}',
                  subtitle: 'inceleme',
                  isDark: isDark,
                  isHighlight: false,
                ),
                const SizedBox(width: 10),
                _buildStatTile(
                  context,
                  title: 'Toplam',
                  value: '${stats.viewsTotal}',
                  subtitle: 'görüntülenme',
                  isDark: isDark,
                  isHighlight: false,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Bu sayaç, doğaseverlerin bu noktayı uygulama içinde ne sıklıkla incelediğini gösterir. Keşif trendlerini takip etmene yardımcı olur.',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: AppFontSizes.caption,
                height: 1.4,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required bool isDark,
    required bool isHighlight,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isHighlight
              ? (isDark
                  ? const Color(0xFF4C0519).withValues(alpha: 0.5)
                  : const Color(0xFFFFF1F2))
              : (isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted),
          borderRadius: BorderRadius.circular(AppRadii.medium),
          border: Border.all(
            color: isHighlight
                ? (isDark ? const Color(0xFF9F1239) : const Color(0xFFFECDD3))
                : (isDark ? AppColors.darkBorder : AppColors.border),
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: AppFontSizes.caption - 2,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isHighlight
                    ? (isDark
                        ? const Color(0xFFFDA4AF)
                        : const Color(0xFFBE123C))
                    : (isDark ? AppColors.darkTextPrimary : ink),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: AppFontSizes.caption - 2.5,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllReviewsDialog extends StatefulWidget {
  const _AllReviewsDialog({
    required this.placeName,
    required this.reviews,
    required this.initiallyHelpful,
    required this.onHelpfulChanged,
  });

  final String placeName;
  final List<ReviewEntry> reviews;
  final Set<String> initiallyHelpful;
  final ValueChanged<Set<String>> onHelpfulChanged;

  @override
  State<_AllReviewsDialog> createState() => _AllReviewsDialogState();
}

class _AllReviewsDialogState extends State<_AllReviewsDialog> {
  late final List<ReviewEntry> sortedReviews;
  late final Set<String> helpfulIds;

  @override
  void initState() {
    super.initState();
    sortedReviews = [...widget.reviews]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    helpfulIds = {...widget.initiallyHelpful};
  }

  void toggleHelpful(String id) {
    setState(() {
      helpfulIds.contains(id) ? helpfulIds.remove(id) : helpfulIds.add(id);
    });
    widget.onHelpfulChanged(Set.unmodifiable(helpfulIds));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final dialogHeight = screenHeight * .84 > 720 ? 720.0 : screenHeight * .84;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          height: dialogHeight,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.large),
            border: isDark ? Border.all(color: AppColors.darkBorder) : null,
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow33,
                blurRadius: 32,
                offset: Offset(0, 14),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(19, 17, 13, 13),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tüm Değerlendirmeler',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              color: isDark ? AppColors.darkTextPrimary : ink,
                              fontSize: AppFontSizes.heading,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${widget.placeName} · En yeniden en eskiye',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              fontSize: AppFontSizes.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            isDark ? AppColors.darkSurfaceMuted : Colors.white,
                        foregroundColor:
                            isDark ? AppColors.darkTextPrimary : ink,
                        side: BorderSide(
                          color:
                              isDark ? AppColors.darkBorder : AppColors.border,
                        ),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
                  ],
                ),
              ),
              Divider(
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.border),
              Expanded(
                child: Scrollbar(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 15, 16, 22),
                    itemCount: sortedReviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final review = sortedReviews[index];
                      return _ReviewCard(
                        review: review,
                        helpful: helpfulIds.contains(review.id),
                        onHelpful: () => toggleHelpful(review.id),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContributionResult {
  const _ContributionResult({
    required this.reviewText,
    required this.rating,
    required this.recommended,
    required this.reasons,
    this.isDelete = false,
    this.socialHandle,
    this.socialPlatform,
  });

  final String reviewText;
  final int rating;
  final bool recommended;
  final List<String> reasons;
  final bool isDelete;
  final String? socialHandle;
  final String? socialPlatform;
}

class _ReviewRecommendSheet extends StatefulWidget {
  const _ReviewRecommendSheet({
    required this.placeName,
    required this.initialTab,
    this.initialRating = 0,
    this.initialReview = '',
    this.initialSocialHandle,
    this.initialSocialPlatform,
  });

  final String placeName;
  final int initialTab;
  final int initialRating;
  final String initialReview;
  final String? initialSocialHandle;
  final String? initialSocialPlatform;

  @override
  State<_ReviewRecommendSheet> createState() => _ReviewRecommendSheetState();
}

class _ReviewRecommendSheetState extends State<_ReviewRecommendSheet> {
  final reviewController = TextEditingController();
  late final TextEditingController instagramController;
  late final String _profileInstagramHandle;
  late int tab;
  int rating = 0;
  bool recommended = true;
  bool attachSocialBadge = true;
  final selectedReasons = <String>{};

  static const positiveReasons = [
    'Manzara',
    'Temizlik',
    'Sessizlik',
    'Aileye uygun',
    'Kolay ulaşım',
    'Fotoğraf noktası',
  ];

  static const negativeReasons = [
    'Kalabalık',
    'Temizlik',
    'Ulaşım zor',
    'Güvenli değil',
    'Eksik bilgi',
    'Bakımsız',
  ];

  bool get isEditing =>
      widget.initialReview.isNotEmpty || widget.initialRating > 0;

  bool get canSubmit => tab == 0
      ? rating > 0 && reviewController.text.trim().isNotEmpty
      : selectedReasons.isNotEmpty;

  @override
  void initState() {
    super.initState();
    tab = widget.initialTab.clamp(0, 1);
    rating = widget.initialRating;
    if (widget.initialReview.isNotEmpty) {
      reviewController.text = widget.initialReview;
    }
    final existingHandle = widget.initialSocialHandle?.trim() ?? '';
    final profileHandle =
        UserSocialAccountsController.accounts.value.instagram.trim();
    _profileInstagramHandle = profileHandle.replaceAll('@', '');
    final effectiveHandle =
        existingHandle.isNotEmpty ? existingHandle : profileHandle;
    instagramController = TextEditingController(
      text: existingHandle.replaceAll('@', ''),
    );
    attachSocialBadge = effectiveHandle.isNotEmpty;
  }

  @override
  void dispose() {
    reviewController.dispose();
    instagramController.dispose();
    super.dispose();
  }

  void submit() {
    if (!canSubmit) return;
    final handleText = (instagramController.text.trim().isNotEmpty
            ? instagramController.text
            : _profileInstagramHandle)
        .trim()
        .replaceAll('@', '');
    final handle =
        (attachSocialBadge && handleText.isNotEmpty) ? handleText : null;
    if (handle != null) {
      UserSocialAccountsController.save(
        instagram: handle,
        facebook: UserSocialAccountsController.accounts.value.facebook,
        youtube: UserSocialAccountsController.accounts.value.youtube,
      );
    }
    Navigator.pop(
      context,
      _ContributionResult(
        reviewText: tab == 0 ? reviewController.text.trim() : '',
        rating: tab == 0 ? rating : 0,
        recommended: recommended,
        reasons: selectedReasons.toList(),
        socialHandle: handle,
        socialPlatform: handle != null ? 'instagram' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .88,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadii.large)),
          border: isDark
              ? Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.12)))
              : null,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 17),
                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tab == 0
                              ? (isEditing
                                  ? 'Değerlendirmeyi Düzenle'
                                  : 'Deneyimini paylaş')
                              : 'Topluluk ile öner',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            color: isDark ? AppColors.darkTextPrimary : ink,
                            fontSize: AppFontSizes.heading,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.placeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            fontSize: AppFontSizes.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          isDark ? AppColors.darkSurfaceMuted : Colors.white,
                      foregroundColor: isDark ? AppColors.darkTextPrimary : ink,
                      side: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ]),
                const SizedBox(height: 18),
                Container(
                  height: 47,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceDeep
                        : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadii.large),
                  ),
                  child: Row(children: [
                    _ContributionTab(
                      label: 'Değerlendirme Yaz',
                      icon: Icons.star_outline_rounded,
                      active: tab == 0,
                      onTap: () => setState(() => tab = 0),
                    ),
                    _ContributionTab(
                      label: 'Topluluk ile Öner',
                      icon: Icons.groups_2_outlined,
                      active: tab == 1,
                      onTap: () => setState(() => tab = 1),
                    ),
                  ]),
                ),
                const SizedBox(height: 22),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: tab == 0 ? _reviewBody() : _recommendBody(),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: canSubmit ? submit : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark ? AppColors.darkPrimary : green,
                      disabledBackgroundColor:
                          isDark ? AppColors.darkPrimarySoft : AppColors.border,
                      disabledForegroundColor: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.large),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tab == 0
                              ? (isEditing
                                  ? 'Değerlendirmeyi Güncelle'
                                  : 'Değerlendirmeyi Gönder')
                              : 'Toplulukla Paylaş',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: AppFontSizes.body,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
                if (tab == 0 && isEditing) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          const _ContributionResult(
                            reviewText: '',
                            rating: 0,
                            recommended: false,
                            reasons: [],
                            isDelete: true,
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.error, size: 18),
                      label: const Text(
                        'Değerlendirmeyi Sil',
                        style: TextStyle(
                          color: AppColors.error,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _reviewBody() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      key: const ValueKey('review'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bu yeri nasıl buldun?',
          style: TextStyle(
            fontFamily: 'Outfit',
            color: isDark ? AppColors.darkTextPrimary : ink,
            fontSize: AppFontSizes.title,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Deneyimini yıldızlarla değerlendir.',
          style: TextStyle(
            fontFamily: 'Outfit',
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            fontSize: AppFontSizes.caption,
          ),
        ),
        const SizedBox(height: 13),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            5,
            (i) => InkWell(
              onTap: () => setState(() => rating = i + 1),
              borderRadius: BorderRadius.circular(AppRadii.large),
              child: Container(
                width: 54,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i < rating
                      ? (isDark
                          ? AppColors.rating.withValues(alpha: 0.20)
                          : AppColors.rating.withValues(alpha: 0.12))
                      : (isDark ? AppColors.darkSurfaceMuted : Colors.white),
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  border: Border.all(
                    color: i < rating
                        ? AppColors.rating
                        : (isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                ),
                child: Icon(
                  i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.rating,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Yorumun',
          style: TextStyle(
            fontFamily: 'Outfit',
            color: isDark ? AppColors.darkTextPrimary : ink,
            fontSize: AppFontSizes.caption,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: reviewController,
          minLines: 4,
          maxLines: 5,
          maxLength: 500,
          onChanged: (_) => setState(() {}),
          style: TextStyle(
            fontFamily: 'Outfit',
            color: isDark ? AppColors.darkTextPrimary : ink,
            fontSize: 13,
            height: 1.45,
          ),
          decoration: InputDecoration(
            hintText: 'Neleri beğendin? Ziyaret edecek kişilere yardımcı ol...',
            hintStyle: TextStyle(
              color:
                  isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
              fontSize: AppFontSizes.caption,
              height: 1.4,
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceMuted : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.large),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.large),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.large),
              borderSide: const BorderSide(color: green, width: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color:
                isDark ? AppColors.darkSurfaceMuted : const Color(0xFFFDF2F8),
            borderRadius: BorderRadius.circular(AppRadii.large),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF831843).withValues(alpha: 0.5)
                  : const Color(0xFFFBCFE8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF833AB4),
                          Color(0xFFFD1D1D),
                          Color(0xFFFCB045),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Instagram Rozeti',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: AppFontSizes.caption,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : ink,
                          ),
                        ),
                        Text(
                          'Yorumunda profilini göster, doğaseverler seni keşfetsin',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: AppFontSizes.caption - 1.5,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: attachSocialBadge,
                    activeTrackColor: const Color(0xFFE1306C),
                    onChanged: (val) {
                      setState(() => attachSocialBadge = val);
                    },
                  ),
                ],
              ),
              if (attachSocialBadge) ...[
                const SizedBox(height: 10),
                if (_profileInstagramHandle.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceDeep : Colors.white,
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    child: Text(
                      'Mevcut profil hesabın yorumunda gösterilecek: @$_profileInstagramHandle',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: AppFontSizes.caption,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  TextField(
                    controller: instagramController,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextPrimary : ink,
                    ),
                    decoration: InputDecoration(
                      prefixText: '@',
                      prefixStyle: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : const Color(0xFFE1306C),
                      ),
                      hintText: 'kullanici_adi',
                      hintStyle: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: AppFontSizes.caption,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.textTertiary,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? AppColors.darkSurfaceDeep : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.medium),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.medium),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.medium),
                        borderSide: const BorderSide(
                          color: Color(0xFFE1306C),
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _recommendBody() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reasons = recommended ? positiveReasons : negativeReasons;
    return Column(
      key: const ValueKey('recommend'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Topluluğa önerir misin?',
          style: TextStyle(
            fontFamily: 'Outfit',
            color: isDark ? AppColors.darkTextPrimary : ink,
            fontSize: AppFontSizes.title,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Seçimin diğer doğaseverlere yol gösterecek.',
          style: TextStyle(
            fontFamily: 'Outfit',
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            fontSize: AppFontSizes.caption,
          ),
        ),
        const SizedBox(height: 15),
        Row(children: [
          _RecommendChoice(
            icon: Icons.thumb_up_alt_outlined,
            label: 'Evet, öneririm',
            active: recommended,
            positive: true,
            onTap: () => setState(() {
              recommended = true;
              selectedReasons.clear();
            }),
          ),
          const SizedBox(width: 10),
          _RecommendChoice(
            icon: Icons.thumb_down_alt_outlined,
            label: 'Hayır',
            active: !recommended,
            positive: false,
            onTap: () => setState(() {
              recommended = false;
              selectedReasons.clear();
            }),
          ),
        ]),
        const SizedBox(height: 21),
        Text(
          recommended ? 'Neden öneriyorsun?' : 'Neden önermiyorsun?',
          style: TextStyle(
            fontFamily: 'Outfit',
            color: isDark ? AppColors.darkTextPrimary : ink,
            fontSize: AppFontSizes.caption,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: reasons.map((reason) {
            final selected = selectedReasons.contains(reason);
            return FilterChip(
              selected: selected,
              showCheckmark: false,
              label: Text(reason),
              onSelected: (_) => setState(() => selected
                  ? selectedReasons.remove(reason)
                  : selectedReasons.add(reason)),
              labelStyle: TextStyle(
                fontFamily: 'Outfit',
                color: selected
                    ? (isDark ? AppColors.darkPrimaryLight : green)
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
                fontSize: AppFontSizes.caption,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
              selectedColor: isDark ? AppColors.darkPrimarySoft : mint,
              backgroundColor:
                  isDark ? AppColors.darkSurfaceMuted : Colors.white,
              side: BorderSide(
                color: selected
                    ? (isDark ? AppColors.darkPrimary : AppColors.primarySoft)
                    : (isDark ? AppColors.darkBorder : AppColors.border),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.large),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ContributionTab extends StatelessWidget {
  const _ContributionTab({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: active
                ? (isDark ? AppColors.darkSurfaceMuted : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.large),
            boxShadow: active
                ? (isDark
                    ? const [
                        BoxShadow(color: AppColors.shadow26, blurRadius: 7)
                      ]
                    : const [
                        BoxShadow(color: AppColors.shadow08, blurRadius: 7)
                      ])
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 17,
                  color: active
                      ? (isDark ? AppColors.darkPrimaryLight : green)
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: active
                      ? (isDark ? AppColors.darkPrimaryLight : green)
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
                  fontSize: AppFontSizes.caption,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendChoice extends StatelessWidget {
  const _RecommendChoice({
    required this.icon,
    required this.label,
    required this.active,
    required this.positive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool positive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = positive
        ? (isDark ? AppColors.darkPrimaryLight : green)
        : AppColors.error;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.large),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 62,
          decoration: BoxDecoration(
            color: active
                ? positive
                    ? (isDark ? AppColors.darkPrimarySoft : mint)
                    : (isDark
                        ? AppColors.darkSurfaceDeep
                        : AppColors.surfaceMuted)
                : (isDark ? AppColors.darkSurfaceMuted : Colors.white),
            borderRadius: BorderRadius.circular(AppRadii.large),
            border: Border.all(
              color: active
                  ? activeColor
                  : (isDark ? AppColors.darkBorder : AppColors.border),
              width: active ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 19,
                  color: active
                      ? activeColor
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary)),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: active
                      ? activeColor
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
                  fontSize: AppFontSizes.caption,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoGalleryDialog extends StatefulWidget {
  const _PhotoGalleryDialog({
    required this.photos,
    required this.placeName,
    required this.initialIndex,
  });

  final List<Place> photos;
  final String placeName;
  final int initialIndex;

  @override
  State<_PhotoGalleryDialog> createState() => _PhotoGalleryDialogState();
}

class _PhotoGalleryDialogState extends State<_PhotoGalleryDialog> {
  late final PageController pageController;
  late int currentIndex;
  final reactions = <int, int>{};

  @override
  void initState() {
    super.initState();
    currentIndex =
        widget.initialIndex.clamp(0, widget.photos.length - 1).toInt();
    pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void changePage(int difference) {
    final next = currentIndex + difference;
    if (next < 0 || next >= widget.photos.length) return;
    pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void react(int value) => setState(() {
        reactions[currentIndex] = reactions[currentIndex] == value ? 0 : value;
      });

  Widget overlayButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color? selectedColor,
    bool selected = false,
  }) =>
      Tooltip(
        message: tooltip,
        child: Material(
          color: selected ? selectedColor : Colors.black.withValues(alpha: .48),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 42,
              height: 42,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.sizeOf(context);
    final dialogHeight =
        screenSize.height * .72 > 620 ? 620.0 : screenSize.height * .72;
    final reaction = reactions[currentIndex] ?? 0;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          height: dialogHeight,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.large),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow33,
                blurRadius: 34,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: pageController,
                      itemCount: widget.photos.length,
                      onPageChanged: (index) =>
                          setState(() => currentIndex = index),
                      itemBuilder: (_, index) => NatureArt(
                        place: widget.photos[index],
                        radius: 0,
                        showKind: false,
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 12,
                      child: overlayButton(
                        icon: Icons.close_rounded,
                        tooltip: 'Galeriyi kapat',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Row(
                        children: [
                          Builder(builder: (ctx) {
                            final currentUrl =
                                widget.photos[currentIndex].image ?? '';
                            final match = CommunityPlacePhotosController
                                .photos.value
                                .where((p) => p.imageUrl == currentUrl)
                                .firstOrNull;
                            if (match == null ||
                                match.id.startsWith('moderated-')) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: overlayButton(
                                icon: Icons.delete_outline_rounded,
                                tooltip: 'Yanlış yüklenen fotoğrafı sil',
                                selected: true,
                                selectedColor: AppColors.error,
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (dialogCtx) => AlertDialog(
                                      title: const Text('Fotoğrafı Sil?'),
                                      content: const Text(
                                          'Bu fotoğraf silinecektir. Devam etmek istiyor musunuz?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(dialogCtx, false),
                                          child: const Text('Vazgeç'),
                                        ),
                                        FilledButton(
                                          style: FilledButton.styleFrom(
                                              backgroundColor: AppColors.error),
                                          onPressed: () =>
                                              Navigator.pop(dialogCtx, true),
                                          child: const Text('Sil'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await CommunityPlacePhotosController
                                        .removePhoto(match.id);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Fotoğraf başarıyla silindi.')),
                                      );
                                    }
                                  }
                                },
                              ),
                            );
                          }),
                          overlayButton(
                            icon: reaction == 1
                                ? Icons.thumb_up_alt_rounded
                                : Icons.thumb_up_alt_outlined,
                            tooltip: 'Beğen',
                            selected: reaction == 1,
                            selectedColor: AppColors.primary,
                            onPressed: () => react(1),
                          ),
                          const SizedBox(width: 8),
                          overlayButton(
                            icon: reaction == -1
                                ? Icons.thumb_down_alt_rounded
                                : Icons.thumb_down_alt_outlined,
                            tooltip: 'Beğenme',
                            selected: reaction == -1,
                            selectedColor: AppColors.error,
                            onPressed: () => react(-1),
                          ),
                        ],
                      ),
                    ),
                    if (currentIndex > 0)
                      Positioned(
                        left: 12,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: overlayButton(
                            icon: Icons.chevron_left_rounded,
                            tooltip: 'Önceki fotoğraf',
                            onPressed: () => changePage(-1),
                          ),
                        ),
                      ),
                    if (currentIndex < widget.photos.length - 1)
                      Positioned(
                        right: 12,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: overlayButton(
                            icon: Icons.chevron_right_rounded,
                            tooltip: 'Sonraki fotoğraf',
                            onPressed: () => changePage(1),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 14,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .52),
                          borderRadius: BorderRadius.circular(AppRadii.large),
                        ),
                        child: Text(
                          '${currentIndex + 1} / ${widget.photos.length}',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            color: Colors.white,
                            fontSize: AppFontSizes.caption,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 70,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.placeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                color: isDark ? AppColors.darkTextPrimary : ink,
                                fontSize: AppFontSizes.title,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Builder(
                              builder: (context) {
                                final currentUrl =
                                    widget.photos[currentIndex].image ?? '';
                                final match = CommunityPlacePhotosController
                                    .photos.value
                                    .where((p) => p.imageUrl == currentUrl)
                                    .firstOrNull;
                                if (match != null) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              PublicUserProfileScreen(
                                            authorName: match.authorName,
                                            authorId: match.authorId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.person_pin_rounded,
                                          size: 14,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Fotoğraf: ${match.authorName}  ›',
                                          style: const TextStyle(
                                            fontFamily: 'Outfit',
                                            color: AppColors.primary,
                                            fontSize: AppFontSizes.caption,
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return Text(
                                  'Kaydırarak diğer fotoğrafları gör',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                    fontSize: AppFontSizes.caption,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          widget.photos.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: index == currentIndex ? 14 : 5,
                            height: 5,
                            margin: const EdgeInsets.only(left: 4),
                            decoration: BoxDecoration(
                              color: index == currentIndex
                                  ? green
                                  : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.border),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveWeatherCard extends StatefulWidget {
  const _LiveWeatherCard({
    required this.place,
    required this.future,
    required this.onRetry,
  });

  final Place place;
  final Future<WeatherSnapshot> future;
  final VoidCallback onRetry;

  @override
  State<_LiveWeatherCard> createState() => _LiveWeatherCardState();
}

class _LiveWeatherCardState extends State<_LiveWeatherCard> {
  bool _isExpanded = false;

  BoxDecoration get decoration => BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.weatherGradientStart,
            AppColors.weatherGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadii.large),
        boxShadow: const [
          BoxShadow(
            color: AppColors.weatherCardShadow,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: decoration,
        child: FutureBuilder<WeatherSnapshot>(
          future: widget.future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${widget.place.location} için hava durumu alınıyor...',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.white70,
                        fontSize: AppFontSizes.caption,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_outlined,
                        color: Colors.white, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.place.location} hava durumu şu anda alınamadı.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        fontSize: AppFontSizes.caption,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton.icon(
                      onPressed: widget.onRetry,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text(AppStrings.get('general_retry'),
                          style:
                              const TextStyle(fontSize: AppFontSizes.caption)),
                    ),
                  ],
                ),
              );
            }

            final weather = snapshot.data!;
            final visibility = weather.visibilityKm < 10
                ? weather.visibilityKm.toStringAsFixed(1)
                : weather.visibilityKm.round().toString();
            final idealConditions = _weatherIsIdeal(weather);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${widget.place.name.toUpperCase()} · ${AppStrings.get('weather_now')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          color: Colors.white70,
                          fontSize: AppFontSizes.caption,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .25,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: idealConditions
                                  ? AppColors.darkPrimaryLight
                                  : AppColors.rating,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            idealConditions ? 'Doğaya Uygun' : 'Tedbirli Ol',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${weather.temperature.round()}°',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        fontSize: 38,
                        height: 1.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weather.condition,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: Colors.white,
                              fontSize: AppFontSizes.body,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${AppStrings.get('weather_feels_like')} ${weather.apparentTemperature.round()}°',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: Colors.white70,
                              fontSize: AppFontSizes.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(AppRadii.medium),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '💧${weather.humidity.round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '〰${weather.windSpeed.round()}km/s',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      weather.emoji,
                      style: const TextStyle(fontSize: 34, height: 1.0),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 7,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: _isExpanded ? .20 : .10),
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isExpanded
                              ? 'Daha Az Göster'
                              : AppStrings.get('weather_5day_forecast'),
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            color: Colors.white,
                            fontSize: AppFontSizes.caption,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 14),
                  Container(
                    height: 66,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(AppRadii.large),
                    ),
                    child: Row(
                      children: [
                        _DetailWeatherMetric(
                          '💧',
                          '${weather.humidity.round()}%',
                          AppStrings.get('weather_humidity'),
                        ),
                        const _WeatherMetricDivider(),
                        _DetailWeatherMetric(
                          '〰',
                          '${weather.windSpeed.round()}km/s',
                          AppStrings.get('weather_wind'),
                        ),
                        const _WeatherMetricDivider(),
                        _DetailWeatherMetric(
                          '☀️',
                          _weatherUvValue(weather.uvIndex),
                          AppStrings.get('weather_uv'),
                        ),
                        const _WeatherMetricDivider(),
                        _DetailWeatherMetric(
                          '◉',
                          '${visibility}km',
                          AppStrings.get('weather_visibility'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: idealConditions
                              ? AppColors.darkPrimaryLight
                              : AppColors.rating,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _weatherOutdoorMessage(weather),
                          maxLines: 2,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            color: Colors.white,
                            fontSize: AppFontSizes.caption,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (weather.dailyForecast.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Detail5DayForecastStrip(forecasts: weather.dailyForecast),
                  ],
                ],
              ],
            );
          },
        ),
      );
}

class Detail5DayForecastStrip extends StatelessWidget {
  const Detail5DayForecastStrip({super.key, required this.forecasts});

  final List<DailyForecast> forecasts;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Row(
      children: forecasts.map((forecast) {
        final isToday = forecast.date.year == now.year &&
            forecast.date.month == now.month &&
            forecast.date.day == now.day;
        final weekdayLabel = AppStrings.weekdayShort(forecast.date);
        final rainChance = forecast.precipitationProbability;

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            decoration: BoxDecoration(
              color: isToday
                  ? Colors.white.withValues(alpha: .22)
                  : Colors.white.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(AppRadii.medium),
              border: isToday
                  ? Border.all(
                      color: Colors.white.withValues(alpha: .45),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  weekdayLabel,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: isToday ? Colors.white : Colors.white70,
                    fontSize: AppFontSizes.caption,
                    fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  forecast.emoji,
                  style: const TextStyle(fontSize: 19, height: 1.1),
                ),
                const SizedBox(height: 5),
                if (rainChance != null && rainChance > 0)
                  Text(
                    '💧${rainChance.round()}%',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      color: AppColors.categoryWater,
                      fontSize: AppFontSizes.caption,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  const Text(
                    '·',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: Colors.white38,
                      fontSize: AppFontSizes.caption,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 5),
                Text(
                  '${forecast.maximumTemperature.round()}°',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.white,
                    fontSize: AppFontSizes.caption,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${forecast.minimumTemperature.round()}°',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.white60,
                    fontSize: AppFontSizes.caption,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _DetailWeatherMetric extends StatelessWidget {
  const _DetailWeatherMetric(this.icon, this.value, this.label);

  final String icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16, height: 1)),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontSize: AppFontSizes.caption,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Outfit',
                color: Colors.white60,
                fontSize: AppFontSizes.caption,
              ),
            ),
          ],
        ),
      );
}

class _WeatherMetricDivider extends StatelessWidget {
  const _WeatherMetricDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: double.infinity,
        color: Colors.white.withValues(alpha: .09),
      );
}

class _PlaceTrustSummary extends StatelessWidget {
  const _PlaceTrustSummary({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final isUnverifiedUserPlace = place.source == PlaceSource.user &&
        place.verificationStatus == VerificationStatus.unverified;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            switch (place.source) {
              PlaceSource.osm => _TrustChip(
                  icon: Icons.map_outlined,
                  label: AppStrings.get('source_osm'),
                  foreground: AppColors.categoryWater,
                  background: AppColors.categoryWater.withValues(alpha: 0.12),
                ),
              PlaceSource.user => _TrustChip(
                  icon: Icons.groups_2_outlined,
                  label: AppStrings.get('source_community'),
                  foreground: AppColors.primary,
                  background: AppColors.primarySoft,
                ),
              PlaceSource.curated => _TrustChip(
                  icon: Icons.storage_outlined,
                  label: AppStrings.get('source_supabase'),
                  foreground: AppColors.categoryWildlife,
                  background: AppColors.surfaceMuted,
                ),
            },
            if (place.source == PlaceSource.user)
              switch (place.verificationStatus) {
                VerificationStatus.verified => _TrustChip(
                    icon: Icons.fact_check_outlined,
                    label: AppStrings.get('trust_verified'),
                    foreground: AppColors.primary,
                    background: AppColors.primarySoft,
                  ),
                VerificationStatus.community => _TrustChip(
                    icon: Icons.people_outline_rounded,
                    label: AppStrings.get('trust_community'),
                    foreground: AppColors.categoryRoute,
                    background: AppColors.categoryRoute.withValues(alpha: 0.12),
                  ),
                VerificationStatus.unverified => _TrustChip(
                    icon: Icons.info_outline_rounded,
                    label: AppStrings.get('trust_unverified'),
                    foreground: AppColors.accentOrange,
                    background: AppColors.surfaceMuted,
                  ),
              },
          ],
        ),
        if (isUnverifiedUserPlace) ...[
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadii.large),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.route_outlined,
                  size: 17,
                  color: AppColors.accentOrange,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bu konum topluluk tarafından eklendi. Gitmeden önce yol ve erişim koşullarını kontrol et.',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: AppColors.textSecondary,
                      fontSize: AppFontSizes.caption,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

enum _FieldInfoStatus { verified, community, absent, unknown }

class _FieldConditionItem {
  const _FieldConditionItem({
    required this.icon,
    required this.title,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBackground,
    required this.statusIcon,
    this.detail,
    this.facilityKey,
  });

  final IconData icon;
  final String title;
  final String statusLabel;
  final Color statusColor;
  final Color statusBackground;
  final IconData statusIcon;
  final String? detail;
  final String? facilityKey;
}

class _FieldConditionsCard extends StatelessWidget {
  const _FieldConditionsCard({
    required this.place,
    this.enrichment,
  });

  final Place place;
  final PlaceEnrichment? enrichment;

  List<_FieldConditionItem> _buildItems(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVerifiedPlace =
        place.verificationStatus == VerificationStatus.verified;
    final fac = place.facilities.values;
    final distances = place.facilities.nearbyDistances;

    (String label, Color color, Color bg, IconData icon) statusProps(
        _FieldInfoStatus s) {
      return switch (s) {
        _FieldInfoStatus.verified => (
            AppStrings.get('field_status_verified'),
            isDark ? AppColors.darkPrimaryLight : AppColors.primary,
            isDark ? AppColors.darkPrimarySoft : AppColors.primarySoft,
            Icons.check_circle_rounded,
          ),
        _FieldInfoStatus.community => (
            AppStrings.get('field_status_community'),
            AppColors.categoryRoute,
            isDark
                ? AppColors.darkSurfaceMuted
                : AppColors.categoryRoute.withValues(alpha: 0.12),
            Icons.people_outline_rounded,
          ),
        _FieldInfoStatus.absent => (
            AppStrings.get('field_status_absent'),
            isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
            isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted,
            Icons.cancel_outlined,
          ),
        _FieldInfoStatus.unknown => (
            AppStrings.get('field_status_unknown'),
            isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
            isDark ? AppColors.darkSurface : AppColors.surfaceMuted,
            Icons.help_outline_rounded,
          ),
      };
    }

    final items = <_FieldConditionItem>[];

    // 1. İçme Suyu
    final waterOverride =
        CommunityFacilityUpdatesController.getStatus(place, 'drinking_water');
    final waterStatus = waterOverride != null
        ? (waterOverride ? _FieldInfoStatus.community : _FieldInfoStatus.absent)
        : (fac['drinking_water'] == true
            ? (isVerifiedPlace
                ? _FieldInfoStatus.verified
                : _FieldInfoStatus.community)
            : (fac['drinking_water'] == false
                ? _FieldInfoStatus.absent
                : _FieldInfoStatus.unknown));
    final waterProps = statusProps(waterStatus);
    items.add(_FieldConditionItem(
      icon: Icons.water_drop_outlined,
      title: AppStrings.get('field_drinking_water'),
      statusLabel: waterOverride != null
          ? (waterOverride ? 'Topluluk: Var' : 'Topluluk: Yok')
          : waterProps.$1,
      statusColor: waterProps.$2,
      statusBackground: waterProps.$3,
      statusIcon: waterProps.$4,
      facilityKey: 'drinking_water',
      detail: waterStatus == _FieldInfoStatus.unknown ||
              waterStatus == _FieldInfoStatus.absent
          ? null
          : (waterOverride == true || fac['drinking_water'] == true
              ? 'Mevcut'
              : null),
    ));

    // 2. Tuvalet
    final toiletOverride =
        CommunityFacilityUpdatesController.getStatus(place, 'toilets');
    final toiletStatus = toiletOverride != null
        ? (toiletOverride
            ? _FieldInfoStatus.community
            : _FieldInfoStatus.absent)
        : (fac['toilets'] == true
            ? (isVerifiedPlace
                ? _FieldInfoStatus.verified
                : _FieldInfoStatus.community)
            : (fac['toilets'] == false
                ? _FieldInfoStatus.absent
                : _FieldInfoStatus.unknown));
    final toiletProps = statusProps(toiletStatus);
    items.add(_FieldConditionItem(
      icon: Icons.wc_outlined,
      title: AppStrings.get('field_toilets'),
      statusLabel: toiletOverride != null
          ? (toiletOverride ? 'Topluluk: Var' : 'Topluluk: Yok')
          : toiletProps.$1,
      statusColor: toiletProps.$2,
      statusBackground: toiletProps.$3,
      statusIcon: toiletProps.$4,
      facilityKey: 'toilets',
      detail: toiletStatus == _FieldInfoStatus.unknown ||
              toiletStatus == _FieldInfoStatus.absent
          ? null
          : (toiletOverride == true || fac['toilets'] == true
              ? 'Mevcut'
              : null),
    ));

    // 3. Otopark
    final parkingOverride =
        CommunityFacilityUpdatesController.getStatus(place, 'parking');
    final parkingStatus = parkingOverride != null
        ? (parkingOverride
            ? _FieldInfoStatus.community
            : _FieldInfoStatus.absent)
        : (fac['parking'] == true
            ? (isVerifiedPlace
                ? _FieldInfoStatus.verified
                : _FieldInfoStatus.community)
            : (fac['parking'] == false
                ? _FieldInfoStatus.absent
                : _FieldInfoStatus.unknown));
    final parkingProps = statusProps(parkingStatus);
    items.add(_FieldConditionItem(
      icon: Icons.local_parking_rounded,
      title: AppStrings.get('field_parking'),
      statusLabel: parkingOverride != null
          ? (parkingOverride ? 'Topluluk: Var' : 'Topluluk: Yok')
          : parkingProps.$1,
      statusColor: parkingProps.$2,
      statusBackground: parkingProps.$3,
      statusIcon: parkingProps.$4,
      facilityKey: 'parking',
      detail: parkingStatus == _FieldInfoStatus.unknown ||
              parkingStatus == _FieldInfoStatus.absent
          ? null
          : (parkingOverride == true || fac['parking'] == true
              ? 'Mevcut'
              : null),
    ));

    // 4. Piknik & Kamp Uygunluğu
    final campOverride =
        CommunityFacilityUpdatesController.getStatus(place, 'picnic_allowed');
    final isCamp = fac['tents'] == true || fac['caravans'] == true;
    final isPicnic = fac['picnic_allowed'] == true ||
        fac['picnic_facility'] == true ||
        fac['picnic_table_nearby'] == true;
    final campStatus = campOverride != null
        ? (campOverride ? _FieldInfoStatus.community : _FieldInfoStatus.absent)
        : ((isCamp || isPicnic)
            ? (isVerifiedPlace
                ? _FieldInfoStatus.verified
                : _FieldInfoStatus.community)
            : ((fac['picnic_allowed'] == false && fac['tents'] == false)
                ? _FieldInfoStatus.absent
                : _FieldInfoStatus.unknown));
    final campProps = statusProps(campStatus);
    final campDetail = isCamp && isPicnic
        ? 'Kamp & Piknik uygun'
        : (isCamp
            ? 'Kamp uygun'
            : (isPicnic
                ? 'Piknik uygun'
                : (campStatus == _FieldInfoStatus.absent
                    ? 'İzin verilmiyor'
                    : null)));
    items.add(_FieldConditionItem(
      icon: Icons.deck_outlined,
      title: AppStrings.get('field_picnic_camp'),
      statusLabel: campOverride != null
          ? (campOverride ? 'Topluluk: Var' : 'Topluluk: Yok')
          : campProps.$1,
      statusColor: campProps.$2,
      statusBackground: campProps.$3,
      statusIcon: campProps.$4,
      facilityKey: 'picnic_allowed',
      detail: campDetail,
    ));

    // 5. Araç Erişimi & Yol Zemini
    final road = place.roadAccess;
    final roadStatus = road != null
        ? (isVerifiedPlace
            ? _FieldInfoStatus.verified
            : _FieldInfoStatus.community)
        : _FieldInfoStatus.unknown;
    final roadProps = statusProps(roadStatus);
    items.add(_FieldConditionItem(
      icon: Icons.directions_car_outlined,
      title: AppStrings.get('field_road_access'),
      statusLabel: roadProps.$1,
      statusColor: roadProps.$2,
      statusBackground: roadProps.$3,
      statusIcon: roadProps.$4,
      detail: road ?? 'Doğrulanmadı',
    ));

    // 6. Son Yürüme Mesafesi
    final parkingDist = distances['parking'] ?? distances['nearby_parking'];
    final walkingStatus = parkingDist != null
        ? _FieldInfoStatus.verified
        : (road == 'Yalnızca yürüyerek'
            ? _FieldInfoStatus.community
            : _FieldInfoStatus.unknown);
    final walkingProps = statusProps(walkingStatus);
    final walkingDetail = parkingDist != null
        ? 'Otoparktan ~$parkingDist m'
        : (road == 'Yalnızca yürüyerek' ? 'Yürüyüş rotası' : null);
    items.add(_FieldConditionItem(
      icon: Icons.hiking_outlined,
      title: AppStrings.get('field_walking_distance'),
      statusLabel: walkingProps.$1,
      statusColor: walkingProps.$2,
      statusBackground: walkingProps.$3,
      statusIcon: walkingProps.$4,
      detail: walkingDetail,
    ));

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<Map<String, Map<String, bool>>>(
      valueListenable: CommunityFacilityUpdatesController.updates,
      builder: (context, _, __) {
        final items = _buildItems(context);
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.large),
            border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow08,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 0.6,
                    indent: 16,
                    endIndent: 16,
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadii.large),
                    onTap: items[i].facilityKey != null
                        ? () => _openFacilityUpdateModal(
                              context,
                              place,
                              items[i].title,
                              items[i].facilityKey!,
                            )
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color:
                                  items[i].statusColor.withValues(alpha: 0.10),
                              borderRadius:
                                  BorderRadius.circular(AppRadii.medium),
                            ),
                            child: Icon(items[i].icon,
                                size: 16, color: items[i].statusColor),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        items[i].title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: AppFontSizes.label,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (items[i].facilityKey != null) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.edit_note_rounded,
                                        size: 15,
                                        color: items[i].statusColor,
                                      ),
                                    ],
                                  ],
                                ),
                                if (items[i].detail != null)
                                  Text(
                                    items[i].detail!,
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: AppFontSizes.caption - 1,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: items[i].statusBackground,
                              borderRadius:
                                  BorderRadius.circular(AppRadii.small),
                              border: Border.all(
                                color: items[i]
                                    .statusColor
                                    .withValues(alpha: 0.25),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(items[i].statusIcon,
                                    size: 11, color: items[i].statusColor),
                                const SizedBox(width: 3),
                                Text(
                                  items[i].statusLabel,
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: AppFontSizes.caption - 1,
                                    fontWeight: FontWeight.w600,
                                    color: items[i].statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

enum _FacilityChoice { yes, no, reset }

Future<void> _openFacilityUpdateModal(
  BuildContext context,
  Place place,
  String facilityTitle,
  String facilityKey,
) async {
  final allowed = await AppAuthGuard.requireAuth(
    context,
    title: 'Giriş Yapmalısınız',
    message: '$facilityTitle durumunu güncellemek için giriş yapmalısınız.',
  );
  if (!allowed || !context.mounted) return;

  final isDark = Theme.of(context).brightness == Brightness.dark;
  final currentStatus =
      CommunityFacilityUpdatesController.getStatus(place, facilityKey);

  final choice = await showModalBottomSheet<_FacilityChoice>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? AppColors.darkSurfaceDeep : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.hero)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$facilityTitle Durumu',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: AppFontSizes.title,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${place.name} için bu olanak mevcut mu?',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: AppFontSizes.caption,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.medium),
            ),
            tileColor: currentStatus == true
                ? (isDark ? AppColors.darkPrimarySoft : AppColors.primarySoft)
                : null,
            leading: const Icon(Icons.check_circle_outline, color: green),
            title: const Text(
              'Var',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: currentStatus == true
                ? const Icon(Icons.check, color: green)
                : null,
            onTap: () => Navigator.pop(ctx, _FacilityChoice.yes),
          ),
          const SizedBox(height: 8),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.medium),
            ),
            tileColor: currentStatus == false
                ? (isDark ? AppColors.darkErrorSoft : AppColors.errorSoft)
                : null,
            leading: const Icon(Icons.cancel_outlined, color: AppColors.error),
            title: const Text(
              'Yok',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: currentStatus == false
                ? const Icon(Icons.check, color: AppColors.error)
                : null,
            onTap: () => Navigator.pop(ctx, _FacilityChoice.no),
          ),
          const SizedBox(height: 8),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.medium),
            ),
            tileColor:
                isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted,
            leading: const Icon(
              Icons.edit_off_rounded,
              color: AppColors.accentOrange,
            ),
            title: const Text(
              'Yanlış / Hatalı Bilgiyi Düzelt',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
                color: AppColors.accentOrange,
              ),
            ),
            subtitle: Text(
              'Mevcut durum yanlışsa bilgiyi sıfırlar ve düzeltir.',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: AppFontSizes.caption,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            onTap: () => Navigator.pop(ctx, _FacilityChoice.reset),
          ),
        ],
      ),
    ),
  );

  if (choice == null || !context.mounted) return;
  final bool? val = switch (choice) {
    _FacilityChoice.yes => true,
    _FacilityChoice.no => false,
    _FacilityChoice.reset => null,
  };
  await CommunityFacilityUpdatesController.setStatus(
    place: place,
    facilityKey: facilityKey,
    value: val,
  );
  if (context.mounted) {
    final statusMsg = switch (choice) {
      _FacilityChoice.yes => '$facilityTitle durumu "Var" olarak güncellendi.',
      _FacilityChoice.no => '$facilityTitle durumu "Yok" olarak güncellendi.',
      _FacilityChoice.reset =>
        '$facilityTitle bilgisi hatalı olarak düzeltildi ve sıfırlandı.',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(statusMsg),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

Future<void> _openAddPhotoModal(BuildContext context, Place place) async {
  final allowed = await AppAuthGuard.requireAuth(
    context,
    title: 'Giriş Yapmalısınız',
    message: 'Mekâna fotoğraf eklemek için giriş yapmalısınız.',
  );
  if (!allowed || !context.mounted) return;

  final isDark = Theme.of(context).brightness == Brightness.dark;
  XFile? selectedPhoto;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? AppColors.darkSurfaceDeep : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.hero)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Fotoğraf Ekle',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: AppFontSizes.title,
                fontWeight: FontWeight.w700,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${place.name} için katkıda bulunun',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: AppFontSizes.caption,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () async {
                final source = await showPhotoSourceSheet(
                  ctx,
                  title: 'Fotoğraf seç',
                );
                if (source == null || !ctx.mounted) return;
                try {
                  final photo = await ImagePicker().pickImage(
                    source: source,
                    imageQuality: 82,
                    maxWidth: 1920,
                    maxHeight: 1920,
                    requestFullMetadata: false,
                  );
                  if (photo != null && ctx.mounted) {
                    setModalState(() => selectedPhoto = photo);
                  }
                } catch (error) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Fotoğraf seçilemedi: $error')),
                    );
                  }
                }
              },
              icon: Icon(
                selectedPhoto == null
                    ? Icons.add_a_photo_outlined
                    : Icons.check_circle_outline_rounded,
              ),
              label: Text(
                selectedPhoto == null
                    ? 'Kamerayla çek veya galeriden seç'
                    : 'Fotoğraf seçildi · Değiştir',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fotoğraf bağlantısı yazmanız gerekmez.',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: AppFontSizes.caption,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.large),
                  ),
                ),
                onPressed: () async {
                  if (selectedPhoto == null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Kameradan çekin veya galeriden bir fotoğraf seçin.'),
                      ),
                    );
                    return;
                  }
                  try {
                    await CommunityPlacePhotosController
                        .submitPhotoForModeration(
                      place: place,
                      photo: selectedPhoto!,
                    );
                  } catch (error) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text('Fotoğraf gönderilemedi: $error'),
                        ),
                      );
                    }
                    return;
                  }
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Fotoğraf yönetici incelemesine gönderildi.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text(
                  'Fotoğrafı Kaydet',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Builder(
              builder: (ctx) {
                final currentPhotos =
                    CommunityPlacePhotosController.forPlace(place)
                        .where((p) => !p.id.startsWith('moderated-'))
                        .toList(growable: false);
                if (currentPhotos.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.delete_sweep_outlined,
                          size: 16,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Yüklenen Fotoğraflar (Yanlış yüklemeyi sil)',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: AppFontSizes.caption,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 56,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: currentPhotos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, idx) {
                          final p = currentPhotos[idx];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.small),
                                child: _CommunityPhotoThumbnail(
                                  imageValue: p.imageUrl,
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () async {
                                    await CommunityPlacePhotosController
                                        .removePhoto(p.id);
                                    setModalState(() {});
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Fotoğraf silindi.'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.black87,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _CommunityPhotoThumbnail extends StatelessWidget {
  const _CommunityPhotoThumbnail({required this.imageValue});

  final String imageValue;

  Widget get _fallback => Container(
        width: 56,
        height: 56,
        color: Colors.grey.shade300,
        child: const Icon(Icons.broken_image, size: 20),
      );

  @override
  Widget build(BuildContext context) {
    if (imageValue.startsWith('https://')) {
      return Image.network(
        imageValue,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback,
      );
    }
    return FutureBuilder<Uint8List?>(
      future: PlacePhotoStorage.readPersistedPhoto(imageValue),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) return _fallback;
        return Image.memory(
          bytes,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback,
        );
      },
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBg =
        isDark ? background.withValues(alpha: 0.18) : background;
    final effectiveFg =
        isDark ? Color.lerp(foreground, Colors.white, 0.45)! : foreground;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(AppRadii.large),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: effectiveFg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              color: effectiveFg,
              fontSize: AppFontSizes.caption,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripReadinessFact extends StatelessWidget {
  const _TripReadinessFact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: isDark ? AppColors.darkPrimaryLight : AppColors.primary,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.metadataOf(context),
          ),
        ),
      ],
    );
  }
}

class _DetailActionIcon extends StatelessWidget {
  const _DetailActionIcon({
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.tooltip,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => GlassIconButton(
        icon: icon,
        onTap: onTap,
        tooltip: tooltip,
        size: 52,
        iconSize: 22,
        iconColor: iconColor ?? AppColors.textSecondary,
        darkIconColor: iconColor ?? AppColors.darkTextPrimary,
        color: Colors.white.withValues(alpha: 0.85),
        darkColor: AppColors.darkPrimarySoft.withValues(alpha: 0.20),
        borderColor: Colors.white.withValues(alpha: 0.75),
        darkBorderColor: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadii.large),
        blur: 10,
      );
}
