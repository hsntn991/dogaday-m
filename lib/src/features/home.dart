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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AppControlSizes.minimumTouchTarget,
            minHeight: AppControlSizes.minimumTouchTarget,
          ),
          child: Center(
            child: Material(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.medium),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppRadii.medium),
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: Icon(
                    icon,
                    color: isDark ? AppColors.darkPrimaryLight : green,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _DailyNatureQuoteBoard extends StatelessWidget {
  const _DailyNatureQuoteBoard({required this.onMessages});

  final VoidCallback onMessages;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
                    color: isDark
                        ? AppColors.darkPrimarySoft
                        : AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    '“${dailyNatureQuote()}”',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      fontSize: AppFontSizes.body,
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
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                  boxShadow: const [
                    BoxShadow(color: AppColors.shadow08, blurRadius: 8),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Icon(Icons.notifications_none_rounded,
                          color: isDark ? AppColors.darkPrimaryLight : green,
                          size: 19),
                    ),
                    Positioned(
                      right: 7,
                      top: 7,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.rating,
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
}

final _homeCategories = placeTaxonomy;

class FigmaHomeScreen extends StatefulWidget {
  const FigmaHomeScreen({
    super.key,
    required this.onOpen,
    required this.onSearch,
    required this.onMessages,
    this.onExploreMap,
    this.onExploreProvince,
    this.onAddPlace,
    this.onRequestLocation,
  });
  final ValueChanged<Place> onOpen;
  final VoidCallback onSearch;
  final VoidCallback onMessages;
  final VoidCallback? onExploreMap;
  final ValueChanged<MapRegionFocus>? onExploreProvince;
  final VoidCallback? onAddPlace;
  final VoidCallback? onRequestLocation;

  @override
  State<FigmaHomeScreen> createState() => _FigmaHomeScreenState();
}

class _FigmaHomeScreenState extends State<FigmaHomeScreen> {
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    AppLocaleController.current.addListener(_onLocaleChanged);
    UserPlacesController.places.addListener(_refreshUserPlaces);
    SupabasePlacesController.places.addListener(_refreshUserPlaces);
    NearbyPlacesService.revision.addListener(_refreshNearbyPlaces);
    WeatherService.revision.addListener(_refreshRecommendations);
  }

  @override
  void dispose() {
    AppLocaleController.current.removeListener(_onLocaleChanged);
    UserPlacesController.places.removeListener(_refreshUserPlaces);
    SupabasePlacesController.places.removeListener(_refreshUserPlaces);
    NearbyPlacesService.revision.removeListener(_refreshNearbyPlaces);
    WeatherService.revision.removeListener(_refreshRecommendations);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
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

  Widget _buildSearchField() => Semantics(
        label: AppStrings.get('map_search_places'),
        button: true,
        child: GestureDetector(
          onTap: widget.onSearch,
          child: AbsorbPointer(
            child: GlassContainer(
              borderRadius: BorderRadius.circular(AppRadii.large),
              blur: 14,
              color: Colors.white.withValues(alpha: 0.70),
              borderColor: Colors.white.withValues(alpha: 0.90),
              borderWidth: 1.2,
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow08,
                  blurRadius: 14,
                  offset: Offset(0, 3),
                ),
              ],
              child: AppSearchField(onFilterTap: widget.onSearch),
            ),
          ),
        ),
      );

  Widget _buildCategoryStrip() => SizedBox(
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
                label: category.localizedLabel,
                icon: _categoryIcon(category.key),
                selected: selectedCategory == category.key,
                onSelected: (_) => selectCategory(category.key),
              );
            },
          ),
        ),
      );

  Widget _buildProvinceExplorerSection() {
    if (widget.onExploreProvince == null) return const SizedBox.shrink();
    return _ProvinceExplorerEntry(
      onOpenAll: () => _showProvinceExplorer(context),
      onSelect: _openProvinceOnMap,
    );
  }

  void _showProvinceExplorer(BuildContext context) {
    final onExplore = widget.onExploreProvince;
    if (onExplore == null) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ProvinceExplorerSheet(
        onSelect: (region) {
          Navigator.pop(sheetContext);
          _openProvinceOnMap(region);
        },
      ),
    );
  }

  void _openProvinceOnMap(MapRegionFocus region) {
    widget.onExploreProvince?.call(region);
  }

  Widget _buildPhoneLayout(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: HomeWeatherLocationController.isResolvingLocation,
            builder: (_, isResolvingLocation, __) =>
                ValueListenableBuilder<WeatherTarget>(
              valueListenable: HomeWeatherLocationController.current,
              builder: (_, target, __) => _HomePremiumHeader(
                target: target,
                isResolvingLocation: isResolvingLocation,
                onMessages: widget.onMessages,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSearchField(),
          const SizedBox(height: 16),
          _buildCategoryStrip(),
          const SizedBox(height: 20),
          _buildProvinceExplorerSection(),
          const SizedBox(height: 24),
          ValueListenableBuilder<WeatherTarget>(
            valueListenable: HomeWeatherLocationController.current,
            builder: (_, target, __) => _TodayRecommendationsSection(
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
              target: target,
              preferredCategory: selectedCategory,
              onOpen: widget.onOpen,
              onExploreMap: widget.onExploreMap,
              onRequestLocation: widget.onRequestLocation,
            ),
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<WeatherTarget>(
            valueListenable: HomeWeatherLocationController.current,
            builder: (_, target, __) => _CommunitySuggestionsSection(
              target: target,
              onOpen: widget.onOpen,
            ),
          ),
        ],
      );

  Widget _buildPortraitTabletLayout(
    BuildContext context,
    BoxConstraints constraints,
  ) =>
      ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: HomeWeatherLocationController.isResolvingLocation,
            builder: (_, isResolvingLocation, __) =>
                ValueListenableBuilder<WeatherTarget>(
              valueListenable: HomeWeatherLocationController.current,
              builder: (_, target, __) => _HomePremiumHeader(
                target: target,
                isResolvingLocation: isResolvingLocation,
                onMessages: widget.onMessages,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSearchField(),
          const SizedBox(height: 16),
          _buildCategoryStrip(),
          const SizedBox(height: 20),
          _buildProvinceExplorerSection(),
          const SizedBox(height: 24),
          ValueListenableBuilder<WeatherTarget>(
            valueListenable: HomeWeatherLocationController.current,
            builder: (_, target, __) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _TodayRecommendationsSection(
                    target: target,
                    preferredCategory: selectedCategory,
                    onOpen: widget.onOpen,
                    onExploreMap: widget.onExploreMap,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _NearbyPlacesSection(
                    target: target,
                    preferredCategory: selectedCategory,
                    onOpen: widget.onOpen,
                    onExploreMap: widget.onExploreMap,
                    onRequestLocation: widget.onRequestLocation,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<WeatherTarget>(
            valueListenable: HomeWeatherLocationController.current,
            builder: (_, target, __) => _CommunitySuggestionsSection(
              target: target,
              onOpen: widget.onOpen,
            ),
          ),
        ],
      );

  Widget _buildLandscapeLayout(
    BuildContext context,
    BoxConstraints constraints,
  ) =>
      ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: HomeWeatherLocationController.isResolvingLocation,
            builder: (_, isResolvingLocation, __) =>
                ValueListenableBuilder<WeatherTarget>(
              valueListenable: HomeWeatherLocationController.current,
              builder: (_, target, __) => _HomePremiumHeader(
                target: target,
                isResolvingLocation: isResolvingLocation,
                onMessages: widget.onMessages,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<WeatherTarget>(
            valueListenable: HomeWeatherLocationController.current,
            builder: (_, target, __) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sol %55: Arama, kategoriler, Bugün sana uygun ve topluluk önerileri
                Expanded(
                  flex: 55,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchField(),
                      const SizedBox(height: 16),
                      _buildCategoryStrip(),
                      const SizedBox(height: 20),
                      _buildProvinceExplorerSection(),
                      const SizedBox(height: 24),
                      _TodayRecommendationsSection(
                        target: target,
                        preferredCategory: selectedCategory,
                        onOpen: widget.onOpen,
                        onExploreMap: widget.onExploreMap,
                      ),
                      const SizedBox(height: 24),
                      _CommunitySuggestionsSection(
                        target: target,
                        onOpen: widget.onOpen,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Sağ %45: Yakın yerler
                Expanded(
                  flex: 45,
                  child: _NearbyPlacesSection(
                    target: target,
                    preferredCategory: selectedCategory,
                    onOpen: widget.onOpen,
                    onExploreMap: widget.onExploreMap,
                    onRequestLocation: widget.onRequestLocation,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscapeTablet =
                constraints.maxWidth >= AppBreakpoints.tabletLandscapeMin;
            final isPortraitTablet = !isLandscapeTablet &&
                constraints.maxWidth >= AppBreakpoints.tabletPortraitMin;

            if (isLandscapeTablet) {
              return _buildLandscapeLayout(context, constraints);
            }
            if (isPortraitTablet) {
              return _buildPortraitTabletLayout(context, constraints);
            }
            return _buildPhoneLayout(context);
          },
        ),
      );
}

IconData _categoryIcon(String category) => switch (category) {
      'camp' => Icons.cabin_rounded,
      'caravan' => Icons.rv_hookup_rounded,
      'lake' => Icons.water_rounded,
      'waterfall' => Icons.waterfall_chart_rounded,
      'canyon_valley' => Icons.terrain_rounded,
      'cave' => Icons.landscape_rounded,
      'national_park' => Icons.forest_rounded,
      _ => Icons.category_outlined,
    };

/// İller için önce o ile ait, bulunamazsa eldeki telifsiz/uygulama arşivinden
/// seçilmiş bir doğa görseli döner. Bu sayede 81 kartın hiçbirinde boş görsel
/// alanı oluşmaz; il bazlı fotoğraf arşivi genişledikçe bu liste güncellenir.
const _provincePhotoAssets = <String, String>{
  'Adana': 'assets/photos/ekotaban_optimized/012f751248c32853523e.jpg',
  'Afyonkarahisar': 'assets/photos/ekotaban_optimized/6163f613af33596c7c1a.jpg',
  'Ankara': 'assets/photos/ekotaban_optimized/bd65c7c5d50856793c17.jpg',
  'Artvin': 'assets/photos/ekotaban_optimized/7aa43047063126595c33.jpg',
  'Bursa': 'assets/photos/ekotaban_optimized/6bd6868d93af4cf609d5.jpg',
  'Burdur': 'assets/photos/ekotaban_optimized/2de1507c506dcbc463ec.jpg',
  'Denizli': 'assets/photos/ekotaban_optimized/191144a986a7537f8510.jpg',
  'Mersin': 'assets/photos/ekotaban_optimized/530c804189b8a718fda7.jpg',
};

const _provinceFallbackPhotos = <String>[
  'assets/photos/ekotaban_optimized/012f751248c32853523e.jpg',
  'assets/photos/ekotaban_optimized/6163f613af33596c7c1a.jpg',
  'assets/photos/ekotaban_optimized/bd65c7c5d50856793c17.jpg',
  'assets/photos/ekotaban_optimized/7aa43047063126595c33.jpg',
  'assets/photos/ekotaban_optimized/530c804189b8a718fda7.jpg',
  'assets/photos/ekotaban_optimized/6bd6868d93af4cf609d5.jpg',
  'assets/photos/ekotaban_optimized/2de1507c506dcbc463ec.jpg',
  'assets/photos/ekotaban_optimized/191144a986a7537f8510.jpg',
];

String _provincePhotoAsset(String province) {
  final knownPhoto = _provincePhotoAssets[province];
  if (knownPhoto != null) return knownPhoto;
  final stableIndex =
      province.runes.fold<int>(0, (total, rune) => total + rune) %
          _provinceFallbackPhotos.length;
  return _provinceFallbackPhotos[stableIndex];
}

class _ProvincePhotoCard extends StatelessWidget {
  const _ProvincePhotoCard({required this.province, this.compact = false});

  final String province;
  final bool compact;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.large),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _provincePhotoAsset(province),
              fit: BoxFit.cover,
              cacheWidth: compact ? 240 : 360,
              errorBuilder: (_, __, ___) => ColoredBox(
                color: AppColors.primarySoft,
                child: Icon(
                  Icons.landscape_rounded,
                  color: AppColors.primary,
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x08000000), Color(0xC6002315)],
                  stops: [.22, 1],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(compact ? 10 : 12),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  province,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    shadows: const [
                      Shadow(color: Color(0x99000000), blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _ProvinceExplorerEntry extends StatelessWidget {
  const _ProvinceExplorerEntry({
    required this.onOpenAll,
    required this.onSelect,
  });

  final VoidCallback onOpenAll;
  final ValueChanged<MapRegionFocus> onSelect;

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimaryOf(context);
    final provinces = _provinceCenters.entries.take(8).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'İllere göre keşfet',
                style: AppTypography.title.copyWith(color: textPrimary),
              ),
            ),
            TextButton.icon(
              onPressed: onOpenAll,
              icon: const Icon(Icons.grid_view_rounded, size: 18),
              label: const Text('Tüm iller'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: provinces.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) {
              final entry = provinces[index];
              return Semantics(
                button: true,
                label: '${entry.key} bölgesini haritada aç',
                child: InkWell(
                  onTap: () => onSelect(MapRegionFocus(
                    label: entry.key,
                    center: entry.value,
                  )),
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  child: Ink(
                    width: 106,
                    child: _ProvincePhotoCard(
                      province: entry.key,
                      compact: true,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProvinceExplorerSheet extends StatelessWidget {
  const _ProvinceExplorerSheet({required this.onSelect});

  final ValueChanged<MapRegionFocus> onSelect;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final entries = _provinceCenters.entries.toList(growable: false);
    return FractionallySizedBox(
      heightFactor: .88,
      child: Material(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.hero),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '81 ilde doğayı keşfet',
                  style: AppTypography.title.copyWith(color: textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bir il seç; harita yalnızca o bölgenin yerlerini açsın.',
                  style: AppTypography.body.copyWith(color: textSecondary),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: GridView.builder(
                    itemCount: entries.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.06,
                    ),
                    itemBuilder: (_, index) {
                      final entry = entries[index];
                      return Semantics(
                        button: true,
                        label: '${entry.key} bölgesini haritada aç',
                        child: InkWell(
                          onTap: () => onSelect(MapRegionFocus(
                            label: entry.key,
                            center: entry.value,
                          )),
                          borderRadius: BorderRadius.circular(AppRadii.large),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppRadii.large),
                            ),
                            child: _ProvincePhotoCard(province: entry.key),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomePremiumHeader extends StatelessWidget {
  const _HomePremiumHeader({
    required this.target,
    required this.isResolvingLocation,
    required this.onMessages,
  });

  final WeatherTarget target;
  final bool isResolvingLocation;
  final VoidCallback onMessages;

  void _showLocationSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => LocationUpdateSheet(target: target),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 370;
          return Row(
            children: [
              Semantics(
                image: true,
                label: 'Doğadayım',
                child: Container(
                  width: compact ? 112 : 154,
                  height: compact ? 38 : AppControlSizes.minimumTouchTarget,
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 8 : 10,
                    vertical: compact ? 7 : 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Image.asset(
                    'assets/branding/dogadayim_logo_full.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              SizedBox(width: compact ? 4 : 8),
              const Spacer(),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: compact ? 112 : 155),
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                  blur: 12,
                  color: Colors.white.withValues(alpha: 0.65),
                  borderColor: Colors.white.withValues(alpha: 0.90),
                  borderWidth: 1.2,
                  padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10),
                  height: compact ? 38 : AppControlSizes.minimumTouchTarget,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showLocationSheet(context),
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: AppColors.textPrimary,
                              size: AppIconSizes.small),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              isResolvingLocation
                                  ? AppStrings.get('home_locating')
                                  : (target.label ==
                                          HomeWeatherLocationController
                                              .unavailableLabel
                                      ? AppStrings.get(
                                          'home_location_permission_required')
                                      : (target.label.trim().toLowerCase() ==
                                                  'konumum' ||
                                              target.label
                                                      .trim()
                                                      .toLowerCase() ==
                                                  'bulunduğu alan'
                                          ? AppStrings.get('my_location')
                                          : target.label)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.label
                                  .copyWith(fontSize: AppFontSizes.label),
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
                  ),
                ),
              ),
              SizedBox(width: compact ? 4 : 6),
              GlassIconButton(
                icon: Icons.forum_outlined,
                onTap: onMessages,
                tooltip: AppStrings.get('profile_community_chat'),
                size: compact ? 38 : 42,
                iconSize: 20,
                blur: 12,
                color: Colors.white.withValues(alpha: 0.65),
                borderColor: Colors.white.withValues(alpha: 0.90),
              ),
            ],
          );
        },
      );
}

class LocationUpdateSheet extends StatefulWidget {
  const LocationUpdateSheet({super.key, required this.target});
  final WeatherTarget target;

  @override
  State<LocationUpdateSheet> createState() => _LocationUpdateSheetState();
}

class _LocationUpdateSheetState extends State<LocationUpdateSheet> {
  bool _isLoading = false;

  Future<void> _updateLocation() async {
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final coordinates =
          await HomeWeatherLocationController.requestAndUseDeviceLocation();
      if (!mounted) return;
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Konum güncellendi: ${coordinates.label}'),
              ),
            ],
          ),
          backgroundColor: green,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final target = widget.target;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.hero),
        ),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkPrimarySoft
                      : AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: isDark ? AppColors.darkPrimaryLight : green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Konum Bilgisi & Güncelleme',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: AppFontSizes.title,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 20),
                color: textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted,
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
                    Text(
                      'Mevcut Konum',
                      style: TextStyle(
                        fontSize: AppFontSizes.caption,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (target.usesCoordinates)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkPrimarySoft
                              : AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadii.small),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.gps_fixed_rounded,
                              size: 11,
                              color:
                                  isDark ? AppColors.darkPrimaryLight : green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'GPS Doğrulanmış',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark ? AppColors.darkPrimaryLight : green,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  target.label,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: AppFontSizes.title,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                if (target.usesCoordinates) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${target.latitude!.toStringAsFixed(4)}° K, ${target.longitude!.toStringAsFixed(4)}° D',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: AppFontSizes.caption,
                      color: textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkPrimarySoft.withValues(alpha: 0.15)
                  : sand.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadii.medium),
              border: Border.all(
                color:
                    isDark ? AppColors.darkPrimarySoft : AppColors.primarySoft,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 18,
                  color: isDark ? AppColors.darkPrimaryLight : green,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Doğa güvenliği, rota mesafeleri ve anlık hava durumunun doğruluğu için konum yalnızca cihazınızın gerçek GPS alıcısından alınır. Konuma dışarıdan elle veya yapay müdahale yapılamaz.',
                    style: TextStyle(
                      fontSize: AppFontSizes.caption,
                      height: 1.4,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _isLoading ? null : _updateLocation,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.my_location_rounded, size: 18),
            label: Text(
              _isLoading ? 'Konum Güncelleniyor...' : 'Konumu Güncelle',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: AppFontSizes.body,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimary : green,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.large),
              ),
            ),
          ),
        ],
      ),
    );
  }
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

class _TodayRecommendationsSection extends StatefulWidget {
  const _TodayRecommendationsSection({
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
  State<_TodayRecommendationsSection> createState() =>
      _TodayRecommendationsSectionState();
}

class _TodayRecommendationsSectionState
    extends State<_TodayRecommendationsSection> {
  List<PlaceRecommendation> _recommendations = const [];

  @override
  void initState() {
    super.initState();
    _recomputeRecommendations();
    AppLocaleController.current.addListener(_handleUpdate);
    UserPlacesController.places.addListener(_handleUpdate);
    SupabasePlacesController.places.addListener(_handleUpdate);
    NearbyPlacesService.revision.addListener(_handleUpdate);
    WeatherService.revision.addListener(_handleUpdate);
  }

  @override
  void didUpdateWidget(covariant _TodayRecommendationsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target ||
        oldWidget.preferredCategory != widget.preferredCategory) {
      _recomputeRecommendations();
    }
  }

  @override
  void dispose() {
    AppLocaleController.current.removeListener(_handleUpdate);
    UserPlacesController.places.removeListener(_handleUpdate);
    SupabasePlacesController.places.removeListener(_handleUpdate);
    NearbyPlacesService.revision.removeListener(_handleUpdate);
    WeatherService.revision.removeListener(_handleUpdate);
    super.dispose();
  }

  void _handleUpdate() {
    if (!mounted) return;
    setState(_recomputeRecommendations);
  }

  void _recomputeRecommendations() {
    final hasLocation = widget.target.usesCoordinates;
    final available = NearbyPlacesService.availableNow(widget.target);

    final candidates = <Place>[
      ...SupabasePlacesController.places.value,
      ...UserPlacesController.places.value,
      ...available,
    ].where(_isTodayTripCandidate);
    _recommendations = RecommendationService.rank(
      places: candidates,
      weather: WeatherService.availableNow(widget.target),
      hasUserLocation: hasLocation,
      preferredCategory: widget.preferredCategory,
    ).take(2).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = _recommendations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: AppStrings.get('home_for_you_today'),
          actionLabel: AppStrings.get('home_see_all'),
          onAction: widget.onExploreMap,
        ),
        const SizedBox(height: 16),
        if (recommendations.isEmpty)
          _EmptyPlacesCard(
            message: AppStrings.get('home_no_recommendations'),
            actionLabel: AppStrings.get('home_explore_map'),
            actionIcon: Icons.map_outlined,
            onAction: widget.onExploreMap ?? () {},
            onRefresh: () =>
                unawaited(NearbyPlacesService.refresh(widget.target)),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              if (recommendations.length == 2) {
                return SizedBox(
                  height: 228,
                  child: Row(
                    children: [
                      Expanded(
                        child: _RecommendationCard(
                          recommendation: recommendations[0],
                          showDistance: widget.target.usesCoordinates,
                          onTap: () => widget.onOpen(recommendations[0].place),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _RecommendationCard(
                          recommendation: recommendations[1],
                          showDistance: widget.target.usesCoordinates,
                          onTap: () => widget.onOpen(recommendations[1].place),
                        ),
                      ),
                    ],
                  ),
                );
              }
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
                        width: recommendations.length == 1
                            ? constraints.maxWidth
                            : cardWidth,
                        recommendation: recommendation,
                        showDistance: widget.target.usesCoordinates,
                        onTap: () => widget.onOpen(recommendation.place),
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
  return !place.isUtility &&
      !isNonNatureCandidateName(
        place.name,
        subtype: place.resolvedTaxonomy.subtype,
        mainCategory: place.resolvedTaxonomy.mainCategory,
      );
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.recommendation,
    required this.onTap,
    this.width,
    required this.showDistance,
  });

  final PlaceRecommendation recommendation;
  final VoidCallback onTap;
  final double? width;
  final bool showDistance;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: AppPlaceHeroCard(
          place: recommendation.place,
          onTap: onTap,
          showDistance: showDistance,
          decisionLabel: recommendation.suitabilityLabel,
          decisionReason: recommendation.primaryReason,
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
          _FigmaSectionTitle(AppStrings.get('home_community_recommendations')),
          const SizedBox(height: 9),
          FutureBuilder<List<RankedCommunitySuggestion>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _CompactSectionLoading();
              }

              if (snapshot.hasError || (snapshot.data?.isEmpty ?? true)) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Container(
                  height: 100,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.large),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  child: Text(
                    AppStrings.get('home_community_error'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      fontSize: AppFontSizes.caption,
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
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
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.large),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow08,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                '1',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontSize: AppFontSizes.caption,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor:
                        isDark ? AppColors.darkPrimaryLight : green,
                    inactiveTrackColor:
                        isDark ? AppColors.darkPrimarySoft : AppColors.border,
                    thumbColor: isDark ? AppColors.darkPrimaryLight : green,
                    overlayColor: (isDark ? AppColors.darkPrimaryLight : green)
                        .withValues(alpha: .12),
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
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontSize: AppFontSizes.caption,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 7),
              Container(
                width: 48,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkPrimarySoft : mint,
                  borderRadius: BorderRadius.circular(AppRadii.large),
                ),
                child: Text(
                  '${radiusKm.round()} km',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: isDark ? AppColors.darkPrimaryLight : green,
                    fontSize: AppFontSizes.caption,
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
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Container(
                height: 112,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Konuma göre kategori sonuçları alınamadı.',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          fontSize: AppFontSizes.caption,
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
}

class _NearbyPlacesSection extends StatefulWidget {
  const _NearbyPlacesSection({
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
    AppLocaleController.current.addListener(_onLocaleChanged);
    future = widget.target.usesCoordinates
        ? NearbyPlacesService.fetch(widget.target)
        : Future.value(const <Place>[]);
  }

  @override
  void dispose() {
    AppLocaleController.current.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant _NearbyPlacesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      future = widget.target.usesCoordinates
          ? NearbyPlacesService.fetch(widget.target)
          : Future.value(const <Place>[]);
    }
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
            title: AppStrings.get('home_nearby_places'),
            actionLabel: AppStrings.get('home_see_all'),
            onAction: widget.onExploreMap,
          ),
          const SizedBox(height: 12),
          if (!widget.target.usesCoordinates) ...[
            _LocationRequiredNearbyCard(
              onRequestLocation: widget.onRequestLocation ??
                  () => unawaited(HomeWeatherLocationController
                      .requestAndUseDeviceLocation()),
            ),
            // Konum yokken şehir bazlı Supabase önerileri
            Builder(builder: (context) {
              final places = SupabasePlacesController.places.value
                  .where((p) =>
                      !p.isUtility &&
                      !isNonNatureCandidateName(
                        p.name,
                        subtype: p.resolvedTaxonomy.subtype,
                        mainCategory: p.resolvedTaxonomy.mainCategory,
                      ))
                  .take(6)
                  .toList(growable: false);
              if (places.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  ...places.map(
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
            }),
          ] else
            FutureBuilder<List<Place>>(
              future: future,
              initialData: NearbyPlacesService.availableNow(widget.target),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const _CompactSectionLoading();
                }

                if (snapshot.hasError) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return Container(
                    height: 122,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.large),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_off_outlined,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            size: 25),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Yakındaki doğa noktaları şu anda alınamadı.',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              fontSize: AppFontSizes.caption,
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

                final recommendedIds = RecommendationService.rank(
                  places: <Place>[
                    ...SupabasePlacesController.places.value,
                    ...UserPlacesController.places.value,
                    ...NearbyPlacesService.availableNow(widget.target),
                  ].where(_isTodayTripCandidate),
                  weather: WeatherService.availableNow(widget.target),
                  hasUserLocation: widget.target.usesCoordinates,
                  preferredCategory: widget.preferredCategory,
                ).take(2).map((r) => r.place.sourceId ?? r.place.name).toSet();

                final distinctNearby = nearby.where((place) {
                  final id = place.sourceId ?? place.name;
                  return !recommendedIds.contains(id);
                }).toList(growable: false);

                final displayPlaces =
                    distinctNearby.isNotEmpty ? distinctNearby : nearby;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...displayPlaces.take(6).map(
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
          color: AppColors.surfaceMutedOf(context),
          borderRadius: BorderRadius.circular(AppRadii.medium),
          border: Border.all(color: AppColors.borderOf(context)),
        ),
        child: Row(
          children: [
            Icon(Icons.location_off_outlined,
                color: AppColors.textSecondaryOf(context),
                size: AppIconSizes.large),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Text(
                AppStrings.get('home_location_permission_needed'),
                style: AppTypography.metadataOf(context)
                    .copyWith(fontSize: AppFontSizes.label),
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            TextButton(
              onPressed: onRequestLocation,
              child: Text(AppStrings.get('home_open_location')),
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
          _FigmaSectionTitle(AppStrings.get('home_newly_added')),
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
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Container(
                  height: 86,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.large),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Güncel yer kayıtları alınamadı.',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            fontSize: AppFontSizes.caption,
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppStrings.get('home_newly_added_sub'),
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: AppColors.textTertiary,
                        fontSize: AppFontSizes.caption,
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : Colors.white.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(AppRadii.large),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted,
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
                    color:
                        isDark ? AppColors.darkPrimarySoft : AppColors.border,
                    borderRadius: BorderRadius.circular(AppRadii.large),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 88,
                  height: 7,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceMuted
                        : AppColors.surfaceMuted,
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.large),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Outfit',
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              fontSize: AppFontSizes.caption,
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
                  foregroundColor: isDark ? AppColors.darkPrimaryLight : green,
                  backgroundColor: isDark ? AppColors.darkPrimarySoft : mint,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: AppFontSizes.caption,
                    fontWeight: FontWeight.w700,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              TextButton(
                onPressed: onRefresh,
                style: TextButton.styleFrom(
                  foregroundColor: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  textStyle: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: AppFontSizes.caption,
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
            colors: [
              AppColors.weatherGradientStart,
              AppColors.weatherGradientEnd
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadii.large),
          boxShadow: const [
            BoxShadow(
              color: AppColors.weatherCardShadow,
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
                    fontSize: AppFontSizes.caption,
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
                      fontSize: AppFontSizes.caption,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: retry,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Yenile',
                      style: TextStyle(fontSize: AppFontSizes.caption)),
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
                    fontSize: AppFontSizes.caption,
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
                          fontSize: AppFontSizes.caption,
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
                                  ? AppColors.darkPrimaryLight
                                  : AppColors.rating,
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
                                fontSize: AppFontSizes.caption,
                                height: 1.15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _HomeWeatherMetric('💧', '${weather.humidity.round()}%',
                        AppStrings.get('weather_humidity')),
                    const SizedBox(width: 6),
                    _HomeWeatherMetric('〰', '${weather.windSpeed.round()}km/s',
                        AppStrings.get('weather_wind')),
                    const SizedBox(width: 6),
                    _HomeWeatherMetric('☀️', weather.uvIndex.round().toString(),
                        AppStrings.get('weather_uv')),
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
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('home_locating'),
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.white,
                    fontSize: AppFontSizes.label,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Hava durumu birazdan bulunduğun yere göre güncellenecek.',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.white70,
                    fontSize: AppFontSizes.caption,
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
                fontSize: AppFontSizes.caption,
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
                fontSize: AppFontSizes.caption,
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
        ? AppStrings.get('weather_ideal_outdoor')
        : AppStrings.get('weather_not_ideal_outdoor');

String _weatherUvValue(double value) {
  final level = value < 3
      ? AppStrings.get('weather_uv_low')
      : value < 6
          ? AppStrings.get('weather_uv_moderate')
          : value < 8
              ? AppStrings.get('weather_uv_high')
              : AppStrings.get('weather_uv_very_high');
  return '${value.round()} $level';
}

class _HomeAdBanner extends StatelessWidget {
  const _HomeAdBanner();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'Reklam alanı',
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(AppRadii.medium),
          border: Border.all(color: AppColors.borderOf(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkPrimarySoft : mint,
                borderRadius: BorderRadius.circular(AppRadii.small),
              ),
              child: Icon(
                Icons.campaign_outlined,
                color: isDark ? AppColors.darkPrimaryLight : green,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SPONSORLU',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: isDark
                          ? AppColors.darkPrimaryLight
                          : AppColors.textSecondary,
                      fontSize: AppFontSizes.caption,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Reklam alanı',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: AppColors.textPrimaryOf(context),
                      fontSize: AppFontSizes.label,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceMutedOf(context),
                borderRadius: BorderRadius.circular(AppRadii.small),
              ),
              child: Text(
                'Reklam',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontSize: AppFontSizes.caption,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
                    fontSize: AppFontSizes.heading,
                    height: 1.12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -.2,
                    color: ink))),
        if (action != null)
          Text(action!,
              style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: AppFontSizes.caption,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary))
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
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
                color: selected
                    ? (isDark ? AppColors.darkPrimarySoft : green)
                    : (isDark ? AppColors.darkSurfaceMuted : background),
                borderRadius: BorderRadius.circular(AppRadii.medium),
                border: Border.all(
                  color: selected
                      ? (isDark ? AppColors.darkPrimaryLight : green)
                      : (isDark
                          ? AppColors.darkBorder
                          : color.withValues(alpha: .08)),
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
                fontSize: AppFontSizes.caption,
                height: 1.05,
                color: selected
                    ? (isDark ? AppColors.darkPrimaryLight : green)
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ]),
        ),
      ),
    );
  }
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
              color: AppColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(AppRadii.large),
              border: Border.all(color: AppColors.borderOf(context))),
          child: Stack(fit: StackFit.expand, children: [
            NatureArt(
              place: place,
              radius: 0,
              showKind: false,
              cacheWidth: 700,
            ),
            const DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.shadow80]))),
            Positioned(
                left: 14,
                top: 12,
                child: Row(children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                          color: AppColors.accentOrange,
                          borderRadius: BorderRadius.circular(AppRadii.large)),
                      child: const Text('ÖNE ÇIKAN',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: AppFontSizes.caption,
                              fontWeight: FontWeight.w700))),
                  const SizedBox(width: 6),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.80),
                          borderRadius: BorderRadius.circular(AppRadii.large)),
                      child: Text(place.kind.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: AppFontSizes.caption,
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
                              fontSize: AppFontSizes.heading,
                              height: 1.08,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -.25)),
                      Text(place.location,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: AppFontSizes.caption)),
                      const SizedBox(height: 7),
                      Row(children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.rating, size: 13),
                        Text(' ${place.rating}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: AppFontSizes.caption,
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: AppColors.surfaceOf(context),
            borderRadius: BorderRadius.circular(AppRadii.medium),
            border: Border.all(color: AppColors.borderOf(context))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Stack(fit: StackFit.expand, children: [
              NatureArt(
                place: place,
                radius: 0,
                showKind: !kindBelow,
                cacheWidth: 360,
              ),
              if (kindBelow)
                Positioned(
                    left: 9,
                    bottom: 8,
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkPrimarySoft
                                : AppColors.surfaceMuted,
                            borderRadius:
                                BorderRadius.circular(AppRadii.small)),
                        child: Text(place.kind,
                            style: TextStyle(
                                color:
                                    isDark ? AppColors.darkPrimaryLight : green,
                                fontSize: AppFontSizes.caption,
                                fontWeight: FontWeight.w600)))),
              if (kindBelow)
                const Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                        radius: 13,
                        backgroundColor: AppColors.shadow80,
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
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          color: AppColors.textPrimaryOf(context),
                          fontSize: AppFontSizes.label,
                          height: 1.1,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Expanded(
                      child: Text(
                        place.location,
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
                    ),
                    const SizedBox(width: 6),
                    if (place.distanceKm != null) ...[
                      Icon(Icons.near_me_rounded,
                          size: 12,
                          color: isDark ? AppColors.darkPrimaryLight : green),
                      const SizedBox(width: 3),
                      Text(
                        '${place.distanceKm!.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          color: isDark ? AppColors.darkPrimaryLight : green,
                          fontSize: AppFontSizes.caption,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.star_rounded,
                          size: 13, color: AppColors.rating),
                      Text('${place.rating}',
                          style: TextStyle(
                              fontFamily: 'Outfit',
                              color: AppColors.textPrimaryOf(context),
                              fontSize: AppFontSizes.caption,
                              fontWeight: FontWeight.w600)),
                    ],
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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

  IconData get categoryIcon {
    if (suggestion.place.kind.contains('Göl')) return Icons.water_rounded;
    if (suggestion.place.kind.contains('Yürüyüş')) return Icons.hiking_rounded;
    if (suggestion.place.kind.contains('Kamp')) return Icons.cabin_rounded;
    return Icons.park_rounded;
  }

  Color get categoryColor {
    if (suggestion.place.kind.contains('Göl')) return AppColors.categoryWater;
    if (suggestion.place.kind.contains('Yürüyüş')) {
      return AppColors.categoryRoute;
    }
    if (suggestion.place.kind.contains('Kamp')) {
      return AppColors.categoryCamp;
    }
    return green;
  }

  Color get categoryBackground {
    if (suggestion.place.kind.contains('Göl')) {
      return AppColors.categoryWater.withValues(alpha: 0.12);
    }
    if (suggestion.place.kind.contains('Yürüyüş')) {
      return AppColors.categoryRoute.withValues(alpha: 0.12);
    }
    if (suggestion.place.kind.contains('Kamp')) {
      return AppColors.categoryCamp.withValues(alpha: 0.12);
    }
    return mint;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.large),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow08,
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
                    cacheWidth: 360,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.shadow80],
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
                        color: AppColors.shadow80,
                        borderRadius: BorderRadius.circular(AppRadii.large),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_rounded,
                              size: 13, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${suggestion.recommendationCount} kişi önerdi',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: Colors.white,
                              fontSize: AppFontSizes.caption,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
                        fontSize: AppFontSizes.title,
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
                        color: AppColors.darkTextPrimary,
                        fontSize: AppFontSizes.caption,
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
                          color: isDark
                              ? AppColors.darkPrimarySoft
                              : categoryBackground,
                          borderRadius: BorderRadius.circular(AppRadii.large),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(categoryIcon, size: 14, color: categoryColor),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                suggestion.place.kind,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  color: categoryColor,
                                  fontSize: AppFontSizes.caption,
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
                        color: AppColors.rating, size: 14),
                    Text(
                      ' ${suggestion.place.rating}',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: isDark ? AppColors.darkTextPrimary : ink,
                        fontSize: AppFontSizes.caption,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      ' (0)',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textTertiary,
                        fontSize: AppFontSizes.caption,
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
}

class _CommunityAvatars extends StatelessWidget {
  const _CommunityAvatars();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 52,
        height: 22,
        child: Stack(
          children: const [
            _CommunityAvatar(
                left: 0, letter: 'A', color: AppColors.categoryNature),
            _CommunityAvatar(
                left: 14, letter: 'B', color: AppColors.categoryCamp),
            _CommunityAvatar(
                left: 28, letter: 'C', color: AppColors.categoryWater),
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
              fontSize: AppFontSizes.caption,
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

  IconData get categoryIcon {
    if (place.kind.contains('Su Kaynağı')) return Icons.water_drop_rounded;
    if (place.kind.contains('Doğal Kaynak') || place.kind.contains('Şelale')) {
      return Icons.water_rounded;
    }
    if (place.kind.contains('Göl')) return Icons.water_rounded;
    if (place.kind.contains('Kamp')) return Icons.cabin_rounded;
    if (place.kind.contains('Piknik')) return Icons.deck_rounded;
    if (place.kind.contains('Yürüyüş')) return Icons.hiking_rounded;
    if (place.kind.contains('Seyir')) return Icons.explore_rounded;
    if (place.kind.contains('Mağara')) return Icons.landscape_rounded;
    if (place.kind.contains('Karavan')) return Icons.rv_hookup_rounded;
    if (place.kind.contains('Milli Park')) return Icons.forest_rounded;
    return Icons.park_rounded;
  }

  Color get categoryColor {
    if (place.kind.contains('Göl') || place.kind.contains('Kaynak')) {
      return AppColors.categoryWater;
    }
    if (place.kind.contains('Kamp')) return AppColors.categoryCamp;
    if (place.kind.contains('Mağara')) return AppColors.categoryFormation;
    if (place.kind.contains('Karavan')) return AppColors.categoryRoute;
    return AppColors.categoryNature;
  }

  String get distance {
    if (place.distanceKm != null) {
      return '${place.distanceKm!.toStringAsFixed(1)} km';
    }
    return AppStrings.get('card_distance');
  }

  String get updatedLabel {
    final date = place.updatedAt;
    if (date == null) return 'OSM';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
          height: 82,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.large),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
              boxShadow: const [
                BoxShadow(
                    color: AppColors.shadow08,
                    blurRadius: 10,
                    offset: Offset(0, 3))
              ]),
          child: Row(children: [
            SizedBox(
                width: 62,
                child: NatureArt(
                  place: place,
                  radius: 13,
                  showKind: false,
                  cacheWidth: 180,
                )),
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
                            style: TextStyle(
                                fontFamily: 'Outfit',
                                color: AppColors.textPrimaryOf(context),
                                fontSize: AppFontSizes.label,
                                height: 1.1,
                                fontWeight: FontWeight.w600))),
                    const SizedBox(width: 6),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                            color: isDark ? AppColors.darkPrimarySoft : mint,
                            borderRadius:
                                BorderRadius.circular(AppRadii.medium)),
                        child: Text(AppStrings.get('home_new_badge'),
                            style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: AppFontSizes.caption,
                                color:
                                    isDark ? AppColors.darkPrimaryLight : green,
                                fontWeight: FontWeight.w700)))
                  ]),
                  const SizedBox(height: 7),
                  Row(children: [
                    Icon(categoryIcon, size: 14, color: categoryColor),
                    const SizedBox(width: 3),
                    Flexible(
                        child: Text(place.kind,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: AppFontSizes.caption,
                                height: 1,
                                color: categoryColor,
                                fontWeight: FontWeight.w600))),
                    Text('  ·  ',
                        style: TextStyle(
                            fontSize: AppFontSizes.caption,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.textTertiary)),
                    Flexible(
                        child: Text(place.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: AppFontSizes.caption,
                                height: 1,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textTertiary)))
                  ])
                ])),
            const SizedBox(width: 8),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (place.sourceId != null)
                Row(children: [
                  Icon(Icons.update_rounded,
                      color: isDark ? AppColors.darkPrimaryLight : green,
                      size: 13),
                  const SizedBox(width: 3),
                  Text(updatedLabel,
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          color: isDark ? AppColors.darkPrimaryLight : green,
                          fontSize: AppFontSizes.caption,
                          fontWeight: FontWeight.w600)),
                ])
              else
                Row(children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.rating, size: 15),
                  Text(' ${place.rating}',
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          color: AppColors.textPrimaryOf(context),
                          fontSize: AppFontSizes.caption,
                          fontWeight: FontWeight.w700)),
                  Text(' (0)',
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: AppFontSizes.caption,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textTertiary))
                ]),
              const SizedBox(height: 8),
              Text(distance,
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: AppFontSizes.caption,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textTertiary))
            ]),
            const SizedBox(width: 4)
          ])),
    );
  }
}
