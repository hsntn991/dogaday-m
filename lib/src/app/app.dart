part of '../../main.dart';

class DogaApp extends StatelessWidget {
  const DogaApp({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.mode,
      builder: (context, themeMode, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Doğada',
            theme: ThemeData(
              useMaterial3: true,
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
                  minimumSize: const Size.fromHeight(AppControlSizes.button),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: ink,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size.fromHeight(AppControlSizes.button),
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
                modalBarrierColor: Color(0x66000000),
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
            builder: (context, child) => ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ));
}

ThemeData _buildDarkTheme() {
  const background = Color(0xFF0D120F);
  const surface = Color(0xFF151C18);
  const border = Color(0xFF303A34);
  const text = Color(0xFFF1F5F2);
  const secondaryText = Color(0xFFAAB4AD);
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
        borderSide: const BorderSide(color: Color(0xFF71A65D), width: 1.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF2F7147),
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
      modalBarrierColor: Color(0x99000000),
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
            ? const Color(0xFF2F7147)
            : border,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: const Color(0xFF26302A),
      contentTextStyle: const TextStyle(color: text),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.medium),
      ),
    ),
  );
}

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
      "Türkiye'nin\nGizli Cennetleri",
      'Ormanlar, şelaleler, göller ve dağlarla dolu bu toprakların doğal hazinelerini seninle paylaşmaya hazırız.',
      Color(0x55304A2B),
    ),
    (
      'https://images.unsplash.com/photo-1728365084805-cf142cf7d275?w=1000&h=1600&fit=crop',
      'SU KAYNAKLARI',
      'Temiz Su\nBulmanın Yeni Yolu',
      'İçme suyu kaynakları, doğal pınarlar ve soğuk dağ sularını haritada anlık olarak keşfet.',
      Color(0x554E260E),
    ),
    (
      'https://images.unsplash.com/photo-1760715648379-39d2e7f59e62?w=1000&h=1600&fit=crop',
      'KAMP & YÜRÜYÜŞ',
      'Doğada\nYaşamak İçin',
      'Kamp alanları, karavan parkları ve yürüyüş rotaları — hepsini tek uygulamada, topluluktan doğrulanan bilgilerle.',
      Color(0x55462A17),
    ),
    (
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1000&h=1600&fit=crop',
      'TOPLULUK',
      'Birlikte\nDaha Güçlüyüz',
      'Keşfettiğin yerleri ekle, fotoğraf paylaş, yorumlarınla diğer doğaseverlere yol göster.',
      Color(0x55304A2B),
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
                            const Color(0x11000000),
                            const Color(0xF2000000)
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
                              ClipOval(
                                child: Image.asset(
                                  'assets/branding/dogadayim_logo_mark.png',
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 9),
                              const Text('Doğadayım',
                                  style: TextStyle(
                                      fontFamily: 'Outfit',
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500)),
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
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ]),
                            const Spacer(flex: 6),
                            Text('●  ${slide.$2}',
                                style: const TextStyle(
                                    color: Color(0xFFB8E898),
                                    fontSize: 11,
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
                                    fontSize: 15,
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
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 11),
                                      const Icon(Icons.arrow_forward_rounded,
                                          size: 19)
                                    ]),
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
  late final TapGestureRecognizer _toggleTermsRecognizer;

  bool get _isSignUp => _mode == AuthMode.signUp;

  static String? get _authRedirectUrl =>
      kIsWeb ? Uri.base.origin : 'io.supabase.dogadagezi://login-callback/';

  @override
  void initState() {
    super.initState();
    _privacyPolicyRecognizer = TapGestureRecognizer()
      ..onTap = () => AppLegalLinks.openPrivacyPolicy(context);
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
          data: {'full_name': _nameController.text.trim()},
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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadii.large)),
      ),
      builder: (sheetContext) => Padding(
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
                  color: const Color(0xFFD4D0C6),
                  borderRadius: BorderRadius.circular(AppRadii.large),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Şifreni yenile',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: Color(0xFF182114),
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Bağlantıyı gönderebilmemiz için e-posta adresini yaz.',
              style: TextStyle(fontSize: 14, color: Color(0xFF74776F)),
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
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(
                        content: Text('Geçerli bir e-posta adresi yaz.'),
                      ),
                    );
                    return;
                  }
                  try {
                    await Supabase.instance.client.auth.resetPasswordForEmail(
                      email,
                      redirectTo: _authRedirectUrl,
                    );
                    if (!sheetContext.mounted) return;
                    Navigator.pop(sheetContext);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Şifre yenileme bağlantısı gönderildi.'),
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
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton.outlined(
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: const Color(0xFF172018),
                      iconSize: 24,
                      padding: const EdgeInsets.all(11),
                      style: IconButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFDDE2E5)),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Image.asset(
                      'assets/branding/dogadayim_logo_full.png',
                      width: 245,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SocialAuthButton(
                    label: 'Apple ile devam et',
                    mark:
                        const Icon(Icons.apple, size: 25, color: Colors.white),
                    dark: true,
                    onPressed: _loading ? null : () => _socialSignIn('apple'),
                  ),
                  const SizedBox(height: 11),
                  _SocialAuthButton(
                    label: 'Google ile devam et',
                    mark: const Text('G',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4285F4))),
                    onPressed: _loading ? null : () => _socialSignIn('google'),
                  ),
                  const SizedBox(height: 18),
                  const Row(children: [
                    Expanded(child: Divider(color: Color(0xFFDDE2E5))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('veya e-posta ile',
                          style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 12,
                              color: Color(0xFF7A8490))),
                    ),
                    Expanded(child: Divider(color: Color(0xFFDDE2E5))),
                  ]),
                  const SizedBox(height: 18),
                  if (_isSignUp) ...[
                    _AuthField(
                      controller: _nameController,
                      label: 'Ad soyad',
                      hint: 'Ad Soyad',
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: (value) => (value?.trim().length ?? 0) < 3
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
                    hint: _isSignUp ? 'En az 8 karakter' : 'Şifreni yaz',
                    icon: Icons.lock_outline_rounded,
                    obscureText: !_passwordVisible,
                    textInputAction:
                        _isSignUp ? TextInputAction.next : TextInputAction.done,
                    suffix: IconButton(
                      onPressed: () =>
                          setState(() => _passwordVisible = !_passwordVisible),
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
                        onPressed: () =>
                            setState(() => _confirmVisible = !_confirmVisible),
                        icon: Icon(_confirmVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                      ),
                      validator: (value) => value != _passwordController.text
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
                          foregroundColor: green,
                          padding: const EdgeInsets.only(top: 9, bottom: 8),
                        ),
                        child: const Text(
                          'Şifremi unuttum',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 23,
                          height: 23,
                          child: Checkbox(
                            value: _acceptedTerms,
                            onChanged: (value) => setState(
                                () => _acceptedTerms = value ?? false),
                            activeColor: const Color(0xFF1E6A43),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(
                            TextSpan(children: [
                              const TextSpan(
                                text: 'Kullanım Şartları',
                                style: TextStyle(
                                  color: Color(0xFF1E6A43),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(text: ' ve '),
                              TextSpan(
                                text: 'Gizlilik Politikası',
                                style: const TextStyle(
                                  color: Color(0xFF1E6A43),
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: _privacyPolicyRecognizer,
                              ),
                              TextSpan(
                                text: '’nı okudum, kabul ediyorum.',
                                recognizer: _toggleTermsRecognizer,
                              ),
                            ]),
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 12,
                              height: 1.45,
                              color: Color(0xFF737E8B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _loading || !_acceptedTerms ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1E6A43),
                        disabledBackgroundColor: const Color(0xFF9AB8AA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.large),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isSignUp ? 'Hesap oluştur' : 'Devam et',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded,
                                    size: 19),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextButton(
                    onPressed: () =>
                        _setMode(_isSignUp ? AuthMode.signIn : AuthMode.signUp),
                    child: Text(
                        _isSignUp
                            ? 'Zaten hesabın var mı? Giriş yap'
                            : 'Hesabın yok mu? Hesap oluştur',
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            color: Color(0xFF1E6A43),
                            fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: TextButton.icon(
                      onPressed: _openApp,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF394237),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Color(0xFFD8D8D0)),
                          borderRadius: BorderRadius.circular(AppRadii.large),
                        ),
                      ),
                      icon: const Icon(Icons.explore_outlined, size: 19),
                      label: const Text(
                        'Misafir olarak devam et',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
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
  Widget build(BuildContext context) => SizedBox(
        height: 52,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: dark ? Colors.white : const Color(0xFF151B26),
            backgroundColor: dark ? Colors.black : Colors.white,
            side: BorderSide(
              color: dark ? Colors.black : const Color(0xFFDDE2E5),
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.large),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              mark,
              const SizedBox(width: 9),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: dark ? Colors.white : const Color(0xFF151B26),
                ),
              ),
            ],
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
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF30382E),
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
            style: const TextStyle(fontSize: 14.5, color: Color(0xFF20251F)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFA2A59D),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(icon, size: 20, color: const Color(0xFF667162)),
              suffixIcon: suffix,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.large),
                borderSide: const BorderSide(color: Color(0xFFE5E3DC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.large),
                borderSide: const BorderSide(color: green, width: 1.4),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.large),
                borderSide: const BorderSide(color: Color(0xFFB85B4B)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.large),
                borderSide:
                    const BorderSide(color: Color(0xFFB85B4B), width: 1.4),
              ),
            ),
          ),
        ],
      );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  final favorites = <String>{};
  late final List<Widget?> _tabScreens;
  Timer? _locationReminderTimer;
  bool _locationReminderShown = false;

  @override
  void initState() {
    super.initState();
    _tabScreens = <Widget?>[_createTab(0), null, null, null];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) offerLocationPermission();
    });
  }

  @override
  void dispose() {
    _locationReminderTimer?.cancel();
    super.dispose();
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
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentMaterialBanner();
    messenger.showMaterialBanner(
      MaterialBanner(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.large),
          ),
          child: const Icon(
            Icons.location_on_outlined,
            color: green,
            size: 22,
          ),
        ),
        content: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yakınındaki doğayı keşfet',
              style: TextStyle(
                fontFamily: 'Outfit',
                color: ink,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Doğru hava durumu ve yakınındaki yerler için konumunu açabilirsin.',
              style: TextStyle(
                fontFamily: 'Outfit',
                color: Color(0xFF68645E),
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: const Text('Daha Sonra'),
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
            const Text(
              'Konumuna göre hava durumu',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                color: ink,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Bulunduğun bölgenin güncel hava durumunu ve yakındaki doğa noktalarını gösterebilmemiz için konum iznine ihtiyacımız var.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                color: Color(0xFF77736C),
                fontSize: 12,
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
                  foregroundColor: const Color(0xFF77736C),
                  minimumSize: const Size.fromHeight(47),
                ),
                child: const Text('Şimdi Değil'),
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
                label: const Text('İzin Ver'),
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
            favorite: favorites.contains(p.name),
            onOpen: open,
            onFavorite: () => setState(() {
              favorites.contains(p.name)
                  ? favorites.remove(p.name)
                  : favorites.add(p.name);
              _tabScreens[2] = null;
            }),
          ),
        ),
      );

  void openAddPlace() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddPlaceScreen(
            onOpenExisting: open,
            onContributeToExisting: open,
          ),
        ),
      );

  Widget _createTab(int tabIndex) => switch (tabIndex) {
        0 => FigmaHomeScreen(
            onOpen: open,
            onExploreMap: () => selectTab(1),
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

  void selectTab(int value) {
    if (value == index) return;
    setState(() {
      index = value;
      _tabScreens[value] ??= _createTab(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: List<Widget>.generate(
          _tabScreens.length,
          (tabIndex) => _tabScreens[tabIndex] ?? const SizedBox.shrink(),
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
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: SizedBox(
          height: 76,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned.fill(
                top: 12,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                    boxShadow: AppShadows.soft,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 9, 8, 6),
                    child: Row(children: [
                      Expanded(
                          child: _FigmaNavItem(
                              index: 0,
                              current: index,
                              icon: Icons.home_outlined,
                              activeIcon: Icons.home_rounded,
                              label: 'Keşfet',
                              onTap: onChanged)),
                      Expanded(
                          child: _FigmaNavItem(
                              index: 1,
                              current: index,
                              icon: Icons.map_outlined,
                              activeIcon: Icons.map_rounded,
                              label: 'Harita',
                              onTap: onChanged)),
                      const SizedBox(width: 64),
                      Expanded(
                          child: _FigmaNavItem(
                              index: 2,
                              current: index,
                              icon: Icons.volunteer_activism_outlined,
                              activeIcon: Icons.volunteer_activism_rounded,
                              label: 'İyilik',
                              onTap: onChanged)),
                      Expanded(
                          child: _FigmaNavItem(
                              index: 3,
                              current: index,
                              icon: Icons.person_outline_rounded,
                              activeIcon: Icons.person_rounded,
                              label: 'Profil',
                              onTap: onChanged)),
                    ]),
                  ),
                ),
              ),
              Positioned(
                top: -14,
                child: Semantics(
                  label: 'Yer Ekle',
                  button: true,
                  child: Tooltip(
                    message: 'Yer Ekle',
                    child: Material(
                      color: AppColors.primary,
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
            ],
          ),
        ),
      );
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
    final active = index == current;
    final color = active ? AppColors.primary : AppColors.textTertiary;
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
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
          ]),
        ),
      ),
    );
  }
}
