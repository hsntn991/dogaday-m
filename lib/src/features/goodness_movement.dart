part of '../../main.dart';

class GoodnessCampaignScore {
  const GoodnessCampaignScore._();

  static int pointsFor(String type) => switch (type) {
        'Fidan Diktim' => 15,
        'Çöp Topladım' => 12,
        'Sokak Hayvanlarına Mama Verdim' => 10,
        'Su Kabı Bıraktım' => 10,
        'Geri Dönüşüme Götürdüm' => 12,
        _ => 10,
      };
}

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

  Map<String, _GoodnessProvinceSummary> get _provinceSummaries {
    final summaries = <String, _GoodnessProvinceSummary>{
      for (final province in _provinceCenters.keys)
        province: _GoodnessProvinceSummary.empty(province),
      for (final seed in _goodnessCampaignSeeds)
        seed.province: _GoodnessProvinceSummary.fromSeed(seed),
    };
    for (final entry in _deedsByProvince.entries) {
      final previous =
          summaries[entry.key] ?? _GoodnessProvinceSummary.empty(entry.key);
      summaries[entry.key] = previous.withAddedDeeds(entry.value);
    }
    return summaries;
  }

  Future<void> _openAddDeed() async {
    String? province;
    String type = _deedTypes.first;
    final noteController = TextEditingController();
    final result = await showModalBottomSheet<_GoodDeed>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceOf(context),
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
                    style: AppTypography.headingOf(context)
                        .copyWith(fontSize: AppFontSizes.heading)),
                const SizedBox(height: 6),
                Text(
                  'Katkın seçtiğin ilde sayılır. Konum ve kanıt sistemi tasarım onayından sonra bağlanacak.',
                  style: AppTypography.metadataOf(context)
                      .copyWith(fontSize: AppFontSizes.label),
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
                    style: AppTypography.headingOf(context)
                        .copyWith(fontSize: AppFontSizes.title)),
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${result.province} için +${GoodnessCampaignScore.pointsFor(result.type)} iyilik puanı eklendi.',
          ),
        ),
      );
    }
  }

  void _showProvince(String province, _GoodnessProvinceSummary summary) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceOf(context),
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
              Text('$province · ${summary.contributionCount} iyilik',
                  style: AppTypography.headingOf(context)
                      .copyWith(fontSize: AppFontSizes.heading)),
              const SizedBox(height: 4),
              Text('${summary.score} iyilik puanı',
                  style: AppTypography.metadataOf(context)),
              Builder(builder: (context) {
                final places = SupabasePlacesController.places.value
                    .where((p) =>
                        p.location.trim().toLowerCase() ==
                            province.trim().toLowerCase() &&
                        !p.isUtility)
                    .toList(growable: false);
                if (places.isEmpty) return const SizedBox.shrink();
                final passing = places.where(PlacePublicationStandard.meetsThreshold).length;
                final pct = ((passing / places.length) * 100).toInt();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_outlined, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Yayın standardı: %$pct ($passing/${places.length} nokta)',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: AppFontSizes.caption,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 14),
              if (summary.userDeeds.isEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceMuted
                        : AppColors.primarySoft,
                    child: const Icon(Icons.volunteer_activism_rounded,
                        color: AppColors.primary),
                  ),
                  title: Text(summary.latestDeed,
                      style: AppTypography.bodyOf(context)
                          .copyWith(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Kampanya örnek verisi'),
                ),
              ...summary.userDeeds.reversed.map(
                (deed) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceMuted
                        : AppColors.primarySoft,
                    child: Icon(_deedIcon(deed.type), color: AppColors.primary),
                  ),
                  title: Text(deed.type,
                      style: AppTypography.bodyOf(context)
                          .copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    deed.note.isEmpty ? 'Az önce eklendi' : deed.note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.metadataOf(context),
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
    final isDark = AppColors.isDark(context);
    final summaries = _provinceSummaries;
    final ranked = summaries.values
        .where((summary) => summary.score > 0)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    final totalContributions = summaries.values.fold<int>(
      0,
      (sum, summary) => sum + summary.contributionCount,
    );
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
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
                          style: AppTypography.headingOf(context)
                              .copyWith(fontSize: AppFontSizes.display)),
                      const SizedBox(height: 3),
                      Text('İyilik yap, şehrini zirveye taşı.',
                          style: AppTypography.metadataOf(context)
                              .copyWith(fontSize: AppFontSizes.title)),
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
                color:
                    isDark ? AppColors.darkPrimarySoft : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    color:
                        isDark ? AppColors.darkPrimaryLight : AppColors.primary,
                    size: 19,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Kampanya örnek verisi · Eklediklerin yalnızca bu oturumda görünür.',
                      style: AppTypography.labelOf(context)
                          .copyWith(fontSize: AppFontSizes.label),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _TurkeyProvinceBoard(
              summaries: summaries,
              onProvinceTap: _showProvince,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                    child:
                        _GoodnessStat('$totalContributions', 'Toplam iyilik')),
                const SizedBox(width: 10),
                Expanded(
                    child:
                        _GoodnessStat('${ranked.length}', 'Katkı sunulan il')),
              ],
            ),
            const SizedBox(height: 22),
            Text('İyilik tablosu',
                style: AppTypography.headingOf(context)
                    .copyWith(fontSize: AppFontSizes.heading)),
            const SizedBox(height: 10),
            ...ranked.take(5).toList().asMap().entries.map(
                  (entry) => _GoodnessLeaderboardRow(
                    rank: entry.key + 1,
                    summary: entry.value,
                    onTap: () =>
                        _showProvince(entry.value.province, entry.value),
                  ),
                ),
            const SizedBox(height: 20),
            Text('Nasıl işler?',
                style: AppTypography.headingOf(context)
                    .copyWith(fontSize: AppFontSizes.heading)),
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
    required this.summaries,
    required this.onProvinceTap,
  });

  final Map<String, _GoodnessProvinceSummary> summaries;
  final void Function(String province, _GoodnessProvinceSummary summary)
      onProvinceTap;

  @override
  State<_TurkeyProvinceBoard> createState() => _TurkeyProvinceBoardState();
}

class _TurkeyProvinceBoardState extends State<_TurkeyProvinceBoard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 224,
      decoration: BoxDecoration(
        color: AppColors.goodnessMapBackground,
        border: Border.all(color: AppColors.goodnessMapBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              // The province board has a fixed geographic aspect ratio. Letting
              // FittedBox calculate the scale keeps the full map centered at
              // every phone width instead of scaling it from the top-left.
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                child: SizedBox(
                  width: 1020,
                  height: 430,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: SvgPicture.asset(
                          'assets/maps/turkiye_il_haritasi.svg',
                          fit: BoxFit.contain,
                          semanticsLabel: "Türkiye'nin 81 il haritası",
                        ),
                      ),
                      ...widget.summaries.entries.map((entry) {
                        final point = _provinceCenters[entry.key];
                        if (point == null) return const SizedBox.shrink();
                        final position = _provinceBoardPosition(point);
                        final hasContribution = entry.value.score > 0;
                        if (!hasContribution) return const SizedBox.shrink();
                        return Positioned(
                          left: position.dx - 22,
                          top: position.dy - 22,
                          child: Semantics(
                            button: true,
                            label:
                                '${entry.key}, ${entry.value.score} iyilik puanı',
                            child: GestureDetector(
                              onTap: () =>
                                  widget.onProvinceTap(entry.key, entry.value),
                              child: Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppColors.shadow26,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${entry.value.score}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: AppFontSizes.caption,
                                    fontWeight: FontWeight.w800,
                                  ),
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
  const mapHeight = 422.0;
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
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return GlassContainer(
      borderRadius: BorderRadius.circular(AppRadii.medium),
      blur: 12,
      color: isDark
          ? AppColors.darkSurfaceMuted.withValues(alpha: 0.88)
          : Colors.white.withValues(alpha: 0.70),
      borderColor:
          isDark ? AppColors.darkBorder : Colors.white.withValues(alpha: 0.85),
      borderWidth: 1.2,
      padding: const EdgeInsets.all(14),
      boxShadow: const [
        BoxShadow(
          color: AppColors.shadow08,
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: AppTypography.headingOf(context).copyWith(
                  fontSize: AppFontSizes.display,
                  color:
                      isDark ? AppColors.darkPrimaryLight : AppColors.primary)),
          Text(label,
              style: AppTypography.metadataOf(context)
                  .copyWith(fontSize: AppFontSizes.label)),
        ],
      ),
    );
  }
}

class _GoodnessLeaderboardRow extends StatelessWidget {
  const _GoodnessLeaderboardRow({
    required this.rank,
    required this.summary,
    required this.onTap,
  });

  final int rank;
  final _GoodnessProvinceSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(AppRadii.medium),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadii.medium),
            child: Container(
              constraints: const BoxConstraints(minHeight: 68),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.medium),
                border: Border.all(color: AppColors.borderOf(context)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.isDark(context)
                          ? AppColors.darkPrimarySoft
                          : AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('#$rank',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: AppFontSizes.caption,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(summary.province,
                            style: AppTypography.bodyOf(context).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: AppFontSizes.title)),
                        const SizedBox(height: 2),
                        Text(summary.latestDeed,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.metadataOf(context)
                                .copyWith(fontSize: AppFontSizes.caption)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${summary.score}',
                          style: AppTypography.headingOf(context).copyWith(
                              color: AppColors.primary,
                              fontSize: AppFontSizes.heading)),
                      Text('puan', style: AppTypography.metadataOf(context)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _GoodnessCampaignSeed {
  const _GoodnessCampaignSeed({
    required this.province,
    required this.score,
    required this.contributionCount,
    required this.latestDeed,
  });

  final String province;
  final int score;
  final int contributionCount;
  final String latestDeed;
}

class _GoodnessProvinceSummary {
  const _GoodnessProvinceSummary({
    required this.province,
    required this.score,
    required this.contributionCount,
    required this.latestDeed,
    required this.userDeeds,
  });

  factory _GoodnessProvinceSummary.fromSeed(_GoodnessCampaignSeed seed) =>
      _GoodnessProvinceSummary(
        province: seed.province,
        score: seed.score,
        contributionCount: seed.contributionCount,
        latestDeed: seed.latestDeed,
        userDeeds: const <_GoodDeed>[],
      );

  factory _GoodnessProvinceSummary.empty(String province) =>
      _GoodnessProvinceSummary(
        province: province,
        score: 0,
        contributionCount: 0,
        latestDeed: 'İlk iyilik katkısını bekliyor',
        userDeeds: const <_GoodDeed>[],
      );

  final String province;
  final int score;
  final int contributionCount;
  final String latestDeed;
  final List<_GoodDeed> userDeeds;

  _GoodnessProvinceSummary withAddedDeeds(List<_GoodDeed> deeds) {
    if (deeds.isEmpty) return this;
    final latest = deeds.last;
    return _GoodnessProvinceSummary(
      province: province,
      score: score +
          deeds.fold<int>(
            0,
            (total, deed) => total + GoodnessCampaignScore.pointsFor(deed.type),
          ),
      contributionCount: contributionCount + deeds.length,
      latestDeed: latest.note.isEmpty ? latest.type : latest.note,
      userDeeds: List<_GoodDeed>.unmodifiable([...userDeeds, ...deeds]),
    );
  }
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
                color: AppColors.isDark(context)
                    ? AppColors.darkPrimarySoft
                    : AppColors.primarySoft,
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
                      style: AppTypography.bodyOf(context).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: AppFontSizes.title)),
                  const SizedBox(height: 3),
                  Text(body,
                      style: AppTypography.metadataOf(context).copyWith(
                          fontSize: AppFontSizes.label, height: 1.35)),
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
        backgroundColor: AppColors.backgroundOf(context),
        appBar: AppBar(title: const Text('Katkı profili')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.primary,
              child: Text('S',
                  style: TextStyle(
                      color: Colors.white, fontSize: AppFontSizes.display)),
            ),
            const SizedBox(height: 12),
            Text('Sen',
                textAlign: TextAlign.center,
                style: AppTypography.headingOf(context)
                    .copyWith(fontSize: AppFontSizes.display)),
            const SizedBox(height: 5),
            Text('${deeds.length} iyilik katkısı',
                textAlign: TextAlign.center,
                style: AppTypography.metadataOf(context)),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.isDark(context)
                    ? AppColors.darkPrimarySoft
                    : AppColors.primarySoft,
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

IconData _deedIcon(String type) => switch (type) {
      'Çöp Topladım' => Icons.cleaning_services_rounded,
      'Fidan Diktim' => Icons.park_rounded,
      'Sokak Hayvanlarına Mama Verdim' => Icons.pets_rounded,
      'Su Kabı Bıraktım' => Icons.water_drop_rounded,
      _ => Icons.recycling_rounded,
    };

const _deedTypes = <String>[
  'Çöp Topladım',
  'Fidan Diktim',
  'Sokak Hayvanlarına Mama Verdim',
  'Su Kabı Bıraktım',
  'Geri Dönüşüme Götürdüm',
];

const _goodnessCampaignSeeds = <_GoodnessCampaignSeed>[
  _GoodnessCampaignSeed(
      province: 'İstanbul',
      score: 340,
      contributionCount: 34,
      latestDeed: '120 poşet çöp toplandı'),
  _GoodnessCampaignSeed(
      province: 'Ankara',
      score: 255,
      contributionCount: 26,
      latestDeed: '80 fidan dikildi'),
  _GoodnessCampaignSeed(
      province: 'İzmir',
      score: 210,
      contributionCount: 21,
      latestDeed: '3 sahil temizliği yapıldı'),
  _GoodnessCampaignSeed(
      province: 'Antalya',
      score: 198,
      contributionCount: 20,
      latestDeed: 'Kaplumbağa yuvaları korundu'),
  _GoodnessCampaignSeed(
      province: 'Bursa',
      score: 150,
      contributionCount: 15,
      latestDeed: '45 fidan dikildi'),
  _GoodnessCampaignSeed(
      province: 'Trabzon',
      score: 132,
      contributionCount: 13,
      latestDeed: 'Yangın sonrası dikim yapıldı'),
  _GoodnessCampaignSeed(
      province: 'Adana',
      score: 120,
      contributionCount: 12,
      latestDeed: 'Nehir kıyısı temizlendi'),
  _GoodnessCampaignSeed(
      province: 'Konya',
      score: 110,
      contributionCount: 11,
      latestDeed: '60 kg atık geri dönüştürüldü'),
  _GoodnessCampaignSeed(
      province: 'Samsun',
      score: 101,
      contributionCount: 10,
      latestDeed: '25 fidan dikildi'),
  _GoodnessCampaignSeed(
      province: 'Diyarbakır',
      score: 96,
      contributionCount: 10,
      latestDeed: 'Sokak hayvanları beslendi'),
  _GoodnessCampaignSeed(
      province: 'Van',
      score: 88,
      contributionCount: 9,
      latestDeed: 'Göl kıyısı temizlendi'),
  _GoodnessCampaignSeed(
      province: 'Mersin',
      score: 84,
      contributionCount: 8,
      latestDeed: 'Sahil temizliği yapıldı'),
  _GoodnessCampaignSeed(
      province: 'Eskişehir',
      score: 77,
      contributionCount: 8,
      latestDeed: 'Kompost atölyesi düzenlendi'),
  _GoodnessCampaignSeed(
      province: 'Gaziantep',
      score: 70,
      contributionCount: 7,
      latestDeed: 'Su tasarrufu kampanyası yapıldı'),
  _GoodnessCampaignSeed(
      province: 'Kayseri',
      score: 66,
      contributionCount: 7,
      latestDeed: '40 fidan dikildi'),
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
