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
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
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
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none)),
                  const SizedBox(height: 3),
                  Text(
                      '${widget.items.length} ${AppStrings.get('favorites_saved_count')}',
                      style: TextStyle(
                          fontSize: AppFontSizes.label,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          decoration: TextDecoration.none))
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
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: AppFontSizes.heading,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                          decoration: TextDecoration.none)),
                  const SizedBox(height: 7),
                  Text(AppStrings.get('favorites_no_saved_desc'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: textSecondary,
                          fontSize: AppFontSizes.label,
                          decoration: TextDecoration.none))
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
                  color: active ? Colors.white : AppColors.textSecondary,
                  decoration: TextDecoration.none))));
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

/// Kullanıcı tam adını saklar; kısa görünüm yalnızca arayüz ve sohbet için
/// soyadını baş harfe indirger. Böylece ayarı değiştirince ad bilgisi kaybolmaz.
String profileDisplayNameForStyle(
  String fullName, {
  required bool abbreviated,
}) {
  final parts = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (!abbreviated || parts.length < 2) return parts.join(' ');
  return '${parts.first} ${parts.last.characters.first.toUpperCase()}.';
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
  bool _rejectionNoticeShown = false;

  Future<void> _showDisplayNameEditor(String currentName) async {
    final controller = TextEditingController(text: currentName);
    final metadata = Supabase.instance.client.auth.currentUser?.userMetadata;
    var abbreviated = metadata?['display_name_style']?.toString() == 'short';
    final selected = await showDialog<({String name, bool abbreviated})>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(AppStrings.get('profile_display_name_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 48,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: AppStrings.get('profile_display_name_label'),
                  hintText: AppStrings.get('profile_display_name_hint'),
                ),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Soyadımı baş harf olarak göster'),
                subtitle: Text(
                  profileDisplayNameForStyle(
                    controller.text.trim().isEmpty
                        ? currentName
                        : controller.text,
                    abbreviated: abbreviated,
                  ),
                ),
                value: abbreviated,
                onChanged: (value) => setDialogState(() => abbreviated = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppStrings.get('general_cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                (name: controller.text, abbreviated: abbreviated),
              ),
              child: Text(AppStrings.get('general_save')),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    final fullName = selected?.name.trim() ?? '';
    if (fullName.length < 2 || fullName.length > 48 || !mounted) return;
    final displayName = profileDisplayNameForStyle(
      fullName,
      abbreviated: selected!.abbreviated,
    );
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {
          'full_name': fullName,
          'display_name': displayName,
          'display_name_style': selected.abbreviated ? 'short' : 'full',
        }),
      );
      // Sohbetin JWT tabanlı görünen adı aynı oturumda da güncel kalsın.
      await Supabase.instance.client.auth.refreshSession();
      if (mounted) setState(() {});
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    unawaited(EmergencyHelpController.load());
    unawaited(_loadSubmissionFeedback());
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _showExpiredCallPrompt());
  }

  Future<void> _loadSubmissionFeedback() async {
    await SubmissionFeedbackController.load();
    if (!mounted) return;
    await _showUnreadRejectionNotice();
  }

  Future<void> _showUnreadRejectionNotice() async {
    if (!mounted || _rejectionNoticeShown) return;
    final feedback = SubmissionFeedbackController.items.value
        .where((item) => item.isRejected || item.isActionRequired)
        .cast<SubmissionFeedback?>()
        .firstWhere((item) => item != null, orElse: () => null);
    if (feedback == null) return;
    _rejectionNoticeShown = true;

    final acknowledged = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          feedback.isActionRequired
              ? Icons.edit_note_rounded
              : Icons.info_outline_rounded,
          color:
              feedback.isActionRequired ? AppColors.primary : AppColors.error,
        ),
        title: Text(feedback.isActionRequired
            ? AppStrings.get('profile_feedback_correction_title')
            : AppStrings.get('profile_feedback_rejected_title')),
        content: Text(feedback.body),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(AppStrings.get('profile_feedback_acknowledge')),
          ),
        ],
      ),
    );
    if (acknowledged != true || !mounted) return;
    try {
      await SubmissionFeedbackController.markRead(feedback);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.get('profile_feedback_mark_read_failed')),
        ));
      }
    }
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
        title: Text(AppStrings.get('profile_help_expired_title')),
        content: Text(AppStrings.get('profile_help_expired_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppStrings.get('profile_help_end')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(AppStrings.get('profile_help_continue')),
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
        SnackBar(content: Text(AppStrings.get('profile_no_active_session'))),
      );
      return;
    }

    // 1. İlk onay diyaloğu
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.get('profile_delete_confirm_title')),
        content: Text(AppStrings.get('profile_delete_confirm_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.get('general_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text(AppStrings.get('profile_delete_action')),
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
        title: Text(AppStrings.get('profile_delete_final_title')),
        content: Text(AppStrings.get('profile_delete_final_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.get('general_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text(AppStrings.get('profile_delete_final_action')),
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
      builder: (_) => PopScope(
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
                    AppStrings.get('profile_deleting'),
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

      await PlaceSubmissionController.clearQueue();
      await UserPlacesController.clear();
      await PlacePhotoStorage.clearLocalPhotos();
      await UserReviewsController.clear();
      await UserFavoritesController.clear();
      await CommunityPlacePhotosController.clear();
      await HomeWeatherLocationController.clearSavedLocation();
      await UserProfileAvatarController.clear();
      EmergencyHelpController.clearLocalData();

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

      // Başarısızlık durumunda yerel veriler korunur, oturum kapatılmaz.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('profile_delete_failed')),
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
    final fullName = (metadata?['display_name']?.toString() ??
            metadata?['full_name']?.toString() ??
            metadata?['name']?.toString() ??
            '')
        .trim();
    final rawEmail = user?.email?.trim() ?? '';
    final maskedEmail = rawEmail.contains('@') && rawEmail.indexOf('@') > 1
        ? '${rawEmail.substring(0, 2)}***@${rawEmail.split('@').last}'
        : (rawEmail.isNotEmpty ? '***@***' : '');
    final isGuest = user == null;
    final displayName = isGuest
        ? AppStrings.get('profile_guest_user')
        : (fullName.isNotEmpty
            ? fullName
            : (maskedEmail.isNotEmpty
                ? maskedEmail
                : AppStrings.get('profile_default_user_name')));
    final subtitle = isGuest
        ? AppStrings.get('profile_guest_subtitle')
        : (fullName.isNotEmpty && maskedEmail.isNotEmpty ? maskedEmail : null);
    final avatarInitial = isGuest
        ? 'M'
        : (displayName.isNotEmpty
            ? displayName.characters.first.toUpperCase()
            : 'D');
    final avatarUrl =
        metadata?['avatar_url']?.toString() ?? metadata?['picture']?.toString();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final dividerColor = AppColors.borderOf(context);

    if (context.isTabletLandscape) {
      return SafeArea(
        child: _buildLandscapeLayout(
          context: context,
          isDark: isDark,
          isGuest: isGuest,
          displayName: displayName,
          subtitle: subtitle,
          avatarInitial: avatarInitial,
          avatarUrl: avatarUrl,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          dividerColor: dividerColor,
        ),
      );
    }

    if (context.isTabletPortrait) {
      return SafeArea(
        child: _buildPortraitTabletLayout(
          context: context,
          isDark: isDark,
          isGuest: isGuest,
          displayName: displayName,
          subtitle: subtitle,
          avatarInitial: avatarInitial,
          avatarUrl: avatarUrl,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          dividerColor: dividerColor,
        ),
      );
    }

    return SafeArea(
      child: _buildPhoneLayout(
        context: context,
        isDark: isDark,
        isGuest: isGuest,
        displayName: displayName,
        subtitle: subtitle,
        avatarInitial: avatarInitial,
        avatarUrl: avatarUrl,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        dividerColor: dividerColor,
      ),
    );
  }

  Widget _buildPhoneLayout({
    required BuildContext context,
    required bool isDark,
    required bool isGuest,
    required String displayName,
    required String? subtitle,
    required String avatarInitial,
    required String? avatarUrl,
    required Color textPrimary,
    required Color textSecondary,
    required Color dividerColor,
  }) =>
      ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
        children: [
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
          _buildProfileUserCard(
            context: context,
            isDark: isDark,
            isGuest: isGuest,
            displayName: displayName,
            subtitle: subtitle,
            avatarInitial: avatarInitial,
            avatarUrl: avatarUrl,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 12),
          _buildFavoritesShortcut(
            context: context,
            isDark: isDark,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 20),
          _buildEmergencyHelpCard(
            context: context,
            isDark: isDark,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 22),
          _buildNotificationsSection(
            context: context,
            isDark: isDark,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          _buildContributionsSection(
            context: context,
            isDark: isDark,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            isGrid: false,
          ),
          const SizedBox(height: 22),
          _buildSettingsMenu(
            context: context,
            isDark: isDark,
            isGuest: isGuest,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            dividerColor: dividerColor,
          ),
        ],
      );

  Widget _buildPortraitTabletLayout({
    required BuildContext context,
    required bool isDark,
    required bool isGuest,
    required String displayName,
    required String? subtitle,
    required String avatarInitial,
    required String? avatarUrl,
    required Color textPrimary,
    required Color textSecondary,
    required Color dividerColor,
  }) =>
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
            children: [
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
              _buildProfileUserCard(
                context: context,
                isDark: isDark,
                isGuest: isGuest,
                displayName: displayName,
                subtitle: subtitle,
                avatarInitial: avatarInitial,
                avatarUrl: avatarUrl,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildContributionsSection(
                          context: context,
                          isDark: isDark,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isGrid: false,
                        ),
                        const SizedBox(height: 24),
                        _buildEmergencyHelpCard(
                          context: context,
                          isDark: isDark,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNotificationsSection(
                          context: context,
                          isDark: isDark,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildSettingsMenu(
                          context: context,
                          isDark: isDark,
                          isGuest: isGuest,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          dividerColor: dividerColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildLandscapeLayout({
    required BuildContext context,
    required bool isDark,
    required bool isGuest,
    required String displayName,
    required String? subtitle,
    required String avatarInitial,
    required String? avatarUrl,
    required Color textPrimary,
    required Color textSecondary,
    required Color dividerColor,
  }) =>
      AppResponsiveScaffoldBody(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sol (%38): Avatar, hesap, yardım iste, ayarlar
            Expanded(
              flex: 38,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 16),
                    _buildProfileUserCard(
                      context: context,
                      isDark: isDark,
                      isGuest: isGuest,
                      displayName: displayName,
                      subtitle: subtitle,
                      avatarInitial: avatarInitial,
                      avatarUrl: avatarUrl,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 16),
                    _buildEmergencyHelpCard(
                      context: context,
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 20),
                    _buildSettingsMenu(
                      context: context,
                      isDark: isDark,
                      isGuest: isGuest,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      dividerColor: dividerColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 28),
            // Sağ (%62): Katkılar, onay durumları ve bildirimler
            Expanded(
              flex: 62,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNotificationsSection(
                      context: context,
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    _buildContributionsSection(
                      context: context,
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isGrid: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildProfileUserCard({
    required BuildContext context,
    required bool isDark,
    required bool isGuest,
    required String displayName,
    required String? subtitle,
    required String avatarInitial,
    required String? avatarUrl,
    required Color textPrimary,
    required Color textSecondary,
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isGuest
              ? () => AppAuthGuard.requireAuth(
                    context,
                    title: AppStrings.get('guest_auth_title'),
                    message:
                        'Profilini görüntülemek ve yönetmek için giriş yapmalısın.',
                  )
              : null,
          borderRadius: BorderRadius.circular(AppRadii.large),
          child: GlassContainer(
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
                ValueListenableBuilder<String?>(
                  valueListenable: UserProfileAvatarController.avatarNotifier,
                  builder: (context, customAvatar, _) {
                    final effectiveAvatar =
                        (customAvatar != null && customAvatar.isNotEmpty)
                            ? customAvatar
                            : avatarUrl;
                    final avatarImage = effectiveAvatar == null
                        ? null
                        : _profileAvatarImageProvider(effectiveAvatar);
                    final hasImage = avatarImage != null;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: isDark
                              ? AppColors.darkPrimarySoft
                              : AppColors.primarySoft,
                          backgroundImage: avatarImage,
                          child: hasImage
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
                        if (!isGuest)
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _showAvatarPickerModal(context),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkPrimary
                                        : AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.darkSurface
                                          : Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: AppColors.shadow08,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
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
                          ),
                          if (!isGuest)
                            IconButton(
                              tooltip: 'Görünecek adı düzenle',
                              onPressed: () =>
                                  _showDisplayNameEditor(displayName),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isGuest
                            ? AppStrings.get('profile_guest_subtitle')
                            : AppStrings.get('profile_nature_explorer'),
                        style: TextStyle(
                          fontSize: AppFontSizes.label,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkPrimaryLight
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (isGuest) ...[
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 32,
                          child: FilledButton.icon(
                            onPressed: () => Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const AuthScreen(),
                              ),
                            ),
                            icon: const Icon(Icons.login_rounded, size: 15),
                            label: Text(
                              AppStrings.get('guest_auth_btn_login'),
                              style: const TextStyle(
                                fontSize: AppFontSizes.caption,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 0),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.pill),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
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
                        ValueListenableBuilder<UserSocialAccounts>(
                          valueListenable:
                              UserSocialAccountsController.accounts,
                          builder: (context, accounts, _) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  if (accounts.instagram.isNotEmpty)
                                    _SocialIconBadge(
                                      icon: Icons.camera_alt_outlined,
                                      color: const Color(0xFFE1306C),
                                      tooltip: 'Instagram',
                                      onTap: () => _openSocialLink(
                                        context,
                                        'instagram',
                                        accounts.instagram,
                                      ),
                                    ),
                                  if (accounts.facebook.isNotEmpty)
                                    _SocialIconBadge(
                                      icon: Icons.facebook,
                                      color: const Color(0xFF1877F2),
                                      tooltip: 'Facebook',
                                      onTap: () => _openSocialLink(
                                        context,
                                        'facebook',
                                        accounts.facebook,
                                      ),
                                    ),
                                  if (accounts.youtube.isNotEmpty)
                                    _SocialIconBadge(
                                      icon: Icons.smart_display_rounded,
                                      color: const Color(0xFFFF0000),
                                      tooltip: 'YouTube',
                                      onTap: () => _openSocialLink(
                                        context,
                                        'youtube',
                                        accounts.youtube,
                                      ),
                                    ),
                                  InkWell(
                                    onTap: () =>
                                        _showSocialAccountsModal(context),
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.pill),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.darkSurfaceMuted
                                            : AppColors.surfaceMuted,
                                        borderRadius: BorderRadius.circular(
                                            AppRadii.pill),
                                        border: Border.all(
                                          color: isDark
                                              ? AppColors.darkBorder
                                              : AppColors.border,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            accounts.isEmpty
                                                ? Icons.add_link_rounded
                                                : Icons.edit_outlined,
                                            size: 12,
                                            color: isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            accounts.isEmpty
                                                ? 'Sosyal Hesap'
                                                : 'Düzenle',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontFamily: 'Outfit',
                                              fontWeight: FontWeight.w500,
                                              color: isDark
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  List<Place> _favoritePlaces() {
    final savedNames = UserFavoritesController.favorites.value;
    final seen = <String>{};
    return <Place>[
      ...SupabasePlacesController.places.value,
      ...UserPlacesController.places.value,
      ...NearbyPlacesService.availableNow(
          HomeWeatherLocationController.current.value),
    ].where((place) {
      final name = place.name.trim();
      return savedNames.contains(name) && name.isNotEmpty && seen.add(name);
    }).toList(growable: false);
  }

  void _openFavorites(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => FigmaFavoritesScreen(
          items: _favoritePlaces(),
          onOpen: widget.onOpen,
        ),
      ),
    );
  }

  Widget _buildFavoritesShortcut({
    required BuildContext context,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) =>
      ValueListenableBuilder<Set<String>>(
        valueListenable: UserFavoritesController.favorites,
        builder: (context, favorites, _) => Semantics(
          button: true,
          label: 'Favorilerim, ${favorites.length} kayıtlı yer',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openFavorites(context),
              borderRadius: BorderRadius.circular(AppRadii.large),
              child: Container(
                constraints: const BoxConstraints(minHeight: 72),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.favorite_rounded,
                        color: AppColors.error, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('favorites_title'),
                            style: TextStyle(
                              color: textPrimary,
                              fontFamily: 'Outfit',
                              fontSize: AppFontSizes.body,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${favorites.length} kayıtlı yer',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: AppFontSizes.caption,
                            ),
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
        ),
      );

  Widget _buildEmergencyHelpCard({
    required BuildContext context,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) =>
      ValueListenableBuilder<List<EmergencyHelpRequest>>(
        valueListenable: EmergencyHelpController.requests,
        builder: (context, _, __) {
          final active = EmergencyHelpController.currentUserActiveRequest;
          return Semantics(
            button: true,
            label:
                active == null ? 'Yardım iste' : 'Aktif yardım çağrını yönet',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openEmergencyHelp,
                borderRadius: BorderRadius.circular(AppRadii.large),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 72),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: active == null
                        ? (isDark
                            ? AppColors.darkSurfaceMuted
                            : AppColors.surfaceMuted)
                        : (isDark
                            ? AppColors.error.withValues(alpha: 0.15)
                            : AppColors.error.withValues(alpha: 0.08)),
                    borderRadius: BorderRadius.circular(AppRadii.large),
                    border: Border.all(
                      color: active == null
                          ? (isDark ? AppColors.darkBorder : AppColors.border)
                          : AppColors.error,
                      width: active == null ? 1 : 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        active == null
                            ? Icons.health_and_safety_outlined
                            : Icons.warning_amber_rounded,
                        color: active == null
                            ? (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary)
                            : AppColors.error,
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
      );

  Widget _buildNotificationsSection({
    required BuildContext context,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) =>
      ValueListenableBuilder<List<SubmissionFeedback>>(
        valueListenable: SubmissionFeedbackController.items,
        builder: (context, feedback, _) {
          final visibleFeedback = feedback
              .where((item) => !item.isRejected && !item.isActionRequired)
              .toList(growable: false);
          if (visibleFeedback.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Katkı bildirimleri',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: AppFontSizes.title,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ...visibleFeedback.take(2).map(
                    (item) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: item.isActionRequired
                            ? (isDark
                                ? AppColors.darkErrorSoft
                                : AppColors.errorSoft)
                            : (isDark
                                ? AppColors.darkPrimarySoft
                                : AppColors.primarySoft),
                        borderRadius: BorderRadius.circular(AppRadii.medium),
                        border: Border.all(
                          color: item.isActionRequired
                              ? AppColors.errorBorder
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.border),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            item.isActionRequired
                                ? Icons.edit_note_rounded
                                : Icons.verified_outlined,
                            color: item.isActionRequired
                                ? AppColors.error
                                : (isDark
                                    ? AppColors.darkPrimaryLight
                                    : AppColors.primary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title,
                                    style: TextStyle(
                                        color: textPrimary,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(item.body,
                                    style: TextStyle(
                                        fontSize: AppFontSizes.caption,
                                        color: textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 14),
            ],
          );
        },
      );

  Widget _buildContributionsSection({
    required BuildContext context,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    bool isGrid = false,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.get('profile_my_contributions'),
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: AppFontSizes.title,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              ValueListenableBuilder<List<Place>>(
                valueListenable: UserPlacesController.places,
                builder: (context, places, _) {
                  if (places.isEmpty) return const SizedBox.shrink();
                  return TextButton.icon(
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
                    label: Text(
                      AppStrings.get('add_place_nav_title'),
                      style: const TextStyle(fontSize: AppFontSizes.caption),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<List<Place>>(
            valueListenable: UserPlacesController.places,
            builder: (context, places, _) {
              if (places.isNotEmpty) {
                if (isGrid) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: places.map((place) {
                      return GestureDetector(
                        onTap: () => widget.onOpen(place),
                        child: Container(
                          width: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadii.large),
                            color: isDark
                                ? AppColors.darkSurfaceMuted
                                : AppColors.surface,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.border,
                            ),
                            boxShadow: AppShadows.softOf(context),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 90,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    NatureArt(
                                      place: place,
                                      radius: 0,
                                      showKind: false,
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
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      place.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: AppFontSizes.caption,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      place.location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: AppFontSizes.caption * 0.9,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
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
                                    child: AppPlaceCategoryPictogram(
                                      place,
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

              // Kompakt, kartsız empty state
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
        ],
      );

  Widget _buildSettingsMenu({
    required BuildContext context,
    required bool isDark,
    required bool isGuest,
    required Color textPrimary,
    required Color textSecondary,
    required Color dividerColor,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          // Sosyal Medya Hesapları (Instagram, Facebook, YouTube)
          if (!isGuest) ...[
            InkWell(
              onTap: () => _showSocialAccountsModal(context),
              child: SizedBox(
                height: 54,
                child: Row(
                  children: [
                    Icon(
                      Icons.alternate_email_rounded,
                      size: 20,
                      color: textSecondary,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Sosyal Medya Hesapları',
                        style: TextStyle(
                          fontSize: AppFontSizes.body,
                          fontWeight: FontWeight.w500,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    ValueListenableBuilder<UserSocialAccounts>(
                      valueListenable: UserSocialAccountsController.accounts,
                      builder: (context, accounts, _) {
                        final count = [
                          accounts.instagram,
                          accounts.facebook,
                          accounts.youtube,
                        ].where((s) => s.trim().isNotEmpty).length;
                        return Text(
                          count > 0 ? '$count hesap bağlı' : 'Ekle',
                          style: TextStyle(
                            fontSize: AppFontSizes.caption,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkPrimaryLight
                                : AppColors.primary,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
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
          ],

          // Topluluk Sohbetleri
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

          if (isGuest) ...[
            InkWell(
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const AuthScreen(),
                ),
              ),
              child: SizedBox(
                height: 54,
                child: Row(
                  children: [
                    Icon(
                      Icons.login_rounded,
                      size: 20,
                      color: isDark
                          ? AppColors.darkPrimaryLight
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        AppStrings.get('guest_auth_btn_login'),
                        style: TextStyle(
                          fontSize: AppFontSizes.body,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkPrimaryLight
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: isDark
                          ? AppColors.darkPrimaryLight
                          : AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, thickness: 0.8, color: dividerColor),
          ] else ...[
            // Çıkış Yap
            InkWell(
              onTap: () async {
                try {
                  await Supabase.instance.client.auth.signOut();
                } catch (_) {}
                await PlaceSubmissionController.clearQueue();
                await PlacePhotoStorage.clearLocalPhotos();
                await UserReviewsController.clear();
                await CommunityPlacePhotosController.clear();
                await HomeWeatherLocationController.clearSavedLocation();
                await UserProfileAvatarController.clear();
                await UserSocialAccountsController.clear();
                EmergencyHelpController.clearLocalData();
                SubmissionFeedbackController.items.value =
                    const <SubmissionFeedback>[];
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ],
      );
}

ImageProvider? _profileAvatarImageProvider(String value) {
  if (value.startsWith('data:image/') && value.contains(',')) {
    try {
      return MemoryImage(base64Decode(value.split(',').last));
    } catch (_) {
      return null;
    }
  }
  return value.startsWith('http') ? NetworkImage(value) : null;
}

Future<void> _pickProfileAvatar(
  BuildContext context,
  ImageSource source,
) async {
  try {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 76,
      maxWidth: 720,
      maxHeight: 720,
      requestFullMetadata: false,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (bytes.isEmpty || bytes.length > 900 * 1024) {
      throw StateError('Lütfen 900 KB altındaki bir fotoğraf seç.');
    }
    await UserProfileAvatarController.setAvatar(
      'data:image/jpeg;base64,${base64Encode(bytes)}',
    );
    if (context.mounted) Navigator.pop(context);
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil fotoğrafı seçilemedi: $error')),
      );
    }
  }
}

Future<void> _showAvatarPickerModal(BuildContext context) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textPrimary = AppColors.textPrimaryOf(context);
  final textSecondary = AppColors.textSecondaryOf(context);

  final presets = const [
    (
      '🌲',
      'Orman Kaşifi',
      'https://images.unsplash.com/photo-1511497584788-87676104235f?w=300'
    ),
    (
      '⛰️',
      'Zirve Dağcısı',
      'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=300'
    ),
    (
      '⛺',
      'Kamp Sever',
      'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=300'
    ),
    (
      '🦅',
      'Kuş Gözlemcisi',
      'https://images.unsplash.com/photo-1444464666168-49d633b86797?w=300'
    ),
    (
      '🌊',
      'Su Gezgini',
      'https://images.unsplash.com/photo-1432405972618-c60b0225b8f9?w=300'
    ),
    (
      '🚙',
      'Rota & Karavan',
      'https://images.unsplash.com/photo-1523987355523-c7b5b0dd90a7?w=300'
    ),
  ];

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? AppColors.darkSurfaceDeep : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.hero)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Profil Fotoğrafı Seç',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: AppFontSizes.heading,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Doğa avatarlarından birini seç veya kameranı ve fotoğraflarını kullan.',
            style: TextStyle(
              fontSize: AppFontSizes.caption,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Doğa Avatarları',
            style: TextStyle(
              fontSize: AppFontSizes.label,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: presets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                final preset = presets[index];
                return GestureDetector(
                  onTap: () async {
                    await UserProfileAvatarController.setAvatar(preset.$3);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(preset.$3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        preset.$1,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: AppSecondaryButton(
                  label: 'Kamerayı aç',
                  leading: const Icon(Icons.photo_camera_outlined, size: 18),
                  onPressed: () => _pickProfileAvatar(ctx, ImageSource.camera),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppPrimaryButton(
                  label: 'Fotoğraflardan seç',
                  leading: const Icon(Icons.photo_library_outlined, size: 18),
                  onPressed: () => _pickProfileAvatar(ctx, ImageSource.gallery),
                ),
              ),
            ],
          ),
          if (UserProfileAvatarController.avatarNotifier.value != null) ...[
            const SizedBox(height: 14),
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  await UserProfileAvatarController.setAvatar(null);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Varsayılan Baş Harfe Dön'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textTertiaryOf(ctx),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

Future<void> _showSocialAccountsModal(BuildContext context) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textPrimary = AppColors.textPrimaryOf(context);
  final textSecondary = AppColors.textSecondaryOf(context);

  final currentAccounts = UserSocialAccountsController.accounts.value;
  final instagramController =
      TextEditingController(text: currentAccounts.instagram);
  final facebookController =
      TextEditingController(text: currentAccounts.facebook);
  final youtubeController =
      TextEditingController(text: currentAccounts.youtube);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? AppColors.darkSurfaceDeep : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.hero)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.get('profile_social_title'),
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: AppFontSizes.heading,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.get('profile_social_description'),
            style: TextStyle(
              fontSize: AppFontSizes.caption,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: instagramController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFFE1306C),
              ),
              labelText: 'Instagram',
              hintText: AppStrings.get('profile_social_instagram_hint'),
              filled: true,
              fillColor:
                  isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.medium),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: facebookController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.facebook,
                color: Color(0xFF1877F2),
              ),
              labelText: 'Facebook',
              hintText: AppStrings.get('profile_social_handle_or_link'),
              filled: true,
              fillColor:
                  isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.medium),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: youtubeController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.smart_display_rounded,
                color: Color(0xFFFF0000),
              ),
              labelText: 'YouTube',
              hintText: AppStrings.get('profile_social_youtube_hint'),
              filled: true,
              fillColor:
                  isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.medium),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
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
                await UserSocialAccountsController.save(
                  instagram: instagramController.text,
                  facebook: facebookController.text,
                  youtube: youtubeController.text,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppStrings.get('profile_social_saved')),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check, size: 18),
              label: Text(
                AppStrings.get('general_save'),
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Uri? _resolveSocialUri(String platform, String raw) =>
    UserSocialAccounts.resolveUri(platform, raw);

Future<void> _openSocialLink(
    BuildContext context, String platform, String raw) async {
  final uri = _resolveSocialUri(platform, raw);
  if (uri != null && isSafeExternalUrl(uri)) {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('profile_social_open_failed'))),
      );
    }
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.get('profile_social_invalid_link'))),
    );
  }
}

class _SocialIconBadge extends StatelessWidget {
  const _SocialIconBadge({
    required this.icon,
    required this.color,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    Widget child = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
    if (tooltip != null) {
      child = Tooltip(message: tooltip!, child: child);
    }
    return child;
  }
}

class _SocialChip extends StatelessWidget {
  const _SocialChip({
    required this.icon,
    required this.label,
    required this.url,
    required this.color,
    this.platform = '',
  });

  final IconData icon;
  final String label;
  final String url;
  final Color color;
  final String platform;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          _openSocialLink(context, platform.isEmpty ? label : platform, url),
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: AppFontSizes.caption,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PublicUserProfileScreen extends StatelessWidget {
  const PublicUserProfileScreen({
    super.key,
    required this.authorName,
    this.authorId = '',
    this.avatarUrl,
  });

  final String authorName;
  final String authorId;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);

    final cleanName =
        authorName.trim().isNotEmpty ? authorName.trim() : 'Doğa Kaşifi';
    final initial =
        cleanName.isNotEmpty ? cleanName.characters.first.toUpperCase() : 'D';

    final authorPhotos =
        CommunityPlacePhotosController.byAuthor(cleanName, authorId: authorId);
    final authorPlaces = [
      ...UserPlacesController.places.value,
      ...SupabasePlacesController.places.value,
    ].where((p) {
      return p.source == PlaceSource.user &&
          (p.description.toLowerCase().contains(cleanName.toLowerCase()) ||
              (authorId.isNotEmpty && p.sourceId?.contains(authorId) == true));
    }).toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Topluluk Profili',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
            fontSize: AppFontSizes.title,
            color: textPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        children: [
          // 1. Profil Bilgi Kartı
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
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: isDark
                      ? AppColors.darkPrimarySoft
                      : AppColors.primarySoft,
                  backgroundImage:
                      (avatarUrl != null && avatarUrl!.startsWith('http'))
                          ? NetworkImage(avatarUrl!)
                          : null,
                  child: (avatarUrl != null && avatarUrl!.startsWith('http'))
                      ? null
                      : Text(
                          initial,
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
                    children: [
                      Text(
                        cleanName,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: AppFontSizes.title,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkPrimarySoft
                              : AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Text(
                          'Doğa Kaşifi',
                          style: TextStyle(
                            fontSize: AppFontSizes.caption,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkPrimaryLight
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${authorPhotos.length} fotoğraf katkısı · ${authorPlaces.length} yer katkısı',
                        style: TextStyle(
                          fontSize: AppFontSizes.caption,
                          color: textSecondary,
                        ),
                      ),
                      ValueListenableBuilder<UserSocialAccounts>(
                        valueListenable: UserSocialAccountsController.accounts,
                        builder: (context, accounts, _) {
                          String currentUserId = '';
                          String currentUserName = '';
                          try {
                            final u = Supabase.instance.client.auth.currentUser;
                            currentUserId = u?.id ?? '';
                            currentUserName =
                                (u?.userMetadata?['full_name'] as String?) ??
                                    '';
                          } catch (_) {}
                          final isCurrentUser = (authorId.isNotEmpty &&
                                  authorId == currentUserId) ||
                              (currentUserName.isNotEmpty &&
                                  authorName == currentUserName);
                          if (!isCurrentUser && accounts.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          if (accounts.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (accounts.instagram.isNotEmpty)
                                  _SocialChip(
                                    icon: Icons.camera_alt_outlined,
                                    label: accounts.instagram.startsWith('@')
                                        ? accounts.instagram
                                        : '@${accounts.instagram.split('/').last}',
                                    url: accounts.instagram,
                                    platform: 'instagram',
                                    color: const Color(0xFFE1306C),
                                  ),
                                if (accounts.facebook.isNotEmpty)
                                  _SocialChip(
                                    icon: Icons.facebook,
                                    label: accounts.facebook.contains('/')
                                        ? accounts.facebook.split('/').last
                                        : accounts.facebook,
                                    url: accounts.facebook,
                                    platform: 'facebook',
                                    color: const Color(0xFF1877F2),
                                  ),
                                if (accounts.youtube.isNotEmpty)
                                  _SocialChip(
                                    icon: Icons.smart_display_rounded,
                                    label: accounts.youtube.startsWith('@')
                                        ? accounts.youtube
                                        : accounts.youtube.split('/').last,
                                    url: accounts.youtube,
                                    platform: 'youtube',
                                    color: const Color(0xFFFF0000),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Katkı Yaptığı Fotoğraflar Bölümü
          Row(
            children: [
              const Icon(Icons.photo_library_outlined,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Fotoğraf Katkıları (${authorPhotos.length})',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: AppFontSizes.title,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (authorPhotos.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.medium),
                border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border),
              ),
              child: Center(
                child: Text(
                  'Henüz paylaştığı bir fotoğraf bulunmuyor.',
                  style: TextStyle(color: textSecondary),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: authorPhotos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (ctx, i) {
                final photo = authorPhotos[i];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        photo.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.surfaceMuted,
                          child: const Icon(Icons.broken_image_rounded,
                              color: AppColors.textTertiary),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.75)
                              ],
                            ),
                          ),
                          child: Text(
                            photo.placeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: AppFontSizes.caption,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 28),

          // 3. Eklediği Yerler Bölümü
          Row(
            children: [
              const Icon(Icons.place_outlined,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Eklediği Doğa Mekanları (${authorPlaces.length})',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: AppFontSizes.title,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (authorPlaces.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.medium),
                border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border),
              ),
              child: Center(
                child: Text(
                  'Henüz yer eklemedi.',
                  style: TextStyle(color: textSecondary),
                ),
              ),
            )
          else
            ...authorPlaces.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCompactPlaceCard(
                  place: p,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(
                        place: p,
                        favorite: false,
                        onFavorite: () {},
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
}
