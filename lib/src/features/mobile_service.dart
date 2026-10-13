part of '../../main.dart';

class MobileServiceCategoryItem {
  const MobileServiceCategoryItem({
    required this.key,
    required this.title,
    required this.icon,
  });

  final String key;
  final String title;
  final IconData icon;
}

const mobileServiceCategories = <MobileServiceCategoryItem>[
  MobileServiceCategoryItem(
    key: 'service_roadside',
    title: 'Çekici / Yol Yardım',
    icon: Icons.local_shipping_rounded,
  ),
  MobileServiceCategoryItem(
    key: 'service_maintenance',
    title: 'Yıllık Bakım',
    icon: Icons.airport_shuttle_rounded,
  ),
  MobileServiceCategoryItem(
    key: 'service_gas',
    title: 'Gaz Tesisatı',
    icon: Icons.local_fire_department_rounded,
  ),
  MobileServiceCategoryItem(
    key: 'service_hvac',
    title: 'Isıtma & Soğutma',
    icon: Icons.device_thermostat_rounded,
  ),
  MobileServiceCategoryItem(
    key: 'service_electric',
    title: 'Elektrik & Enerji',
    icon: Icons.bolt_rounded,
  ),
  MobileServiceCategoryItem(
    key: 'service_plumbing',
    title: 'Su & Tesisat',
    icon: Icons.shower_rounded,
  ),
  MobileServiceCategoryItem(
    key: 'service_bodywork',
    title: 'Nem & Gövde',
    icon: Icons.water_drop_rounded,
  ),
  MobileServiceCategoryItem(
    key: 'service_chassis_brakes',
    title: 'Şasi & Fren',
    icon: Icons.tire_repair_rounded,
  ),
  MobileServiceCategoryItem(
    key: 'service_parts',
    title: 'Montaj & Parça',
    icon: Icons.settings_rounded,
  ),
  MobileServiceCategoryItem(
    key: 'service_inspection',
    title: 'Muayene',
    icon: Icons.fact_check_rounded,
  ),
];

/// Kullanıcının talep ettiği hizmeti seçtiği ve servis firması ekleyebildiği ana merkez ekranı.
class MobileServiceHubScreen extends StatelessWidget {
  const MobileServiceHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mobil Servis',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hangi hizmete ihtiyacın var?',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Talep ettiğin hizmeti seç, sana en uygun firmaları haritada ve listede gösterelim.',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  height: 1.4,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              // 3 Kolonlu Izgara Düzeni
              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 12.0;
                  final itemWidth = (constraints.maxWidth - (spacing * 2)) / 3;
                  // Özgün kart dili korunur; adlar ve firma çağrısı bütün
                  // telefon genişliklerinde taşmadan okunur.
                  const itemHeight = 138.0;

                  return Column(
                    children: [
                      // Sıra 1: 0, 1, 2
                      Row(
                        children: [
                          _buildServiceTile(context, mobileServiceCategories[0],
                              itemWidth, itemHeight, isDark),
                          const SizedBox(width: spacing),
                          _buildServiceTile(context, mobileServiceCategories[1],
                              itemWidth, itemHeight, isDark),
                          const SizedBox(width: spacing),
                          _buildServiceTile(context, mobileServiceCategories[2],
                              itemWidth, itemHeight, isDark),
                        ],
                      ),
                      const SizedBox(height: spacing),
                      // Sıra 2: 3, 4, 5
                      Row(
                        children: [
                          _buildServiceTile(context, mobileServiceCategories[3],
                              itemWidth, itemHeight, isDark),
                          const SizedBox(width: spacing),
                          _buildServiceTile(context, mobileServiceCategories[4],
                              itemWidth, itemHeight, isDark),
                          const SizedBox(width: spacing),
                          _buildServiceTile(context, mobileServiceCategories[5],
                              itemWidth, itemHeight, isDark),
                        ],
                      ),
                      const SizedBox(height: spacing),
                      // Sıra 3: 6, 7, 8
                      Row(
                        children: [
                          _buildServiceTile(context, mobileServiceCategories[6],
                              itemWidth, itemHeight, isDark),
                          const SizedBox(width: spacing),
                          _buildServiceTile(context, mobileServiceCategories[7],
                              itemWidth, itemHeight, isDark),
                          const SizedBox(width: spacing),
                          _buildServiceTile(context, mobileServiceCategories[8],
                              itemWidth, itemHeight, isDark),
                        ],
                      ),
                      const SizedBox(height: spacing),
                      // Sıra 4: 9 (Muayene) + 2 Kolonluk "Servis veren firma mısınız?" kartı
                      Row(
                        children: [
                          _buildServiceTile(context, mobileServiceCategories[9],
                              itemWidth, itemHeight, isDark),
                          const SizedBox(width: spacing),
                          Expanded(
                            child: _buildFirmRegistrationCard(
                                context, itemHeight, isDark),
                          ),
                        ],
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

  Widget _buildServiceTile(
    BuildContext context,
    MobileServiceCategoryItem item,
    double width,
    double height,
    bool isDark,
  ) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: isDark ? AppColors.darkSurfaceMuted : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: () {
            // Seçilen hizmet anahtarını döndürerek haritada filtreleme yapar
            Navigator.pop(context, item.key);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  size: 28,
                  color:
                      isDark ? AppColors.darkPrimaryLight : AppColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFirmRegistrationCard(
      BuildContext context, double height, bool isDark) {
    return SizedBox(
      height: height,
      child: Material(
        color: isDark ? AppColors.darkSurfaceMuted : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () async {
            final authOk = await AppAuthGuard.requireAuth(
              context,
              message:
                  'Servis veren firma eklemek için giriş yapmanız gerekiyor.',
            );
            if (!authOk || !context.mounted) return;

            final result = await showModalBottomSheet<Place?>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const _AddServiceFirmSheet(),
            );

            if (result != null && context.mounted) {
              Navigator.pop(context,
                  result.resolvedTaxonomy.subtype ?? 'service_roadside');
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? const Color(0xFF064E3B).withValues(alpha: 0.20)
                  : const Color(0xFFF0FDF4),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.65),
                width: 1.4,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF059669).withValues(alpha: 0.35)
                        : const Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Color(0xFF059669),
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
                        'Servis veren firma mısınız?',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Firmanızı ekleyin, inceleyip listeleyelim',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 11,
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
          ),
        ),
      ),
    );
  }
}

/// Servis Veren Firma Ekleme Alt Formu
class _AddServiceFirmSheet extends StatefulWidget {
  const _AddServiceFirmSheet();

  @override
  State<_AddServiceFirmSheet> createState() => _AddServiceFirmSheetState();
}

class _AddServiceFirmSheetState extends State<_AddServiceFirmSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hoursController = TextEditingController(text: '7/24 Açık');
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedSubtype = 'service_roadside';
  bool _saving = false;
  double? _latitude;
  double? _longitude;
  XFile? _selectedPhoto;

  @override
  void initState() {
    super.initState();
    _fillCurrentLocation();
  }

  Future<void> _fillCurrentLocation() async {
    final currentLoc = HomeWeatherLocationController.current.value;
    if (currentLoc.usesCoordinates) {
      _latitude = currentLoc.latitude;
      _longitude = currentLoc.longitude;
      _cityController.text = currentLoc.label;
    } else {
      _cityController.text = 'Antalya, Merkez';
      _latitude = 36.8969;
      _longitude = 30.7133;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _hoursController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final source = await showPhotoSourceSheet(
      context,
      title: 'İşletme fotoğrafı ekle',
    );
    if (source == null || !mounted) return;
    try {
      final photo = await ImagePicker().pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1920,
        maxHeight: 1920,
        requestFullMetadata: false,
      );
      if (!mounted || photo == null) return;
      setState(() => _selectedPhoto = photo);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf seçilemedi: $error')),
      );
    }
  }

  Future<void> _saveFirm() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final location = _cityController.text.trim();
    final hours = _hoursController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen firma adını girin.')),
      );
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen iletişim telefonunu girin.')),
      );
      return;
    }

    setState(() => _saving = true);

    final subtypeDef = mobileServiceCategories.firstWhere(
      (cat) => cat.key == _selectedSubtype,
      orElse: () => mobileServiceCategories.first,
    );

    final features = <String>[
      'Telefon: $phone',
      if (hours.isNotEmpty) 'Çalışma: $hours',
      'Hizmet: ${subtypeDef.title}',
    ];

    final authorName = () {
      try {
        final u = Supabase.instance.client.auth.currentUser;
        final md = u?.userMetadata;
        final fullName = (md?['full_name']?.toString() ??
                md?['name']?.toString() ??
                md?['display_name']?.toString() ??
                '')
            .trim();
        return fullName.isNotEmpty
            ? fullName
            : (u?.email?.split('@').first ?? '');
      } catch (_) {
        return null;
      }
    }();

    final sourceId = 'user-${DateTime.now().microsecondsSinceEpoch}';
    String? persistentImage;
    if (_selectedPhoto != null) {
      try {
        persistentImage = await PlacePhotoStorage.persistPrimaryPhoto(
          _selectedPhoto!,
          sourceId,
        );
      } catch (error) {
        if (mounted) {
          setState(() => _saving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fotoğraf hazırlanamadı: $error')),
          );
        }
        return;
      }
    }

    final newPlace = Place(
      name,
      location.isEmpty ? 'Türkiye' : location,
      subtypeDef.title,
      5.0,
      subtypeDef.icon,
      AppColors.defaultGradient,
      persistentImage,
      description: description.isEmpty
          ? '${subtypeDef.title} hizmeti sunulmaktadır. İletişim: $phone'
          : description,
      latitude: _latitude ?? 36.8969,
      longitude: _longitude ?? 30.7133,
      source: PlaceSource.user,
      verificationStatus: VerificationStatus.unverified,
      mainCategory: 'local_service',
      subtype: _selectedSubtype,
      features: features,
      sourceId: sourceId,
      contributorName: authorName,
      updatedAt: DateTime.now(),
    );

    await UserPlacesController.add(newPlace);
    final syncResult = await PlaceSubmissionController.enqueueAndSync(newPlace);
    if (syncResult == SubmissionSyncResult.sent) {
      await SubmissionFeedbackController.load();
    }

    if (!mounted) return;
    setState(() => _saving = false);

    final statusMessage = switch (syncResult) {
      SubmissionSyncResult.sent =>
        'İşletme başvurunuz yönetici onayına iletildi. Onaylandıktan sonra haritada yayınlanacaktır.',
      SubmissionSyncResult.signInRequired =>
        'Giriş yapılmadığı için işletme yerel olarak kaydedildi. Giriş yaptığınızda onaya gönderilecektir.',
      SubmissionSyncResult.queued =>
        'İnternet bağlantısı sağlandığında işletme başvurunuz yönetici onayına iletilecektir.',
      SubmissionSyncResult.failed =>
        'İşletme henüz yöneticiye gönderilemedi. Bağlantı veya sunucu sorunu giderildiğinde otomatik olarak tekrar denenecek.',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text(statusMessage),
      ),
    );

    Navigator.pop(context, newPlace);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.handyman_rounded,
                    color: Color(0xFFD97706),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Servis Veren Firma Ekle',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Doğadayım haritasında hizmet sağlayıcı olarak yer alın',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),
            // Firma Adı
            Text(
              'Firma / İşletme Adı *',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Örn: Toros Karavan & Yol Yardım',
                prefixIcon: const Icon(Icons.storefront_rounded, size: 20),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),
            // Hizmet Kategorisi
            Text(
              'Hizmet Alanı *',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: mobileServiceCategories.map((item) {
                final isSelected = _selectedSubtype == item.key;
                return ChoiceChip(
                  label: Text(item.title),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFEF3C7),
                  backgroundColor: isDark
                      ? AppColors.darkSurfaceMuted
                      : AppColors.surfaceMuted,
                  labelStyle: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFFB45309)
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary),
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedSubtype = item.key);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            // Telefon Numarası
            Text(
              'İletişim / Telefon Numarası *',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Örn: 0532 123 45 67',
                prefixIcon: const Icon(Icons.phone_in_talk_rounded, size: 20),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),
            // Çalışma Saatleri
            Text(
              'Çalışma Saatleri',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildQuickChip('7/24 Açık'),
                const SizedBox(width: 8),
                _buildQuickChip('08:30 - 19:00'),
                const SizedBox(width: 8),
                _buildQuickChip('09:00 - 18:00'),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _hoursController,
              decoration: InputDecoration(
                hintText: 'Örn: 7/24 Açık veya 08:30 - 19:00',
                prefixIcon: const Icon(Icons.schedule_rounded, size: 20),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),
            // Konum / Şehir
            Text(
              'Şehir / İlçe ve Konum',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: 'Örn: Antalya, Konyaaltı',
                prefixIcon: const Icon(Icons.location_on_rounded, size: 20),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),
            // Açıklama
            Text(
              'Verilen Hizmetler / Detaylar',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Yol yardım, akü takviyesi, lastik tamiri ve acil müdahale ekibimiz mevcuttur...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'İşletme Fotoğrafı',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: _saving ? null : _pickPhoto,
              icon: Icon(
                _selectedPhoto == null
                    ? Icons.add_photo_alternate_outlined
                    : Icons.check_circle_outline_rounded,
              ),
              label: Text(
                _selectedPhoto == null
                    ? 'Fotoğraf seç (isteğe bağlı)'
                    : 'Fotoğraf seçildi · Değiştir',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fotoğraf, başvurunuzla birlikte yalnızca yönetici incelemesine gönderilir.',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _saveFirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Başvuruyu incelemeye gönder',
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label) {
    return InkWell(
      onTap: () => setState(() => _hoursController.text = label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Başlangıçta kullanıcının Türkiye genelinde görebileceği örnek doğrulanmış mobil servis noktaları.
class SampleMobileServices {
  SampleMobileServices._();

  static List<Place> get samples => const <Place>[
        Place(
          'Akdeniz Karavan & 7/24 Yol Yardım',
          'Antalya, Konyaaltı',
          'Çekici / Yol Yardım',
          4.9,
          Icons.local_shipping_rounded,
          AppColors.defaultGradient,
          null,
          description:
              'Antalya, Kemer ve Kaş hattında karavan, çekici, akü takviye ve 7/24 oto kurtarma desteği.',
          latitude: 36.8841,
          longitude: 30.6480,
          source: PlaceSource.curated,
          verificationStatus: VerificationStatus.verified,
          mainCategory: 'local_service',
          subtype: 'service_roadside',
          features: [
            'Telefon: 0532 400 12 34',
            'Çalışma: 7/24 Açık',
            'Hizmet: Çekici / Yol Yardım'
          ],
        ),
        Place(
          'Toroslar Karavan Bakım & Gaz Tesisatı',
          'Muğla, Fethiye',
          'Gaz Tesisatı',
          4.8,
          Icons.local_fire_department_rounded,
          AppColors.defaultGradient,
          null,
          description:
              'Karavan Truma gaz tesisatı, lpg montajı, kaçak testi ve periyodik sızdırmazlık bakımı.',
          latitude: 36.6217,
          longitude: 29.1164,
          source: PlaceSource.curated,
          verificationStatus: VerificationStatus.verified,
          mainCategory: 'local_service',
          subtype: 'service_gas',
          features: [
            'Telefon: 0542 321 98 76',
            'Çalışma: 08:30 - 19:00',
            'Hizmet: Gaz Tesisatı'
          ],
        ),
        Place(
          'Bolu Dağı Karavan Isıtma & Webasto Servisi',
          'Bolu, Merkez',
          'Isıtma & Soğutma',
          4.9,
          Icons.device_thermostat_rounded,
          AppColors.defaultGradient,
          null,
          description:
              'Webasto, Eberspächer dizel ısıtıcı montajı, klima ve kışlık ısıtma sistemleri teknik servisi.',
          latitude: 40.7358,
          longitude: 31.6061,
          source: PlaceSource.curated,
          verificationStatus: VerificationStatus.verified,
          mainCategory: 'local_service',
          subtype: 'service_hvac',
          features: [
            'Telefon: 0555 789 45 12',
            'Çalışma: 7/24 Açık',
            'Hizmet: Isıtma & Soğutma'
          ],
        ),
        Place(
          'Ege Solar & Mobil Enerji Çözümleri',
          'İzmir, Urla',
          'Elektrik & Enerji',
          4.9,
          Icons.bolt_rounded,
          AppColors.defaultGradient,
          null,
          description:
              'Lityum akü, güneş paneli, mppt şarj kontrol ve karavan 12V/220V inverter tesisat servisi.',
          latitude: 38.3224,
          longitude: 26.7640,
          source: PlaceSource.curated,
          verificationStatus: VerificationStatus.verified,
          mainCategory: 'local_service',
          subtype: 'service_electric',
          features: [
            'Telefon: 0533 654 32 10',
            'Çalışma: 09:00 - 18:30',
            'Hizmet: Elektrik & Enerji'
          ],
        ),
        Place(
          'Kapadokya Karavan Su & Hidrofor Servisi',
          'Nevşehir, Ürgüp',
          'Su & Tesisat',
          4.7,
          Icons.shower_rounded,
          AppColors.defaultGradient,
          null,
          description:
              'Temiz su deposu, hidrofor motoru, atık su tesisatı ve kışlık donma koruma bakımı.',
          latitude: 38.6300,
          longitude: 34.9100,
          source: PlaceSource.curated,
          verificationStatus: VerificationStatus.verified,
          mainCategory: 'local_service',
          subtype: 'service_plumbing',
          features: [
            'Telefon: 0544 987 65 43',
            'Çalışma: 08:00 - 20:00',
            'Hizmet: Su & Tesisat'
          ],
        ),
        Place(
          'Başkent Karavan Şasi, Fren & Lastik Merkezi',
          'Ankara, Şaşmaz',
          'Şasi & Fren',
          4.8,
          Icons.tire_repair_rounded,
          AppColors.defaultGradient,
          null,
          description:
              'Al-Ko ve Knott torsiyon dingil, fren teli ayarı, kaplin kontrolü ve arazi lastik montajı.',
          latitude: 39.9485,
          longitude: 32.7214,
          source: PlaceSource.curated,
          verificationStatus: VerificationStatus.verified,
          mainCategory: 'local_service',
          subtype: 'service_chassis_brakes',
          features: [
            'Telefon: 0530 112 23 34',
            'Çalışma: 08:30 - 18:00',
            'Hizmet: Şasi & Fren'
          ],
        ),
      ];
}
