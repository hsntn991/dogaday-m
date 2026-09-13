part of '../../main.dart';

bool isSafeExternalUrl(Uri? uri) =>
    uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.place,
    required this.favorite,
    required this.onFavorite,
    this.onOpen,
  });
  final Place place;
  final bool favorite;
  final VoidCallback onFavorite;
  final ValueChanged<Place>? onOpen;
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
  bool? userRecommendation;
  List<String> userRecommendationReasons = const [];
  PlaceEnrichment? enrichment;

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
    final existing = widget.place.image?.trim();
    if (existing != null && existing.isNotEmpty) urls.add(existing);
    for (final photo in enrichment?.photos ?? const <PlacePhotoInfo>[]) {
      if (photo.url.isNotEmpty && !urls.contains(photo.url)) {
        urls.add(photo.url);
      }
    }
    return urls.map(placeWithImage).toList(growable: false);
  }

  List<Place> get nearbyPlaces {
    if (!widget.place.hasCoordinates) return const <Place>[];
    final target = widget.place.weatherTarget;
    final candidates = <Place>[
      ...NearbyPlacesService.availableNow(target),
      ...SupabasePlacesController.places.value,
      ...UserPlacesController.places.value,
    ];
    final seen = <String>{};
    final result = <Place>[];
    for (final place in candidates) {
      if (!place.hasCoordinates) continue;
      final distance = NearbyPlacesService.calculateDistanceKm(
        widget.place.latitude!,
        widget.place.longitude!,
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

  List<ReviewEntry> get allReviews {
    final now = DateTime.now();
    if (userReview == null) return const <ReviewEntry>[];
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
      ),
    ];
  }

  String get detailDescription {
    final aboutText = enrichment?.aboutText.trim() ?? '';
    if (aboutText.isNotEmpty) return aboutText;
    return widget.place.description.trim().isEmpty
        ? 'Bu yer için kayıtlı bir açıklama henüz eklenmemiş.'
        : widget.place.description.trim();
  }

  String get coordinateLabel {
    if (!widget.place.hasCoordinates) return 'Koordinat yok';
    final latitude = widget.place.latitude!;
    final longitude = widget.place.longitude!;
    return '${latitude.abs().toStringAsFixed(5)}°${latitude >= 0 ? 'K' : 'G'}  '
        '${longitude.abs().toStringAsFixed(5)}°${longitude >= 0 ? 'D' : 'B'}';
  }

  String get sourceLabel => switch (widget.place.source) {
        PlaceSource.osm => 'OpenStreetMap',
        PlaceSource.user => 'Topluluk katkısı',
        PlaceSource.curated => 'Supabase',
      };

  String get updatedAtLabel {
    final date = widget.place.updatedAt;
    if (date == null) return 'Tarih bilgisi yok';
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String get userDistanceLabel {
    final target = HomeWeatherLocationController.current.value;
    if (!target.usesCoordinates || !widget.place.hasCoordinates) {
      return 'Konum gerekli';
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
          final fallbackDistance = userDistanceLabel == 'Konum gerekli'
              ? userDistanceLabel
              : '~$userDistanceLabel';
          final distance = route?.distanceLabel ??
              (waiting ? 'Hesaplanıyor' : fallbackDistance);
          final distanceTitle = route != null
              ? 'Yol Mesafesi'
              : waiting
                  ? 'Mesafe'
                  : 'Kuş Uçuşu';
          final duration = route?.durationLabel ??
              (waiting ? 'Hesaplanıyor' : 'Rota bulunamadı');
          return Row(children: [
            stat('📍', distance, distanceTitle),
            const SizedBox(width: 9),
            stat('⏱', duration, 'Ortalama Varış Süresi'),
            const SizedBox(width: 9),
            stat('🧭', widget.place.kind, 'Yer Türü'),
            const SizedBox(width: 9),
            stat('✓', placeSourceLabel, 'Veri Kaynağı'),
          ]);
        },
      );

  Widget facilitiesSection() {
    final facilities = widget.place.facilities;
    final enrichedAmenities = enrichment?.amenities ?? const [];
    final available = facilityLabels.entries
        .where((entry) => facilities.values[entry.key] == true)
        .toList(growable: false);
    final nearby = nearbyFacilityLabels.entries
        .where((entry) => facilities.values[entry.key] == true)
        .toList(growable: false);
    if (available.isEmpty && nearby.isEmpty && enrichedAmenities.isEmpty) {
      return unavailableData(
        enrichment?.amenitiesStatus == 'not_found'
            ? 'Bu yer için doğrulanmış olanak bulunamadı.'
            : 'Bu yer için doğrulanmış olanak bilgisi henüz yok.',
      );
    }

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
              backgroundColor: const Color(0xFFF3F7EF),
              side: const BorderSide(color: Color(0xFFDDE8D8)),
            );
          }).toList(growable: false),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (enrichedAmenities.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: enrichedAmenities.map((amenity) {
              final distance = amenity.distanceMeters;
              final label = distance == null
                  ? amenity.label
                  : '${amenity.label} · $distance m';
              return Tooltip(
                message: [amenity.name, amenity.source]
                    .whereType<String>()
                    .where((value) => value.isNotEmpty)
                    .join(' · '),
                child: Chip(
                  avatar: const Icon(Icons.verified_outlined,
                      size: 17, color: green),
                  label: Text(label),
                  backgroundColor: const Color(0xFFF3F7EF),
                  side: const BorderSide(color: Color(0xFFDDE8D8)),
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
          const Text(
            'Yakında',
            style: TextStyle(fontWeight: FontWeight.w700, color: green),
          ),
          const SizedBox(height: 8),
          chips(nearby, showDistance: true),
        ],
      ],
    );
  }

  Widget nearbyPlacesSection() {
    final nearby = nearbyPlaces;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading('Buraya Yakın Yerler'),
        const SizedBox(height: 3),
        Text(
          '${widget.place.name} merkez alınarak yakından uzağa sıralanır.',
          style: const TextStyle(
            fontFamily: 'Outfit',
            color: Color(0xFF8A8680),
            fontSize: 10.5,
          ),
        ),
        const SizedBox(height: 12),
        if (nearby.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.large),
              border: Border.all(color: const Color(0xFFE8E4DC)),
            ),
            child: Text(
              'Bu noktaya ${NearbyPlacesService.queryRadiusKm} km mesafede '
              'başka bir doğa noktası bulunamadı.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF77736C),
                fontSize: 11.5,
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
    weatherFuture = WeatherService.fetchTarget(widget.place.weatherTarget);
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

  Future<void> loadEnrichment() async {
    final result = await PlaceEnrichmentService.find(widget.place);
    if (mounted && result != null) setState(() => enrichment = result);
  }

  Widget aboutSourcesSection() {
    final sources = enrichment?.aboutSources ?? const <PlaceAboutSource>[];
    if (sources.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 7,
        children: sources.map((source) {
          final license = source.license?.trim();
          final label = license == null || license.isEmpty
              ? source.name
              : '${source.name} · $license';
          final uri = Uri.tryParse(source.url ?? '');
          return ActionChip(
            avatar: const Icon(Icons.open_in_new_rounded, size: 15),
            label: Text(label),
            onPressed: isSafeExternalUrl(uri)
                ? () => launchUrl(uri!, mode: LaunchMode.externalApplication)
                : null,
          );
        }).toList(growable: false),
      ),
    );
  }

  @override
  void dispose() {
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

  Future<void> startNavigation() async {
    if (!widget.place.hasCoordinates) {
      message('Bu yer için geçerli koordinat bulunmuyor.');
      return;
    }

    final provider = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.large),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Navigasyon uygulamasını seç',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              _NavigationProviderTile(
                icon: Icons.map_outlined,
                label: 'Google Maps',
                onTap: () => Navigator.pop(sheetContext, 'google'),
              ),
              _NavigationProviderTile(
                icon: Icons.directions_outlined,
                label: 'Apple Haritalar',
                onTap: () => Navigator.pop(sheetContext, 'apple'),
              ),
              _NavigationProviderTile(
                icon: Icons.navigation_outlined,
                label: 'Yandex Maps',
                onTap: () => Navigator.pop(sheetContext, 'yandex'),
              ),
            ],
          ),
        ),
      ),
    );
    if (provider == null || !mounted) return;

    final latitude = widget.place.latitude!;
    final longitude = widget.place.longitude!;
    final destination = '$latitude,$longitude';
    final uri = switch (provider) {
      'apple' => Uri.parse(
          'https://maps.apple.com/?daddr=$destination&dirflg=d',
        ),
      'yandex' => Uri.parse(
          'https://yandex.com/maps/?rtext=~$destination&rtt=auto',
        ),
      _ => Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$destination&travelmode=driving',
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

  void refreshWeather() => setState(() {
        weatherFuture = WeatherService.fetchTarget(
          widget.place.weatherTarget,
          forceRefresh: true,
        );
      });

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
      barrierColor: const Color(0xB3000000),
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
        barrierColor: const Color(0x99000000),
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
    final result = await showModalBottomSheet<_ContributionResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewRecommendSheet(
        placeName: widget.place.name,
        initialTab: initialTab,
      ),
    );
    if (!mounted || result == null) return;

    setState(() {
      if (result.reviewText.isNotEmpty) {
        userReview = result.reviewText;
        userRating = result.rating;
        userReviewCreatedAt = DateTime.now();
      } else {
        userRecommendation = result.recommended;
        userRecommendationReasons = result.reasons;
      }
    });

    message(result.reviewText.isNotEmpty
        ? 'Değerlendirmen yayınlandı.'
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
                side: const BorderSide(color: Color(0xFFD9D7CF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.large),
                ),
              ),
              icon: const Icon(Icons.star_outline_rounded, size: 18),
              label: const Text(
                'Değerlendirme Yaz',
                maxLines: 1,
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
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
                side: const BorderSide(color: Color(0xFFCADDBB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.large),
                ),
              ),
              icon: const Icon(Icons.groups_2_outlined, size: 18),
              label: const Text(
                'Topluluk ile Öner',
                maxLines: 1,
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
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
              ? const Color(0xFFEDF6E6)
              : const Color(0xFFF2EFE9),
          borderRadius: BorderRadius.circular(AppRadii.large),
          border: Border.all(
            color: userRecommendation!
                ? const Color(0xFFC9DFBB)
                : const Color(0xFFDDD9D1),
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
                  fontSize: 11.5,
                  height: 1.35,
                  color: userRecommendation!
                      ? const Color(0xFF567845)
                      : const Color(0xFF77736C),
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
                    fontSize: 19,
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
                      color: green, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          )
      ]);

  Widget stat(String icon, String value, String label) => Expanded(
        child: Container(
          height: 88,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.large),
              boxShadow: const [
                BoxShadow(color: Color(0x10000000), blurRadius: 8)
              ]),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(icon, style: const TextStyle(fontSize: 19)),
            const SizedBox(height: 7),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 4),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: const TextStyle(fontSize: 8.5, color: Color(0xFF949089)))
          ]),
        ),
      );

  Widget info(String icon, String label, String value) => Expanded(
        child: Container(
          height: 89,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.large),
              border: Border.all(color: const Color(0xFFE9E6DF))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(icon, style: const TextStyle(fontSize: 17)),
            const Spacer(),
            Text(label,
                style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF98938D),
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(value,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))
          ]),
        ),
      );

  Widget unavailableData(String message) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadii.large),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                size: 19, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.surface,
        body: CustomScrollView(controller: scrollController, slivers: [
          SliverAppBar(
            expandedHeight: 330,
            pinned: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 4,
            title: collapsed
                ? Text(widget.place.name,
                    style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 18,
                        fontWeight: FontWeight.w700))
                : null,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                      backgroundColor: const Color(0xA6222921),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24)),
                  icon: const Icon(Icons.arrow_back_rounded)),
            ),
            actions: [
              IconButton(
                  onPressed: () => message('Paylaşım bağlantısı hazırlandı.'),
                  style: IconButton.styleFrom(
                      backgroundColor: const Color(0xA6222921),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24)),
                  icon: const Icon(Icons.share_outlined, size: 20)),
              const SizedBox(width: 7),
              IconButton(
                  onPressed: toggleFavorite,
                  style: IconButton.styleFrom(
                      backgroundColor: const Color(0xA6222921),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24)),
                  icon: Icon(favorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded)),
              const SizedBox(width: 10)
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadii.large),
                  bottomRight: Radius.circular(AppRadii.large),
                ),
                child: Stack(fit: StackFit.expand, children: [
                  NatureArt(place: displayPlace, radius: 0, showKind: false),
                  const DecoratedBox(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                        Color(0x22000000),
                        Colors.transparent,
                        Color(0xC511150F)
                      ]))),
                  Positioned(
                      left: 16,
                      right: 16,
                      bottom: 22,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.place.name,
                                style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    color: Colors.white,
                                    fontSize: 27,
                                    height: 1.06,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Row(children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 15, color: Colors.white70),
                              Text(' ${widget.place.location}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 11)),
                              const Spacer(),
                              if (galleryPlaces.isNotEmpty)
                                InkWell(
                                  onTap: scrollToPhotos,
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.large),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    child: Row(children: [
                                      const Icon(Icons.photo_camera_outlined,
                                          size: 14, color: Colors.white),
                                      Text('  ${galleryPlaces.length} fotoğraf',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600))
                                    ]),
                                  ),
                                )
                            ])
                          ]))
                ]),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 118),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      button: true,
                      label: 'Değerlendirmelere git',
                      child: InkWell(
                        onTap: scrollToReviews,
                        borderRadius: BorderRadius.circular(AppRadii.large),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 2, vertical: 7),
                          child: Row(children: [
                            Icon(
                              allReviews.isEmpty
                                  ? Icons.star_border_rounded
                                  : Icons.star_rounded,
                              color: const Color(0xFFFFA000),
                              size: 19,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              allReviews.isEmpty
                                  ? 'Henüz değerlendirme yok'
                                  : '$userRating · 1 değerlendirme',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                size: 17, color: Color(0xFF8A8680)),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    journeyStats(),
                    const SizedBox(height: 28),
                    Container(
                      key: photoSectionKey,
                      child: heading(
                        'Fotoğraflar',
                        action: galleryPlaces.isEmpty ? null : 'Görüntüle',
                        onAction:
                            galleryPlaces.isEmpty ? null : () => openGallery(0),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (galleryPlaces.isEmpty)
                      unavailableData(
                          'Bu yer için gerçek bir fotoğraf henüz eklenmemiş.')
                    else
                      SizedBox(
                          height: 86,
                          child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: galleryPlaces.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (_, i) => GestureDetector(
                                    onTap: () => openGallery(i),
                                    child: SizedBox(
                                        width: 112,
                                        child: NatureArt(
                                            place: galleryPlaces[i],
                                            radius: 14,
                                            showKind: false)),
                                  ))),
                    const SizedBox(height: 28),
                    heading('Hakkında'),
                    const SizedBox(height: 10),
                    Text(detailDescription,
                        style: const TextStyle(
                            fontSize: 14,
                            height: 1.72,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF625F58))),
                    for (final photo in enrichment?.photos ?? const <PlacePhotoInfo>[])
                      ListTile(
                        dense: true,
                        title: Text(photo.attribution ?? 'Fotoğraf: ${photo.author ?? photo.source} / ${photo.source}'),
                        subtitle: Text(photo.license ?? ''),
                        trailing: const Icon(Icons.open_in_new, size: 16),
                        onTap: () {
                          final uri = Uri.tryParse(photo.sourcePageUrl ?? '');
                          if (isSafeExternalUrl(uri)) launchUrl(uri!);
                        },
                      ),
                    aboutSourcesSection(),
                    const SizedBox(height: 22),
                    Row(children: [
                      info('🧭', 'KOORDİNATLAR', coordinateLabel),
                      const SizedBox(width: 10),
                      info('↗', 'VERİ KAYNAĞI', sourceLabel)
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      info('◉', 'VERİ KAYNAĞI', placeSourceLabel),
                      const SizedBox(width: 10),
                      info('↻', 'SON GÜNCELLEME', updatedAtLabel)
                    ]),
                    const SizedBox(height: 20),
                    _PlaceTrustSummary(place: widget.place),
                    const SizedBox(height: 26),
                    heading('Bölge Havası'),
                    const SizedBox(height: 11),
                    _LiveWeatherCard(
                      place: widget.place,
                      future: weatherFuture,
                      onRetry: refreshWeather,
                    ),
                    const SizedBox(height: 27),
                    heading('Olanaklar'),
                    const SizedBox(height: 12),
                    facilitiesSection(),
                    const SizedBox(height: 28),
                    Container(
                      key: reviewsSectionKey,
                      child: heading(
                        'Değerlendirmeler',
                        action: allReviews.isEmpty ? null : 'Tümünü Gör',
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
                      unavailableData(
                          'Bu yer için henüz gerçek bir değerlendirme yapılmamış.'),
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
                    const SizedBox(height: 28),
                    nearbyPlacesSection(),
                  ]),
            ),
          )
        ]),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: const BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 20,
                      offset: Offset(0, -5))
                ]),
            child: Row(children: [
              _DetailActionIcon(
                  icon: favorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  onTap: toggleFavorite),
              const SizedBox(width: 9),
              _DetailActionIcon(
                  icon: Icons.share_outlined,
                  onTap: () => message('Paylaşım bağlantısı hazırlandı.')),
              const SizedBox(width: 11),
              Expanded(
                  child: FilledButton.icon(
                      onPressed: startNavigation,
                      style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(53),
                          backgroundColor: green,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadii.large))),
                      icon: const Icon(Icons.navigation_outlined),
                      label: const Text('Navigasyonu Başlat')))
            ]),
          ),
        ),
      );
}

class _NavigationProviderTile extends StatelessWidget {
  const _NavigationProviderTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadii.medium),
          ),
          child: Icon(icon, color: green, size: 21),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      );
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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.large),
          boxShadow: const [
            BoxShadow(color: Color(0x0F000000), blurRadius: 8),
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
                      Text(
                        review.name,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$stars  ${review.timeLabel}',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          color: Color(0xFFFFA000),
                          fontSize: 9,
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
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12.5,
                height: 1.5,
                color: Color(0xFF65635E),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: helpful
                            ? const Color(0xFFEAF2E3)
                            : const Color(0xFFF5F3EE),
                        borderRadius: BorderRadius.circular(AppRadii.large),
                        border: Border.all(
                          color: helpful
                              ? const Color(0xFFBFD5AE)
                              : const Color(0xFFE7E3DB),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            helpful
                                ? Icons.thumb_up_alt_rounded
                                : Icons.thumb_up_alt_outlined,
                            size: 15,
                            color: helpful ? green : const Color(0xFF8C8983),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Faydalı (${review.helpfulCount + (helpful ? 1 : 0)})',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 9.5,
                              color: helpful ? green : const Color(0xFF8C8983),
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
                const Text(
                  'Yanıtla',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 9.5,
                    color: Color(0xFF8C8983),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
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
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.large),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
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
                          const Text(
                            'Tüm Değerlendirmeler',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              color: ink,
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${widget.placeName} · En yeniden en eskiye',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: Color(0xFF827E77),
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: ink,
                        side: const BorderSide(color: Color(0xFFE4E0D8)),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE3DFD7)),
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
  });

  final String reviewText;
  final int rating;
  final bool recommended;
  final List<String> reasons;
}

class _ReviewRecommendSheet extends StatefulWidget {
  const _ReviewRecommendSheet({
    required this.placeName,
    required this.initialTab,
  });

  final String placeName;
  final int initialTab;

  @override
  State<_ReviewRecommendSheet> createState() => _ReviewRecommendSheetState();
}

class _ReviewRecommendSheetState extends State<_ReviewRecommendSheet> {
  final reviewController = TextEditingController();
  late int tab;
  int rating = 0;
  bool recommended = true;
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

  bool get canSubmit => tab == 0
      ? rating > 0 && reviewController.text.trim().isNotEmpty
      : selectedReasons.isNotEmpty;

  @override
  void initState() {
    super.initState();
    tab = widget.initialTab.clamp(0, 1);
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  void submit() {
    if (!canSubmit) return;
    Navigator.pop(
      context,
      _ContributionResult(
        reviewText: tab == 0 ? reviewController.text.trim() : '',
        rating: tab == 0 ? rating : 0,
        recommended: recommended,
        reasons: selectedReasons.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .88,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadii.large)),
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
                      color: const Color(0xFFD4D0C8),
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
                          tab == 0 ? 'Deneyimini paylaş' : 'Topluluk ile öner',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            color: ink,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.placeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            color: Color(0xFF8A8680),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: ink,
                      side: const BorderSide(color: Color(0xFFE4E0D8)),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ]),
                const SizedBox(height: 18),
                Container(
                  height: 47,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECE8DF),
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
                      backgroundColor: green,
                      disabledBackgroundColor: const Color(0xFFE1DED6),
                      disabledForegroundColor: const Color(0xFFA29E96),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.large),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tab == 0
                              ? 'Değerlendirmeyi Gönder'
                              : 'Toplulukla Paylaş',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _reviewBody() => Column(
        key: const ValueKey('review'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bu yeri nasıl buldun?',
            style: TextStyle(
              fontFamily: 'Outfit',
              color: ink,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Deneyimini yıldızlarla değerlendir.',
            style: TextStyle(
              fontFamily: 'Outfit',
              color: Color(0xFF8A8680),
              fontSize: 11,
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
                    color: i < rating ? const Color(0xFFFFF3D8) : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.large),
                    border: Border.all(
                      color: i < rating
                          ? const Color(0xFFFFD47B)
                          : const Color(0xFFE4E0D8),
                    ),
                  ),
                  child: Icon(
                    i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: const Color(0xFFFFA000),
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Yorumun',
            style: TextStyle(
              fontFamily: 'Outfit',
              color: ink,
              fontSize: 12,
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
            style: const TextStyle(
              fontFamily: 'Outfit',
              color: ink,
              fontSize: 13,
              height: 1.45,
            ),
            decoration: InputDecoration(
              hintText:
                  'Neleri beğendin? Ziyaret edecek kişilere yardımcı ol...',
              hintStyle: const TextStyle(
                color: Color(0xFFA19D95),
                fontSize: 12,
                height: 1.4,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.large),
                borderSide: const BorderSide(color: Color(0xFFE1DED6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.large),
                borderSide: const BorderSide(color: Color(0xFFE1DED6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.large),
                borderSide: const BorderSide(color: green, width: 1.4),
              ),
            ),
          ),
        ],
      );

  Widget _recommendBody() {
    final reasons = recommended ? positiveReasons : negativeReasons;
    return Column(
      key: const ValueKey('recommend'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Topluluğa önerir misin?',
          style: TextStyle(
            fontFamily: 'Outfit',
            color: ink,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Seçimin diğer doğaseverlere yol gösterecek.',
          style: TextStyle(
            fontFamily: 'Outfit',
            color: Color(0xFF8A8680),
            fontSize: 11,
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
          style: const TextStyle(
            fontFamily: 'Outfit',
            color: ink,
            fontSize: 12,
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
                color: selected ? green : const Color(0xFF706C65),
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
              selectedColor: mint,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected
                    ? const Color(0xFFBFD8AD)
                    : const Color(0xFFE1DED6),
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
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.large),
              boxShadow: active
                  ? const [BoxShadow(color: Color(0x10000000), blurRadius: 7)]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 17, color: active ? green : const Color(0xFF8A8680)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: active ? green : const Color(0xFF8A8680),
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
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
    final activeColor = positive ? green : const Color(0xFF8A5A48);
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
                    ? mint
                    : const Color(0xFFF5ECE8)
                : Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.large),
            border: Border.all(
              color: active ? activeColor : const Color(0xFFE1DED6),
              width: active ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 19,
                  color: active ? activeColor : const Color(0xFF8A8680)),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: active ? activeColor : const Color(0xFF69665F),
                  fontSize: 11.5,
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
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.large),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
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
                          overlayButton(
                            icon: reaction == 1
                                ? Icons.thumb_up_alt_rounded
                                : Icons.thumb_up_alt_outlined,
                            tooltip: 'Beğen',
                            selected: reaction == 1,
                            selectedColor: const Color(0xFF3A7D22),
                            onPressed: () => react(1),
                          ),
                          const SizedBox(width: 8),
                          overlayButton(
                            icon: reaction == -1
                                ? Icons.thumb_down_alt_rounded
                                : Icons.thumb_down_alt_outlined,
                            tooltip: 'Beğenme',
                            selected: reaction == -1,
                            selectedColor: const Color(0xFFB95343),
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
                            fontSize: 11,
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
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                color: ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Kaydırarak diğer fotoğrafları gör',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                color: Color(0xFF817D76),
                                fontSize: 10.5,
                              ),
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
                                  : const Color(0xFFD4D0C8),
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

class _LiveWeatherCard extends StatelessWidget {
  const _LiveWeatherCard({
    required this.place,
    required this.future,
    required this.onRetry,
  });

  final Place place;
  final Future<WeatherSnapshot> future;
  final VoidCallback onRetry;

  BoxDecoration get decoration => BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF174A0D), Color(0xFF4AA62B)],
        ),
        borderRadius: BorderRadius.circular(AppRadii.large),
        boxShadow: const [
          BoxShadow(
            color: Color(0x382B751A),
            blurRadius: 22,
            offset: Offset(0, 9),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => Container(
        height: 244,
        padding: const EdgeInsets.fromLTRB(20, 18, 14, 14),
        decoration: decoration,
        child: FutureBuilder<WeatherSnapshot>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    '${place.location} için hava durumu alınıyor...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_outlined,
                      color: Colors.white, size: 30),
                  const SizedBox(height: 8),
                  Text(
                    '${place.location} hava durumu şu anda alınamadı.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 7),
                  TextButton.icon(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Yeniden dene',
                        style: TextStyle(fontSize: 10)),
                  ),
                ],
              );
            }

            final weather = snapshot.data!;
            final visibility = weather.visibilityKm < 10
                ? weather.visibilityKm.toStringAsFixed(1)
                : weather.visibilityKm.round().toString();
            final idealConditions = _weatherIsIdeal(weather);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${place.name.toUpperCase()} · ŞU AN',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.white70,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .25,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${weather.temperature.round()}°',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        fontSize: 47,
                        height: .95,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Hissedilen ${weather.apparentTemperature.round()}°',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: Colors.white60,
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(weather.emoji,
                        style: const TextStyle(fontSize: 47, height: 1)),
                  ],
                ),
                const SizedBox(height: 17),
                Container(
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(AppRadii.large),
                  ),
                  child: Row(
                    children: [
                      _DetailWeatherMetric(
                          '💧', '${weather.humidity.round()}%', 'Nem'),
                      const _WeatherMetricDivider(),
                      _DetailWeatherMetric(
                          '〰', '${weather.windSpeed.round()}km/s', 'Rüzgâr'),
                      const _WeatherMetricDivider(),
                      _DetailWeatherMetric(
                          '☀️', _weatherUvValue(weather.uvIndex), 'UV'),
                      const _WeatherMetricDivider(),
                      _DetailWeatherMetric('◉', '${visibility}km', 'Görüş'),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: idealConditions
                            ? const Color(0xFF64E3B0)
                            : const Color(0xFFFFD166),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _weatherOutdoorMessage(weather),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
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
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Outfit',
                color: Colors.white60,
                fontSize: 8.5,
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
              PlaceSource.osm => const _TrustChip(
                  icon: Icons.map_outlined,
                  label: 'OpenStreetMap verisi',
                  foreground: Color(0xFF3B6F87),
                  background: Color(0xFFEAF4F7),
                ),
              PlaceSource.user => const _TrustChip(
                  icon: Icons.groups_2_outlined,
                  label: 'Topluluk katkısı',
                  foreground: Color(0xFF567845),
                  background: Color(0xFFEDF6E6),
                ),
              PlaceSource.curated => const _TrustChip(
                  icon: Icons.storage_outlined,
                  label: 'Supabase kaydı',
                  foreground: Color(0xFF4F6558),
                  background: Color(0xFFF0F3F1),
                ),
            },
            if (place.source == PlaceSource.user)
              switch (place.verificationStatus) {
                VerificationStatus.verified => const _TrustChip(
                    icon: Icons.fact_check_outlined,
                    label: 'İnceleme işareti var',
                    foreground: Color(0xFF397044),
                    background: Color(0xFFE8F4E8),
                  ),
                VerificationStatus.community => const _TrustChip(
                    icon: Icons.people_outline_rounded,
                    label: 'Toplulukça güncelleniyor',
                    foreground: Color(0xFF6F6639),
                    background: Color(0xFFF6F1DD),
                  ),
                VerificationStatus.unverified => const _TrustChip(
                    icon: Icons.info_outline_rounded,
                    label: 'Henüz incelenmedi',
                    foreground: Color(0xFF806A3E),
                    background: Color(0xFFF8F1E3),
                  ),
              },
          ],
        ),
        if (isUnverifiedUserPlace) ...[
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F4EA),
              borderRadius: BorderRadius.circular(AppRadii.large),
              border: Border.all(color: const Color(0xFFE8DEC8)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.route_outlined,
                  size: 17,
                  color: Color(0xFF806A3E),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bu konum topluluk tarafından eklendi. Gitmeden önce yol ve erişim koşullarını kontrol et.',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: Color(0xFF6E624C),
                      fontSize: 10.5,
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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.large),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Outfit',
                color: foreground,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}

class _DetailActionIcon extends StatelessWidget {
  const _DetailActionIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 52,
      height: 52,
      child: IconButton(
          onPressed: onTap,
          icon: Icon(icon),
          color: const Color(0xFF777A72),
          style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE5E2DB)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.large)))));
}
