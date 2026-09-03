part of '../../main.dart';

class DogaApp extends StatelessWidget {
  const DogaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Doğada',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: green,
            surface: AppColors.surface,
          ),
          scaffoldBackgroundColor: AppColors.background,
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.medium),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: ink,
              side: const BorderSide(color: AppColors.border),
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
        ),
        home: const SplashScreen(),
        builder: (context, child) => ColoredBox(
          color: const Color(0xFFF0F2F0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: child ?? const SizedBox.shrink(),
            ),
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
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            hasSeenOnboarding ? const AuthScreen() : const OnboardingScreen(),
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
        backgroundColor: green,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.terrain_rounded, size: 54, color: green),
              ),
              const SizedBox(height: 22),
              const Text(
                'doğada',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1.5,
                ),
              ),
              const Text(
                'Keşfet • Nefes al • Hatırla',
                style: TextStyle(color: Color(0xFFCFE7DB), fontSize: 15),
              ),
            ],
          ),
        ),
      );
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int current = 0;
  bool finishing = false;

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
      MaterialPageRoute(builder: (_) => const AuthScreen()),
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
        body: PageView.builder(
          controller: controller,
          physics: const BouncingScrollPhysics(),
          itemCount: slides.length,
          onPageChanged: (value) => setState(() => current = value),
          itemBuilder: (_, index) {
            final slide = slides[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.network(slide.$1,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: green)),
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
                          Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.eco_rounded,
                                  color: Color(0xFFA7E06E), size: 21)),
                          const SizedBox(width: 9),
                          const Text('Doğadayım',
                              style: TextStyle(
                                  fontFamily: 'Fraunces',
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500)),
                          const Spacer(),
                          TextButton(
                            onPressed: finishing ? null : finish,
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.white12,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 17, vertical: 11),
                                shape: RoundedRectangleBorder(
                                    side:
                                        const BorderSide(color: Colors.white24),
                                    borderRadius: BorderRadius.circular(25))),
                            child: const Text('Geç',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                        ]),
                        const Spacer(flex: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 7),
                          decoration: BoxDecoration(
                              color: const Color(0xAA3A6B1E),
                              border:
                                  Border.all(color: const Color(0xBB92C96C)),
                              borderRadius: BorderRadius.circular(30)),
                          child: Text('●  ${slide.$2}',
                              style: const TextStyle(
                                  color: Color(0xFFB8E898),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: .5)),
                        ),
                        const SizedBox(height: 17),
                        Text(slide.$3,
                            style: const TextStyle(
                                fontFamily: 'Fraunces',
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
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeOutCubic,
                                    width: i == current ? 25 : 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(right: 7),
                                    decoration: BoxDecoration(
                                      color: i == current
                                          ? Colors.white
                                          : Colors.white38,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 27),
                        SizedBox(
                          width: double.infinity,
                          height: 57,
                          child: FilledButton(
                            onPressed: finishing ? null : next,
                            style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xCC37393A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    side:
                                        const BorderSide(color: Colors.white30),
                                    borderRadius: BorderRadius.circular(18))),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
            );
          },
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

  bool get _isSignUp => _mode == AuthMode.signUp;

  @override
  void dispose() {
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

  void _openApp() => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );

  Future<void> _socialSignIn(String provider) async {
    setState(() => _loading = true);
    // TODO(auth): Firebase bağlandığında GoogleAuthProvider veya
    // AppleAuthProvider ile gerçek sağlayıcı oturumu burada başlatılacak.
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    _openApp();
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
    // TODO(auth): Firebase bağlandığında burada signInWithEmailAndPassword veya
    // createUserWithEmailAndPassword çağrılacak.
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    _openApp();
  }

  void _forgotPassword() {
    final controller = TextEditingController(text: _emailController.text);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF8F5EE),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Şifreni yenile',
              style: TextStyle(
                fontFamily: 'Fraunces',
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
                onPressed: () {
                  // TODO(auth): FirebaseAuth.sendPasswordResetEmail.
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Şifre yenileme bağlantısı gönderildi.'),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
        backgroundColor: const Color(0xFFF7F8FB),
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
                  const Center(
                    child: Text(
                      'Doğadayım',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: Color(0xFF1E6A43),
                        fontSize: 43,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -2.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Türkiye'nin Toplum Destekli Doğa Haritası.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: Color(0xFF737E8B),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
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
                  InkWell(
                    onTap: () =>
                        setState(() => _acceptedTerms = !_acceptedTerms),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
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
                                )),
                            const SizedBox(width: 10),
                            const Expanded(
                                child: Text.rich(
                                    TextSpan(children: [
                                      TextSpan(
                                          text: 'Kullanım Şartları',
                                          style: TextStyle(
                                              color: Color(0xFF1E6A43),
                                              fontWeight: FontWeight.w700)),
                                      TextSpan(text: ' ve '),
                                      TextSpan(
                                          text: 'Gizlilik Politikası',
                                          style: TextStyle(
                                              color: Color(0xFF1E6A43),
                                              fontWeight: FontWeight.w700)),
                                      TextSpan(
                                          text: '’nı okudum, kabul ediyorum.'),
                                    ]),
                                    style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 12,
                                        height: 1.45,
                                        color: Color(0xFF737E8B)))),
                          ]),
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
                          borderRadius: BorderRadius.circular(17),
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
                          borderRadius: BorderRadius.circular(16),
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
              borderRadius: BorderRadius.circular(16),
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
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE5E3DC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: green, width: 1.4),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFB85B4B)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
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
  final favorites = <String>{places.first.name, places[3].name};
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
        backgroundColor: const Color(0xFFF1F5EC),
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
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
                fontFamily: 'Fraunces',
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
        backgroundColor: const Color(0xFFF7F4ED),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(22, 24, 22, 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: mint,
                borderRadius: BorderRadius.circular(18),
              ),
              child:
                  const Icon(Icons.my_location_rounded, color: green, size: 27),
            ),
            const SizedBox(height: 17),
            const Text(
              'Konumuna göre hava durumu',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fraunces',
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
                    borderRadius: BorderRadius.circular(14),
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
            onAddPlace: openAddPlace,
            onSearch: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FigmaSearchScreen(onOpen: open),
              ),
            ),
          ),
        1 => MapScreen(onOpen: open),
        2 => FigmaFavoritesScreen(
            items: places.where((p) => favorites.contains(p.name)).toList(),
            onOpen: open,
          ),
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
  Widget build(BuildContext context) => SizedBox(
        height: 78,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned.fill(
              top: 4,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(9, 6, 9, 8),
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
                    const SizedBox(width: 62),
                    Expanded(
                        child: _FigmaNavItem(
                            index: 2,
                            current: index,
                            icon: Icons.favorite_border_rounded,
                            activeIcon: Icons.favorite_rounded,
                            label: 'Favoriler',
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
              top: -5,
              child: GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: green,
                    borderRadius: BorderRadius.circular(AppRadii.large),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x241F5A35),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 25),
                ),
              ),
            ),
          ],
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
    final color = active ? green : const Color(0xFFA8A4A0);
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(AppRadii.small),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 36,
          height: 25,
          decoration: BoxDecoration(
              color: active ? mint : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.small)),
          child: Icon(active ? activeIcon : icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontFamily: 'Outfit',
                color: color,
                fontSize: 9.5,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
      ]),
    );
  }
}
