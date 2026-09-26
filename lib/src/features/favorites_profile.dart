part of '../../main.dart';

class FigmaFavoritesScreen extends StatefulWidget {
  const FigmaFavoritesScreen(
      {super.key, required this.items, required this.onOpen});
  final List<Place> items;
  final ValueChanged<Place> onOpen;
  @override
  State<FigmaFavoritesScreen> createState() => _FigmaFavoritesScreenState();
}

class _FigmaFavoritesScreenState extends State<FigmaFavoritesScreen> {
  bool collections = false;
  bool grid = true;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
        child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 110),
            children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(AppStrings.get('favorites_title'),
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          color: isDark ? AppColors.darkPrimaryLight : green,
                          fontSize: AppFontSizes.display,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text(
                      '${widget.items.length} ${AppStrings.get('favorites_saved_count')}',
                      style: TextStyle(
                          fontSize: AppFontSizes.label,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary))
                ])),
            Container(
                decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.large),
                    border: Border.all(
                        color:
                            isDark ? AppColors.darkBorder : AppColors.border)),
                child: Row(children: [
                  IconButton(
                      onPressed: () => setState(() => grid = true),
                      icon: Icon(Icons.grid_view_rounded,
                          size: 17,
                          color: grid
                              ? (isDark ? AppColors.darkPrimaryLight : green)
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary))),
                  IconButton(
                      onPressed: () => setState(() => grid = false),
                      icon: Icon(Icons.view_list_rounded,
                          size: 18,
                          color: !grid
                              ? (isDark ? AppColors.darkPrimaryLight : green)
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary)))
                ])),
          ]),
          const SizedBox(height: 20),
          GlassContainer(
              borderRadius: BorderRadius.circular(AppRadii.large),
              blur: 14,
              color: Colors.white.withValues(alpha: 0.70),
              borderColor: Colors.white.withValues(alpha: 0.85),
              borderWidth: 1.2,
              padding: const EdgeInsets.all(4),
              child: Row(children: [
                Expanded(
                    child: _SegmentButton(
                        label:
                            '${AppStrings.get('favorites_saved_tab')} (${widget.items.length})',
                        active: !collections,
                        onTap: () => setState(() => collections = false))),
                Expanded(
                    child: _SegmentButton(
                        label: AppStrings.get('favorites_collections_tab'),
                        active: collections,
                        onTap: () => setState(() => collections = true))),
              ])),
          const SizedBox(height: 18),
          if (collections) ...[
            Container(
                height: 70,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.large),
                    border: Border.all(
                        color:
                            isDark ? AppColors.darkBorder : AppColors.border)),
                child: Row(children: [
                  const SquareAdd(),
                  const SizedBox(width: 12),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.get('favorites_new_collection'),
                            style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: AppFontSizes.label)),
                        Text(AppStrings.get('favorites_categorize'),
                            style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                                fontSize: AppFontSizes.caption))
                      ])
                ])),
            const SizedBox(height: 24),
            Center(
                child: Text(AppStrings.get('favorites_no_collections'),
                    style: const TextStyle(color: AppColors.textSecondary))),
          ] else if (widget.items.isEmpty)
            Padding(
                padding: const EdgeInsets.only(top: 70),
                child: Column(children: [
                  const Icon(Icons.eco_rounded,
                      size: 55, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(AppStrings.get('favorites_no_saved'),
                      style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: AppFontSizes.heading,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 7),
                  Text(AppStrings.get('favorites_no_saved_desc'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppFontSizes.label))
                ]))
          else if (grid)
            GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: .83,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12),
                itemBuilder: (_, i) => _FavoriteGridCard(
                    place: widget.items[i],
                    onTap: () => widget.onOpen(widget.items[i])))
          else
            ...widget.items.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child:
                    CompactPlaceCard(place: p, onTap: () => widget.onOpen(p)))),
        ]));
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton(
      {required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: active ? green : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.large)),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  fontSize: AppFontSizes.caption,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.textSecondary))));
}

class SquareAdd extends StatelessWidget {
  const SquareAdd({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceMuted : sand,
            borderRadius: BorderRadius.circular(AppRadii.large),
            border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border)),
        child: Icon(
          Icons.add_rounded,
          color: isDark ? AppColors.darkPrimaryLight : green,
        ));
  }
}

class _FavoriteGridCard extends StatelessWidget {
  const _FavoriteGridCard({required this.place, required this.onTap});
  final Place place;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.large),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
              boxShadow: const [
                BoxShadow(color: AppColors.shadow08, blurRadius: 10)
              ]),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Stack(fit: StackFit.expand, children: [
              NatureArt(place: place, radius: 0),
              const Positioned(
                  right: 9,
                  top: 9,
                  child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.favorite_rounded,
                          color: AppColors.accentOrange, size: 15)))
            ])),
            Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : Colors.black87,
                              fontSize: AppFontSizes.caption,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Text(place.location,
                            style: TextStyle(
                                fontSize: AppFontSizes.caption,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary)),
                        const Spacer(),
                        const Icon(Icons.star_rounded,
                            size: 11, color: AppColors.rating),
                        Text('${place.rating}',
                            style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : Colors.black87,
                                fontSize: AppFontSizes.caption,
                                fontWeight: FontWeight.w700))
                      ])
                    ]))
          ])),
    );
  }
}

class _PendingApprovalBadge extends StatelessWidget {
  const _PendingApprovalBadge();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warningSoft,
          border: Border.all(color: AppColors.warningBorder),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule_rounded,
                size: 12, color: AppColors.warningText),
            SizedBox(width: 4),
            Text(
              'Onay bekliyor',
              style: TextStyle(
                color: AppColors.warningText,
                fontSize: AppFontSizes.caption,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
}

class FigmaProfileScreen extends StatefulWidget {
  const FigmaProfileScreen({super.key, required this.onOpen});
  final ValueChanged<Place> onOpen;

  @override
  State<FigmaProfileScreen> createState() => _FigmaProfileScreenState();
}

class _FigmaProfileScreenState extends State<FigmaProfileScreen> {
  bool _isDeletingAccount = false;
  bool _expiredCallPromptShown = false;

  @override
  void initState() {
    super.initState();
    unawaited(EmergencyHelpController.load());
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _showExpiredCallPrompt());
  }

  Future<void> _showExpiredCallPrompt() async {
    if (!mounted || _expiredCallPromptShown) return;
    await EmergencyHelpController.load();
    final request = EmergencyHelpController.currentUserExpiredRequest;
    if (!mounted || request == null || _expiredCallPromptShown) return;
    _expiredCallPromptShown = true;
    final continueRequest = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hâlâ yardıma ihtiyacın var mı?'),
        content: const Text(
          'Yardım çağrın 48 saati doldurdu ve haritadan kaldırıldı. İstersen 48 saat daha görünür kalsın.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hayır, sonlandır'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Evet, sürdür'),
          ),
        ],
      ),
    );
    try {
      if (continueRequest == true) {
        await EmergencyHelpController.extend(request);
      } else {
        await EmergencyHelpController.resolve(request);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }

  Future<void> _openEmergencyHelp() async {
    if (EmergencyHelpController.currentUserId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yardım çağrısı için önce hesabına giriş yapmalısın.'),
        ),
      );
      await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
      );
      return;
    }
    await EmergencyHelpController.load();
    if (!mounted) return;
    if (!EmergencyHelpController.isAvailable.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yardım çağrısı altyapısı henüz etkin değil.'),
        ),
      );
      return;
    }
    final active = EmergencyHelpController.currentUserActiveRequest;
    if (active != null) {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
            builder: (_) => EmergencyHelpMapScreen(focusRequest: active)),
      );
      return;
    }
    final request = await EmergencyHelpRequestSheet.show(context);
    if (!mounted || request == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (_) => EmergencyHelpMapScreen(focusRequest: request)),
    );
  }

  Future<void> _handleDeleteAccount() async {
    if (_isDeletingAccount) return;

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aktif bir kullanıcı oturumu bulunamadı.'),
        ),
      );
      return;
    }

    // 1. İlk onay diyaloğu
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hesabınızı silmek istiyor musunuz?'),
        content: const Text(
          'Hesabınız ve hesabınızla ilişkili veriler kalıcı olarak silinecektir. Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Hesabımı Sil'),
          ),
        ],
      ),
    );

    if (firstConfirm != true) return;
    if (!mounted) return;

    // 2. İkinci ve daha güçlü onay diyaloğu
    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Emin misiniz?'),
        content: const Text(
          'Bu işlem geri alınamaz. Devam etmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Evet, Kalıcı Olarak Sil'),
          ),
        ],
      ),
    );

    if (secondConfirm != true) return;
    if (!mounted) return;

    setState(() => _isDeletingAccount = true);

    // İşlem sırasında modal progress göstergesi (aynı çağrının iki kez gönderilmesini engeller)
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Hesabınız siliniyor...',
                    style: TextStyle(
                      fontSize: AppFontSizes.label,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      // Yalnızca Edge Function çağrılır; istemciden user_id GÖNDERİLMEZ.
      // Kimlik Supabase client tarafından Authorization başlığındaki Bearer JWT ile taşınır.
      final response =
          await Supabase.instance.client.functions.invoke('delete-account');

      if (response.status != 200) {
        throw Exception(
            'Account deletion failed with status ${response.status}');
      }

      // Başarılı: Yerel kullanıcı verilerini temizle
      await PlaceSubmissionController.clearQueue();
      await UserPlacesController.clear();
      await PlacePhotoStorage.clearLocalPhotos();
      await UserReviewsController.clear();

      // Auth oturumunu kapat (Server-side kullanıcı silinmiş olabileceğinden signOut hata verebilir, başarı akışını bozmaz)
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}

      if (!mounted) return;

      // Loading diyaloğunu kapat
      Navigator.of(context, rootNavigator: true).pop();

      // Kullanıcıyı giriş ekranına döndür
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const AuthScreen(),
        ),
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;

      // Loading diyaloğunu kapat
      Navigator.of(context, rootNavigator: true).pop();

      setState(() => _isDeletingAccount = false);

      // Başarısızlık durumunda yerel veriler korunur, oturum kapatılmaz, anlaşılır Türkçe hata gösterilir.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hesabınız silinemedi. Lütfen tekrar deneyin.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showLanguageSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => ValueListenableBuilder<Locale>(
        valueListenable: AppLocaleController.current,
        builder: (context, currentLocale, _) => Container(
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
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkPrimarySoft
                          : AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                    ),
                    child: Icon(
                      Icons.translate_rounded,
                      color: isDark
                          ? AppColors.darkPrimaryLight
                          : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.get('select_language_title'),
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: AppFontSizes.title,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...AppLocaleController.options.map((option) {
                final isSelected =
                    option.locale.languageCode == currentLocale.languageCode;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await AppLocaleController.setLocale(option.locale);
                        if (!sheetContext.mounted) return;
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppStrings.get('language_changed_toast'),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(AppRadii.large),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark
                                  ? AppColors.darkPrimarySoft
                                  : AppColors.primarySoft)
                              : (isDark
                                  ? AppColors.darkSurface
                                  : AppColors.surfaceMuted),
                          borderRadius: BorderRadius.circular(AppRadii.large),
                          border: Border.all(
                            color: isSelected
                                ? (isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.primary)
                                : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.border),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              option.flag,
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.nativeLabel,
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: AppFontSizes.title,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? (isDark
                                              ? AppColors.darkPrimaryLight
                                              : AppColors.primary)
                                          : (isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.textPrimary),
                                    ),
                                  ),
                                  Text(
                                    option.label,
                                    style: TextStyle(
                                      fontSize: AppFontSizes.caption,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: isDark
                                    ? AppColors.darkPrimaryLight
                                    : AppColors.primary,
                                size: 22,
                              )
                            else
                              Icon(
                                Icons.radio_button_unchecked_rounded,
                                color: isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.disabled,
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user;
    try {
      user = Supabase.instance.client.auth.currentUser;
    } catch (_) {
      user = null;
    }
    final metadata = user?.userMetadata;
    final fullName = (metadata?['full_name']?.toString() ??
            metadata?['name']?.toString() ??
            metadata?['display_name']?.toString() ??
            '')
        .trim();
    final email = user?.email?.trim() ?? '';
    final displayName = fullName.isNotEmpty
        ? fullName
        : (email.isNotEmpty
            ? email
            : AppStrings.get('profile_default_user_name'));
    final subtitle = fullName.isNotEmpty && email.isNotEmpty ? email : null;
    final avatarInitial = displayName.isNotEmpty
        ? displayName.characters.first.toUpperCase()
        : 'D';
    final avatarUrl =
        metadata?['avatar_url']?.toString() ?? metadata?['picture']?.toString();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final dividerColor = AppColors.borderOf(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
        children: [
          // 1. ÜST BAR: Sol "Profil"
          Text(
            AppStrings.get('profile_title'),
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: AppFontSizes.display,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 18),

          // 2. KULLANICI PROFİL ALANI (CircleAvatar + Ad + Doğa Kaşifi + Katkı Sayısı)
          GlassContainer(
            borderRadius: BorderRadius.circular(AppRadii.large),
            blur: 14,
            color: isDark
                ? AppColors.darkPrimarySoft.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.70),
            borderColor: Colors.white.withValues(alpha: 0.85),
            borderWidth: 1.2,
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow08,
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: isDark
                      ? AppColors.darkPrimarySoft
                      : AppColors.primarySoft,
                  backgroundImage:
                      (avatarUrl != null && avatarUrl.startsWith('http'))
                          ? NetworkImage(avatarUrl)
                          : null,
                  child: (avatarUrl != null && avatarUrl.startsWith('http'))
                      ? null
                      : Text(
                          avatarInitial,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            color: AppColors.primary,
                            fontSize: AppFontSizes.display,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: AppFontSizes.title,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        AppStrings.get('profile_nature_explorer'),
                        style: TextStyle(
                          fontSize: AppFontSizes.label,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkPrimaryLight
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      ValueListenableBuilder<List<Place>>(
                        valueListenable: UserPlacesController.places,
                        builder: (context, places, _) => Text(
                          '${places.length} ${AppStrings.get('profile_contributions')}',
                          style: TextStyle(
                            fontSize: AppFontSizes.caption,
                            fontWeight: FontWeight.w400,
                            color: textSecondary,
                          ),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppFontSizes.caption,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          ValueListenableBuilder<List<EmergencyHelpRequest>>(
            valueListenable: EmergencyHelpController.requests,
            builder: (context, _, __) {
              final active = EmergencyHelpController.currentUserActiveRequest;
              return Semantics(
                button: true,
                label: active == null
                    ? 'Yardım iste'
                    : 'Aktif yardım çağrını yönet',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openEmergencyHelp,
                    borderRadius: BorderRadius.circular(AppRadii.large),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 72),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.error.withValues(alpha: 0.15)
                            : AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadii.large),
                        border: Border.all(
                          color: active == null
                              ? AppColors.error.withValues(alpha: 0.3)
                              : AppColors.error,
                          width: active == null ? 1 : 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            active == null
                                ? Icons.sos_rounded
                                : Icons.warning_amber_rounded,
                            color: AppColors.error,
                            size: 25,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  active == null
                                      ? 'Yardım iste'
                                      : 'Yardım çağrın aktif',
                                  style: TextStyle(
                                    fontSize: AppFontSizes.title,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  active == null
                                      ? 'Konumunu ve ulaşım tercihini paylaş'
                                      : 'Haritada gör, yardım ulaştığında sonlandır',
                                  style: TextStyle(
                                      fontSize: AppFontSizes.caption,
                                      color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              color: textSecondary, size: 22),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 22),

          // 3. KATKILARIM BAŞLIĞI (Doğrudan kullanıcı alanından 20px sonra)
          Text(
            AppStrings.get('profile_my_contributions'),
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: AppFontSizes.title,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Katkılarım listesi veya kompakt empty state
          ValueListenableBuilder<List<Place>>(
            valueListenable: UserPlacesController.places,
            builder: (context, places, _) {
              if (places.isNotEmpty) {
                return SizedBox(
                  height: 94,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: places.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final place = places[i];
                      return GestureDetector(
                        onTap: () => widget.onOpen(place),
                        child: Container(
                          width: 94,
                          height: 94,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppRadii.medium),
                            color: isDark
                                ? AppColors.darkSurfaceMuted
                                : AppColors.surfaceMuted,
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              NatureArt(
                                place: place,
                                radius: 0,
                                showKind: false,
                              ),
                              Positioned(
                                bottom: 6,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkSurface
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: AppColors.shadow08,
                                          blurRadius: 4,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      place.icon,
                                      size: 13,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              if (place.verificationStatus !=
                                  VerificationStatus.verified)
                                const Positioned(
                                  top: 5,
                                  left: 5,
                                  child: _PendingApprovalBadge(),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }

              // Kompakt, kartsız empty state (yaklaşık 40px buton yüksekliği)
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('profile_no_contributions'),
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: AppFontSizes.body,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.get('profile_share_places'),
                      style: TextStyle(
                        fontSize: AppFontSizes.caption,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 38,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddPlaceScreen(
                                onOpenExisting: widget.onOpen,
                                onContributeToExisting: widget.onOpen,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: Text(AppStrings.get('profile_add_first_place')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.small),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 22),

          // 4. ALT MENÜ LİSTESİ
          // Görünüm (Açık / Koyu tema switch)
          ValueListenableBuilder<ThemeMode>(
            valueListenable: AppThemeController.mode,
            builder: (context, mode, _) => SizedBox(
              height: 54,
              child: Row(
                children: [
                  Icon(
                    mode == ThemeMode.dark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    size: 20,
                    color: textSecondary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      AppStrings.get('profile_theme'),
                      style: TextStyle(
                        fontSize: AppFontSizes.body,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Switch(
                    value: mode == ThemeMode.dark,
                    onChanged: AppThemeController.setDark,
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),

          // Dil Seçeneği (Türkçe / English / العربية)
          ValueListenableBuilder<Locale>(
            valueListenable: AppLocaleController.current,
            builder: (context, locale, _) {
              final currentOption = AppLocaleController.options.firstWhere(
                (opt) => opt.locale.languageCode == locale.languageCode,
                orElse: () => AppLocaleController.options.first,
              );
              return InkWell(
                onTap: () => _showLanguageSelector(context),
                child: SizedBox(
                  height: 54,
                  child: Row(
                    children: [
                      Icon(
                        Icons.language_rounded,
                        size: 20,
                        color: textSecondary,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          AppStrings.get('profile_language'),
                          style: TextStyle(
                            fontSize: AppFontSizes.body,
                            fontWeight: FontWeight.w500,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkPrimarySoft
                              : AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(currentOption.flag,
                                style: const TextStyle(
                                    fontSize: AppFontSizes.label)),
                            const SizedBox(width: 5),
                            Text(
                              currentOption.nativeLabel,
                              style: TextStyle(
                                fontSize: AppFontSizes.caption,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkPrimaryLight
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: textSecondary,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const CommunityChatHubScreen(),
                ),
              );
            },
            child: SizedBox(
              height: 54,
              child: Row(
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 20,
                    color: textSecondary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      AppStrings.get('profile_community_chat'),
                      style: TextStyle(
                        fontSize: AppFontSizes.body,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: textSecondary,
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),

          // Gizlilik Politikası
          InkWell(
            onTap: () => AppLegalLinks.openPrivacyPolicy(context),
            child: SizedBox(
              height: 54,
              child: Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 20,
                    color: textSecondary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      AppStrings.get('profile_privacy_policy'),
                      style: TextStyle(
                        fontSize: AppFontSizes.body,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: textSecondary,
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),

          // Kullanım Koşulları
          InkWell(
            onTap: () => AppLegalLinks.openTermsOfService(context),
            child: SizedBox(
              height: 54,
              child: Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 20,
                    color: textSecondary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      AppStrings.get('profile_terms'),
                      style: TextStyle(
                        fontSize: AppFontSizes.body,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: textSecondary,
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),

          // Geri Bildirim ve Destek
          InkWell(
            onTap: () => AppLegalLinks.openFeedback(context),
            child: SizedBox(
              height: 54,
              child: Row(
                children: [
                  Icon(
                    Icons.mail_outline_rounded,
                    size: 20,
                    color: textSecondary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      AppStrings.get('profile_feedback'),
                      style: TextStyle(
                        fontSize: AppFontSizes.body,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: textSecondary,
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),

          // Çıkış Yap
          InkWell(
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (!context.mounted) return;
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (_) => const AuthScreen(),
                ),
                (_) => false,
              );
            },
            child: SizedBox(
              height: 54,
              child: Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: textSecondary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      AppStrings.get('profile_logout'),
                      style: TextStyle(
                        fontSize: AppFontSizes.body,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: textSecondary,
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),
          const SizedBox(height: 16),

          // Hesabımı Sil: en altta, kırmızı, sade ve küçük
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _isDeletingAccount ? null : _handleDeleteAccount,
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 15,
                color: AppColors.error,
              ),
              label: Text(
                AppStrings.get('profile_delete_account'),
                style: const TextStyle(
                  fontSize: AppFontSizes.label,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
