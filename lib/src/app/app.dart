part of '../../main.dart';

class DogaApp extends StatelessWidget {
  const DogaApp({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.mode,
      builder: (context, themeMode, _) => ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.current,
          builder: (context, locale, _) => MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Doğada',
                locale: locale,
                supportedLocales: AppLocaleController.supported,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: ThemeData(
                  useMaterial3: true,
                  brightness: Brightness.light,
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: AppColors.onPrimary,
                    primaryContainer: AppColors.primarySoft,
                    onPrimaryContainer: AppColors.primary,
                    secondary: AppColors.primary,
                    onSecondary: AppColors.onPrimary,
                    secondaryContainer: AppColors.surfaceMuted,
                    onSecondaryContainer: AppColors.textPrimary,
                    tertiary: AppColors.primary,
                    onTertiary: AppColors.onPrimary,
                    surface: AppColors.surface,
                    onSurface: AppColors.textPrimary,
                    surfaceContainerHighest: AppColors.surfaceMuted,
                    outline: AppColors.border,
                    outlineVariant: AppColors.border,
                    error: AppColors.error,
                    onError: AppColors.onPrimary,
                  ),
                  scaffoldBackgroundColor: AppColors.background,
                  canvasColor: AppColors.surface,
                  fontFamily: 'Outfit',
                  textTheme: const TextTheme(
                    displayLarge: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.6,
                    ),
                    displayMedium: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.5,
                    ),
                    headlineLarge: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.4,
                    ),
                    headlineMedium: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.3,
                    ),
                    headlineSmall: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.2,
                    ),
                    titleLarge: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                    ),
                    titleMedium: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w500,
                    ),
                    bodyLarge: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w400,
                    ),
                    bodyMedium: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w400,
                    ),
                    bodySmall: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  cardTheme: CardThemeData(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: AppColors.surface,
                    hintStyle: AppTypography.body.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.large,
                      vertical: AppSpacing.medium,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      borderSide: const BorderSide(color: green, width: 1.4),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      borderSide:
                          const BorderSide(color: AppColors.error, width: 1.4),
                    ),
                  ),
                  filledButtonTheme: FilledButtonThemeData(
                    style: FilledButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(0, AppControlSizes.button),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.medium),
                      ),
                    ),
                  ),
                  outlinedButtonTheme: OutlinedButtonThemeData(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ink,
                      side: const BorderSide(color: AppColors.border),
                      minimumSize: const Size(0, AppControlSizes.button),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.medium),
                      ),
                    ),
                  ),
                  dividerTheme: const DividerThemeData(
                    color: AppColors.border,
                    thickness: 1,
                    space: 1,
                  ),
                  iconTheme: const IconThemeData(
                    color: AppColors.textSecondary,
                  ),
                  listTileTheme: const ListTileThemeData(
                    iconColor: AppColors.textSecondary,
                    textColor: AppColors.textPrimary,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.medium,
                    ),
                  ),
                  chipTheme: ChipThemeData(
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary,
                    secondarySelectedColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                    labelStyle: AppTypography.label.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    secondaryLabelStyle: AppTypography.label.copyWith(
                      color: AppColors.onPrimary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                    backgroundColor: AppColors.surface,
                    selectedItemColor: AppColors.primary,
                    unselectedItemColor: AppColors.textSecondary,
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                  ),
                  appBarTheme: const AppBarTheme(
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    backgroundColor: AppColors.surface,
                    surfaceTintColor: Colors.transparent,
                    foregroundColor: AppColors.textPrimary,
                  ),
                  dialogTheme: DialogThemeData(
                    backgroundColor: AppColors.surface,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.large),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  bottomSheetTheme: const BottomSheetThemeData(
                    backgroundColor: AppColors.surface,
                    surfaceTintColor: Colors.transparent,
                    modalBackgroundColor: AppColors.surface,
                    modalBarrierColor: AppColors.shadow33,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadii.large),
                      ),
                    ),
                  ),
                  snackBarTheme: SnackBarThemeData(
                    behavior: SnackBarBehavior.floating,
                    elevation: 0,
                    backgroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                    ),
                  ),
                ),
                darkTheme: _buildDarkTheme(),
                themeMode: themeMode,
                home: const SplashScreen(),
                builder: (context, child) {
                  return Directionality(
                    textDirection: locale.languageCode == 'ar'
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    // Önizleme penceresinde de gerçek cihazda da uygulamayı
                    // dar bir telefon kartına sıkıştırma: ekranın tamamını
                    // kullanması gerekir.
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              )));
}

ThemeData _buildDarkTheme() {
  const background = AppColors.darkBackground;
  const surface = AppColors.darkSurface;
  const border = AppColors.darkBorder;
  const text = AppColors.darkTextPrimary;
  const secondaryText = AppColors.darkTextSecondary;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: green,
    brightness: Brightness.dark,
    surface: surface,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    canvasColor: surface,
    fontFamily: 'Outfit',
    textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Outfit',
          bodyColor: text,
          displayColor: text,
        ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        side: const BorderSide(color: border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      hintStyle: const TextStyle(color: secondaryText),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: border,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: text,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.large),
        side: const BorderSide(color: border),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: surface,
      modalBarrierColor: AppColors.shadow80,
      elevation: 0,
    ),
    listTileTheme: const ListTileThemeData(
      textColor: text,
      iconColor: secondaryText,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : secondaryText,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.darkPrimary
            : border,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: AppColors.darkPrimarySoft,
      contentTextStyle: const TextStyle(color: text),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.medium),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// AppStartupTimer — Başlangıç süresi ölçümü (U0 ölçüm zemini)
// ---------------------------------------------------------------------------

abstract final class AppStartupTimer {
  static final _sw = Stopwatch()..start();
  static final _marks = <String, int>{};

  static void mark(String name) {
    _marks[name] = _sw.elapsedMilliseconds;
    debugPrint('[StartupTimer] $name: ${_marks[name]}ms');
  }

  /// İki milestone arasındaki süreyi döndürür (ms).
  static int? elapsed(String from, String to) {
    final a = _marks[from];
    final b = _marks[to];
    if (a == null || b == null) return null;
    return b - a;
  }

  static Map<String, int> get snapshot => Map.unmodifiable(_marks);
}

// ---------------------------------------------------------------------------
// _AppStartupErrorApp — Supabase başlatma hatası ekranı
// ---------------------------------------------------------------------------

class _AppStartupErrorApp extends StatelessWidget {
  const _AppStartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.signal_wifi_off_rounded,
                  size: 56,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bağlantı kurulamadı',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  kIsWeb
                      ? 'İnternet bağlantını kontrol et ve sayfayı yenile.'
                      : 'İnternet bağlantını kontrol et; ardından uygulamayı kapatıp tekrar aç.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                if (!kIsWeb)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Uygulamayı kapat'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SplashScreen
// ---------------------------------------------------------------------------

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _onboardingSeenKey = 'onboarding_seen_v1';
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(milliseconds: 1100), _openNext);
  }

  Future<void> _openNext() async {
    final preferences = await SharedPreferences.getInstance();
    final hasSeenOnboarding = preferences.getBool(_onboardingSeenKey) ?? false;
    final hasSession = Supabase.instance.client.auth.currentSession != null;
    if (!mounted) return;

    final destination = hasSeenOnboarding
        ? (hasSession ? 'main_shell' : 'auth_screen')
        : 'onboarding';
    AppStartupTimer.mark('splash_nav_$destination');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => hasSeenOnboarding
            ? hasSession
                ? const MainShell()
                : const AuthScreen()
            : const OnboardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Image.asset(
            'assets/branding/dogadayim_logo_full.png',
            width: 270,
            fit: BoxFit.contain,
          ),
        ),
      );
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final controller = PageController();
  late final AnimationController entryController;
  late final Animation<double> entryScale;
  late final Animation<double> entryOpacity;
  int current = 0;
  bool finishing = false;

  @override
  void initState() {
    super.initState();
    entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    final curve = CurvedAnimation(
      parent: entryController,
      curve: Curves.easeOutCubic,
    );
    entryScale = Tween<double>(begin: 1.09, end: 1).animate(curve);
    entryOpacity = Tween<double>(begin: .55, end: 1).animate(curve);
    entryController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_precacheSlideImages());
    });
  }

  static const slides = [
    (
      'https://images.unsplash.com/photo-1693921443047-c59f572a485f?w=1000&h=1600&fit=crop',
      'KEŞFET',
      "Güvenilir Doğa\nNoktalarını Bul",
      'Ormanlar, şelaleler, göller ve dağlar... Doğrulanmış doğa noktalarını en güncel harita verileriyle keşfet.',
      AppColors.onboardingGreen,
    ),
    (
      'https://images.unsplash.com/photo-1728365084805-cf142cf7d275?w=1000&h=1600&fit=crop',
      'ALTYAPI & GÜVENLİK',
      'Gitmeden Önce\nHer Şeyi Gör',
      'İçme suyu, tuvalet, yol durumu, kamp imkanları ve acil durum güvenlik bilgilerini gitmeden öğren.',
      AppColors.onboardingWater,
    ),
    (
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1000&h=1600&fit=crop',
      'TOPLULUK & İYİLİK',
      'Keşfet, Doğrula,\nBirlikte Koru',
      'Yeni yerler ekle, topluluk verilerini doğrula, iyilik hareketiyle doğayı birlikte koru.',
      AppColors.onboardingCamp,
    ),
  ];

  Future<void> _precacheSlideImages() async {
    // Kullanıcı sonraki sayfaya geçtiğinde ağdan görsel beklemesin. Sırayla
    // önbelleğe almak ilk ekranın çizimini ve kaydırma karelerini engellemez.
    for (final slide in slides) {
      if (!mounted) return;
      await precacheImage(NetworkImage(slide.$1), context);
    }
  }

  @override
  void dispose() {
    entryController.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> finish() async {
    if (finishing) return;
    setState(() => finishing = true);
    await SharedPreferences.getInstance()
        .then((preferences) => preferences.setBool('onboarding_seen_v1', true));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 480),
        reverseTransitionDuration: const Duration(milliseconds: 360),
        pageBuilder: (_, __, ___) => const AuthScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.055, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  /// Kullanıcıyı giriş yapmadan direkt keşif ekranına alır.
  Future<void> guestFinish() async {
    if (finishing) return;
    setState(() => finishing = true);
    await SharedPreferences.getInstance()
        .then((preferences) => preferences.setBool('onboarding_seen_v1', true));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 480),
        reverseTransitionDuration: const Duration(milliseconds: 360),
        pageBuilder: (_, __, ___) => const MainShell(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.055, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void next() {
    if (current == slides.length - 1) {
      finish();
    } else {
      controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: AnimatedBuilder(
          animation: entryController,
          builder: (_, child) => Opacity(
            opacity: entryOpacity.value,
            child: Transform.scale(scale: entryScale.value, child: child),
          ),
          child: PageView.builder(
            controller: controller,
            physics: const PageScrollPhysics(),
            itemCount: slides.length,
            onPageChanged: (value) => setState(() => current = value),
            itemBuilder: (_, index) {
              final slide = slides[index];
              return RepaintBoundary(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(slide.$1,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: AppColors.surfaceMuted)),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            slide.$5,
                            AppColors.shadow08,
                            AppColors.shadow80,
                          ],
                          stops: const [0, .42, 1],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(26, 22, 26, 48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Semantics(
                                image: true,
                                label: 'Doğadayım',
                                child: Container(
                                  width: 150,
                                  height: 42,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: .94),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.asset(
                                    'assets/branding/dogadayim_logo_full.png',
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: finishing ? null : finish,
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    disabledForegroundColor: Colors.white54,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 12)),
                                child: const Text('Geç',
                                    style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: AppFontSizes.body,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ]),
                            const Spacer(flex: 6),
                            Text('●  ${slide.$2}',
                                style: const TextStyle(
                                    color: AppColors.darkPrimaryLight,
                                    fontSize: AppFontSizes.caption,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: .5)),
                            const SizedBox(height: 17),
                            Text(slide.$3,
                                style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    color: Colors.white,
                                    fontSize: 39,
                                    height: 1.08,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -.6)),
                            const SizedBox(height: 17),
                            Text(slide.$4,
                                style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    color: Colors.white70,
                                    height: 1.55,
                                    fontSize: AppFontSizes.title,
                                    fontWeight: FontWeight.w400)),
                            const Spacer(flex: 1),
                            Row(
                              children: List.generate(
                                slides.length,
                                (i) => Semantics(
                                  button: true,
                                  selected: i == current,
                                  label: '${i + 1}. tanıtım ekranı',
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: finishing || i == current
                                        ? null
                                        : () => controller.animateToPage(
                                              i,
                                              duration: const Duration(
                                                milliseconds: 360,
                                              ),
                                              curve: Curves.easeInOutCubic,
                                            ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 3,
                                      ),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 220),
                                        curve: Curves.easeOutCubic,
                                        width: i == current ? 25 : 6,
                                        height: 6,
                                        margin: const EdgeInsets.only(right: 7),
                                        decoration: BoxDecoration(
                                          color: i == current
                                              ? Colors.white
                                              : Colors.white38,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 27),
                            Center(
                              child: TextButton(
                                onPressed: finishing ? null : next,
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    disabledForegroundColor: Colors.white54,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 12)),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          index == slides.length - 1
                                              ? 'Keşfetmeye Başla'
                                              : 'Devam Et',
                                          style: const TextStyle(
                                              fontFamily: 'Outfit',
                                              fontSize: AppFontSizes.title,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 11),
                                      const Icon(Icons.arrow_forward_rounded,
                                          size: 19)
                                    ]),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Center(
                              child: TextButton(
                                onPressed: finishing ? null : guestFinish,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white60,
                                  disabledForegroundColor: Colors.white30,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 6),
                                ),
                                child: const Text(
                                  'Misafir olarak keşfet',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: AppFontSizes.label,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
        ),
      );
}

enum AuthMode { signIn, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  // Kayıt ekranı uygulamaya ilk kez gelen kişilerin ana akışıdır. Aynı
  // ekrandaki sekme, hesabı olanların girişe geçmesini sağlar.
  AuthMode _mode = AuthMode.signUp;
  bool _passwordVisible = false;
  bool _confirmVisible = false;
  bool _acceptedTerms = false;
  bool _loading = false;
  bool _openingApp = false;
  StreamSubscription<AuthState>? _authSubscription;
  late final TapGestureRecognizer _privacyPolicyRecognizer;
  late final TapGestureRecognizer _termsOfServiceRecognizer;
  late final TapGestureRecognizer _toggleTermsRecognizer;

  bool get _isSignUp => _mode == AuthMode.signUp;

  String _authText(String tr, String en, String ar) =>
      switch (AppLocaleController.current.value.languageCode) {
        'en' => en,
        'ar' => ar,
        _ => tr,
      };

  static String? get _authRedirectUrl =>
      kIsWeb ? Uri.base.origin : 'io.supabase.dogadagezi://login-callback/';

  @override
  void initState() {
    super.initState();
    _privacyPolicyRecognizer = TapGestureRecognizer()
      ..onTap = () => AppLegalLinks.openPrivacyPolicy(context);
    _termsOfServiceRecognizer = TapGestureRecognizer()
      ..onTap = () => AppLegalLinks.openTermsOfService(context);
    _toggleTermsRecognizer = TapGestureRecognizer()
      ..onTap = () => setState(() => _acceptedTerms = !_acceptedTerms);
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (state) {
        if (state.session != null &&
            state.event == AuthChangeEvent.signedIn &&
            mounted) {
          unawaited(PlaceSubmissionController.syncPending());
          _openApp();
        }
      },
    );
  }

  @override
  void dispose() {
    _privacyPolicyRecognizer.dispose();
    _termsOfServiceRecognizer.dispose();
    _toggleTermsRecognizer.dispose();
    _authSubscription?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _setMode(AuthMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _acceptedTerms = false;
    });
    _formKey.currentState?.reset();
  }

  void _openApp() {
    if (!mounted || _openingApp) return;
    _openingApp = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  void _showAuthError(Object error) {
    if (!mounted) return;
    final message = error is AuthException
        ? error.message
        : _authText(
            'İşlem tamamlanamadı. İnternet bağlantını kontrol edip tekrar dene.',
            'The action could not be completed. Check your connection and try again.',
            'تعذر إكمال العملية. تحقق من اتصالك وحاول مرة أخرى.',
          );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _socialSignIn(String provider) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        provider == 'apple' ? OAuthProvider.apple : OAuthProvider.google,
        redirectTo: _authRedirectUrl,
      );
    } catch (error) {
      _showAuthError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSignUp && !_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_authText(
          'Devam etmek için koşulları kabul et.',
          'Accept the terms to continue.',
          'وافق على الشروط للمتابعة.',
        ))),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (_isSignUp) {
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: <String, dynamic>{
            'full_name': _nameController.text.trim(),
            ...AppLegalLinks.termsAcceptanceMetadata(DateTime.now()),
          },
          emailRedirectTo: _authRedirectUrl,
        );
        if (!mounted) return;
        if (response.session == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_authText(
              'Hesabın oluşturuldu. E-postana gönderilen doğrulama bağlantısını aç.',
              'Your account was created. Open the verification link sent to your email.',
              'تم إنشاء حسابك. افتح رابط التحقق المرسل إلى بريدك الإلكتروني.',
            ))),
          );
          _setMode(AuthMode.signIn);
        } else {
          _openApp();
        }
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (mounted) _openApp();
      }
    } catch (error) {
      _showAuthError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _forgotPassword() {
    final controller = TextEditingController(text: _emailController.text);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (sheetContext) {
        final isSheetDark =
            Theme.of(sheetContext).brightness == Brightness.dark;
        return GlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          blur: 24,
          color: Colors.white.withValues(alpha: 0.94),
          darkColor: AppColors.darkGlass,
          borderColor: Colors.white.withValues(alpha: 0.95),
          darkBorderColor: Colors.white.withValues(alpha: 0.12),
          borderWidth: 1.2,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              12,
              24,
              MediaQuery.viewInsetsOf(sheetContext).bottom + 28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          isSheetDark ? AppColors.darkBorder : AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadii.large),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _authText('Şifreni yenile', 'Reset your password', 'إعادة تعيين كلمة المرور'),
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: AppFontSizes.display,
                    fontWeight: FontWeight.w500,
                    color: isSheetDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _authText('Bağlantıyı gönderebilmemiz için e-posta adresini yaz.', 'Enter your email address so we can send the link.', 'أدخل بريدك الإلكتروني لإرسال الرابط.'),
                  style: TextStyle(
                    fontSize: AppFontSizes.body,
                    color: isSheetDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                _AuthField(
                  controller: controller,
                  label: _authText('E-posta adresi', 'Email address', 'البريد الإلكتروني'),
                  hint: 'ornek@eposta.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: () async {
                      final email = controller.text.trim();
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(email)) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          SnackBar(
                            content: Text(_authText('Geçerli bir e-posta adresi yaz.', 'Enter a valid email address.', 'أدخل بريدًا إلكترونيًا صالحًا.')),
                          ),
                        );
                        return;
                      }
                      try {
                        await Supabase.instance.client.auth
                            .resetPasswordForEmail(
                          email,
                          redirectTo: _authRedirectUrl,
                        );
                        if (!sheetContext.mounted) return;
                        Navigator.pop(sheetContext);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_authText('Şifre yenileme bağlantısı gönderildi.', 'Password reset link sent.', 'تم إرسال رابط إعادة التعيين.')),
                          ),
                        );
                      } catch (error) {
                        if (!sheetContext.mounted) return;
                        final message = error is AuthException
                            ? error.message
                            : _authText('Bağlantı gönderilemedi. Tekrar dene.', 'The link could not be sent. Try again.', 'تعذر إرسال الرابط. حاول مرة أخرى.');
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.large),
                      ),
                    ),
                    child: Text(
                      _authText('Bağlantıyı Gönder', 'Send link', 'إرسال الرابط'),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(controller.dispose);
  }

  Widget _buildSocialAuthRow(bool isDark) => Row(
        children: [
          Expanded(
            child: _SocialAuthButton(
              label: 'Apple',
              mark: const Icon(Icons.apple, size: 23, color: Colors.white),
              dark: true,
              onPressed: _loading ? null : () => _socialSignIn('apple'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SocialAuthButton(
              label: 'Google',
              mark: const Text(
                'G',
                style: TextStyle(
                  fontSize: AppFontSizes.title,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandGoogle,
                ),
              ),
              onPressed: _loading ? null : () => _socialSignIn('google'),
            ),
          ),
        ],
      );

  Widget _buildAuthModeSwitcher(bool isDark) => Semantics(
        label: _authText('Hesap işlemi seçimi', 'Choose account action', 'اختر إجراء الحساب'),
        child: Container(
          key: const Key('auth_mode_switcher'),
          height: 52,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isDark ? .16 : .78),
            borderRadius: BorderRadius.circular(AppRadii.large),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? .18 : .88),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _AuthModeTab(
                  key: const Key('auth_sign_up_tab'),
                  label: _authText('Kayıt ol', 'Sign up', 'إنشاء حساب'),
                  selected: _isSignUp,
                  onTap: () => _setMode(AuthMode.signUp),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _AuthModeTab(
                  key: const Key('auth_sign_in_tab'),
                  label: _authText('Giriş yap', 'Sign in', 'تسجيل الدخول'),
                  selected: !_isSignUp,
                  onTap: () => _setMode(AuthMode.signIn),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildLanguageChooser() => ValueListenableBuilder<Locale>(
        valueListenable: AppLocaleController.current,
        builder: (context, locale, _) => Column(
          children: [
            Text(
              _authText('Uygulama dilini seç', 'Choose app language', 'اختر لغة التطبيق'),
              style: TextStyle(
                color: Colors.white,
                fontSize: AppFontSizes.caption,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                for (final option in AppLocaleController.options)
                  ChoiceChip(
                    label: Text(option.nativeLabel),
                    selected: locale.languageCode == option.locale.languageCode,
                    onSelected: (_) =>
                        unawaited(AppLocaleController.setLocale(option.locale)),
                    selectedColor: Colors.white,
                    backgroundColor: Colors.black.withValues(alpha: .28),
                    labelStyle: TextStyle(
                      color: locale.languageCode == option.locale.languageCode
                          ? AppColors.primary
                          : Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: .58),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.surfaceMuted,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Kullanıcının seçtiği sisli orman görseli giriş ekranının ana
          // atmosferidir. Üstteki koyu geçiş, form ve marka alanını her
          // ekranda okunur tutar.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/auth_misty_forest.jpg'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  filterQuality: FilterQuality.high,
                  colorFilter: ColorFilter.mode(
                    Color(0x770B482A),
                    BlendMode.srcOver,
                  ),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          AppColors.darkSurfaceDeep.withValues(alpha: .90),
                          AppColors.darkBackground.withValues(alpha: .82),
                          AppColors.darkSurface.withValues(alpha: .90),
                        ]
                      : [
                          AppColors.primary.withValues(alpha: .62),
                          AppColors.primary.withValues(alpha: .48),
                          AppColors.primaryPressed.withValues(alpha: .74),
                        ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -60,
                    left: -40,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            (isDark ? AppColors.darkPrimary : AppColors.primary)
                                .withValues(alpha: isDark ? 0.14 : 0.12),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 240,
                    right: -60,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.categoryNature
                            .withValues(alpha: isDark ? 0.10 : 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: -40,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isDark
                                ? AppColors.darkPrimarySoft
                                : AppColors.accentOrange)
                            .withValues(alpha: isDark ? 0.15 : 0.09),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GlassIconButton(
                              icon: Icons.arrow_back_rounded,
                              onTap: () => Navigator.maybePop(context),
                              iconColor: AppColors.textPrimary,
                              darkIconColor: AppColors.darkTextPrimary,
                              size: 44,
                              iconSize: 22,
                              blur: 14,
                              color: Colors.white.withValues(alpha: 0.65),
                              darkColor: AppColors.darkGlass,
                              borderColor: Colors.white.withValues(alpha: 0.90),
                              darkBorderColor:
                                  Colors.white.withValues(alpha: 0.14),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .84),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.large),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: .92),
                                ),
                              ),
                              child: Image.asset(
                                'assets/branding/dogadayim_logo_full.png',
                                width: 220,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildAuthModeSwitcher(isDark),
                          const SizedBox(height: 16),
                          _buildSocialAuthRow(isDark),
                          const SizedBox(height: 16),
                          Row(children: [
                            Expanded(
                              child: Divider(
                                color: Colors.white.withValues(alpha: .70),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                _authText('veya e-posta ile', 'or continue with email', 'أو تابع بالبريد الإلكتروني'),
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: AppFontSizes.caption,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: .88),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.white.withValues(alpha: .70),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_isSignUp) ...[
                                _AuthField(
                                  controller: _nameController,
                                  label: _authText('Ad soyad', 'Full name', 'الاسم الكامل'),
                                  hint: _authText('Ad Soyad', 'Full name', 'الاسم الكامل'),
                                  icon: Icons.person_outline_rounded,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) =>
                                      (value?.trim().length ?? 0) < 3
                                          ? _authText('Adını ve soyadını yaz.', 'Enter your full name.', 'أدخل اسمك الكامل.')
                                          : null,
                                ),
                                const SizedBox(height: 12),
                              ],
                              _AuthField(
                                controller: _emailController,
                                  label: _authText('E-posta', 'Email', 'البريد الإلكتروني'),
                                hint: 'ornek@eposta.com',
                                icon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  final email = value?.trim() ?? '';
                                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                      .hasMatch(email)) {
                                    return _authText('Geçerli bir e-posta adresi yaz.', 'Enter a valid email address.', 'أدخل بريدًا إلكترونيًا صالحًا.');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _AuthField(
                                controller: _passwordController,
                                label: _authText('Şifre', 'Password', 'كلمة المرور'),
                                hint: _isSignUp
                                    ? _authText('En az 8 karakter', 'At least 8 characters', '8 أحرف على الأقل')
                                    : _authText('Şifreni yaz', 'Enter your password', 'أدخل كلمة المرور'),
                                icon: Icons.lock_outline_rounded,
                                obscureText: !_passwordVisible,
                                textInputAction: _isSignUp
                                    ? TextInputAction.next
                                    : TextInputAction.done,
                                suffix: IconButton(
                                  onPressed: () => setState(() =>
                                      _passwordVisible = !_passwordVisible),
                                  icon: Icon(_passwordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined),
                                ),
                                validator: (value) => (value?.length ?? 0) < 8
                                    ? _authText('Şifre en az 8 karakter olmalı.', 'Password must be at least 8 characters.', 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل.')
                                    : null,
                                onSubmitted: (_) {
                                  if (!_isSignUp) _submit();
                                },
                              ),
                              if (_isSignUp) ...[
                                const SizedBox(height: 12),
                                _AuthField(
                                  controller: _confirmController,
                                  label: _authText('Şifre tekrarı', 'Repeat password', 'تأكيد كلمة المرور'),
                                  hint: _authText('Şifreni yeniden yaz', 'Enter your password again', 'أدخل كلمة المرور مرة أخرى'),
                                  icon: Icons.verified_user_outlined,
                                  obscureText: !_confirmVisible,
                                  textInputAction: TextInputAction.done,
                                  suffix: IconButton(
                                    onPressed: () => setState(() =>
                                        _confirmVisible = !_confirmVisible),
                                    icon: Icon(_confirmVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined),
                                  ),
                                  validator: (value) =>
                                      value != _passwordController.text
                                          ? _authText('Şifreler birbiriyle aynı değil.', 'Passwords do not match.', 'كلمتا المرور غير متطابقتين.')
                                          : null,
                                  onSubmitted: (_) => _submit(),
                                ),
                              ] else
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _forgotPassword,
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.only(
                                          top: 9, bottom: 8),
                                    ),
                                    child: Text(
                                      _authText('Şifremi unuttum', 'Forgot password?', 'نسيت كلمة المرور؟'),
                                      style: TextStyle(
                                          fontSize: AppFontSizes.label,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              if (_isSignUp) ...[
                                const SizedBox(height: 8),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 23,
                                        height: 23,
                                        child: Checkbox(
                                          value: _acceptedTerms,
                                          onChanged: (value) => setState(() =>
                                              _acceptedTerms = value ?? false),
                                          activeColor: isDark
                                              ? AppColors.darkPrimary
                                              : AppColors.primary,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(children: [
                                            TextSpan(
                                              text: _authText('Kullanım Şartları', 'Terms of Service', 'شروط الاستخدام'),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                              recognizer:
                                                  _termsOfServiceRecognizer,
                                            ),
                                            TextSpan(text: _authText(' ve ', ' and ', ' و')),
                                            TextSpan(
                                              text: _authText('Gizlilik Politikası', 'Privacy Policy', 'سياسة الخصوصية'),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                              recognizer:
                                                  _privacyPolicyRecognizer,
                                            ),
                                            TextSpan(
                                              text: _authText('’nı okudum, kabul ediyorum.', ' — I have read and accept.', ' — قرأت وأوافق.'),
                                              recognizer:
                                                  _toggleTermsRecognizer,
                                            ),
                                          ]),
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: AppFontSizes.caption,
                                            height: 1.45,
                                            color: Colors.white
                                                .withValues(alpha: .90),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 13),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: FilledButton(
                                  onPressed:
                                      _loading || (_isSignUp && !_acceptedTerms)
                                          ? null
                                          : _submit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: isDark
                                        ? AppColors.darkPrimary
                                        : AppColors.primary,
                                    disabledBackgroundColor: isDark
                                        ? AppColors.darkPrimarySoft
                                        : AppColors.disabled,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(AppRadii.large),
                                    ),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _authText('Devam et', 'Continue', 'متابعة'),
                                              style: const TextStyle(
                                                  fontSize: AppFontSizes.title,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 19),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: GlassContainer(
                              borderRadius:
                                  BorderRadius.circular(AppRadii.large),
                              blur: 14,
                              color: Colors.white.withValues(alpha: 0.65),
                              darkColor: AppColors.darkGlass,
                              borderColor: Colors.white.withValues(alpha: 0.90),
                              darkBorderColor:
                                  Colors.white.withValues(alpha: 0.14),
                              borderWidth: 1.2,
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? AppColors.shadow26
                                      : AppColors.shadow08,
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _openApp,
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.large),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.explore_outlined,
                                          size: 20,
                                          color: isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.textPrimary),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Misafir olarak devam et',
                                        style: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: AppFontSizes.body,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildLanguageChooser(),
                        ],
                      ),
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

class _SocialAuthButton extends StatelessWidget {
  const _SocialAuthButton({
    required this.label,
    required this.mark,
    required this.onPressed,
    this.dark = false,
  });

  final String label;
  final Widget mark;
  final VoidCallback? onPressed;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 52,
      child: GlassContainer(
        borderRadius: BorderRadius.circular(AppRadii.large),
        blur: 14,
        color:
            dark ? AppColors.darkGlass : Colors.white.withValues(alpha: 0.68),
        darkColor: dark ? AppColors.darkGlass : AppColors.darkSurfaceMuted,
        borderColor: dark
            ? Colors.white.withValues(alpha: 0.16)
            : (isDark
                ? Colors.white.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.90)),
        darkBorderColor: dark
            ? Colors.white.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.14),
        borderWidth: 1.2,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadow26 : AppColors.shadow08,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadii.large),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                mark,
                const SizedBox(width: 9),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: AppFontSizes.body,
                    fontWeight: FontWeight.w700,
                    color: dark
                        ? Colors.white
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthModeTab extends StatelessWidget {
  const _AuthModeTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Material(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.medium),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadii.medium),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: AppFontSizes.body,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      );
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffix,
    this.validator,
    this.onSubmitted,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Form artık doğrudan fotoğraf üzerinde; etiketler tema yerine bu yüzeyin
    // kontrast ihtiyacına göre beyaz kalır.
    final labelColor = Colors.white;
    final fieldFillColor = isDark
        ? AppColors.darkSurfaceMuted
        : Colors.white.withValues(alpha: 0.78);
    final fieldBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.95);
    final textColor = AppColors.textPrimary;
    final hintColor =
        isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    final iconColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSizes.label,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          validator: validator,
          onFieldSubmitted: onSubmitted,
          autocorrect: false,
          enableSuggestions: !obscureText,
          style: TextStyle(fontSize: AppFontSizes.body, color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: hintColor,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(icon, size: 20, color: iconColor),
            suffixIcon: suffix,
            filled: true,
            fillColor: fieldFillColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.large),
              borderSide: BorderSide(
                color: fieldBorderColor,
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.large),
              borderSide: const BorderSide(color: green, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.large),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.large),
              borderSide: const BorderSide(color: AppColors.error, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _mapNavigationIdleDuration = Duration(seconds: 6);
  int index = 0;
  Set<String> get favorites => UserFavoritesController.favorites.value;
  late List<Widget?> _tabScreens;
  Timer? _locationReminderTimer;
  Timer? _mapNavigationTimer;
  final ValueNotifier<bool> _mapNavigationVisibility = ValueNotifier(true);
  bool _locationReminderShown = false;
  bool _isMapNavigationVisible = true;

  @override
  void initState() {
    super.initState();
    AppLocaleController.current.addListener(_onLocaleChanged);
    // İyilik ekranını önceden oluştur: alt menüde sekme seçiliyken boş
    // önbellek hücresinin görünmesine izin verme.
    _tabScreens = <Widget?>[
      _createTab(0),
      null,
      const GoodnessMovementScreen(),
      null,
    ];
  }

  @override
  void dispose() {
    AppLocaleController.current.removeListener(_onLocaleChanged);
    _locationReminderTimer?.cancel();
    _mapNavigationTimer?.cancel();
    _mapNavigationVisibility.dispose();
    super.dispose();
  }

  void _setMapNavigationVisibility(bool visible) {
    if (_isMapNavigationVisible == visible) return;
    _mapNavigationVisibility.value = visible;
    if (mounted) setState(() => _isMapNavigationVisible = visible);
  }

  /// Harita, içeriğin önünde kalması için kısa bir süre sonra alt menüyü
  /// kapatır. Kullanıcı haritaya yeniden dokunduğunda menü hemen geri gelir.
  void _registerMapInteraction() {
    if (index != 1) return;
    _mapNavigationTimer?.cancel();
    _setMapNavigationVisibility(true);
    _mapNavigationTimer = Timer(_mapNavigationIdleDuration, () {
      if (mounted && index == 1) {
        _setMapNavigationVisibility(false);
      }
    });
  }

  void _showMapNavigation() {
    _mapNavigationTimer?.cancel();
    if (!_isMapNavigationVisible) {
      _setMapNavigationVisibility(true);
    }
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {
        _tabScreens = <Widget?>[null, null, null, null];
        _tabScreens[index] = _createTab(index);
      });
    }
  }

  void scheduleLocationReminder() {
    if (_locationReminderShown ||
        HomeWeatherLocationController.current.value.usesCoordinates) {
      return;
    }
    _locationReminderTimer?.cancel();
    _locationReminderTimer = Timer(const Duration(minutes: 1), () {
      if (!mounted ||
          _locationReminderShown ||
          HomeWeatherLocationController.current.value.usesCoordinates) {
        return;
      }
      _locationReminderShown = true;
      showLocationReminder();
    });
  }

  void showLocationReminder() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentMaterialBanner();
    messenger.showMaterialBanner(
      MaterialBanner(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceMuted : Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.large),
          ),
          child: Icon(
            Icons.location_on_outlined,
            color: isDark ? AppColors.darkPrimaryLight : green,
            size: 22,
          ),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yakınındaki doğayı keşfet',
              style: TextStyle(
                fontFamily: 'Outfit',
                color: isDark ? AppColors.darkTextPrimary : ink,
                fontSize: AppFontSizes.title,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Doğru hava durumu ve yakınındaki yerler için konumunu açabilirsin.',
              style: TextStyle(
                fontFamily: 'Outfit',
                color: Colors.white.withValues(alpha: .92),
                fontSize: AppFontSizes.caption,
                height: 1.35,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: Text(
              'Daha Sonra',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : null,
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              messenger.hideCurrentMaterialBanner();
              unawaited(offerLocationPermission());
            },
            style: FilledButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.my_location_rounded, size: 16),
            label: const Text('Konumu Aç'),
          ),
        ],
      ),
    );
  }

  Future<void> offerLocationPermission() async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.large)),
        contentPadding: const EdgeInsets.fromLTRB(22, 24, 22, 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: mint,
                borderRadius: BorderRadius.circular(AppRadii.large),
              ),
              child:
                  const Icon(Icons.my_location_rounded, color: green, size: 27),
            ),
            const SizedBox(height: 17),
            Text(
              AppStrings.get('location_dialog_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Outfit',
                color: ink,
                fontSize: AppFontSizes.heading,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              AppStrings.get('location_dialog_desc'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Outfit',
                color: AppColors.textSecondary,
                fontSize: AppFontSizes.caption,
                height: 1.5,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
        actions: [
          Row(children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  minimumSize: const Size.fromHeight(47),
                ),
                child: Text(AppStrings.get('location_dialog_not_now')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: FilledButton.styleFrom(
                  backgroundColor: green,
                  minimumSize: const Size.fromHeight(47),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.large),
                  ),
                ),
                icon: const Icon(Icons.location_on_rounded, size: 18),
                label: Text(AppStrings.get('location_dialog_allow')),
              ),
            ),
          ]),
        ],
      ),
    );
    if (accepted != true || !mounted) {
      scheduleLocationReminder();
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 4),
        content: Row(children: [
          Icon(Icons.my_location_rounded, color: Colors.white, size: 18),
          SizedBox(width: 9),
          Text('Konum belirleniyor...'),
        ]),
      ),
    );

    try {
      final coordinates =
          await HomeWeatherLocationController.requestAndUseDeviceLocation();
      if (!mounted) return;
      _locationReminderTimer?.cancel();
      messenger.hideCurrentMaterialBanner();
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            coordinates.isApproximate
                ? '${coordinates.label} için yaklaşık konum kullanıldı; hava durumu ve yakındaki yerler güncellendi.'
                : 'Hava durumu ve yakındaki yerler kesin konumuna göre güncellendi.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      scheduleLocationReminder();
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          action: SnackBarAction(
            label: 'Tekrar Dene',
            onPressed: offerLocationPermission,
          ),
        ),
      );
    }
  }

  void open(Place p) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailScreen(
            place: p,
            favorite: UserFavoritesController.isFavorite(p.name),
            onOpen: open,
            onShowOnMap: (targetPlace) {
              Navigator.pop(context);
              selectTab(1);
              MapFocusController.focus(targetPlace);
            },
            onFavorite: () async {
              await UserFavoritesController.toggle(p.name);
              if (mounted) {
                setState(() {
                  _tabScreens[2] = null;
                });
              }
            },
          ),
        ),
      );

  Future<void> openAddPlace() async {
    final allowed = await AppAuthGuard.requireAuth(
      context,
      title: AppStrings.get('guest_auth_title'),
      message: AppStrings.get('guest_add_place_prompt'),
    );
    if (!allowed || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPlaceScreen(
          onOpenExisting: open,
          onContributeToExisting: open,
        ),
      ),
    );
  }

  void _openNearbyPlacesOnMap() {
    final target = HomeWeatherLocationController.current.value;
    selectTab(1);
    if (!target.usesCoordinates) return;
    MapRegionFocusController.focus(
      MapRegionFocus(
        label: target.label,
        center: LatLng(target.latitude!, target.longitude!),
        zoom: 11.5,
      ),
    );
  }

  Widget _createTab(int tabIndex) => switch (tabIndex) {
        0 => FigmaHomeScreen(
            onOpen: open,
            onExploreMap: _openNearbyPlacesOnMap,
            onExploreProvince: (region) {
              selectTab(1);
              MapRegionFocusController.focus(region);
            },
            onRequestLocation: () => unawaited(offerLocationPermission()),
            onAddPlace: openAddPlace,
            onMessages: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CommunityChatHubScreen(),
              ),
            ),
            onSearch: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FigmaSearchScreen(onOpen: open),
              ),
            ),
          ),
        1 => MapScreen(
            onOpen: open,
            onUserInteraction: _registerMapInteraction,
            bottomNavigationVisible: _mapNavigationVisibility,
          ),
        2 => const GoodnessMovementScreen(),
        _ => FigmaProfileScreen(onOpen: open),
      };

  Future<void> selectTab(int value) async {
    if (value == 3 && AppAuthGuard.isGuest) {
      final allowed = await AppAuthGuard.requireAuth(
        context,
        title: AppStrings.get('guest_auth_title'),
        message: 'Profilini görüntülemek ve yönetmek için giriş yapmalısın.',
      );
      if (!allowed || !mounted) return;
    }
    if (value == index && _tabScreens[value] != null) return;
    setState(() {
      index = value;
      _tabScreens[value] ??= _createTab(value);
    });
    if (value == 1) {
      _registerMapInteraction();
    } else {
      _showMapNavigation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showNavigation = index != 1 || _isMapNavigationVisible;
    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          IndexedStack(
            index: index,
            children: List<Widget>.generate(
              _tabScreens.length,
              // A locale/theme rebuild can temporarily clear an inactive
              // cached tab. Never render a blank page for a selected item.
              (tabIndex) =>
                  _tabScreens[tabIndex] ??
                  (tabIndex == index
                      ? _createTab(tabIndex)
                      : const SizedBox.shrink()),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              reverseDuration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, .22),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: showNavigation
                  ? KeyedSubtree(
                      key: const Key('map_auto_hiding_bottom_navigation'),
                      child: _FigmaBottomBar(
                        index: index,
                        onChanged: selectTab,
                        onAdd: openAddPlace,
                      ),
                    )
                  : const SizedBox.shrink(
                      key: ValueKey('map_navigation_hidden'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FigmaBottomBar extends StatelessWidget {
  const _FigmaBottomBar(
      {required this.index, required this.onChanged, required this.onAdd});
  final int index;
  final ValueChanged<int> onChanged;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: SizedBox(
        height: AppControlSizes.bottomNavigation,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Positioned.fill(
                  child: Material(
                    key: const Key('figma_floating_bottom_bar'),
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.zero,
                    child: Container(
                      key: const Key('figma_attached_navigation_surface'),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.border,
                          ),
                        ),
                      ),
                      child: DecoratedBox(
                        key: const Key('figma_navigation_surface'),
                        decoration: const BoxDecoration(),
                        child: ValueListenableBuilder<Locale>(
                          valueListenable: AppLocaleController.current,
                          builder: (context, _, __) => Row(children: [
                            Expanded(
                              child: _FigmaNavItem(
                                index: 0,
                                current: index,
                                icon: Icons.explore_outlined,
                                activeIcon: Icons.explore_rounded,
                                label: AppStrings.get('tab_discover'),
                                onTap: onChanged,
                              ),
                            ),
                            Expanded(
                              child: _FigmaNavItem(
                                index: 1,
                                current: index,
                                icon: Icons.map_outlined,
                                activeIcon: Icons.map_outlined,
                                label: AppStrings.get('tab_map'),
                                onTap: onChanged,
                              ),
                            ),
                            const SizedBox(width: 60),
                            Expanded(
                              child: _FigmaNavItem(
                                index: 2,
                                current: index,
                                icon: Icons.volunteer_activism_outlined,
                                activeIcon: Icons.volunteer_activism_rounded,
                                label: AppStrings.get('tab_goodness'),
                                onTap: onChanged,
                                customIconBuilder: (active, color) =>
                                    _GoodnessImpactIcon(
                                  active: active,
                                  color: color,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _FigmaNavItem(
                                index: 3,
                                current: index,
                                icon: Icons.account_circle_outlined,
                                activeIcon: Icons.account_circle_rounded,
                                label: AppStrings.get('tab_profile'),
                                onTap: onChanged,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 13,
                  child: ValueListenableBuilder<Locale>(
                    valueListenable: AppLocaleController.current,
                    builder: (context, _, __) => Semantics(
                      label: AppStrings.get('tab_add_place'),
                      button: true,
                      child: Tooltip(
                        message: AppStrings.get('tab_add_place'),
                        child: Material(
                          key: const Key('figma_center_add_button'),
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.primary,
                          shape: const CircleBorder(),
                          elevation: 5,
                          shadowColor: Colors.black.withValues(alpha: .28),
                          child: InkWell(
                            onTap: onAdd,
                            customBorder: const CircleBorder(),
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 29,
                              ),
                            ),
                          ),
                        ),
                      ),
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
}

class _FigmaNavItem extends StatelessWidget {
  const _FigmaNavItem(
      {required this.index,
      required this.current,
      required this.icon,
      required this.activeIcon,
      required this.label,
      required this.onTap,
      this.customIconBuilder});
  final int index, current;
  final IconData icon, activeIcon;
  final String label;
  final ValueChanged<int> onTap;
  final Widget Function(bool active, Color color)? customIconBuilder;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final active = index == current;
    final color = active
        ? (isDark ? AppColors.darkPrimaryLight : AppColors.primary)
        : (isDark ? AppColors.darkTextTertiary : AppColors.textTertiary);
    return Semantics(
      label: label,
      selected: active,
      button: true,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: () => _runWithSelectionHaptic(() => onTap(index)),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 180),
                      scale: active ? 1.08 : 1,
                      child: customIconBuilder?.call(active, color) ??
                          Icon(active ? activeIcon : icon,
                              color: color, size: 23),
                    ),
                    const SizedBox(height: 3),
                    Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            color: color,
                            fontSize: 10,
                            height: 1.1,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500)),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// A small brand mark for the İyilik tab: a seedling whose influence spreads
/// outward instead of the generic hand-heart metaphor.
class _GoodnessImpactIcon extends StatelessWidget {
  const _GoodnessImpactIcon({required this.active, required this.color});

  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox(
          key: const Key('goodness_impact_icon'),
          width: 25,
          height: 25,
          child: CustomPaint(
            painter: _GoodnessImpactPainter(color),
            child: Center(
              child: Icon(
                active ? Icons.eco_rounded : Icons.eco_outlined,
                color: color,
                size: 14,
              ),
            ),
          ),
        ),
      );
}

class _GoodnessImpactPainter extends CustomPainter {
  const _GoodnessImpactPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.65
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    final outer = Rect.fromCircle(center: center, radius: 10.5);
    final inner = Rect.fromCircle(center: center, radius: 7.3);
    // Two pairs of arcs leave breathing space around the seedling while
    // suggesting that one small action can spread through a community.
    canvas.drawArc(outer, -2.42, 1.12, false, paint);
    canvas.drawArc(outer, .72, 1.12, false, paint);
    canvas.drawArc(inner, -2.30, .72, false, paint);
    canvas.drawArc(inner, .84, .72, false, paint);
  }

  @override
  bool shouldRepaint(covariant _GoodnessImpactPainter oldDelegate) =>
      oldDelegate.color != color;
}
