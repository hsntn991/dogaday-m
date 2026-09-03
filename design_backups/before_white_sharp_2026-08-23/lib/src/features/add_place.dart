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
  final selectedPhotos = <XFile>[];

  static const steps = ['Kategori', 'Detaylar', 'Konum', 'Özellikler'];
  static const categories = [
    (
      '💧',
      'Su Kaynağı',
      'İçme suyu kaynakları',
      Color(0xFFE9F5FF),
      Color(0xFF55B9ED)
    ),
    (
      '🌊',
      'Doğal Kaynak',
      'Soğuk ve temiz kaynaklar',
      Color(0xFFEAF2FF),
      Color(0xFF4A8EC4)
    ),
    ('🌊', 'Şelale', 'Doğal şelaleler', Color(0xFFEAF2FF), Color(0xFF4A8EC4)),
    (
      '🏞️',
      'Göl',
      'Doğal göl ve göletler',
      Color(0xFFF3F0E8),
      Color(0xFF252A20)
    ),
    (
      '🏕️',
      'Kamp Alanı',
      'Kamp ve bungalov',
      Color(0xFFF3F0E8),
      Color(0xFF252A20)
    ),
    ('🌿', 'Piknik', 'Piknik alanları', Color(0xFFEAF2E3), Color(0xFF85C64A)),
    (
      '🥾',
      'Yürüyüş',
      'Doğa yürüyüş rotaları',
      Color(0xFFFFEEE6),
      Color(0xFFC4622D)
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
      ...places,
      ...communitySuggestions.map((suggestion) => suggestion.place),
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
      await UserPlacesController.add(Place(
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
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni yer gerçek konumuyla kaydedildi.')),
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
      setState(() => step++);
    } else {
      await savePlace();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(26, 24, 26, 18),
                  children: [
                    Row(children: [
                      Container(
                          width: 39,
                          height: 39,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x18000000),
                                    blurRadius: 12,
                                    offset: Offset(0, 4))
                              ]),
                          child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => step == 0
                                  ? Navigator.pop(context)
                                  : setState(() => step--),
                              icon: const Icon(Icons.arrow_back_rounded,
                                  color: green, size: 19))),
                      const SizedBox(width: 13),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Yeni Yer Ekle',
                                style: TextStyle(
                                    fontFamily: 'Fraunces',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: ink)),
                            const SizedBox(height: 2),
                            Text('Adım ${step + 1}/4  —  ${steps[step]}',
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF8A8680))),
                          ]),
                    ]),
                    const SizedBox(height: 22),
                    LayoutBuilder(
                        builder: (context, constraints) => Stack(children: [
                              Container(
                                  height: 4,
                                  margin: const EdgeInsets.only(top: 1),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFE5E2DA),
                                      borderRadius: BorderRadius.circular(4))),
                              AnimatedContainer(
                                  duration: const Duration(milliseconds: 260),
                                  height: 4,
                                  width:
                                      constraints.maxWidth * ((step + 1) / 4),
                                  decoration: BoxDecoration(
                                      color: green,
                                      borderRadius: BorderRadius.circular(4))),
                            ])),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                            steps.length,
                            (i) => Text(steps[i],
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: i == step
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: i == step
                                        ? green
                                        : const Color(0xFF8A8680))))),
                    const SizedBox(height: 27),
                    AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _stepBody()),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(26, 12, 26, 22),
                decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFE5E2DA)))),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: saving ? null : () => unawaited(next()),
                    style: FilledButton.styleFrom(
                        backgroundColor: green,
                        disabledBackgroundColor: const Color(0xFFE6E2D9),
                        disabledForegroundColor: const Color(0xFFAAA69E),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    child: saving
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Text(step == 3 ? 'Kaydet' : 'Devam Et',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(width: 9),
                                Icon(
                                    step == 3
                                        ? Icons.check_rounded
                                        : Icons.arrow_forward_rounded,
                                    size: 17)
                              ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _stepBody() {
    if (step == 0) {
      return Column(
          key: const ValueKey(0),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Eklemek istediğin yerin türünü seç',
                style: TextStyle(fontSize: 14, color: Color(0xFF8A8680))),
            if (categoryError != null) ...[
              const SizedBox(height: 7),
              Text(
                categoryError!,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  color: Color(0xFFB64A3A),
                  fontSize: 11,
                ),
              ),
            ],
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 68,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              itemBuilder: (_, i) {
                final c = categories[i];
                final active = selected == i;
                return InkWell(
                  onTap: () => setState(() {
                    selected = i;
                    categoryError = null;
                  }),
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                        color: active ? mint : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: active ? green : Colors.transparent,
                            width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 11,
                              offset: Offset(0, 4))
                        ]),
                    child: Row(children: [
                      Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: c.$4,
                              borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child:
                              Text(c.$1, style: const TextStyle(fontSize: 20))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(c.$2,
                                maxLines: 1,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: ink)),
                            const SizedBox(height: 1),
                            Text(c.$3,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 10,
                                    height: 1.3,
                                    color: Color(0xFF8A8680)))
                          ])),
                    ]),
                  ),
                );
              },
            ),
          ]);
    }
    if (step == 1) {
      return Column(
          key: const ValueKey(1),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Yerle ilgili temel bilgileri ekle',
                style: TextStyle(fontSize: 13, color: Color(0xFF8A8680))),
            const SizedBox(height: 18),
            TextField(
                controller: name,
                maxLength: AddPlaceQualityService.maxNameLength,
                onChanged: (_) => setState(() => nameError = null),
                decoration: InputDecoration(
                    labelText: 'Yer adı',
                    hintText: 'Örn. Düden Şelalesi',
                    errorText: nameError)),
            const SizedBox(height: 12),
            TextField(
                controller: description,
                maxLines: 5,
                maxLength: AddPlaceQualityService.maxDescriptionLength,
                onChanged: (_) => setState(() => descriptionError = null),
                decoration: InputDecoration(
                    labelText: 'Açıklama',
                    hintText: 'Bu yeri özel yapan nedir?',
                    errorText: descriptionError,
                    alignLabelWithHint: true)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
                onPressed: pickPhotos,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(selectedPhotos.isEmpty
                    ? 'Fotoğraf ekle'
                    : '${selectedPhotos.length} fotoğraf seçildi')),
            if (selectedPhotos.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedPhotos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 9),
                  itemBuilder: (_, index) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: SizedBox(
                          width: 92,
                          height: 92,
                          child: FutureBuilder<Uint8List>(
                            future: selectedPhotos[index].readAsBytes(),
                            builder: (_, snapshot) {
                              if (snapshot.hasError) {
                                return const ColoredBox(
                                  color: Color(0xFFE9E6DE),
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Color(0xFF8A8680),
                                    ),
                                  ),
                                );
                              }
                              if (!snapshot.hasData) {
                                return const ColoredBox(
                                  color: Color(0xFFE9E6DE),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: green),
                                  ),
                                );
                              }
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                                errorBuilder: (_, __, ___) => const ColoredBox(
                                  color: Color(0xFFE9E6DE),
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Color(0xFF8A8680),
                                    ),
                                  ),
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
                          onTap: () =>
                              setState(() => selectedPhotos.removeAt(index)),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: .62),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ]);
    }
    if (step == 2) {
      return Column(
          key: const ValueKey(2),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Konumu haritada işaretle',
                style: TextStyle(fontSize: 13, color: Color(0xFF8A8680))),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 330,
                child: Stack(children: [
                  FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(39.0, 35.2),
                      initialZoom: 5.4,
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
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.dogadagezi.dogada_gezi',
                        maxNativeZoom: 19,
                      ),
                      if (selectedLocation != null)
                        MarkerLayer(markers: [
                          Marker(
                            point: selectedLocation!,
                            width: 54,
                            height: 54,
                            child: const Icon(Icons.location_on_rounded,
                                color: green, size: 48),
                          ),
                        ]),
                    ],
                  ),
                  Positioned(
                    left: 10,
                    right: 10,
                    top: 10,
                    child: Material(
                      color: Colors.white,
                      elevation: 3,
                      borderRadius: BorderRadius.circular(14),
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
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
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
                    bottom: 28,
                    child: FloatingActionButton.small(
                      heroTag: 'add-place-location',
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
                ]),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              locationError ??
                  (selectedLocation == null
                      ? 'Haritaya dokunarak konumu işaretle.'
                      : 'Seçilen konum: $selectedLocationLabel'),
              style: TextStyle(
                fontSize: 11,
                color: locationError != null
                    ? const Color(0xFFB64A3A)
                    : selectedLocation == null
                        ? const Color(0xFF8A8680)
                        : green,
              ),
            ),
          ]);
    }
    return Column(
        key: const ValueKey(3),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bu yerde hangi özellikler var?',
              style: TextStyle(fontSize: 13, color: Color(0xFF8A8680))),
          const SizedBox(height: 18),
          Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                'Otopark',
                'Tuvalet',
                'İçme suyu',
                'Ateş alanı',
                'Çadır',
                'Karavan',
                'Evcil hayvan',
                'Aile dostu'
              ]
                  .map((e) => FilterChip(
                      label: Text(e),
                      selected: selectedFeatures.contains(e),
                      onSelected: (value) => setState(() => value
                          ? selectedFeatures.add(e)
                          : selectedFeatures.remove(e))))
                  .toList()),
        ]);
  }
}

class _DuplicatePlacePreview extends StatelessWidget {
  const _DuplicatePlacePreview({required this.match});

  final PlaceDuplicateMatch match;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3ED),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE3DED4)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: mint,
                borderRadius: BorderRadius.circular(11),
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
