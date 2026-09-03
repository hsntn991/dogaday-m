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
  int tab = 0;
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.only(bottom: 110), children: [
        Container(
            height: 180,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  Color(0xFF0F2006),
                  Color(0xFF1B3A0A),
                  Color(0xFF3A6B1E)
                ])),
            child: const Stack(children: [
              Positioned(
                  right: 16,
                  top: 24,
                  child: CircleAvatar(
                      backgroundColor: Colors.white12,
                      child: Icon(Icons.settings_outlined,
                          color: Colors.white, size: 18)))
            ])),
        Transform.translate(
            offset: const Offset(0, -40),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [
                                      Color(0xFF4E8C2A),
                                      Color(0xFF1B3A0A)
                                    ]),
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.large),
                                    border: Border.all(color: sand, width: 4),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color(0x441C380A),
                                          blurRadius: 20)
                                    ]),
                                alignment: Alignment.center,
                                child: const Text('M',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 31,
                                        fontWeight: FontWeight.w700))),
                            const Spacer(),
                            OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(
                                        color: Color(0x221C380A)),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppRadii.large))),
                                child: const Text('Profili Düzenle',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: green,
                                        fontWeight: FontWeight.w600)))
                          ]),
                      const SizedBox(height: 13),
                      const Text('Misafir kullanıcı',
                          style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 22,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 3),
                      const Text('Bağlı bir hesap bulunmuyor',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF8A8680))),
                      const SizedBox(height: 8),
                      const Text(
                          'Eklediğin gerçek doğa noktaları burada görünür.',
                          style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: Color(0xFF5A5650))),
                      const SizedBox(height: 15),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(AppRadii.large),
                              border:
                                  Border.all(color: const Color(0x141C380A))),
                          child: Row(children: [
                            _ProfileStat(
                                '${UserPlacesController.places.value.length}',
                                'Eklenen Yer')
                          ])),
                      const SizedBox(height: 20),
                      const Text('Rozetler',
                          style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 11),
                      const Text('Henüz kazanılmış bir rozet yok.',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 20),
                      Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(AppRadii.large)),
                          child: Row(
                              children: ['Yerlerim', 'Yorumlarım', 'Ziyaretler']
                                  .asMap()
                                  .entries
                                  .map((e) => Expanded(
                                      child: _SegmentButton(
                                          label: e.value,
                                          active: tab == e.key,
                                          onTap: () =>
                                              setState(() => tab = e.key))))
                                  .toList())),
                      const SizedBox(height: 14),
                      if (tab == 0 &&
                          UserPlacesController.places.value.isNotEmpty)
                        GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: UserPlacesController.places.value.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1.08,
                                    crossAxisSpacing: 11,
                                    mainAxisSpacing: 11),
                            itemBuilder: (_, i) => Stack(
                                  children: [
                                    Positioned.fill(
                                      child: _SmallPhotoCard(
                                          place: UserPlacesController
                                              .places.value[i],
                                          onTap: () => widget.onOpen(
                                              UserPlacesController
                                                  .places.value[i])),
                                    ),
                                    const Positioned(
                                      left: 7,
                                      top: 7,
                                      child: _PendingApprovalBadge(),
                                    ),
                                  ],
                                ))
                      else if (tab == 0)
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text('Henüz eklediğin bir yer yok.',
                                style:
                                    TextStyle(color: AppColors.textSecondary)))
                      else
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                                'Bu bölümde henüz gerçek bir kayıt yok.',
                                style:
                                    TextStyle(color: AppColors.textSecondary))),
                      const SizedBox(height: 26),
                      const Text('Ayarlar',
                          style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: AppThemeController.mode,
                        builder: (context, mode, _) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius:
                                  BorderRadius.circular(AppRadii.large),
                            ),
                            child: Icon(
                              mode == ThemeMode.dark
                                  ? Icons.dark_mode_outlined
                                  : Icons.light_mode_outlined,
                              size: 17,
                              color: green,
                            ),
                          ),
                          title: const Text(
                            'Görünüm',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            mode == ThemeMode.dark ? 'Gece' : 'Gündüz',
                            style: const TextStyle(fontSize: 10),
                          ),
                          trailing: Switch(
                            value: mode == ThemeMode.dark,
                            onChanged: AppThemeController.setDark,
                          ),
                        ),
                      ),
                      ...[
                        (Icons.notifications_none_rounded, 'Bildirimler'),
                        (Icons.language_rounded, 'Dil ve Bölge'),
                        (Icons.lock_outline_rounded, 'Gizlilik'),
                        (Icons.help_outline_rounded, 'Yardım'),
                        (Icons.phone_android_rounded, 'Uygulama Hakkında')
                      ].map((e) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.large)),
                              child: Icon(e.$1, size: 17, color: green)),
                          title: Text(e.$2,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                          trailing: const Icon(Icons.chevron_right_rounded,
                              size: 16, color: Color(0xFF8A8680)))),
                      const SizedBox(height: 10),
                      SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                              onPressed: () async {
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
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFC4622D),
                                  side: const BorderSide(
                                      color: Color(0x55C4622D)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppRadii.large))),
                              child: const Text('Çıkış Yap'))),
                    ]))),
      ]);
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat(this.value, this.label);
  final String value, label;
  @override
  Widget build(BuildContext context) => Expanded(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 3),
          child: Column(children: [
            Text(value,
                style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: green,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 7.5, color: Color(0xFF8A8680)))
          ])));
}
