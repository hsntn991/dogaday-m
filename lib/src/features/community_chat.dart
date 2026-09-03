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
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
            side: const BorderSide(color: Color(0xFFE2DED6)),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadii.medium),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(icon, color: green, size: 19),
            ),
          ),
        ),
      );
}

class CommunityChatHubScreen extends StatelessWidget {
  const CommunityChatHubScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Topluluk Sohbetleri'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const Text(
              'Doğayı bilenlere sor',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Merak ettiğin konuya ait odayı seç; bölgeyi bilen doğaseverlerle konuş.',
              style: TextStyle(
                fontFamily: 'Outfit',
                color: Color(0xFF74716B),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            ..._homeCategories.map(
              (category) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ChatCategoryTile(
                  emoji: category.emoji,
                  title: category.label,
                  iconColor: category.foreground,
                  iconBackground: category.background,
                ),
              ),
            ),
          ],
        ),
      );
}

class _ChatCategoryTile extends StatelessWidget {
  const _ChatCategoryTile({
    required this.emoji,
    required this.title,
    required this.iconColor,
    required this.iconBackground,
  });

  final String emoji;
  final String title;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.large),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CommunityChatRoomScreen(
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
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 21)),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Soru sor, deneyimini paylaş',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          color: Color(0xFF8C8881),
                          fontSize: 11,
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
      );
}

class CommunityChatRoomScreen extends StatefulWidget {
  const CommunityChatRoomScreen({
    super.key,
    required this.emoji,
    required this.category,
  });

  final String emoji;
  final String category;

  @override
  State<CommunityChatRoomScreen> createState() =>
      _CommunityChatRoomScreenState();
}

class _CommunityChatRoomScreenState extends State<CommunityChatRoomScreen> {
  final controller = TextEditingController();
  final messages = <String>[];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void addPreviewMessage() {
    final message = controller.text.trim();
    if (message.isEmpty) return;
    setState(() {
      messages.add(message);
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('${widget.emoji} ${widget.category}'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              color: const Color(0xFFF0F5ED),
              child: const Text(
                'Tasarım önizlemesi · Mesajlar henüz diğer kullanıcılara gönderilmez.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: green,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(widget.emoji,
                                style: const TextStyle(fontSize: 42)),
                            const SizedBox(height: 15),
                            const Text(
                              'Henüz mesaj yok',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${widget.category} hakkında ilk soruyu sen yaz.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                color: Color(0xFF817D76),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      reverse: true,
                      padding: const EdgeInsets.all(18),
                      itemCount: messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, index) {
                        final message = messages[messages.length - 1 - index];
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 290),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: green,
                              borderRadius:
                                  BorderRadius.circular(AppRadii.large),
                            ),
                            child: Text(
                              message,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => addPreviewMessage(),
                        decoration: InputDecoration(
                          hintText: 'Topluluğa sor...',
                          filled: true,
                          fillColor: const Color(0xFFF6F5F1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadii.large),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    IconButton.filled(
                      onPressed: addPreviewMessage,
                      style: IconButton.styleFrom(backgroundColor: green),
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
