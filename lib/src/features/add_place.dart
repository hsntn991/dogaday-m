part of '../../main.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({
    super.key,
    this.onOpenExisting,
    this.onContributeToExisting,
  });

  final ValueChanged<Place>? onOpenExisting;
  final ValueChanged<Place>? onContributeToExisting;

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  int step = 0;
  int? selected;
  final name = TextEditingController();
  final description = TextEditingController();
  final locationSearch = TextEditingController();
  final mapController = MapController();
  TileProvider? _tileProvider;
  TileProvider get tileProvider =>
      _tileProvider ??= OfflineMapTiles.createTileProvider();
  LatLng? selectedLocation;
  String selectedLocationLabel = '';
  bool locating = false;
  bool searching = false;
  bool saving = false;
  String? categoryError;
  String? nameError;
  String? descriptionError;
  String? locationError;
  final selectedFeatures = <String>{};
  final selectedEnvironment = <String>{};
  final selectedPhotos = <XFile>[];
  bool locationExpanded = false;
  String? roadAccess;

  static const categories = [
    (
      '💧',
      'Su Kaynağı',
      'İçme suyu kaynakları',
      Color(0xFFE9F5FF),
      Color(0xFF55B9ED)
    ),
    ('🌊', 'Şelale', 'Doğal şelaleler', Color(0xFFEAF2FF), Color(0xFF4A8EC4)),
    (
      '🏞️',
      'Göl',
      'Doğal göl ve göletler',
      Color(0xFFF3F0E8),
      Color(0xFF252A20)
    ),
    ('🏞️', 'Kanyon', 'Doğal kanyonlar', Color(0xFFF3F0E8), Color(0xFF6F604F)),
    (
      '🏕️',
      'Kamp Alanı',
      'Kamp ve bungalov',
      Color(0xFFF3F0E8),
      Color(0xFF252A20)
    ),
    ('🌲', 'Milli Park', 'Millî parklar', Color(0xFFEAF3EC), Color(0xFF2E6D43)),
    (
      '🌳',
      'Tabiat Parkı',
      'Tabiat parkları',
      Color(0xFFEDF4E8),
      Color(0xFF4E7A34)
    ),
    ('⛰️', 'Yayla', 'Doğal yaylalar', Color(0xFFF0F4EB), Color(0xFF617A4A)),
    ('🌿', 'Piknik', 'Piknik alanları', Color(0xFFEAF2E3), Color(0xFF85C64A)),
    (
      '🥾',
      'Yürüyüş',
      'Doğa yürüyüş rotaları',
      Color(0xFFFFEEE6),
      Color(0xFFC4622D)
    ),
    (
      '🏖️',
      'Koy ve Plaj',
      'Koylar ve plajlar',
      Color(0xFFE8F5F7),
      Color(0xFF247C91)
    ),
    (
      '🔭',
      'Seyir Noktası',
      'Panoramik manzaralar',
      Color(0xFFF0EDFA),
      Color(0xFF7860B8)
    ),
    ('🪨', 'Mağara', 'Doğal mağaralar', Color(0xFFF0EEF4), Color(0xFF9C96AA)),
    (
      '🚐',
      'Karavan',
      'Karavan dostu alanlar',
      Color(0xFFFFE9F0),
      Color(0xFF6B66B5)
    ),
    (
      '🚻',
      'WC',
      'Bağımsız tuvalet noktası',
      Color(0xFFEEF1F2),
      Color(0xFF68747B)
    ),
  ];

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    locationSearch.dispose();
    mapController.dispose();
    super.dispose();
  }

  Future<void> useCurrentLocation() async {
    setState(() => locating = true);
    try {
      final value = await DeviceLocationService.requestCurrentPosition();
      if (!mounted) return;
      final point = LatLng(value.latitude, value.longitude);
      setState(() {
        selectedLocation = point;
        selectedLocationLabel = value.label;
        locationError = null;
      });
      mapController.move(point, 15);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => locating = false);
    }
  }

  Future<void> searchLocation() async {
    final query = locationSearch.text.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => searching = true);
    try {
      final response = await http.get(
          Uri.https(
            'nominatim.openstreetmap.org',
            '/search',
            {
              'q': query,
              'format': 'jsonv2',
              'limit': '1',
              'countrycodes': 'tr'
            },
          ),
          headers: {
            'User-Agent': 'Dogadayim/1.0 (Flutter nature discovery app)',
            'Accept-Language': 'tr',
          }).timeout(const Duration(seconds: 15));
      final data = jsonDecode(response.body) as List<dynamic>;
      if (response.statusCode != 200 || data.isEmpty) {
        throw Exception('Aradığın konum bulunamadı.');
      }
      final item = data.first as Map<String, dynamic>;
      final point = LatLng(
        double.parse(item['lat'].toString()),
        double.parse(item['lon'].toString()),
      );
      if (!mounted) return;
      setState(() {
        selectedLocation = point;
        selectedLocationLabel = item['display_name']?.toString() ?? query;
        locationError = null;
      });
      mapController.move(point, 14);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => searching = false);
    }
  }

  AddPlaceValidationResult validateDraft() => AddPlaceQualityService.validate(
        name: name.text,
        category: selected == null ? null : categories[selected!].$2,
        description: description.text,
        latitude: selectedLocation?.latitude,
        longitude: selectedLocation?.longitude,
      );

  void applyValidationErrors(AddPlaceValidationResult result) {
    setState(() {
      categoryError = result.errors['category'];
      nameError = result.errors['name'];
      descriptionError = result.errors['description'];
      locationError = result.errors['location'];
      if (categoryError != null) {
        step = 0;
      } else if (nameError != null || descriptionError != null) {
        step = 1;
      } else if (locationError != null) {
        step = 2;
      }
    });
  }

  bool validateCurrentStep() {
    if (step == 0) {
      setState(() =>
          categoryError = selected == null ? 'Bir ana kategori seç.' : null);
      return categoryError == null;
    }
    if (step == 1) {
      setState(() {
        nameError = AddPlaceQualityService.validateName(name.text);
        descriptionError =
            AddPlaceQualityService.validateDescription(description.text);
      });
      return nameError == null && descriptionError == null;
    }
    if (step == 2) {
      final point = selectedLocation;
      setState(() {
        locationError = AddPlaceQualityService.isValidCoordinate(
          point?.latitude,
          point?.longitude,
        )
            ? null
            : 'Haritadan geçerli bir konum seç.';
      });
      return locationError == null;
    }
    return true;
  }

  List<Place> duplicateCandidates(LatLng point) {
    final target = WeatherTarget.coordinates(
      latitude: point.latitude,
      longitude: point.longitude,
      label: selectedLocationLabel.isEmpty
          ? 'Seçilen konum'
          : selectedLocationLabel,
    );
    return <Place>[
      ...NearbyPlacesService.availableNow(target),
      ...SupabasePlacesController.places.value,
      ...UserPlacesController.places.value,
    ];
  }

  Future<void> showStrongDuplicate(PlaceDuplicateMatch match) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bu konumda benzer bir yer zaten var'),
        content: _DuplicatePlacePreview(match: match),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Geri dön'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final callback = widget.onContributeToExisting;
              if (callback != null) {
                callback(match.place);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Mevcut yerin katkı sayfası açılacak.'),
                ));
              }
            },
            child: const Text('Bilgi/fotoğraf ekle'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              widget.onOpenExisting?.call(match.place);
            },
            child: const Text('Mevcut yeri görüntüle'),
          ),
        ],
      ),
    );
  }

  Future<bool> confirmProbableDuplicates(
    List<PlaceDuplicateMatch> matches,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Buna benzer bir yer bulduk'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yine de yeni yer oluşturmak istediğine emin misin?',
                ),
                const SizedBox(height: 12),
                ...matches.map(
                  (match) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _DuplicatePlacePreview(match: match),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Geri dön'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Yine de oluştur'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> savePlace() async {
    if (saving) return;
    final validation = validateDraft();
    if (!validation.isValid) {
      applyValidationErrors(validation);
      return;
    }

    setState(() => saving = true);
    try {
      final category = categories[selected!];
      final point = selectedLocation!;
      final assessment = AddPlaceQualityService.assessDuplicates(
        name: name.text,
        category: category.$2,
        latitude: point.latitude,
        longitude: point.longitude,
        existingPlaces: duplicateCandidates(point),
      );
      if (assessment.strongMatch case final strongMatch?) {
        await showStrongDuplicate(strongMatch);
        return;
      }
      if (assessment.probableMatches.isNotEmpty &&
          !await confirmProbableDuplicates(assessment.probableMatches)) {
        return;
      }

      final now = DateTime.now();
      final sourceId = 'user-${now.microsecondsSinceEpoch}';
      final taxonomy = taxonomyFromLegacy(category.$2);
      String? persistentImage;
      if (selectedPhotos.isNotEmpty) {
        try {
          persistentImage = await PlacePhotoStorage.persistPrimaryPhoto(
            selectedPhotos.first,
            sourceId,
          );
        } catch (_) {
          // Fotoğraf bozuk veya okunamıyorsa yer kaydı yine güvenle tamamlanır.
        }
      }
      final newPlace = Place(
        name.text.trim(),
        selectedLocationLabel.isEmpty ? 'Seçilen konum' : selectedLocationLabel,
        category.$2,
        0,
        Icons.place_rounded,
        [category.$5, category.$4],
        persistentImage,
        description: description.text.trim(),
        latitude: point.latitude,
        longitude: point.longitude,
        sourceId: sourceId,
        updatedAt: now,
        source: PlaceSource.user,
        verificationStatus: VerificationStatus.unverified,
        mainCategory: taxonomy.mainCategory,
        subtype: taxonomy.subtype,
        facilities: PlaceFacilities(values: {
          'parking': selectedFeatures.contains('Otopark') ? true : null,
          'toilets': selectedFeatures.contains('Tuvalet') ? true : null,
          'drinking_water':
              selectedFeatures.contains('İçme suyu') ? true : null,
          'shower': selectedFeatures.contains('Duş') ? true : null,
          'tents': selectedFeatures.contains('Çadır uygun') ? true : null,
          'caravans': selectedFeatures.contains('Karavan uygun') ? true : null,
          'picnic_table_nearby':
              selectedFeatures.contains('Piknik masası') ? true : null,
        }),
        features: <String>[
          ...selectedEnvironment.map((item) => 'Çevre: $item'),
          ...selectedFeatures,
          if (roadAccess != null) 'Ulaşım: $roadAccess',
        ],
      );
      await UserPlacesController.add(newPlace);
      final syncResult =
          await PlaceSubmissionController.enqueueAndSync(newPlace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            switch (syncResult) {
              SubmissionSyncResult.sent =>
                'Yer gönderildi ve yönetici onayı bekliyor. Şimdilik yalnızca sen görebilirsin.',
              SubmissionSyncResult.signInRequired =>
                'Yer cihazına kaydedildi. Giriş yaptığında onay için otomatik gönderilecek.',
              SubmissionSyncResult.queued =>
                'Yer cihazına kaydedildi. İnternet geldiğinde onay için otomatik gönderilecek.',
            },
          ),
        ),
      );
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> pickPhotos() async {
    try {
      final photos = await ImagePicker().pickMultiImage(
        imageQuality: 82,
        maxWidth: 1920,
        maxHeight: 1920,
        limit: AddPlaceQualityService.maxPhotoCount,
      );
      if (!mounted || photos.isEmpty) return;
      setState(() {
        selectedPhotos
          ..clear()
          ..addAll(photos.take(AddPlaceQualityService.maxPhotoCount));
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraflar seçilemedi: $error')),
      );
    }
  }

  Future<void> next() async {
    if (saving || !validateCurrentStep()) return;
    if (step < 3) {
      setState(() {
        if (step == 2) _tileProvider = null;
        step++;
      });
    } else {
      await savePlace();
    }
  }

  void previous() {
    if (step == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      if (step == 2) _tileProvider = null;
      step--;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8F8F7),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                  children: [
                    Row(
                      children: [
                        IconButton.outlined(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 12),
                        Text('Alan Ekle',
                            style:
                                AppTypography.heading.copyWith(fontSize: 26)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.add_location_alt_rounded,
                              color: Color(0xFFD36D2B)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Bildiğin bir doğa noktasını ekleyerek haritanın toplulukla büyümesine yardımcı olabilirsin.',
                              style: TextStyle(fontSize: 13, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _AddPlaceSection(
                      child: Column(
                        children: [
                          TextField(
                            controller: name,
                            maxLength: AddPlaceQualityService.maxNameLength,
                            onChanged: (_) => setState(() => nameError = null),
                            decoration: InputDecoration(
                              labelText: 'Alan ismi *',
                              hintText: 'Örn. Kapuzbaşı Şelaleleri',
                              errorText: nameError,
                              prefixIcon: const Icon(Icons.text_fields_rounded),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: description,
                            maxLines: 4,
                            maxLength:
                                AddPlaceQualityService.maxDescriptionLength,
                            onChanged: (_) =>
                                setState(() => descriptionError = null),
                            decoration: InputDecoration(
                              labelText: 'Açıklama *',
                              hintText:
                                  'Alanı, ulaşımı ve bilinmesi gerekenleri kısaca anlat.',
                              errorText: descriptionError,
                              alignLabelWithHint: true,
                              prefixIcon:
                                  const Icon(Icons.description_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AddPlaceActionCard(
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFF38A560),
                      title: 'Konum Seç *',
                      subtitle: selectedLocation == null
                          ? 'Haritada noktayı işaretle'
                          : selectedLocationLabel,
                      error: locationError,
                      onTap: () =>
                          setState(() => locationExpanded = !locationExpanded),
                    ),
                    if (locationExpanded) ...[
                      const SizedBox(height: 10),
                      _inlineLocationPicker(),
                    ],
                    const SizedBox(height: 12),
                    _AddPlaceActionCard(
                      icon: Icons.add_photo_alternate_outlined,
                      iconColor: const Color(0xFF358FD4),
                      title: 'Fotoğraf Ekle',
                      subtitle: selectedPhotos.isEmpty
                          ? 'En fazla ${AddPlaceQualityService.maxPhotoCount} fotoğraf'
                          : '${selectedPhotos.length} fotoğraf seçildi',
                      onTap: pickPhotos,
                    ),
                    if (selectedPhotos.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _photoPreviewStrip(),
                    ],
                    const SizedBox(height: 12),
                    _AddPlaceSection(
                      title: 'Kategori Seç *',
                      error: categoryError,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(categories.length, (index) {
                          final category = categories[index];
                          return ChoiceChip(
                            avatar: Text(category.$1),
                            label: Text(category.$2),
                            selected: selected == index,
                            onSelected: (_) => setState(() {
                              selected = index;
                              categoryError = null;
                            }),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AddPlaceSection(
                      title: 'Çevre Yapısı',
                      child: _multiChoiceWrap(
                        const [
                          'Ormanlık',
                          'Göl kıyısı',
                          'Sahil',
                          'Yayla',
                          'Dağlık',
                          'Açık alan',
                        ],
                        selectedEnvironment,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AddPlaceSection(
                      title: 'Ulaşım',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          'Binek araç',
                          'Arazi aracı',
                          'Yalnızca yürüyerek',
                          'Toplu taşıma',
                        ]
                            .map((item) => ChoiceChip(
                                  label: Text(item),
                                  selected: roadAccess == item,
                                  onSelected: (_) =>
                                      setState(() => roadAccess = item),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AddPlaceSection(
                      title: 'Olanaklar ve Uyarılar',
                      child: _multiChoiceWrap(
                        const [
                          'Otopark',
                          'Tuvalet',
                          'İçme suyu',
                          'Çeşme',
                          'Duş',
                          'Büfe / Market',
                          'Ücretli',
                          'Çadır uygun',
                          'Karavan uygun',
                          'Piknik masası',
                          'Mobil sinyal',
                          'Engelli erişimi',
                          'Evcil hayvan',
                          'Ateş yasak',
                          'Yaban hayvanı riski',
                        ],
                        selectedFeatures,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: saving ? null : () => unawaited(savePlace()),
                    icon: saving
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(saving ? 'Kaydediliyor...' : 'Gönder'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _inlineLocationPicker() => Container(
        height: 360,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: selectedLocation ?? const LatLng(39.0, 35.2),
                initialZoom: selectedLocation == null ? 5.4 : 14,
                minZoom: 4,
                maxZoom: 19,
                cameraConstraint: CameraConstraint.containLatitude(),
                onTap: (_, point) => setState(() {
                  selectedLocation = point;
                  selectedLocationLabel =
                      '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
                  locationError = null;
                }),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.dogadagezi.dogada_gezi',
                  maxNativeZoom: 19,
                  panBuffer: 2,
                  tileProvider: tileProvider,
                ),
                if (selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selectedLocation!,
                        width: 54,
                        height: 54,
                        child: const Icon(Icons.location_on_rounded,
                            color: green, size: 48),
                      ),
                    ],
                  ),
              ],
            ),
            Positioned(
              left: 10,
              right: 10,
              top: 10,
              child: Material(
                color: Colors.white,
                elevation: 2,
                borderRadius: BorderRadius.circular(8),
                child: TextField(
                  controller: locationSearch,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => searchLocation(),
                  decoration: InputDecoration(
                    hintText: 'İl, ilçe veya yer ara',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: searching
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            onPressed: searchLocation,
                            icon: const Icon(Icons.arrow_forward_rounded),
                          ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 25,
              child: FloatingActionButton.small(
                heroTag: 'inline-add-place-location',
                onPressed: locating ? null : useCurrentLocation,
                backgroundColor: Colors.white,
                foregroundColor: green,
                child: locating
                    ? const Padding(
                        padding: EdgeInsets.all(11),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_rounded),
              ),
            ),
            const Positioned(
              left: 8,
              bottom: 5,
              child: Text('© OpenStreetMap contributors',
                  style: TextStyle(fontSize: 8)),
            ),
          ],
        ),
      );

  Widget _photoPreviewStrip() => SizedBox(
        height: 96,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: selectedPhotos.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, index) => Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: FutureBuilder<Uint8List>(
                    future: selectedPhotos[index].readAsBytes(),
                    builder: (_, snapshot) {
                      if (!snapshot.hasData || snapshot.hasError) {
                        return const ColoredBox(
                          color: Color(0xFFE9E6DE),
                          child: Center(
                              child: Icon(Icons.image_outlined,
                                  color: AppColors.textSecondary)),
                        );
                      }
                      return Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        cacheWidth: 220,
                        gaplessPlayback: true,
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: Color(0xFFE9E6DE),
                          child:
                              Center(child: Icon(Icons.broken_image_outlined)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: InkWell(
                  onTap: () => setState(() => selectedPhotos.removeAt(index)),
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Color(0xAA000000),
                    child: Icon(Icons.close_rounded,
                        color: Colors.white, size: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _multiChoiceWrap(List<String> items, Set<String> selection) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items
            .map(
              (item) => FilterChip(
                label: Text(item),
                selected: selection.contains(item),
                onSelected: (value) => setState(
                    () => value ? selection.add(item) : selection.remove(item)),
              ),
            )
            .toList(),
      );

}

class _AddPlaceSection extends StatelessWidget {
  const _AddPlaceSection({
    required this.child,
    this.title,
    this.error,
  });

  final Widget child;
  final String? title;
  final String? error;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title!,
                  style: AppTypography.body
                      .copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
              if (error != null) ...[
                const SizedBox(height: 4),
                Text(error!,
                    style: const TextStyle(
                        color: Color(0xFFB64A3A), fontSize: 11)),
              ],
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      );
}

class _AddPlaceActionCard extends StatelessWidget {
  const _AddPlaceActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.error,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? error;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color:
                  error == null ? AppColors.border : const Color(0xFFB64A3A)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: AppTypography.body.copyWith(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(error ?? subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.metadata.copyWith(
                              fontSize: 12,
                              color: error == null
                                  ? AppColors.textSecondary
                                  : const Color(0xFFB64A3A))),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      );
}

class _DuplicatePlacePreview extends StatelessWidget {
  const _DuplicatePlacePreview({required this.match});

  final PlaceDuplicateMatch match;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.large),
          border: Border.all(color: const Color(0xFFE3DED4)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: mint,
                borderRadius: BorderRadius.circular(AppRadii.large),
              ),
              child: Icon(match.place.icon, color: green, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      color: ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${match.place.kind} · ${(match.distanceKm * 1000).round()} m uzakta',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      color: Color(0xFF77736C),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
