part of '../../main.dart';

class GoodnessMovementScreen extends StatefulWidget {
  const GoodnessMovementScreen({super.key});

  @override
  State<GoodnessMovementScreen> createState() => _GoodnessMovementScreenState();
}

class _GoodnessMovementScreenState extends State<GoodnessMovementScreen> {
  final List<_GoodDeed> _deeds = <_GoodDeed>[];

  Map<String, List<_GoodDeed>> get _deedsByProvince {
    final grouped = <String, List<_GoodDeed>>{};
    for (final deed in _deeds) {
      grouped.putIfAbsent(deed.province, () => <_GoodDeed>[]).add(deed);
    }
    return grouped;
  }

  Future<void> _openAddDeed() async {
    String? province;
    String type = _deedTypes.first;
    final noteController = TextEditingController();
    final result = await showModalBottomSheet<_GoodDeed>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Yaptığın iyiliği ekle',
                    style: AppTypography.heading.copyWith(fontSize: 22)),
                const SizedBox(height: 6),
                Text(
                  'Katkın seçtiğin ilde sayılır. Konum ve kanıt sistemi tasarım onayından sonra bağlanacak.',
                  style: AppTypography.metadata.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  initialValue: province,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'İl',
                    border: OutlineInputBorder(),
                  ),
                  items: _provinceCenters.keys
                      .map((name) => DropdownMenuItem(
                            value: name,
                            child: Text(name),
                          ))
                      .toList(),
                  onChanged: (value) => setSheetState(() => province = value),
                ),
                const SizedBox(height: 16),
                Text('İyilik türü',
                    style: AppTypography.heading.copyWith(fontSize: 15)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _deedTypes
                      .map((item) => ChoiceChip(
                            label: Text(item),
                            selected: type == item,
                            onSelected: (_) => setSheetState(() => type = item),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  maxLength: 140,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Kısa not (isteğe bağlı)',
                    hintText: 'Örn. Sahil yolundaki iki torba çöpü topladım.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: province == null
                      ? null
                      : () => Navigator.pop(
                            sheetContext,
                            _GoodDeed(
                              province: province!,
                              type: type,
                              note: noteController.text.trim(),
                              createdAt: DateTime.now(),
                            ),
                          ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('İyiliği Ekle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    noteController.dispose();
    if (result == null || !mounted) return;
    setState(() => _deeds.add(result));
  }

  void _showProvince(String province, List<_GoodDeed> deeds) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$province · ${deeds.length} iyilik',
                  style: AppTypography.heading.copyWith(fontSize: 21)),
              const SizedBox(height: 14),
              ...deeds.reversed.map(
                (deed) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primarySoft,
                    child: Text(_deedEmoji(deed.type)),
                  ),
                  title: Text(deed.type,
                      style: AppTypography.body
                          .copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    deed.note.isEmpty ? 'Az önce eklendi' : deed.note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: TextButton(
                    onPressed: () => _openContributorPreview(),
                    child: const Text('Sen'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openContributorPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _GoodnessContributorPreview(deeds: _deeds),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _deedsByProvince;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('İyilik Harekâtı',
                          style: AppTypography.heading.copyWith(fontSize: 27)),
                      const SizedBox(height: 3),
                      Text('İyilik yap, kendini göster.',
                          style: AppTypography.metadata.copyWith(fontSize: 15)),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: _openAddDeed,
                  icon: const Icon(Icons.add_rounded, size: 19),
                  label: const Text('Ekle'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.visibility_outlined,
                      color: AppColors.primary, size: 19),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Tasarım önizlemesi · Eklediklerin bu oturumda görünür.',
                      style: TextStyle(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _TurkeyProvinceBoard(
              deedsByProvince: grouped,
              onProvinceTap: _showProvince,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                    child: _GoodnessStat('${_deeds.length}', 'Toplam iyilik')),
                const SizedBox(width: 10),
                Expanded(
                    child:
                        _GoodnessStat('${grouped.length}', 'Katkı sunulan il')),
              ],
            ),
            const SizedBox(height: 20),
            Text('Nasıl işler?',
                style: AppTypography.heading.copyWith(fontSize: 20)),
            const SizedBox(height: 10),
            const _GoodnessStep(
              icon: Icons.add_location_alt_outlined,
              title: 'Yaptığın iyiliği ve ili seç',
              body:
                  'Fotoğraf, yaklaşık konum ve tarih sonraki aşamada kanıt olarak kullanılacak.',
            ),
            const _GoodnessStep(
              icon: Icons.verified_user_outlined,
              title: 'Topluluk doğrulasın',
              body:
                  'Aynı kaydı tekrar kullanma ve sahte katkılar moderasyonla engellenecek.',
            ),
            const _GoodnessStep(
              icon: Icons.public_rounded,
              title: 'İlin katkısı büyüsün',
              body:
                  'İl işaretine dokunanlar katkıları ve herkese açık profilleri görebilecek.',
            ),
          ],
        ),
      ),
    );
  }
}

class _TurkeyProvinceBoard extends StatefulWidget {
  const _TurkeyProvinceBoard({
    required this.deedsByProvince,
    required this.onProvinceTap,
  });

  final Map<String, List<_GoodDeed>> deedsByProvince;
  final void Function(String province, List<_GoodDeed> deeds) onProvinceTap;

  @override
  State<_TurkeyProvinceBoard> createState() => _TurkeyProvinceBoardState();
}

class _TurkeyProvinceBoardState extends State<_TurkeyProvinceBoard> {
  late final TransformationController _controller = TransformationController(
    Matrix4.diagonal3Values(.41, .41, 1),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F4),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _controller,
              constrained: false,
              minScale: .32,
              maxScale: 2.4,
              boundaryMargin: const EdgeInsets.all(120),
              child: SizedBox(
                width: 1020,
                height: 565,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/maps/turkiye_provinces_paintmaps.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    ...widget.deedsByProvince.entries.map((entry) {
                      final point = _provinceCenters[entry.key]!;
                      final position = _provinceBoardPosition(point);
                      return Positioned(
                        left: position.dx - 24,
                        top: position.dy - 24,
                        child: GestureDetector(
                          onTap: () =>
                              widget.onProvinceTap(entry.key, entry.value),
                          child: Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x44000000),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              '+${entry.value.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
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
          ),
          Positioned(
            left: 10,
            top: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .94),
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Text(
                '81 İl · Yakınlaştırmak için dokun',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (widget.deedsByProvince.isEmpty)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .96),
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Text(
                  'İlk iyiliği sen ekle; katkı yaptığın il renklensin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Offset _provinceBoardPosition(LatLng point) {
  const leftLongitude = 25.5;
  const rightLongitude = 45.5;
  const topLatitude = 42.3;
  const bottomLatitude = 35.7;
  const boardWidth = 1020.0;
  const mapHeight = 520.0;
  final x = (point.longitude - leftLongitude) /
      (rightLongitude - leftLongitude) *
      boardWidth;
  final y = (topLatitude - point.latitude) /
      (topLatitude - bottomLatitude) *
      mapHeight;
  return Offset(x.clamp(20, boardWidth - 20), y.clamp(20, mapHeight - 20));
}

class _GoodnessStat extends StatelessWidget {
  const _GoodnessStat(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: AppTypography.heading
                    .copyWith(fontSize: 24, color: AppColors.primary)),
            Text(label, style: AppTypography.metadata.copyWith(fontSize: 12.5)),
          ],
        ),
      );
}

class _GoodnessStep extends StatelessWidget {
  const _GoodnessStep({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.body
                          .copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(body,
                      style: AppTypography.metadata
                          .copyWith(fontSize: 13, height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _GoodnessContributorPreview extends StatelessWidget {
  const _GoodnessContributorPreview({required this.deeds});
  final List<_GoodDeed> deeds;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Katkı profili')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.primary,
              child: Text('S',
                  style: TextStyle(color: Colors.white, fontSize: 26)),
            ),
            const SizedBox(height: 12),
            Text('Sen',
                textAlign: TextAlign.center,
                style: AppTypography.heading.copyWith(fontSize: 24)),
            const SizedBox(height: 5),
            Text('${deeds.length} iyilik katkısı',
                textAlign: TextAlign.center, style: AppTypography.metadata),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Bu bir profil önizlemesidir. Gerçek kullanıcı profilleri hesap ve Supabase sistemi bağlandığında açılacak.',
              ),
            ),
          ],
        ),
      );
}

class _GoodDeed {
  const _GoodDeed({
    required this.province,
    required this.type,
    required this.note,
    required this.createdAt,
  });

  final String province;
  final String type;
  final String note;
  final DateTime createdAt;
}

String _deedEmoji(String type) => switch (type) {
      'Çöp Topladım' => '🧹',
      'Fidan Diktim' => '🌱',
      'Sokak Hayvanlarına Mama Verdim' => '🐾',
      'Su Kabı Bıraktım' => '💧',
      _ => '♻️',
    };

const _deedTypes = <String>[
  'Çöp Topladım',
  'Fidan Diktim',
  'Sokak Hayvanlarına Mama Verdim',
  'Su Kabı Bıraktım',
  'Geri Dönüşüme Götürdüm',
];

const _provinceCenters = <String, LatLng>{
  'Adana': LatLng(37.00, 35.32),
  'Adıyaman': LatLng(37.76, 38.28),
  'Afyonkarahisar': LatLng(38.75, 30.54),
  'Ağrı': LatLng(39.72, 43.05),
  'Aksaray': LatLng(38.37, 34.03),
  'Amasya': LatLng(40.65, 35.83),
  'Ankara': LatLng(39.93, 32.85),
  'Antalya': LatLng(36.90, 30.70),
  'Ardahan': LatLng(41.11, 42.70),
  'Artvin': LatLng(41.18, 41.82),
  'Aydın': LatLng(37.84, 27.84),
  'Balıkesir': LatLng(39.65, 27.88),
  'Bartın': LatLng(41.64, 32.34),
  'Batman': LatLng(37.88, 41.13),
  'Bayburt': LatLng(40.26, 40.23),
  'Bilecik': LatLng(40.15, 29.98),
  'Bingöl': LatLng(38.89, 40.50),
  'Bitlis': LatLng(38.40, 42.11),
  'Bolu': LatLng(40.74, 31.61),
  'Burdur': LatLng(37.72, 30.29),
  'Bursa': LatLng(40.19, 29.06),
  'Çanakkale': LatLng(40.15, 26.41),
  'Çankırı': LatLng(40.60, 33.62),
  'Çorum': LatLng(40.55, 34.95),
  'Denizli': LatLng(37.78, 29.09),
  'Diyarbakır': LatLng(37.91, 40.24),
  'Düzce': LatLng(40.84, 31.16),
  'Edirne': LatLng(41.68, 26.56),
  'Elazığ': LatLng(38.68, 39.23),
  'Erzincan': LatLng(39.75, 39.49),
  'Erzurum': LatLng(39.90, 41.27),
  'Eskişehir': LatLng(39.77, 30.52),
  'Gaziantep': LatLng(37.07, 37.38),
  'Giresun': LatLng(40.91, 38.39),
  'Gümüşhane': LatLng(40.46, 39.48),
  'Hakkâri': LatLng(37.58, 43.74),
  'Hatay': LatLng(36.20, 36.16),
  'Iğdır': LatLng(39.92, 44.05),
  'Isparta': LatLng(37.76, 30.55),
  'İstanbul': LatLng(41.01, 28.98),
  'İzmir': LatLng(38.42, 27.14),
  'Kahramanmaraş': LatLng(37.58, 36.93),
  'Karabük': LatLng(41.20, 32.63),
  'Karaman': LatLng(37.18, 33.22),
  'Kars': LatLng(40.60, 43.10),
  'Kastamonu': LatLng(41.39, 33.78),
  'Kayseri': LatLng(38.72, 35.49),
  'Kırıkkale': LatLng(39.85, 33.51),
  'Kırklareli': LatLng(41.73, 27.22),
  'Kırşehir': LatLng(39.15, 34.16),
  'Kilis': LatLng(36.72, 37.12),
  'Kocaeli': LatLng(40.77, 29.94),
  'Konya': LatLng(37.87, 32.49),
  'Kütahya': LatLng(39.42, 29.98),
  'Malatya': LatLng(38.36, 38.31),
  'Manisa': LatLng(38.62, 27.43),
  'Mardin': LatLng(37.31, 40.74),
  'Mersin': LatLng(36.81, 34.64),
  'Muğla': LatLng(37.22, 28.36),
  'Muş': LatLng(38.74, 41.49),
  'Nevşehir': LatLng(38.62, 34.71),
  'Niğde': LatLng(37.97, 34.68),
  'Ordu': LatLng(40.98, 37.88),
  'Osmaniye': LatLng(37.07, 36.25),
  'Rize': LatLng(41.02, 40.52),
  'Sakarya': LatLng(40.77, 30.40),
  'Samsun': LatLng(41.29, 36.33),
  'Siirt': LatLng(37.93, 41.94),
  'Sinop': LatLng(42.03, 35.15),
  'Sivas': LatLng(39.75, 37.02),
  'Şanlıurfa': LatLng(37.17, 38.79),
  'Şırnak': LatLng(37.52, 42.46),
  'Tekirdağ': LatLng(40.98, 27.52),
  'Tokat': LatLng(40.31, 36.55),
  'Trabzon': LatLng(41.00, 39.72),
  'Tunceli': LatLng(39.11, 39.55),
  'Uşak': LatLng(38.67, 29.41),
  'Van': LatLng(38.50, 43.38),
  'Yalova': LatLng(40.66, 29.27),
  'Yozgat': LatLng(39.82, 34.81),
  'Zonguldak': LatLng(41.45, 31.79),
};
