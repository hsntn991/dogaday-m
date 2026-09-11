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
  Widget build(BuildContext context) => SafeArea(
          child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 110),
              children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Favorilerim',
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            color: green,
                            fontSize: 28,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 3),
                    Text('${widget.items.length} yer kaydedildi',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF8A8680)))
                  ])),
              Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadii.large),
                      border: Border.all(color: const Color(0x141C380A))),
                  child: Row(children: [
                    IconButton(
                        onPressed: () => setState(() => grid = true),
                        icon: Icon(Icons.grid_view_rounded,
                            size: 17,
                            color: grid ? green : const Color(0xFF8A8680))),
                    IconButton(
                        onPressed: () => setState(() => grid = false),
                        icon: Icon(Icons.view_list_rounded,
                            size: 18,
                            color: !grid ? green : const Color(0xFF8A8680)))
                  ])),
            ]),
            const SizedBox(height: 20),
            Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.large),
                    border: Border.all(color: const Color(0x141C380A))),
                child: Row(children: [
                  Expanded(
                      child: _SegmentButton(
                          label: 'Kaydedilenler (${widget.items.length})',
                          active: !collections,
                          onTap: () => setState(() => collections = false))),
                  Expanded(
                      child: _SegmentButton(
                          label: 'Koleksiyonlar',
                          active: collections,
                          onTap: () => setState(() => collections = true))),
                ])),
            const SizedBox(height: 18),
            if (collections) ...[
              Container(
                  height: 70,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadii.large),
                      border: Border.all(color: const Color(0x221C380A))),
                  child: const Row(children: [
                    SquareAdd(),
                    SizedBox(width: 12),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Yeni Koleksiyon',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('Yerlerini kategorize et',
                              style: TextStyle(
                                  color: Color(0xFF8A8680), fontSize: 10))
                        ])
                  ])),
              const SizedBox(height: 24),
              const Center(
                  child: Text('Henüz oluşturulmuş bir koleksiyon yok.',
                      style: TextStyle(color: AppColors.textSecondary))),
            ] else if (widget.items.isEmpty)
              const Padding(
                  padding: EdgeInsets.only(top: 70),
                  child: Column(children: [
                    Icon(Icons.eco_rounded, size: 55, color: Color(0xFF92C96C)),
                    SizedBox(height: 16),
                    Text('Henüz Kaydedilen Yer Yok',
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 20,
                            fontWeight: FontWeight.w500)),
                    SizedBox(height: 7),
                    Text('Beğendiğin yerleri kaydet, her zaman bulabilirsin.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Color(0xFF8A8680), fontSize: 13))
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
                  child: CompactPlaceCard(
                      place: p, onTap: () => widget.onOpen(p)))),
          ]));
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
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : const Color(0xFF8A8680)))));
}

class SquareAdd extends StatelessWidget {
  const SquareAdd({super.key});
  @override
  Widget build(BuildContext context) => Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
          color: sand,
          borderRadius: BorderRadius.circular(AppRadii.large),
          border: Border.all(color: const Color(0x221C380A))),
      child: const Icon(Icons.add_rounded, color: Color(0xFF4E8C2A)));
}

class _FavoriteGridCard extends StatelessWidget {
  const _FavoriteGridCard({required this.place, required this.onTap});
  final Place place;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.large),
              boxShadow: const [
                BoxShadow(color: Color(0x12000000), blurRadius: 10)
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
                          color: Color(0xFFC4622D), size: 15)))
            ])),
            Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Text(place.location,
                            style: const TextStyle(
                                fontSize: 9, color: Color(0xFF8A8680))),
                        const Spacer(),
                        const Icon(Icons.star_rounded,
                            size: 11, color: Color(0xFFF59E0B)),
                        Text('${place.rating}',
                            style: const TextStyle(
                                fontSize: 9, fontWeight: FontWeight.w700))
                      ])
                    ]))
          ])));
}

class _PendingApprovalBadge extends StatelessWidget {
  const _PendingApprovalBadge();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1D6),
          border: Border.all(color: const Color(0xFFE7B45D)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule_rounded, size: 12, color: Color(0xFF8B5D13)),
            SizedBox(width: 4),
            Text(
              'Onay bekliyor',
              style: TextStyle(
                color: Color(0xFF8B5D13),
                fontSize: 9.5,
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
                      fontSize: 13,
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

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata;
    final fullName = (metadata?['full_name']?.toString() ??
            metadata?['name']?.toString() ??
            metadata?['display_name']?.toString() ??
            '')
        .trim();
    final email = user?.email?.trim() ?? '';
    final displayName = fullName.isNotEmpty
        ? fullName
        : (email.isNotEmpty ? email : 'Doğadayım Kullanıcısı');
    final subtitle = fullName.isNotEmpty && email.isNotEmpty ? email : null;
    final avatarInitial = displayName.isNotEmpty
        ? displayName.characters.first.toUpperCase()
        : 'D';
    final avatarUrl = metadata?['avatar_url']?.toString() ??
        metadata?['picture']?.toString();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? const Color(0xFFF1F5F2) : AppColors.textPrimary;
    final textSecondary =
        isDark ? const Color(0xFFAAB4AD) : AppColors.textSecondary;
    final dividerColor =
        isDark ? const Color(0xFF263029) : const Color(0xFFEEEEEE);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
        children: [
          // 1. ÜST BAR: Sol "Profil"
          Text(
            'Profil',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 18),

          // 2. KULLANICI PROFİL ALANI (CircleAvatar + Ad + Doğa Kaşifi + Katkı Sayısı)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor:
                    isDark ? const Color(0xFF1E2D23) : AppColors.primarySoft,
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
                          fontSize: 24,
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
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Doğa Kaşifi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFF8FD8A8)
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ValueListenableBuilder<List<Place>>(
                      valueListenable: UserPlacesController.places,
                      builder: (context, places, _) => Text(
                        '${places.length} katkı',
                        style: TextStyle(
                          fontSize: 12,
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
                          fontSize: 11.5,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. KATKILARIM BAŞLIĞI (Doğrudan kullanıcı alanından 20px sonra)
          Text(
            'Katkılarım',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 17,
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
                                ? const Color(0xFF1E231F)
                                : const Color(0xFFEAEAEA),
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
                                          ? const Color(0xFF151C18)
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x22000000),
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
                      'Henüz yer eklemediniz',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Doğada keşfettiğin yerleri toplulukla paylaş.',
                      style: TextStyle(
                        fontSize: 12,
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
                        label: const Text('İlk Yerini Ekle'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadii.small),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16),
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
                      'Görünüm',
                      style: TextStyle(
                        fontSize: 14.5,
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
                      'Gizlilik Politikası',
                      style: TextStyle(
                        fontSize: 14.5,
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
              Navigator.of(context, rootNavigator: true)
                  .pushAndRemoveUntil(
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
                      'Çıkış Yap',
                      style: TextStyle(
                        fontSize: 14.5,
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
              onPressed:
                  _isDeletingAccount ? null : _handleDeleteAccount,
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 15,
                color: AppColors.error,
              ),
              label: const Text(
                'Hesabımı Sil',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 6),
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

