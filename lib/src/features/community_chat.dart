part of '../../main.dart';

class CommunityChatHubScreen extends StatefulWidget {
  const CommunityChatHubScreen({super.key});

  @override
  State<CommunityChatHubScreen> createState() => _CommunityChatHubScreenState();
}

class _CommunityChatHubScreenState extends State<CommunityChatHubScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLandscape = context.isTabletLandscape;

    if (isLandscape) {
      final selectedCategory = _homeCategories.isNotEmpty
          ? _homeCategories[_selectedIndex.clamp(0, _homeCategories.length - 1)]
          : null;

      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              SizedBox(
                width: 340,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        children: [
                          if (Navigator.canPop(context))
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_rounded),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          if (Navigator.canPop(context))
                            const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppStrings.get('community_chats_title'),
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: AppFontSizes.heading,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      child: Text(
                        AppStrings.get('community_chats_desc'),
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          fontSize: AppFontSizes.caption,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: _homeCategories.length,
                        itemBuilder: (context, index) {
                          final category = _homeCategories[index];
                          final isSelected = index == _selectedIndex;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _ChatCategoryTile(
                              icon: category.icon,
                              emoji: category.emoji,
                              title: category.localizedLabel,
                              iconColor: category.foreground,
                              iconBackground: category.background,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() => _selectedIndex = index);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(
                child: selectedCategory != null
                    ? CommunityChatRoomScreen(
                        key: ValueKey(selectedCategory.localizedLabel),
                        icon: selectedCategory.icon,
                        iconColor: selectedCategory.foreground,
                        iconBackground: selectedCategory.background,
                        emoji: selectedCategory.emoji,
                        category: selectedCategory.localizedLabel,
                        isEmbedded: true,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }

    final listContent = ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Text(
          AppStrings.get('community_chats_subtitle'),
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: AppFontSizes.display,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          AppStrings.get('community_chats_desc'),
          style: TextStyle(
            fontFamily: 'Outfit',
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            fontSize: AppFontSizes.label,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 22),
        ..._homeCategories.map(
          (category) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ChatCategoryTile(
              icon: category.icon,
              emoji: category.emoji,
              title: category.localizedLabel,
              iconColor: category.foreground,
              iconBackground: category.background,
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('community_chats_title')),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: context.isTabletPortrait
          ? context.centerContent(maxWidth: 760, child: listContent)
          : listContent,
    );
  }
}

class _ChatCategoryTile extends StatelessWidget {
  const _ChatCategoryTile({
    this.icon,
    this.emoji = '',
    required this.title,
    required this.iconColor,
    required this.iconBackground,
    this.isSelected = false,
    this.onTap,
  });

  final IconData? icon;
  final String emoji;
  final String title;
  final Color iconColor;
  final Color iconBackground;
  final bool isSelected;
  final VoidCallback? onTap;

  Future<void> _toggleRoomNotifications(BuildContext context) async {
    final following = CommunityChatSubscriptionController.isFollowing(title);
    final answer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(following ? 'Bildirimleri kapat' : 'Sohbet bildirimleri'),
        content: Text(
          following
              ? 'Bu sohbet odasıyla ilgili bildirimleri kapatmak ister misiniz?'
              : 'Bu sohbet odası ile ilgili bildirim almak ister misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hayır'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(following ? 'Kapat' : 'Evet'),
          ),
        ],
      ),
    );
    if (answer != true || !context.mounted) return;

    if (following) {
      await CommunityChatSubscriptionController.unsubscribe(title);
    } else {
      await CommunityChatSubscriptionController.subscribe(title);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          following
              ? '$title sohbeti için bildirimler kapatıldı.'
              : '$title sohbeti için bildirimler açıldı.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      borderRadius: BorderRadius.circular(AppRadii.large),
      blur: 10,
      color: isSelected
          ? (isDark
              ? AppColors.darkPrimarySoft.withValues(alpha: 0.6)
              : AppColors.primarySoft.withValues(alpha: 0.8))
          : Colors.white.withValues(alpha: 0.72),
      borderColor: isSelected
          ? (isDark ? AppColors.darkPrimaryLight : AppColors.primary)
          : Colors.white.withValues(alpha: 0.88),
      borderWidth: isSelected ? 1.8 : 1.2,
      boxShadow: const [
        BoxShadow(
          color: AppColors.shadow08,
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ??
              () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommunityChatRoomScreen(
                        icon: icon,
                        iconColor: iconColor,
                        iconBackground: iconBackground,
                        emoji: emoji,
                        category: title,
                      ),
                    ),
                  ),
          borderRadius: BorderRadius.circular(AppRadii.large),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark
                        ? iconBackground.withValues(alpha: 0.25)
                        : iconBackground,
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                  ),
                  child: icon != null
                      ? Icon(icon, size: 22, color: iconColor)
                      : Text(emoji, style: const TextStyle(fontSize: 21)),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: AppFontSizes.body,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ValueListenableBuilder<Set<String>>(
                            valueListenable: CommunityChatSubscriptionController
                                .followedRooms,
                            builder: (context, followedRooms, _) {
                              final following = followedRooms.contains(title);
                              return IconButton(
                                tooltip: following
                                    ? '$title bildirimlerini kapat'
                                    : '$title bildirimlerini aç',
                                onPressed: () =>
                                    _toggleRoomNotifications(context),
                                icon: Icon(
                                  following
                                      ? Icons.notifications_active_rounded
                                      : Icons.notifications_none_rounded,
                                  color: following
                                      ? (isDark
                                          ? AppColors.darkPrimaryLight
                                          : AppColors.primary)
                                      : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        AppStrings.get('community_chat_tile_subtitle'),
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.textTertiary,
                          fontSize: AppFontSizes.caption,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: iconColor, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CommunityChatRoomScreen extends StatefulWidget {
  const CommunityChatRoomScreen({
    super.key,
    this.icon,
    this.iconColor,
    this.iconBackground,
    this.emoji = '',
    required this.category,
    this.isEmbedded = false,
  });

  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackground;
  final String emoji;
  final String category;
  final bool isEmbedded;

  @override
  State<CommunityChatRoomScreen> createState() =>
      _CommunityChatRoomScreenState();
}

class _CommunityMessage {
  const _CommunityMessage({
    this.id = '',
    this.authorId = '',
    required this.author,
    required this.role,
    required this.text,
    required this.time,
    this.isUser = false,
    this.isStaff = false,
  });

  final String id;
  final String authorId;
  final String author;
  final String role;
  final String text;
  final String time;
  final bool isUser;
  final bool isStaff;

  factory _CommunityMessage.fromLive(CommunityChatMessage message) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    return _CommunityMessage(
      id: message.id,
      authorId: message.authorId,
      author: message.authorName,
      role: message.isStaff ? 'Yönetici' : 'Doğa Kaşifi',
      text: message.body,
      time: _relativeChatTime(message.createdAt),
      isUser: currentUserId == message.authorId,
      isStaff: message.isStaff,
    );
  }
}

String _relativeChatTime(DateTime time) {
  final elapsed = DateTime.now().difference(time.toLocal());
  if (elapsed.inMinutes < 1) return 'Şimdi';
  if (elapsed.inMinutes < 60) return '${elapsed.inMinutes} dk';
  if (elapsed.inHours < 24) return '${elapsed.inHours} sa';
  return '${elapsed.inDays} gün';
}

// Kept only as a local development fixture; production rooms load live data.
// ignore: unused_element
List<_CommunityMessage> _getInitialMessages(String category) {
  final cat = category.toLowerCase();
  if (cat.contains('su') || cat.contains('water')) {
    return const [
      _CommunityMessage(
        author: 'Emre T.',
        role: 'Doğa Gezgini',
        text: 'Göl ve şelale çevresinde içilebilir temiz su kaynağı var mı?',
        time: '34 dk önce',
      ),
      _CommunityMessage(
        author: 'Murat K.',
        role: 'Bölge Rehberi',
        text:
            'Evet, şelaleye inen patikanın yaklaşık 200m yukarısında gürül gürül akan kaynak suyu çeşmesi var. Suyu buz gibi ve içilebilir nitelikte.',
        time: '28 dk önce',
      ),
      _CommunityMessage(
        author: 'Deniz A.',
        role: 'Doğa Sever',
        text:
            'Yaz aylarında debi çok düşüyor mu, su geçişi için ekipman gerekir mi?',
        time: '15 dk önce',
      ),
      _CommunityMessage(
        author: 'Selin Y.',
        role: 'Kaşif',
        text:
            'Ağustos sonuna doğru biraz azalıyor ama kesilmiyor. Su geçişi için kayalar kaygan olabiliyor, baton bulundurmak faydalı.',
        time: '8 dk önce',
      ),
    ];
  } else if (cat.contains('dağ') ||
      cat.contains('arazi') ||
      cat.contains('mountain')) {
    return const [
      _CommunityMessage(
        author: 'Kaan B.',
        role: 'Dağcı',
        text:
            'Zirveye ve yaylaya çıkan yol açık mı, binek araçla çıkılabilir mi?',
        time: '45 dk önce',
      ),
      _CommunityMessage(
        author: 'Hakan R.',
        role: 'Yerel Rehber',
        text:
            'Ana yaylaya kadar yol stabilize ve açık, binek araçla temkinli çıkılıyor. Zirve patikası için 4x4 veya tabanı yüksek araç önerilir.',
        time: '32 dk önce',
      ),
      _CommunityMessage(
        author: 'Bora D.',
        role: 'Doğa Kaşifi',
        text:
            'Gece yaylada sıcaklık 4-6 dereceye kadar düşüyor. Rüzgar siperi ve termal tulum şart.',
        time: '12 dk önce',
      ),
    ];
  } else if (cat.contains('oluşum') ||
      cat.contains('formation') ||
      cat.contains('kanyon') ||
      cat.contains('mağara')) {
    return const [
      _CommunityMessage(
        author: 'Burak Ö.',
        role: 'Kaşif',
        text:
            'Kanyon ve mağara geçişinde su ayakkabısı veya kafa feneri gerekiyor mu?',
        time: '50 dk önce',
      ),
      _CommunityMessage(
        author: 'Oğuz V.',
        role: 'Mağara Araştırmacısı',
        text:
            'Mağarada doğal ışık yok, en az 300 lümen kafa feneri ve yedek pil şart. Kanyonda ise bilek boyu su geçişleri var, kaymayan su ayakkabısı şart.',
        time: '38 dk önce',
      ),
      _CommunityMessage(
        author: 'Gizem L.',
        role: 'Doğa Sever',
        text:
            'İlk 800 metrelik ahşap yürüyüş yolu çok rahat, kanyonun derin kısımları ise kaygan kayalar nedeniyle dikkat gerektiriyor.',
        time: '19 dk önce',
      ),
    ];
  } else if (cat.contains('doğa') ||
      cat.contains('orman') ||
      cat.contains('milli park') ||
      cat.contains('nature')) {
    return const [
      _CommunityMessage(
        author: 'Zeynep M.',
        role: 'Doğa Kaşifi',
        text:
            'Milli park içinde kamp veya piknik için ateş ve ocak yakma durumu nedir?',
        time: '1 saat önce',
      ),
      _CommunityMessage(
        author: 'Serdar E.',
        role: 'Park Gözlemcisi',
        text:
            'Açık ateş ve mangal kesinlikle yasak. Belirlenmiş piknik masalarında yalnızca tüplü kamp ocağı kullanımına izin veriliyor.',
        time: '42 dk önce',
      ),
      _CommunityMessage(
        author: 'Tolga A.',
        role: 'Yürüyüşçü',
        text:
            'Orman içi kırmızı-beyaz rota işaretleri çok belirgin, kaybolma riski yok.',
        time: '20 dk önce',
      ),
    ];
  } else if (cat.contains('kamp') ||
      cat.contains('karavan') ||
      cat.contains('camp')) {
    return const [
      _CommunityMessage(
        author: 'Barış G.',
        role: 'Kampçı',
        text:
            'Çadır kurmak için düz, rüzgardan korunaklı ve gölgelik alanlar var mı?',
        time: '40 dk önce',
      ),
      _CommunityMessage(
        author: 'Cem U.',
        role: 'Kamp Lideri',
        text:
            'Gölün güney tarafındaki çamlık alan hem rüzgarsız hem de zemin oldukça düz. Çadır altlığı kullanmanızı öneririm.',
        time: '25 dk önce',
      ),
      _CommunityMessage(
        author: 'Derya N.',
        role: 'Karavan Kaşifi',
        text:
            'Girişte tatlı su dolumu ücretsiz yapılabiliyor. Elektrik içinse güneş paneli kullanmanız daha rahat olur.',
        time: '14 dk önce',
      ),
    ];
  } else if (cat.contains('rota') ||
      cat.contains('aktivite') ||
      cat.contains('route') ||
      cat.contains('yürüyüş')) {
    return const [
      _CommunityMessage(
        author: 'Ece K.',
        role: 'Yürüyüşçü',
        text: 'Rotanın toplam uzunluğu ve tamamlanma süresi ortalama ne kadar?',
        time: '55 dk önce',
      ),
      _CommunityMessage(
        author: 'Fatih B.',
        role: 'Rota Lideri',
        text:
            'Rota 9.2 km gidiş-dönüş. Orta tempoda ve fotoğraf molalarıyla yaklaşık 3.5 saatte rahatça tamamlanıyor.',
        time: '36 dk önce',
      ),
      _CommunityMessage(
        author: 'Alperen M.',
        role: 'Trekking Sever',
        text:
            'Dönüş inişindeki dik ve mıcırlı eğim için yürüyüş batonu kullanmak dizleri koruyor.',
        time: '18 dk önce',
      ),
    ];
  } else if (cat.contains('keşif') ||
      cat.contains('discovery') ||
      cat.contains('seyir')) {
    return const [
      _CommunityMessage(
        author: 'Onur S.',
        role: 'Fotoğrafçı',
        text:
            'Gün batımı ve fotoğraf çekimi için en iyi seyir noktası neresidir?',
        time: '1 saat önce',
      ),
      _CommunityMessage(
        author: 'Büşra D.',
        role: 'Gezgin Fotoğrafçı',
        text:
            'Kuzey tepesindeki seyir terası batıya tam hakim. Saat 18:45-19:30 arası altın saat ışığı muhteşem kareler veriyor.',
        time: '44 dk önce',
      ),
      _CommunityMessage(
        author: 'Kemal H.',
        role: 'Yerel Rehber',
        text:
            'Giriş tamamen serbest ve ücretsiz. Doğal alanı korumak için lütfen çöpleri yanınızda geri götürün.',
        time: '22 dk önce',
      ),
    ];
  } else {
    return const [
      _CommunityMessage(
        author: 'Sinan R.',
        role: 'Kuş Gözlemcisi',
        text:
            'Kuş gözlemi ve endemik türler için en verimli saatler hangileri?',
        time: '1 saat önce',
      ),
      _CommunityMessage(
        author: 'Dr. Aslı T.',
        role: 'Biyolog',
        text:
            'Sabahın ilk ışıkları (06:30 - 08:30) sulak alan kenarında kuşlar çok hareketli. Dürbün ile harika türler gözlemlenebiliyor.',
        time: '48 dk önce',
      ),
      _CommunityMessage(
        author: 'Gökhan S.',
        role: 'Yaban Hayatı Gözlemcisi',
        text:
            'Yürüyüş yaparken konuşarak ses çıkarmak yaban hayvanlarının yaklaşmasını engeller ve doğa güvenliğini sağlar.',
        time: '26 dk önce',
      ),
    ];
  }
}

List<String> _getCategoryPrompts(String category) {
  final cat = category.toLowerCase();
  if (cat.contains('su') || cat.contains('water')) {
    return const [
      'Yakında içme suyu kaynağı var mı?',
      'Şelale/göl kenarında kamp yapılabiliyor mu?',
    ];
  } else if (cat.contains('dağ') ||
      cat.contains('arazi') ||
      cat.contains('mountain')) {
    return const [
      'Yayla yolu binek araca uygun mu?',
      'Zirve rotasında rüzgar ve hava durumu nasıl?',
    ];
  } else if (cat.contains('oluşum') ||
      cat.contains('formation') ||
      cat.contains('kanyon') ||
      cat.contains('mağara')) {
    return const [
      'Kanyonda su geçişi var mı, ayakkabı gerekir mi?',
      'Mağara girişi için kafa feneri şart mı?',
    ];
  } else if (cat.contains('doğa') ||
      cat.contains('orman') ||
      cat.contains('milli park') ||
      cat.contains('nature')) {
    return const [
      'Milli parkta tüplü kamp ocağı serbest mi?',
      'Orman içi patika işaretleri belirgin mi?',
    ];
  } else if (cat.contains('kamp') ||
      cat.contains('karavan') ||
      cat.contains('camp')) {
    return const [
      'Rüzgarsız ve düz çadır alanı var mı?',
      'Karavan için tatlı su dolum noktası var mı?',
    ];
  } else if (cat.contains('rota') ||
      cat.contains('aktivite') ||
      cat.contains('route') ||
      cat.contains('yürüyüş')) {
    return const [
      'Parkurun toplam yürüyüş süresi nedir?',
      'Rotada yürüyüş batonu gerekli mi?',
    ];
  } else if (cat.contains('keşif') ||
      cat.contains('discovery') ||
      cat.contains('seyir')) {
    return const [
      'En iyi gün batımı seyir noktası neresi?',
      'Keşif noktasına giriş ücretli veya izinli mi?',
    ];
  } else {
    return const [
      'Kuş gözlemi için en uygun saatler nedir?',
      'Yaban hayatı güvenliği için nelere dikkat edilmeli?',
    ];
  }
}

class _CommunityChatRoomScreenState extends State<CommunityChatRoomScreen> {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  List<_CommunityMessage> messages = const [];
  bool _loadingMessages = true;
  String? _loadError;
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _subscribeToLiveMessages();
  }

  @override
  void didUpdateWidget(covariant CommunityChatRoomScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      controller.clear();
      _loadMessages();
      _unsubscribeFromLiveMessages();
      _subscribeToLiveMessages();
    }
  }

  @override
  void dispose() {
    _unsubscribeFromLiveMessages();
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _subscribeToLiveMessages() {
    // Widget testleri ve bağlantısız önizlemeler Supabase'i başlatmadan bu
    // ekranı açabilir. Sohbetin ilk yüklemesi çalışmaya devam eder; yalnızca
    // canlı güncelleme, servis hazır olana kadar bekler.
    try {
      _realtimeChannel = CommunityChatService.watchMessages(
        categoryKey: widget.category,
        onChanged: _refreshLiveMessages,
      );
    } catch (_) {
      _realtimeChannel = null;
    }
  }

  void _unsubscribeFromLiveMessages() {
    final channel = _realtimeChannel;
    _realtimeChannel = null;
    if (channel != null) {
      unawaited(Supabase.instance.client.removeChannel(channel));
    }
  }

  Future<void> _refreshLiveMessages() async {
    try {
      final liveMessages =
          await CommunityChatService.loadMessages(widget.category);
      if (!mounted) return;
      setState(() {
        messages = liveMessages.map(_CommunityMessage.fromLive).toList();
        _loadError = null;
      });
    } catch (_) {
      // A transient realtime refresh failure must not erase visible messages.
    }
  }

  Future<void> _loadMessages() async {
    setState(() {
      _loadingMessages = true;
      _loadError = null;
    });
    try {
      final liveMessages =
          await CommunityChatService.loadMessages(widget.category);
      if (!mounted) return;
      setState(() {
        messages = liveMessages.map(_CommunityMessage.fromLive).toList();
      });
      if (CommunityChatSubscriptionController.isFollowing(widget.category)) {
        unawaited(CommunityChatSubscriptionController.markRoomRead(
          widget.category,
        ));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadError = 'Sohbet şu anda yüklenemedi.');
    } finally {
      if (mounted) setState(() => _loadingMessages = false);
    }
  }

  Future<void> addPreviewMessage([String? presetText]) async {
    final allowed = await AppAuthGuard.requireAuth(
      context,
      title: AppStrings.get('guest_auth_title'),
      message: AppStrings.get('guest_chat_prompt'),
    );
    if (!allowed || !mounted) return;

    final message = (presetText ?? controller.text).trim();
    if (message.isEmpty) return;
    try {
      final sent = await CommunityChatService.sendMessage(
        categoryKey: widget.category,
        body: message,
      );
      if (!mounted) return;
      setState(() {
        messages = [...messages, _CommunityMessage.fromLive(sent)];
        controller.clear();
      });
    } catch (error) {
      if (!mounted) return;
      final text = error.toString();
      final restriction = RegExp(r'chat_restricted:([^\s]+)').firstMatch(text);
      final feedback = restriction == null
          ? 'Mesaj gönderilemedi. Bağlantılar ve uygunsuz içerikler kabul edilmez.'
          : restriction.group(1) == 'permanent'
              ? 'Sohbet erişimin süresiz olarak kısıtlandı.'
              : 'Sohbet erişimin ${restriction.group(1)} tarihine kadar kısıtlandı.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(feedback)));
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _showReportDialog(_CommunityMessage message) async {
    String reason = 'abuse';
    final noteController = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(AppStrings.get('chat_report_message')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in <(String, String)>[
                    ('abuse', AppStrings.get('chat_report_abuse')),
                    ('harassment', AppStrings.get('chat_report_harassment')),
                    ('spam', AppStrings.get('chat_report_spam')),
                    ('unsafe', AppStrings.get('chat_report_unsafe')),
                    ('other', AppStrings.get('chat_report_other')),
                  ])
                    ChoiceChip(
                      label: Text(item.$2),
                      selected: reason == item.$1,
                      onSelected: (_) => setDialogState(() => reason = item.$1),
                    ),
                ],
              ),
              TextField(
                controller: noteController,
                maxLength: 300,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppStrings.get('chat_report_note'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(AppStrings.get('general_cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(AppStrings.get('general_confirm')),
            ),
          ],
        ),
      ),
    );
    if (submitted != true || !mounted) {
      noteController.dispose();
      return;
    }
    try {
      await CommunityChatService.reportMessage(
        messageId: message.id,
        reason: reason,
        note: noteController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('chat_report_sent'))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('chat_report_failed'))),
      );
    } finally {
      noteController.dispose();
    }
  }

  Future<void> _showOwnMessageActions(_CommunityMessage message) async {
    if (message.id.isEmpty) return;
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Düzenle'),
              onTap: () => Navigator.pop(sheetContext, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              title:
                  const Text('Sil', style: TextStyle(color: AppColors.error)),
              onTap: () => Navigator.pop(sheetContext, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (action == 'edit') {
      await _editOwnMessage(message);
    } else if (action == 'delete') {
      await _deleteOwnMessage(message);
    }
  }

  Future<void> _editOwnMessage(_CommunityMessage message) async {
    final controller = TextEditingController(text: message.text);
    final updatedBody = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mesajı düzenle'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 500,
          minLines: 2,
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppStrings.get('general_cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(AppStrings.get('general_save')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (updatedBody == null || updatedBody.trim() == message.text.trim()) {
      return;
    }
    try {
      final updated = await CommunityChatService.updateMessage(
        messageId: message.id,
        body: updatedBody,
      );
      if (!mounted) return;
      setState(() {
        messages = messages
            .map((item) => item.id == message.id
                ? _CommunityMessage.fromLive(updated)
                : item)
            .toList(growable: false);
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mesaj düzenlenemedi. Tekrar dene.')),
        );
      }
    }
  }

  Future<void> _deleteOwnMessage(_CommunityMessage message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mesaj silinsin mi?'),
        content: const Text('Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppStrings.get('general_cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await CommunityChatService.deleteMessage(messageId: message.id);
      if (!mounted) return;
      setState(() {
        messages = messages
            .where((item) => item.id != message.id)
            .toList(growable: false);
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mesaj silinemedi. Tekrar dene.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppColors.textPrimaryOf(context);
    final textTertiary = AppColors.textTertiaryOf(context);
    final prompts = _getCategoryPrompts(widget.category);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isEmbedded,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 20,
                color: widget.iconColor ??
                    (isDark ? AppColors.darkPrimaryLight : green),
              ),
              const SizedBox(width: 8),
            ] else if (widget.emoji.isNotEmpty) ...[
              Text(widget.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
            ],
            Text(widget.category),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            color: isDark ? AppColors.darkPrimarySoft : AppColors.primarySoft,
            child: Text(
              AppStrings.get('community_chat_preview_banner'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                color: isDark ? AppColors.darkPrimaryLight : green,
                fontSize: AppFontSizes.caption,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: _loadingMessages
                ? const Center(child: CircularProgressIndicator())
                : _loadError != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_loadError!),
                              const SizedBox(height: 12),
                              AppTextButton(
                                onPressed: _loadMessages,
                                label: AppStrings.get('community_chat_retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : messages.isEmpty
                        ? Center(
                            child: Text(
                              AppStrings.get('community_chat_empty'),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                            itemCount: messages.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, index) {
                              final message = messages[index];
                              if (message.isUser) {
                                return Align(
                                  alignment: Alignment.centerRight,
                                  child: Semantics(
                                    button: message.id.isNotEmpty,
                                    label: message.id.isEmpty
                                        ? message.text
                                        : 'Mesaj seçeneklerini aç: ${message.text}',
                                    child: AppPressable(
                                      onPressed: message.id.isEmpty
                                          ? null
                                          : () =>
                                              _showOwnMessageActions(message),
                                      borderRadius:
                                          BorderRadius.circular(AppRadii.large),
                                      child: Container(
                                        constraints:
                                            const BoxConstraints(maxWidth: 290),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: green,
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.large,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              message.text,
                                              style: const TextStyle(
                                                fontFamily: 'Outfit',
                                                color: Colors.white,
                                                fontSize: AppFontSizes.label,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${message.time} · ${message.author}',
                                              style: TextStyle(
                                                fontSize: AppFontSizes.caption,
                                                color: Colors.white.withValues(
                                                  alpha: 0.75,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 320),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkSurface
                                        : Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.large),
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.darkBorder
                                          : AppColors.border,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: AppColors.shadow08,
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundColor: isDark
                                                ? AppColors.darkPrimarySoft
                                                : AppColors.primarySoft,
                                            child: Text(
                                              message.author.isNotEmpty
                                                  ? message.author[0]
                                                  : 'D',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    message.author,
                                                    style: TextStyle(
                                                      fontFamily: 'Outfit',
                                                      fontSize:
                                                          AppFontSizes.label,
                                                      fontWeight:
                                                          message.isStaff
                                                              ? FontWeight.w800
                                                              : FontWeight.w600,
                                                      color: textPrimary,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                if (message.isStaff) ...[
                                                  const Icon(
                                                    Icons.verified_rounded,
                                                    size: 16,
                                                    color: AppColors.primary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                ],
                                                Flexible(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? AppColors
                                                              .darkPrimarySoft
                                                          : AppColors
                                                              .primarySoft,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppRadii.small),
                                                    ),
                                                    child: Text(
                                                      message.role,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isDark
                                                            ? AppColors
                                                                .darkPrimaryLight
                                                            : AppColors.primary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (!message.isUser &&
                                              message.id.isNotEmpty)
                                            IconButton(
                                              tooltip: 'Şikayet et',
                                              visualDensity:
                                                  VisualDensity.compact,
                                              icon: Icon(
                                                Icons.more_horiz_rounded,
                                                size: 20,
                                                color: textTertiary,
                                              ),
                                              onPressed: () =>
                                                  _showReportDialog(message),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        message.text,
                                        style: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: AppFontSizes.body,
                                          height: 1.35,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: prompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final prompt = prompts[i];
                return ActionChip(
                  avatar: const Icon(
                    Icons.help_outline_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    prompt,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: AppFontSizes.caption,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () {
                    controller.text = prompt;
                    addPreviewMessage();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          SafeArea(
            top: false,
            child: GlassContainer(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadii.large)),
              blur: 16,
              color: Colors.white.withValues(alpha: 0.85),
              darkColor: AppColors.darkGlass,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.90),
                  width: 1.2,
                ),
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow08,
                  blurRadius: 16,
                  offset: Offset(0, -3),
                ),
              ],
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: AppAuthGuard.isGuest
                  ? InkWell(
                      onTap: addPreviewMessage,
                      borderRadius: BorderRadius.circular(AppRadii.large),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(AppRadii.large),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lock_outline_rounded,
                                size: 18,
                                color: isDark
                                    ? AppColors.darkPrimaryLight
                                    : AppColors.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppStrings.get('guest_chat_prompt'),
                                style: TextStyle(
                                  fontSize: AppFontSizes.caption,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded,
                                size: 16,
                                color: isDark
                                    ? AppColors.darkPrimaryLight
                                    : AppColors.primary),
                          ],
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        for (final emoji in const ['⛺', '💧', '🌿', '👍'])
                          InkWell(
                            onTap: () {
                              controller.text = '${controller.text}$emoji';
                              controller.selection = TextSelection.collapsed(
                                offset: controller.text.length,
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => addPreviewMessage(),
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextPrimary : null,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  AppStrings.get('community_chat_input_hint'),
                              hintStyle: TextStyle(
                                color:
                                    isDark ? AppColors.darkTextTertiary : null,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withValues(alpha: 0.13)
                                  : AppColors.surfaceMuted,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.large),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        IconButton.filled(
                          onPressed: addPreviewMessage,
                          style: IconButton.styleFrom(
                            backgroundColor:
                                isDark ? AppColors.darkPrimary : green,
                          ),
                          icon: const Icon(Icons.send_rounded),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
