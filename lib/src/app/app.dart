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
                    secondary: AppColors.primary,
                    onSecondary: AppColors.onPrimary,
                    surface: AppColors.surface,
                    onSurface: AppColors.textPrimary,
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
                  final mediaQuery = MediaQuery.of(context);
                  final isWide = mediaQuery.size.width > 430;
                  final effectiveWidth = isWide ? 430.0 : mediaQuery.size.width;
                  final effectiveMediaQuery = mediaQuery.copyWith(
                    size: Size(effectiveWidth, mediaQuery.size.height),
                  );

                  Widget appContent = MediaQuery(
                    data: effectiveMediaQuery,
                    child: child ?? const SizedBox.shrink(),
                  );

                  if (isWide) {
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    appContent = Center(
                      child: Container(
                        width: 430,
                        height: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? const Color(0x66000000)
                                  : const Color(0x22000000),
                              blurRadius: 32,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: appContent,
                      ),
                    );
                  }

                  return Directionality(
                    textDirection: locale.languageCode == 'ar'
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: ColoredBox(
                      color: isWide
                          ? (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF0F1411)
                              : const Color(0xFFE4E9E6))
                          : Theme.of(context).scaffoldBackgroundColor,
                      child: appContent,
                    ),
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
        backgroundColor: const Color(0xFFF5F5F0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.signal_wifi_off_rounded,
                    size: 56, color: Color(0xFF888880)),
                const SizedBox(height: 20),
                const Text(
                  'Bağlantı kurulamadı',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2718),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'İnternet bağlantını kontrol et ve uygulamayı yeniden başlat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B6B60)),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A4F),
                  ),
                  onPressed: () {
                    // Web'de sayfayı yenile
                    if (kIsWeb) {
                      // ignore: avoid_dynamic_calls
                      // dart:html bağımlılığı eklememek için url_launcher kullanılıyor.
                    }
                    // Native'de uygulama yeniden başlatılamaz; kullanıcı manuel yapar.
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Yeniden Dene'),
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
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeInOutCubic,
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
            physics: const BouncingScrollPhysics(),
            itemCount: slides.length,
            onPageChanged: (value) => setState(() => current = value),
            itemBuilder: (_, index) {
              final slide = slides[index];
              return AnimatedBuilder(
                animation: controller,
                builder: (_, child) {
                  var page = current.toDouble();
                  if (controller.hasClients &&
                      controller.position.hasContentDimensions) {
                    page = controller.page ?? page;
                  }
                  final distance = (page - index).abs().clamp(0.0, 1.0);
                  return Opacity(
                    opacity: 1 - (.18 * distance),
                    child: Transform.scale(
                      scale: 1 + (.05 * distance),
                      child: child,
                    ),
                  );
                },
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
  AuthMode _mode = AuthMode.signIn;
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
        : 'İşlem tamamlanamadı. İnternet bağlantını kontrol edip tekrar dene.';
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
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Devam etmek için koşulları kabul et.')),
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
            const SnackBar(
              content: Text(
                'Hesabın oluşturuldu. E-postana gönderilen doğrulama bağlantısını aç.',
              ),
            ),
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
                  'Şifreni yenile',
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
                  'Bağlantıyı gönderebilmemiz için e-posta adresini yaz.',
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
                  label: 'E-posta adresi',
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
                          const SnackBar(
                            content: Text('Geçerli bir e-posta adresi yaz.'),
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
                          const SnackBar(
                            content:
                                Text('Şifre yenileme bağlantısı gönderildi.'),
                          ),
                        );
                      } catch (error) {
                        if (!sheetContext.mounted) return;
                        final message = error is AuthException
                            ? error.message
                            : 'Bağlantı gönderilemedi. Tekrar dene.';
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
                    child: const Text(
                      'Bağlantıyı Gönder',
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

  Widget _buildLanguageChooser() => ValueListenableBuilder<Locale>(
        valueListenable: AppLocaleController.current,
        builder: (context, locale, _) => Column(
          children: [
            const Text(
              'Uygulama dilini seç',
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
                          const SizedBox(height: 26),
                          _buildSocialAuthRow(isDark),
                          const SizedBox(height: 20),
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
                                'veya e-posta ile',
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
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_isSignUp) ...[
                                _AuthField(
                                  controller: _nameController,
                                  label: 'Ad soyad',
                                  hint: 'Ad Soyad',
                                  icon: Icons.person_outline_rounded,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) =>
                                      (value?.trim().length ?? 0) < 3
                                          ? 'Adını ve soyadını yaz.'
                                          : null,
                                ),
                                const SizedBox(height: 16),
                              ],
                              _AuthField(
                                controller: _emailController,
                                label: 'E-posta',
                                hint: 'ornek@eposta.com',
                                icon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  final email = value?.trim() ?? '';
                                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                      .hasMatch(email)) {
                                    return 'Geçerli bir e-posta adresi yaz.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _AuthField(
                                controller: _passwordController,
                                label: 'Şifre',
                                hint: _isSignUp
                                    ? 'En az 8 karakter'
                                    : 'Şifreni yaz',
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
                                    ? 'Şifre en az 8 karakter olmalı.'
                                    : null,
                                onSubmitted: (_) {
                                  if (!_isSignUp) _submit();
                                },
                              ),
                              if (_isSignUp) ...[
                                const SizedBox(height: 16),
                                _AuthField(
                                  controller: _confirmController,
                                  label: 'Şifre tekrarı',
                                  hint: 'Şifreni yeniden yaz',
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
                                          ? 'Şifreler birbiriyle aynı değil.'
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
                                    child: const Text(
                                      'Şifremi unuttum',
                                      style: TextStyle(
                                          fontSize: AppFontSizes.label,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            text: 'Kullanım Şartları',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            recognizer:
                                                _termsOfServiceRecognizer,
                                          ),
                                          const TextSpan(text: ' ve '),
                                          TextSpan(
                                            text: 'Gizlilik Politikası',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            recognizer:
                                                _privacyPolicyRecognizer,
                                          ),
                                          TextSpan(
                                            text: '’nı okudum, kabul ediyorum.',
                                            recognizer: _toggleTermsRecognizer,
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
                              const SizedBox(height: 13),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: FilledButton(
                                  onPressed: _loading || !_acceptedTerms
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
                                              _isSignUp
                                                  ? 'Hesap oluştur'
                                                  : 'Devam et',
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
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () => _setMode(_isSignUp
                                    ? AuthMode.signIn
                                    : AuthMode.signUp),
                                child: Text(
                                    _isSignUp
                                        ? 'Zaten hesabın var mı? Giriş yap'
                                        : 'Hesabın yok mu? Hesap oluştur',
                                    style: TextStyle(
                                        fontFamily: 'Outfit',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
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
  int index = 0;
  Set<String> get favorites => UserFavoritesController.favorites.value;
  late List<Widget?> _tabScreens;
  Timer? _locationReminderTimer;
  bool _locationReminderShown = false;

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
    super.dispose();
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

  Widget _createTab(int tabIndex) => switch (tabIndex) {
        0 => FigmaHomeScreen(
            onOpen: open,
            onExploreMap: () => selectTab(1),
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
        1 => MapScreen(onOpen: open),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: index,
        children: List<Widget>.generate(
          _tabScreens.length,
          // A locale/theme rebuild can temporarily clear an inactive cached
          // tab. Never render a blank page for a selected navigation item.
          (tabIndex) =>
              _tabScreens[tabIndex] ??
              (tabIndex == index
                  ? _createTab(tabIndex)
                  : const SizedBox.shrink()),
        ),
      ),
      bottomNavigationBar: _FigmaBottomBar(
        index: index,
        onChanged: selectTab,
        onAdd: openAddPlace,
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
            height: 76,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned.fill(
                      top: 12,
                      child: GlassContainer(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppRadii.hero),
                          topRight: Radius.circular(AppRadii.hero),
                        ),
                        blur: 10.0,
                        color: Colors.white.withValues(alpha: 0.72),
                        darkColor: AppColors.darkGlass,
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : Colors.white.withValues(alpha: 0.85),
                            width: 1.2,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? AppColors.shadow33
                                : AppColors.shadow08,
                            blurRadius: 16,
                            offset: const Offset(0, -2),
                          ),
                        ],
                        child: ValueListenableBuilder<Locale>(
                          valueListenable: AppLocaleController.current,
                          builder: (context, _, __) => Row(children: [
                            Expanded(
                                child: _FigmaNavItem(
                                    index: 0,
                                    current: index,
                                    icon: Icons.home_outlined,
                                    activeIcon: Icons.home_rounded,
                                    label: AppStrings.get('tab_discover'),
                                    onTap: onChanged)),
                            Expanded(
                                child: _FigmaNavItem(
                                    index: 1,
                                    current: index,
                                    icon: Icons.map_outlined,
                                    activeIcon: Icons.map_rounded,
                                    label: AppStrings.get('tab_map'),
                                    onTap: onChanged)),
                            const SizedBox(width: 64),
                            Expanded(
                                child: _FigmaNavItem(
                                    index: 2,
                                    current: index,
                                    icon: Icons.volunteer_activism_outlined,
                                    activeIcon:
                                        Icons.volunteer_activism_rounded,
                                    label: AppStrings.get('tab_goodness'),
                                    onTap: onChanged)),
                            Expanded(
                                child: _FigmaNavItem(
                                    index: 3,
                                    current: index,
                                    icon: Icons.person_outline_rounded,
                                    activeIcon: Icons.person_rounded,
                                    label: AppStrings.get('tab_profile'),
                                    onTap: onChanged)),
                          ]),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -14,
                      child: ValueListenableBuilder<Locale>(
                        valueListenable: AppLocaleController.current,
                        builder: (context, _, __) => Semantics(
                          label: AppStrings.get('tab_add_place'),
                          button: true,
                          child: Tooltip(
                            message: AppStrings.get('tab_add_place'),
                            child: Material(
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.primary,
                              shape: const CircleBorder(),
                              elevation: 3,
                              child: InkWell(
                                onTap: onAdd,
                                customBorder: const CircleBorder(),
                                child: const SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: Icon(Icons.add_rounded,
                                      color: Colors.white, size: 28),
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
            )));
  }
}

class _FigmaNavItem extends StatelessWidget {
  const _FigmaNavItem(
      {required this.index,
      required this.current,
      required this.icon,
      required this.activeIcon,
      required this.label,
      required this.onTap});
  final int index, current;
  final IconData icon, activeIcon;
  final String label;
  final ValueChanged<int> onTap;

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
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(AppRadii.medium),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(active ? activeIcon : icon, color: color, size: 23),
            const SizedBox(height: 4),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'Outfit',
                    color: color,
                    fontSize: AppFontSizes.caption,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
          ]),
        ),
      ),
    );
  }
}
