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

class AddPlaceDraftController {
  AddPlaceDraftController._();

  static const _storageKey = 'add_place_draft_v1';

  static Future<Map<String, dynamic>?> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(_storageKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final value = jsonDecode(raw);
      return value is Map<String, dynamic> ? value : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(Map<String, dynamic> value) async {
    await (await SharedPreferences.getInstance()).setString(
      _storageKey,
      jsonEncode(value),
    );
  }

  static Future<void> clear() async {
    await (await SharedPreferences.getInstance()).remove(_storageKey);
  }
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  int step = 0;
  int? selected;
  final name = TextEditingController();
  final description = TextEditingController();
  final locationSearch = TextEditingController();
  final latitudeInput = TextEditingController();
  final longitudeInput = TextEditingController();
  final mapController = MapController();
  bool _mapReady = false;
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
  bool draftRestored = false;

  void _handleMapReady() {
    _mapReady = true;
    _moveMapToSelectedLocation();
  }

  /// Konum servisi ya da arama sonucu, FlutterMap ilk karesini çizmeden önce
  /// gelebilir. Kamera henüz hazır değilken yapılan move çağrısı kaybolduğu
  /// için seçili noktayı saklıyor ve harita hazır olduğunda taşıyoruz.
  void _moveMapToSelectedLocation([double? zoom]) {
    final point = selectedLocation;
    if (!_mapReady || point == null) return;
    mapController.move(point, zoom ?? 14);
  }

  static const categories = [
    (
      Icons.cabin_rounded,
      'Kamp',
      'Çadır kurmaya uygun alanlar',
      AppColors.categoryCampSoft,
      AppColors.categoryCamp,
    ),
    (
      Icons.rv_hookup_rounded,
      'Karavan',
      'Karavan dostu alanlar',
      AppColors.categoryCampSoft,
      AppColors.categoryCamp,
    ),
    (
      Icons.water_rounded,
      'Göl',
      'Göl ve göletler',
      AppColors.categoryWaterSoft,
      AppColors.categoryWater,
    ),
    (
      Icons.waterfall_chart_rounded,
      'Şelale',
      'Doğal şelaleler',
      AppColors.categoryWaterSoft,
      AppColors.categoryWater,
    ),
    (
      Icons.terrain_rounded,
      'Kanyon & Vadi',
      'Kanyon ve vadiler',
      AppColors.categoryFormationSoft,
      AppColors.categoryFormation,
    ),
    (
      Icons.landscape_rounded,
      'Mağara',
      'Doğal mağaralar',
      AppColors.categoryFormationSoft,
      AppColors.categoryFormation,
    ),
    (
      Icons.forest_rounded,
      'Millî / Doğa Parkı',
      'Korunan doğal alanlar',
      AppColors.categoryNatureSoft,
      AppColors.categoryNature,
    ),
  ];

  @override
  void initState() {
    super.initState();
    AppLocaleController.current.addListener(_onLocaleChanged);
    name.addListener(_saveDraft);
    description.addListener(_saveDraft);
    unawaited(_restoreDraft());
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppLocaleController.current.removeListener(_onLocaleChanged);
    name.removeListener(_saveDraft);
    description.removeListener(_saveDraft);
    name.dispose();
    description.dispose();
    locationSearch.dispose();
    latitudeInput.dispose();
    longitudeInput.dispose();
    mapController.dispose();
    super.dispose();
  }

  Future<void> _restoreDraft() async {
    final draft = await AddPlaceDraftController.load();
    if (!mounted || draft == null) return;
    final latitude = (draft['latitude'] as num?)?.toDouble();
    final longitude = (draft['longitude'] as num?)?.toDouble();
    final savedCategoryKey = draft['categoryKey']?.toString();
    final restoredCategoryIndex = savedCategoryKey == null
        ? -1
        : categories.indexWhere(
            (category) =>
                taxonomyFromLegacy(category.$2).mainCategory ==
                savedCategoryKey,
          );
    setState(() {
      // Eski taslaktaki sıra numarası artık başka bir kategoriye karşılık
      // gelebilir. Yanlış türde kayıt göndermek yerine kullanıcıdan yeniden
      // seçim isteriz; yeni taslaklar sabit kategori anahtarını saklar.
      selected = restoredCategoryIndex >= 0 ? restoredCategoryIndex : null;
      name.text = draft['name']?.toString() ?? '';
      description.text = draft['description']?.toString() ?? '';
      selectedLocation = latitude == null || longitude == null
          ? null
          : LatLng(latitude, longitude);
      selectedLocationLabel = draft['locationLabel']?.toString() ?? '';
      latitudeInput.text = latitude?.toStringAsFixed(5) ?? '';
      longitudeInput.text = longitude?.toStringAsFixed(5) ?? '';
      selectedFeatures
        ..clear()
        ..addAll((draft['features'] as List? ?? const [])
            .map((item) => item.toString()));
      selectedEnvironment
        ..clear()
        ..addAll((draft['environment'] as List? ?? const [])
            .map((item) => item.toString()));
      roadAccess = draft['roadAccess']?.toString();
      draftRestored = true;
    });
    _moveMapToSelectedLocation();
  }

  void _saveDraft() {
    final hasDraft = selected != null ||
        name.text.trim().isNotEmpty ||
        description.text.trim().isNotEmpty ||
        selectedLocation != null;
    if (!hasDraft) return;
    unawaited(AddPlaceDraftController.save({
      'category': selected,
      'categoryKey': selected == null
          ? null
          : taxonomyFromLegacy(categories[selected!].$2).mainCategory,
      'name': name.text,
      'description': description.text,
      'latitude': selectedLocation?.latitude,
      'longitude': selectedLocation?.longitude,
      'locationLabel': selectedLocationLabel,
      'features': selectedFeatures.toList(growable: false),
      'environment': selectedEnvironment.toList(growable: false),
      'roadAccess': roadAccess,
    }));
  }

  Future<void> useCurrentLocation() async {
    setState(() => locating = true);
    try {
      final value = await DeviceLocationService.requestCurrentPosition();
      if (!mounted) return;
      final point = LatLng(value.latitude, value.longitude);
      _selectLocation(point, label: value.label, zoom: 15);
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
      _selectLocation(
        point,
        label: item['display_name']?.toString() ?? query,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => searching = false);
    }
  }

  void _openLocationPicker() => setState(() => locationExpanded = true);

  void _selectLocation(
    LatLng point, {
    String? label,
    double zoom = 14,
  }) {
    setState(() {
      selectedLocation = point;
      selectedLocationLabel = label ??
          '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
      latitudeInput.text = point.latitude.toStringAsFixed(5);
      longitudeInput.text = point.longitude.toStringAsFixed(5);
      locationError = null;
      locationExpanded = true;
    });
    _moveMapToSelectedLocation(zoom);
    _saveDraft();
  }

  double? _parseCoordinate(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  void _showCoordinateEntry() {
    String? error;
    showDialog<void>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.82,
              ),
              child: GlassContainer(
                borderRadius: BorderRadius.circular(24),
                blur: 18,
                color: AppColors.surface,
                darkColor: AppColors.darkSurface,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        AppStrings.get('add_place_coordinates_title'),
                        style: AppTypography.headingOf(sheetContext),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.get('add_place_coordinates_hint'),
                        style: AppTypography.metadataOf(sheetContext),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        key: const Key('add_place_latitude'),
                        controller: latitudeInput,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: InputDecoration(
                          labelText: AppStrings.get('add_place_latitude'),
                          hintText: '39.92080',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        key: const Key('add_place_longitude'),
                        controller: longitudeInput,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: InputDecoration(
                          labelText: AppStrings.get('add_place_longitude'),
                          hintText: '32.85410',
                          errorText: error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const Key('add_place_apply_coordinates'),
                          onPressed: () {
                            final latitude =
                                _parseCoordinate(latitudeInput.text);
                            final longitude =
                                _parseCoordinate(longitudeInput.text);
                            if (!AddPlaceQualityService.isValidCoordinate(
                              latitude,
                              longitude,
                            )) {
                              setSheetState(() => error = AppStrings.get(
                                  'add_place_coordinates_invalid'));
                              return;
                            }
                            Navigator.pop(sheetContext);
                            _selectLocation(LatLng(latitude!, longitude!));
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: Text(
                            AppStrings.get('add_place_apply_coordinates'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
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
      setState(() => categoryError = selected == null
          ? AppStrings.get('add_place_validation_category')
          : null);
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
            : AppStrings.get('add_place_validation_location');
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
        title: Text(AppStrings.get('add_place_duplicate_title')),
        content: _DuplicatePlacePreview(match: match),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppStrings.get('add_place_btn_back')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final callback = widget.onContributeToExisting;
              if (callback != null) {
                callback(match.place);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppStrings.get('add_place_btn_contribute')),
                ));
              }
            },
            child: Text(AppStrings.get('add_place_btn_contribute')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              widget.onOpenExisting?.call(match.place);
            },
            child: Text(AppStrings.get('add_place_btn_view_existing')),
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
            title: Text(AppStrings.get('add_place_duplicate_title')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('add_place_duplicate_title'),
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
                child: Text(AppStrings.get('add_place_btn_back')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(AppStrings.get('add_place_btn_create_anyway')),
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
    final allowed = await AppAuthGuard.requireAuth(
      context,
      title: AppStrings.get('guest_auth_title'),
      message: AppStrings.get('guest_add_place_prompt'),
    );
    if (!allowed || !mounted) return;

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
        contributorName: () {
          try {
            final u = Supabase.instance.client.auth.currentUser;
            final meta = u?.userMetadata;
            final fullName = (meta?['full_name']?.toString() ??
                    meta?['name']?.toString() ??
                    meta?['display_name']?.toString() ??
                    '')
                .trim();
            return fullName.isNotEmpty
                ? fullName
                : (u?.email?.split('@').first ?? '');
          } catch (_) {
            return null;
          }
        }(),
      );
      await UserPlacesController.add(newPlace);
      final syncResult =
          await PlaceSubmissionController.enqueueAndSync(newPlace);
      if (syncResult == SubmissionSyncResult.sent) {
        await SubmissionFeedbackController.load();
      }
      if (!mounted) return;
      await AddPlaceDraftController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            switch (syncResult) {
              SubmissionSyncResult.sent =>
                AppStrings.get('add_place_submitted_waiting'),
              SubmissionSyncResult.signInRequired =>
                AppStrings.get('add_place_saved_offline_login'),
              SubmissionSyncResult.queued =>
                AppStrings.get('add_place_saved_offline_net'),
              SubmissionSyncResult.failed =>
                'Yer henüz yöneticiye gönderilemedi. Bağlantı veya sunucu '
                    'sorunu giderildiğinde otomatik olarak tekrar denenecek.',
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
    final source = await showPhotoSourceSheet(
      context,
      title: 'Yer fotoğrafı ekle',
    );
    if (source == null || !mounted) return;
    try {
      final picker = ImagePicker();
      late final List<XFile> photos;
      if (source == ImageSource.camera) {
        final photo = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 82,
          maxWidth: 1920,
          maxHeight: 1920,
          requestFullMetadata: false,
        );
        photos = photo == null ? const <XFile>[] : <XFile>[photo];
      } else {
        photos = await picker.pickMultiImage(
          imageQuality: 82,
          maxWidth: 1920,
          maxHeight: 1920,
          limit: AddPlaceQualityService.maxPhotoCount,
          requestFullMetadata: false,
        );
      }
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Geri dön',
          child: IconButton.outlined(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        const SizedBox(width: 12),
        Text(AppStrings.get('add_place_title'),
            style: AppTypography.headingOf(context)
                .copyWith(fontSize: AppFontSizes.display)),
      ],
    );
  }

  Widget _buildBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentOrangeOf(context)
            .withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(
                color: AppColors.accentOrangeOf(context).withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.add_location_alt_rounded,
              color: AppColors.accentOrangeOf(context)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              draftRestored
                  ? 'Taslağın geri yüklendi. Fotoğrafları yeniden seçebilirsin.'
                  : AppStrings.get('add_place_banner'),
              style: TextStyle(
                fontSize: AppFontSizes.label,
                height: 1.4,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFields(BuildContext context) {
    return _AddPlaceSection(
      child: Column(
        children: [
          TextField(
            controller: name,
            maxLength: AddPlaceQualityService.maxNameLength,
            onChanged: (_) => setState(() => nameError = null),
            decoration: InputDecoration(
              labelText: AppStrings.get('add_place_name_label'),
              hintText: AppStrings.get('add_place_name_hint'),
              errorText: nameError,
              prefixIcon: const Icon(Icons.text_fields_rounded),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: description,
            maxLines: 4,
            maxLength: AddPlaceQualityService.maxDescriptionLength,
            onChanged: (_) => setState(() => descriptionError = null),
            decoration: InputDecoration(
              labelText: AppStrings.get('add_place_desc_label'),
              hintText: AppStrings.get('add_place_desc_hint'),
              errorText: descriptionError,
              alignLabelWithHint: true,
              prefixIcon: const Icon(Icons.description_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return _AddPlaceSection(
      title: AppStrings.get('add_place_category_title'),
      error: categoryError,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(categories.length, (index) {
          final category = categories[index];
          return ChoiceChip(
            avatar: Icon(
              category.$1,
              size: 18,
              color: selected == index ? Colors.white : category.$5,
            ),
            label: Text(AppStrings.addPlaceOption(category.$2)),
            selected: selected == index,
            onSelected: (_) {
              setState(() {
                selected = index;
                categoryError = null;
              });
              _saveDraft();
            },
          );
        }),
      ),
    );
  }

  Widget _buildEnvironmentSection() {
    return _AddPlaceSection(
      title: AppStrings.get('add_place_environment_title'),
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
        labelBuilder: AppStrings.addPlaceOption,
      ),
    );
  }

  Widget _buildTransportSection() {
    return _AddPlaceSection(
      title: AppStrings.get('add_place_transport_title'),
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
                  label: Text(AppStrings.addPlaceOption(item)),
                  selected: roadAccess == item,
                  onSelected: (_) {
                    setState(() => roadAccess = item);
                    _saveDraft();
                  },
                ))
            .toList(),
      ),
    );
  }

  Widget _buildFacilitiesSection() {
    return _AddPlaceSection(
      title: AppStrings.get('add_place_facilities_title'),
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
        labelBuilder: AppStrings.addPlaceOption,
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, bool isDark) {
    final cat = selected != null && selected! < categories.length
        ? categories[selected!]
        : null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
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
              const Icon(Icons.fact_check_outlined,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Gönderim Özeti',
                style: AppTypography.headingOf(context)
                    .copyWith(fontSize: AppFontSizes.title),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _summaryRow(
            'Yer Adı',
            name.text.trim().isEmpty ? 'Henüz girilmedi' : name.text.trim(),
            context,
          ),
          const SizedBox(height: 6),
          _summaryRow(
            'Kategori',
            cat != null ? cat.$2 : 'Seçilmedi',
            context,
          ),
          const SizedBox(height: 6),
          _summaryRow(
            'Konum',
            selectedLocationLabel.isNotEmpty
                ? selectedLocationLabel
                : 'Haritadan seçilmedi',
            context,
          ),
          const SizedBox(height: 6),
          _summaryRow(
            'Fotoğraflar',
            selectedPhotos.isNotEmpty
                ? '${selectedPhotos.length} fotoğraf yüklendi'
                : 'Fotoğraf seçilmedi',
            context,
          ),
          const SizedBox(height: 6),
          _summaryRow(
            'İmkanlar',
            selectedFeatures.isNotEmpty
                ? '${selectedFeatures.length} olanak seçildi'
                : 'Belirtilmedi',
            context,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: AppTypography.metadataOf(context),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyOf(context).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: AppFontSizes.caption,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: Semantics(
          button: true,
          label: saving
              ? AppStrings.get('add_place_saving')
              : AppStrings.get('add_place_submit'),
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
            label: Text(saving
                ? AppStrings.get('add_place_saving')
                : AppStrings.get('add_place_submit')),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneLayout(BuildContext context, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
            children: [
              _buildHeader(context),
              const SizedBox(height: 14),
              _buildBanner(context, isDark),
              const SizedBox(height: 14),
              _buildTextFields(context),
              const SizedBox(height: 12),
              _AddPlaceActionCard(
                icon: Icons.location_on_rounded,
                iconColor: AppColors.categoryNature,
                title: AppStrings.get('add_place_location_title'),
                subtitle: selectedLocation == null
                    ? AppStrings.get('add_place_location_hint')
                    : selectedLocationLabel,
                error: locationError,
                onTap: _openLocationPicker,
              ),
              if (locationExpanded) ...[
                const SizedBox(height: 10),
                _inlineLocationPicker(),
              ],
              const SizedBox(height: 12),
              _AddPlaceActionCard(
                icon: Icons.add_photo_alternate_outlined,
                iconColor: AppColors.categoryWater,
                title: AppStrings.get('add_place_photo_title'),
                subtitle: selectedPhotos.isEmpty
                    ? AppStrings.get('add_place_photo_hint_max')
                    : '${selectedPhotos.length} ${AppStrings.get('add_place_photos_selected')}',
                onTap: pickPhotos,
              ),
              if (selectedPhotos.isNotEmpty) ...[
                const SizedBox(height: 10),
                _photoPreviewStrip(),
              ],
              const SizedBox(height: 12),
              _buildCategorySection(),
              const SizedBox(height: 12),
              _buildEnvironmentSection(),
              const SizedBox(height: 12),
              _buildTransportSection(),
              const SizedBox(height: 12),
              _buildFacilitiesSection(),
            ],
          ),
        ),
        _buildSubmitButton(context, isDark),
      ],
    );
  }

  Widget _buildPortraitTabletLayout(BuildContext context, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: context.centerContent(
            maxWidth: 720,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
              children: [
                _buildHeader(context),
                const SizedBox(height: 14),
                _buildBanner(context, isDark),
                const SizedBox(height: 14),
                _buildTextFields(context),
                const SizedBox(height: 12),
                _AddPlaceActionCard(
                  icon: Icons.location_on_rounded,
                  iconColor: AppColors.categoryNature,
                  title: AppStrings.get('add_place_location_title'),
                  subtitle: selectedLocation == null
                      ? AppStrings.get('add_place_location_hint')
                      : selectedLocationLabel,
                  error: locationError,
                  onTap: _openLocationPicker,
                ),
                if (locationExpanded) ...[
                  const SizedBox(height: 10),
                  _inlineLocationPicker(height: 380),
                ],
                const SizedBox(height: 12),
                _AddPlaceActionCard(
                  icon: Icons.add_photo_alternate_outlined,
                  iconColor: AppColors.categoryWater,
                  title: AppStrings.get('add_place_photo_title'),
                  subtitle: selectedPhotos.isEmpty
                      ? AppStrings.get('add_place_photo_hint_max')
                      : '${selectedPhotos.length} ${AppStrings.get('add_place_photos_selected')}',
                  onTap: pickPhotos,
                ),
                if (selectedPhotos.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _photoPreviewStrip(),
                ],
                const SizedBox(height: 12),
                _buildCategorySection(),
                const SizedBox(height: 12),
                _buildEnvironmentSection(),
                const SizedBox(height: 12),
                _buildTransportSection(),
                const SizedBox(height: 12),
                _buildFacilitiesSection(),
              ],
            ),
          ),
        ),
        context.centerContent(
          maxWidth: 720,
          child: _buildSubmitButton(context, isDark),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: context.centerContent(
        maxWidth: 1400,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 54,
              child: ListView(
                padding: const EdgeInsets.only(right: 16, bottom: 32),
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 14),
                  _buildBanner(context, isDark),
                  const SizedBox(height: 14),
                  _buildTextFields(context),
                  const SizedBox(height: 12),
                  _buildCategorySection(),
                  const SizedBox(height: 12),
                  _buildEnvironmentSection(),
                  const SizedBox(height: 12),
                  _buildTransportSection(),
                  const SizedBox(height: 12),
                  _buildFacilitiesSection(),
                ],
              ),
            ),
            const VerticalDivider(width: 24, thickness: 1),
            Expanded(
              flex: 46,
              child: ListView(
                padding: const EdgeInsets.only(left: 8, bottom: 32),
                children: [
                  Text(
                    AppStrings.get('add_place_location_title'),
                    style: AppTypography.headingOf(context)
                        .copyWith(fontSize: AppFontSizes.heading),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedLocation == null
                        ? AppStrings.get('add_place_location_hint')
                        : selectedLocationLabel,
                    style: AppTypography.metadataOf(context),
                  ),
                  const SizedBox(height: 8),
                  _inlineLocationPicker(height: 280),
                  const SizedBox(height: 16),
                  _AddPlaceActionCard(
                    icon: Icons.add_photo_alternate_outlined,
                    iconColor: AppColors.categoryWater,
                    title: AppStrings.get('add_place_photo_title'),
                    subtitle: selectedPhotos.isEmpty
                        ? AppStrings.get('add_place_photo_hint_max')
                        : '${selectedPhotos.length} ${AppStrings.get('add_place_photos_selected')}',
                    onTap: pickPhotos,
                  ),
                  if (selectedPhotos.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _photoPreviewStrip(),
                  ],
                  const SizedBox(height: 16),
                  _buildSummaryCard(context, isDark),
                  const SizedBox(height: 18),
                  SizedBox(
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
                      label: Text(saving
                          ? AppStrings.get('add_place_saving')
                          : AppStrings.get('add_place_submit')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Widget content;
    if (context.isTabletLandscape) {
      content = _buildLandscapeLayout(context, isDark);
    } else if (context.isTabletPortrait) {
      content = _buildPortraitTabletLayout(context, isDark);
    } else {
      content = _buildPhoneLayout(context, isDark);
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.surfaceMuted,
      body: SafeArea(child: content),
    );
  }

  Widget _inlineLocationPicker({double height = 360}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
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
              onMapReady: _handleMapReady,
              onTap: (_, point) {
                _selectLocation(point);
              },
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
            child: GlassContainer(
              borderRadius: BorderRadius.circular(AppRadii.medium),
              blur: 14,
              color: Colors.white.withValues(alpha: 0.80),
              borderColor: Colors.white.withValues(alpha: 0.90),
              borderWidth: 1.2,
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow08,
                  blurRadius: 12,
                  offset: Offset(0, 3),
                ),
              ],
              child: TextField(
                controller: locationSearch,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => searchLocation(),
                decoration: InputDecoration(
                  hintText: AppStrings.get('add_place_search_location_hint'),
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
            left: 10,
            top: 64,
            child: FilledButton.tonalIcon(
              key: const Key('add_place_enter_coordinates'),
              onPressed: _showCoordinateEntry,
              icon: const Icon(Icons.pin_drop_outlined, size: 18),
              label: Text(AppStrings.get('add_place_enter_coordinates')),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, AppControlSizes.minimumTouchTarget),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 20,
            child: GlassIconButton(
              icon: Icons.my_location_rounded,
              tooltip: AppStrings.get('add_place_use_current_location'),
              onTap: locating ? () {} : useCurrentLocation,
              size: 44,
              iconSize: 20,
              iconColor: green,
              blur: 14,
              color: Colors.white.withValues(alpha: 0.80),
              borderColor: Colors.white.withValues(alpha: 0.90),
              borderWidth: 1.2,
            ),
          ),
          Positioned(
            left: 8,
            bottom: 5,
            child: Semantics(
              link: true,
              label:
                  'OpenStreetMap katkıcıları. Kaynak ve lisans ayrıntılarını aç',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => unawaited(
                    launchUrl(
                      Uri.parse('https://www.openstreetmap.org/copyright'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.small),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    child: Text(
                      '© OpenStreetMap contributors',
                      style: TextStyle(fontSize: AppFontSizes.caption),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                          color: AppColors.surfaceMuted,
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
                          color: AppColors.surfaceMuted,
                          child:
                              Center(child: Icon(Icons.broken_image_outlined)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Semantics(
                  button: true,
                  label: 'Fotoğrafı kaldır',
                  child: InkWell(
                    onTap: () => setState(() => selectedPhotos.removeAt(index)),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.shadow80,
                        child: Icon(Icons.close_rounded,
                            color: Colors.white, size: 15),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _multiChoiceWrap(List<String> items, Set<String> selection,
          {String Function(String)? labelBuilder}) =>
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map(
          (item) {
            final isSelected = selection.contains(item);
            final text = labelBuilder != null ? labelBuilder(item) : item;
            return Semantics(
              button: true,
              selected: isSelected,
              label: text,
              child: FilterChip(
                label: Text(text),
                selected: isSelected,
                onSelected: (value) {
                  setState(() =>
                      value ? selection.add(item) : selection.remove(item));
                  _saveDraft();
                },
              ),
            );
          },
        ).toList(),
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: AppColors.shadow08,
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
                style: AppTypography.bodyOf(context).copyWith(
                    fontSize: AppFontSizes.title, fontWeight: FontWeight.w600)),
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(error!,
                  style: const TextStyle(
                      color: AppColors.error, fontSize: AppFontSizes.caption)),
            ],
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: '$title: ${error ?? subtitle}',
      child: Material(
        color: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: error == null
                  ? (isDark ? AppColors.darkBorder : AppColors.border)
                  : AppColors.error),
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
                          style: AppTypography.bodyOf(context).copyWith(
                              fontSize: AppFontSizes.body,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(error ?? subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.metadataOf(context).copyWith(
                              fontSize: AppFontSizes.caption,
                              color: error == null ? null : AppColors.error)),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DuplicatePlacePreview extends StatelessWidget {
  const _DuplicatePlacePreview({required this.match});

  final PlaceDuplicateMatch match;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.large),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkPrimarySoft : mint,
              borderRadius: BorderRadius.circular(AppRadii.large),
            ),
            child: Icon(
              match.place.icon,
              color: isDark ? AppColors.darkPrimaryLight : green,
              size: 20,
            ),
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
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: isDark ? AppColors.darkTextPrimary : ink,
                    fontSize: AppFontSizes.caption,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${match.place.kind} · ${(match.distanceKm * 1000).round()} m uzakta',
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
        ],
      ),
    );
  }
}
