part of '../../main.dart';

class DogaAdminApp extends StatelessWidget {
  const DogaAdminApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Doğadayım Yönetim',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: AppColors.surfaceMuted,
          fontFamily: 'Outfit',
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
        home: const _AdminGate(),
      );
}

class _AdminGate extends StatefulWidget {
  const _AdminGate();

  @override
  State<_AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<_AdminGate> {
  StreamSubscription<AuthState>? _authSubscription;
  bool _checking = true;
  bool _authorized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) => _checkAccess(),
    );
    _checkAccess();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkAccess() async {
    if (mounted) {
      setState(() {
        _checking = true;
        _error = null;
      });
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _checking = false;
          _authorized = false;
        });
      }
      return;
    }

    try {
      final row = await Supabase.instance.client
          .from('app_user_roles')
          .select('role')
          .eq('user_id', user.id)
          .maybeSingle();
      final role = row?['role']?.toString();
      if (mounted) {
        setState(() {
          _checking = false;
          _authorized = role == 'admin' || role == 'moderator';
          if (!_authorized) _error = 'Bu hesabın yönetici yetkisi yok.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _checking = false;
          _authorized = false;
          _error = 'Yetki bilgisi kontrol edilemedi.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_authorized) {
      return _AdminLogin(
        error: _error,
        onSignedIn: _checkAccess,
      );
    }
    return const _AdminDashboard();
  }
}

class _AdminLogin extends StatefulWidget {
  const _AdminLogin({required this.onSignedIn, this.error});

  final Future<void> Function() onSignedIn;
  final String? error;

  @override
  State<_AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<_AdminLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false) || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await widget.onSignedIn();
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Giriş yapılamadı. Tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: AppColors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset(
                          'assets/branding/dogadayim_logo_full.png',
                          height: 94,
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Yönetici Paneli',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFontSizes.display,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Yalnızca yetkili hesaplar giriş yapabilir.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'E-posta',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          validator: (value) => (value?.contains('@') ?? false)
                              ? null
                              : 'Geçerli bir e-posta yazın.',
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _signIn(),
                          decoration: const InputDecoration(
                            labelText: 'Şifre',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (value) => (value?.length ?? 0) >= 8
                              ? null
                              : 'Şifrenizi yazın.',
                        ),
                        if ((_error ?? widget.error) != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            _error ?? widget.error!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _loading ? null : _signIn,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                          ),
                          child: _loading
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Giriş Yap'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class _AdminDashboard extends StatefulWidget {
  const _AdminDashboard();

  @override
  State<_AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<_AdminDashboard> {
  static const _statuses = <String>[
    'pending',
    'changes_requested',
    'approved',
    'rejected',
  ];

  String _status = 'pending';
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _submissions = const [];
  Map<String, dynamic>? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await Supabase.instance.client
          .from('place_submissions')
          .select('*, categories(name)')
          .eq('status', _status)
          .order('created_at', ascending: false)
          .limit(250);
      final loaded = rows
          .map((row) => Map<String, dynamic>.from(row))
          .toList(growable: false);
      if (mounted) {
        setState(() {
          _submissions = loaded;
          _selected = loaded.isEmpty ? null : loaded.first;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Başvurular yüklenemedi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  Future<void> _review(String decision) async {
    final selected = _selected;
    if (selected == null) return;
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          decision == 'approved'
              ? 'Başvuruyu onayla'
              : decision == 'rejected'
                  ? 'Başvuruyu reddet'
                  : 'Düzeltme iste',
        ),
        content: TextField(
          controller: noteController,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: decision == 'approved'
                ? 'Yönetici notu (isteğe bağlı)'
                : 'Açıklama',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
    final note = noteController.text.trim();
    noteController.dispose();
    if (confirmed != true) return;

    try {
      if (decision == 'approved') {
        await Supabase.instance.client.rpc(
          'approve_place_submission',
          params: {
            'p_submission_id': selected['id'],
            'p_note': note.isEmpty ? null : note,
          },
        );
      } else {
        await Supabase.instance.client.rpc(
          'review_place_submission',
          params: {
            'p_submission_id': selected['id'],
            'p_decision': decision,
            'p_note': note.isEmpty ? null : note,
          },
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başvuru güncellendi.')),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İşlem tamamlanamadı: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Doğadayım Yönetim',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(
              tooltip: 'Yenile',
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: 'Çıkış yap',
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _statuses
                    .map(
                      (status) => ChoiceChip(
                        label: Text(_statusLabel(status)),
                        selected: _status == status,
                        onSelected: (_) {
                          if (_status == status) return;
                          setState(() => _status = status);
                          _load();
                        },
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
            Expanded(child: _body()),
          ],
        ),
      );

  Widget _body() {
    if (_loading && _submissions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _submissions.isEmpty) {
      return _AdminEmpty(
        icon: Icons.cloud_off_outlined,
        title: _error!,
        action: TextButton(onPressed: _load, child: const Text('Tekrar dene')),
      );
    }
    if (_submissions.isEmpty) {
      return _AdminEmpty(
        icon: Icons.inbox_outlined,
        title: '${_statusLabel(_status)} başvuru bulunmuyor.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final list = _SubmissionList(
          submissions: _submissions,
          selectedId: _selected?['id']?.toString(),
          onSelected: (submission) {
            if (wide) {
              setState(() => _selected = submission);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('Başvuru detayı')),
                    body: _SubmissionDetail(
                      submission: submission,
                      onReview: _review,
                    ),
                  ),
                ),
              );
              setState(() => _selected = submission);
            }
          },
        );
        if (!wide) return list;
        return Row(
          children: [
            SizedBox(width: 390, child: list),
            const VerticalDivider(width: 1),
            Expanded(
              child: _selected == null
                  ? const SizedBox.shrink()
                  : _SubmissionDetail(
                      submission: _selected!,
                      onReview: _review,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _SubmissionList extends StatelessWidget {
  const _SubmissionList({
    required this.submissions,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Map<String, dynamic>> submissions;
  final String? selectedId;
  final ValueChanged<Map<String, dynamic>> onSelected;

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: submissions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final submission = submissions[index];
          final category = submission['categories'];
          final categoryName =
              category is Map ? category['name']?.toString() : null;
          return ListTile(
            selected: selectedId == submission['id']?.toString(),
            selectedTileColor: AppColors.primarySoft,
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              submission['name']?.toString() ?? 'Adsız yer',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${categoryName ?? 'Kategori yok'} · ${submission['city'] ?? ''}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onSelected(submission),
          );
        },
      );
}

class _SubmissionDetail extends StatelessWidget {
  const _SubmissionDetail({
    required this.submission,
    required this.onReview,
  });

  final Map<String, dynamic> submission;
  final Future<void> Function(String decision) onReview;

  @override
  Widget build(BuildContext context) {
    final category = submission['categories'];
    final categoryName = category is Map ? category['name']?.toString() : null;
    final latitude = (submission['latitude'] as num?)?.toDouble();
    final longitude = (submission['longitude'] as num?)?.toDouble();
    final tags = (submission['environment_tags'] as List?) ?? const [];
    final features = (submission['features'] as List?) ?? const [];
    final flags = (submission['content_flags'] as List?) ?? const [];
    final photoPaths = (submission['photo_paths'] as List?)
            ?.map((item) => item.toString())
            .where((item) => item.isNotEmpty)
            .toList(growable: false) ??
        const <String>[];
    final pending = submission['status'] == 'pending' ||
        submission['status'] == 'changes_requested';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  submission['name']?.toString() ?? 'Adsız yer',
                  style: const TextStyle(
                    fontSize: AppFontSizes.display,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${categoryName ?? 'Kategori yok'} · ${submission['district'] ?? ''}, ${submission['city'] ?? ''}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            _StatusBadge(status: submission['status']?.toString() ?? ''),
          ],
        ),
        const SizedBox(height: 24),
        _AdminSection(
          title: 'Açıklama',
          child: Text(
            submission['description']?.toString() ?? '-',
            style: const TextStyle(fontSize: AppFontSizes.title, height: 1.5),
          ),
        ),
        if (photoPaths.isNotEmpty) ...[
          const SizedBox(height: 14),
          _AdminSection(
            title: 'Fotoğraflar',
            child: _SubmissionPhotos(paths: photoPaths),
          ),
        ],
        const SizedBox(height: 14),
        _AdminSection(
          title: 'Konum',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(submission['location_label']?.toString() ?? '-'),
              const SizedBox(height: 6),
              Text('${latitude ?? '-'}, ${longitude ?? '-'}'),
              if (latitude != null && longitude != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse(
                      'https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude#map=16/$latitude/$longitude',
                    ),
                    webOnlyWindowName: '_blank',
                  ),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Haritada aç'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _AdminSection(
          title: 'Alan bilgileri',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Yol erişimi: ${submission['road_access'] ?? '-'}'),
              if (tags.isNotEmpty) Text('Çevre: ${tags.join(', ')}'),
              if (features.isNotEmpty)
                Text('Olanaklar: ${features.join(', ')}'),
            ],
          ),
        ),
        if (flags.isNotEmpty) ...[
          const SizedBox(height: 14),
          _AdminSection(
            title: 'İçerik uyarıları',
            child: Text(flags.join(', ')),
          ),
        ],
        if ((submission['moderator_note']?.toString().trim() ?? '')
            .isNotEmpty) ...[
          const SizedBox(height: 14),
          _AdminSection(
            title: 'Yönetici notu',
            child: Text(submission['moderator_note'].toString()),
          ),
        ],
        if (pending) ...[
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () => onReview('approved'),
                icon: const Icon(Icons.check),
                label: const Text('Onayla'),
              ),
              OutlinedButton.icon(
                onPressed: () => onReview('changes_requested'),
                icon: const Icon(Icons.edit_note),
                label: const Text('Düzeltme iste'),
              ),
              OutlinedButton.icon(
                onPressed: () => onReview('rejected'),
                icon: const Icon(Icons.close),
                label: const Text('Reddet'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SubmissionPhotos extends StatefulWidget {
  const _SubmissionPhotos({required this.paths});

  final List<String> paths;

  @override
  State<_SubmissionPhotos> createState() => _SubmissionPhotosState();
}

class _SubmissionPhotosState extends State<_SubmissionPhotos> {
  late Future<List<String>> _urls;

  @override
  void initState() {
    super.initState();
    _urls = _loadUrls();
  }

  @override
  void didUpdateWidget(covariant _SubmissionPhotos oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.paths, widget.paths)) _urls = _loadUrls();
  }

  Future<List<String>> _loadUrls() => Future.wait(
        widget.paths.map(
          (path) => Supabase.instance.client.storage
              .from('place-submissions')
              .createSignedUrl(path, 600),
        ),
      );

  @override
  Widget build(BuildContext context) => FutureBuilder<List<String>>(
        future: _urls,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 72,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final urls = snapshot.data ?? const <String>[];
          if (urls.isEmpty) {
            return const Text('Fotoğraf yüklenemedi.');
          }
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: urls
                .map(
                  (url) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      width: 180,
                      height: 130,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        width: 180,
                        height: 130,
                        child: Center(child: Icon(Icons.broken_image_outlined)),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          );
        },
      );
}

class _AdminSection extends StatelessWidget {
  const _AdminSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _statusLabel(status),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _AdminEmpty extends StatelessWidget {
  const _AdminEmpty({required this.icon, required this.title, this.action});

  final IconData icon;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(title),
            if (action != null) action!,
          ],
        ),
      );
}

String _statusLabel(String status) => switch (status) {
      'pending' => 'Bekleyen',
      'changes_requested' => 'Düzeltme bekleyen',
      'approved' => 'Onaylanan',
      'rejected' => 'Reddedilen',
      _ => status,
    };
