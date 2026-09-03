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
                            fontFamily: 'Fraunces',
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
                      borderRadius: BorderRadius.circular(12),
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
                    borderRadius: BorderRadius.circular(14),
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
                      borderRadius: BorderRadius.circular(18),
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
              const SizedBox(height: 12),
              ...['Şelaleler', 'Kamp Alanları', 'Su Kaynakları', 'Yürüyüş']
                  .asMap()
                  .entries
                  .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CollectionRow(
                          title: e.value,
                          place: places[e.key % places.length]))),
            ] else if (widget.items.isEmpty)
              const Padding(
                  padding: EdgeInsets.only(top: 70),
                  child: Column(children: [
                    Icon(Icons.eco_rounded, size: 55, color: Color(0xFF92C96C)),
                    SizedBox(height: 16),
                    Text('Henüz Kaydedilen Yer Yok',
                        style: TextStyle(
                            fontFamily: 'Fraunces',
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
              borderRadius: BorderRadius.circular(10)),
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
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0x221C380A))),
      child: const Icon(Icons.add_rounded, color: Color(0xFF4E8C2A)));
}

class _CollectionRow extends StatelessWidget {
  const _CollectionRow({required this.title, required this.place});
  final String title;
  final Place place;
  @override
  Widget build(BuildContext context) => Container(
      height: 76,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: const [
            BoxShadow(color: Color(0x10000000), blurRadius: 8)
          ]),
      child: Row(children: [
        SizedBox(width: 58, child: NatureArt(place: place, radius: 13)),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 3),
              const Text('4 yer',
                  style: TextStyle(fontSize: 10, color: Color(0xFF8A8680)))
            ])),
        const Icon(Icons.chevron_right_rounded, size: 18, color: green)
      ]));
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
              borderRadius: BorderRadius.circular(18),
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
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: sand, width: 4),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color(0x441C380A),
                                          blurRadius: 20)
                                    ]),
                                alignment: Alignment.center,
                                child: const Text('K',
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
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                child: const Text('Profili Düzenle',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: green,
                                        fontWeight: FontWeight.w600)))
                          ]),
                      const SizedBox(height: 13),
                      const Text('Kerem Aydın',
                          style: TextStyle(
                              fontFamily: 'Fraunces',
                              fontSize: 22,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 3),
                      const Text('@kerem_dogaci · Antalya, Türkiye 🇹🇷',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF8A8680))),
                      const SizedBox(height: 8),
                      const Text(
                          "Doğa kaşifi ve fotoğrafçı. Türkiye'nin gizli cennetlerini keşfediyorum. 🌿",
                          style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: Color(0xFF5A5650))),
                      const SizedBox(height: 15),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border:
                                  Border.all(color: const Color(0x141C380A))),
                          child: const Row(children: [
                            _ProfileStat('24', 'Eklenen Yer'),
                            _ProfileStat('148', 'Değerlendirme'),
                            _ProfileStat('1.2B', 'Görüntülenme'),
                            _ProfileStat('340', 'Takipçi')
                          ])),
                      const SizedBox(height: 20),
                      const Text('Rozetler',
                          style: TextStyle(
                              fontFamily: 'Fraunces',
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 11),
                      SizedBox(
                          height: 74,
                          child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: const [
                                _Badge(Icons.emoji_events_rounded, 'İlk Yer',
                                    Color(0xFFC4622D)),
                                _Badge(Icons.water_drop_rounded, 'Su Avcısı',
                                    Color(0xFF4A8EC4)),
                                _Badge(Icons.explore_rounded, 'Kaşif', green),
                                _Badge(Icons.star_rounded, 'Güvenilir',
                                    Color(0xFFF59E0B)),
                                _Badge(Icons.cabin_rounded, 'Kampçı',
                                    Color(0xFFC4622D))
                              ])),
                      const SizedBox(height: 20),
                      Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14)),
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
                      if (tab == 0)
                        GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 4,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1.08,
                                    crossAxisSpacing: 11,
                                    mainAxisSpacing: 11),
                            itemBuilder: (_, i) => _SmallPhotoCard(
                                place: places[i],
                                onTap: () => widget.onOpen(places[i])))
                      else
                        ...places.take(3).map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 9),
                            child: CompactPlaceCard(
                                place: p, onTap: () => widget.onOpen(p)))),
                      const SizedBox(height: 26),
                      const Text('Ayarlar',
                          style: TextStyle(
                              fontFamily: 'Fraunces',
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
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
                                  borderRadius: BorderRadius.circular(10)),
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
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFC4622D),
                                  side: const BorderSide(
                                      color: Color(0x55C4622D)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14))),
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
                    fontFamily: 'Fraunces',
                    color: green,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 7.5, color: Color(0xFF8A8680)))
          ])));
}

class _Badge extends StatelessWidget {
  const _Badge(this.icon, this.label, this.color);
  final IconData icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
      width: 69,
      margin: const EdgeInsets.only(right: 9),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: Color(0x0E000000), blurRadius: 7)
          ]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 5),
        Text(label,
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600))
      ]));
}
