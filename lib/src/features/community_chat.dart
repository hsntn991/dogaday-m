part of '../../main.dart';

class CommunityChatHubScreen extends StatelessWidget {
  const CommunityChatHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('community_chats_title')),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
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
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              fontSize: AppFontSizes.label,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          ..._homeCategories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ChatCategoryTile(
                emoji: category.emoji,
                title: category.localizedLabel,
                iconColor: category.foreground,
                iconBackground: category.background,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      borderRadius: BorderRadius.circular(AppRadii.large),
      blur: 10,
      color: Colors.white.withValues(alpha: 0.72),
      borderColor: Colors.white.withValues(alpha: 0.88),
      borderWidth: 1.2,
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
                    color: isDark
                        ? iconBackground.withValues(alpha: 0.25)
                        : iconBackground,
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
                          fontSize: AppFontSizes.body,
                          fontWeight: FontWeight.w600,
                        ),
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
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
                          Text(
                            AppStrings.get('community_chat_no_messages'),
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: AppFontSizes.title,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppLocaleController.current.value.languageCode ==
                                    'tr'
                                ? '${widget.category} ${AppStrings.get('community_chat_first_message_prompt')}'
                                : '${AppStrings.get('community_chat_first_message_prompt')} ${widget.category}.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: AppColors.textTertiary,
                              fontSize: AppFontSizes.label,
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
                            borderRadius: BorderRadius.circular(AppRadii.large),
                          ),
                          child: Text(
                            message,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: Colors.white,
                              fontSize: AppFontSizes.label,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
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
              child: Row(
                children: [
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
                        hintText: AppStrings.get('community_chat_input_hint'),
                        hintStyle: TextStyle(
                          color: isDark ? AppColors.darkTextTertiary : null,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.13)
                            : AppColors.surfaceMuted,
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
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? AppColors.darkPrimary : green,
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
