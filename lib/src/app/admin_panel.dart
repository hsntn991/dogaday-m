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
  bool _needsMfa = false;
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
          _needsMfa = false;
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
      final isStaff = role == 'admin' || role == 'moderator';

      bool mfaPending = false;
      if (isStaff) {
        try {
          final aal = Supabase.instance.client.auth.mfa
              .getAuthenticatorAssuranceLevel();
          if (aal.nextLevel == AuthenticatorAssuranceLevels.aal2 &&
              aal.currentLevel != AuthenticatorAssuranceLevels.aal2) {
            mfaPending = true;
          }
        } catch (e) {
          // Fail-closed: MFA kontrolünde hata olursa paneli kesinlikle açma, erişimi engelle.
          if (mounted) {
            setState(() {
              _checking = false;
              _authorized = false;
              _needsMfa = false;
              _error =
                  'MFA güvenlik kontrolü başarısız oldu. Güvenlik nedeniyle erişim reddedildi.';
            });
          }
          return;
        }
      }

      if (mounted) {
        setState(() {
          _checking = false;
          _authorized = isStaff;
          _needsMfa = mfaPending;
          if (!_authorized) _error = 'Bu hesabın yönetici yetkisi yok.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _checking = false;
          _authorized = false;
          _needsMfa = false;
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
    if (_needsMfa) {
      return _AdminMfaVerifyScreen(
        onVerified: _checkAccess,
        onCancel: () async {
          await Supabase.instance.client.auth.signOut();
        },
      );
    }
    return const _AdminDashboard();
  }
}

class AdminChatModerationScreen extends StatefulWidget {
  const AdminChatModerationScreen({super.key});

  @override
  State<AdminChatModerationScreen> createState() =>
      _AdminChatModerationScreenState();
}

class _AdminChatModerationScreenState extends State<AdminChatModerationScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _reports = const [];

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
          .from('community_chat_reports')
          .select(
              'id, reason, note, created_at, community_chat_messages(id, author_id, author_name, body)')
          .order('created_at', ascending: false)
          .limit(200);
      if (mounted) {
        setState(() => _reports = rows
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false));
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Sohbet şikayetleri yüklenemedi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _restrict(Map<String, dynamic> report, int days) async {
    final message = Map<String, dynamic>.from(
      report['community_chat_messages'] as Map? ?? const {},
    );
    final userId = message['author_id']?.toString();
    if (userId == null || userId.isEmpty) return;
    final reasonController = TextEditingController(
      text: report['reason']?.toString() ?? 'Sohbet kurallarının ihlali',
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(days == -1 ? 'Süresiz kısıtla' : '1 hafta kısıtla'),
        content: TextField(
          controller: reasonController,
          maxLength: 300,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Kısıtlama nedeni'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Kısıtla'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      reasonController.dispose();
      return;
    }
    try {
      await Supabase.instance.client.rpc(
        'apply_community_chat_restriction',
        params: {
          'p_user_id': userId,
          'p_duration_days': days,
          'p_reason': reasonController.text.trim(),
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(days == -1
              ? 'Kullanıcı süresiz kısıtlandı.'
              : 'Kullanıcı 1 hafta kısıtlandı.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kısıtlama uygulanamadı: $error')),
      );
    } finally {
      reasonController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Sohbet şikayetleri'),
          actions: [
            IconButton(
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.refresh)),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _reports.isEmpty
                    ? const Center(
                        child: Text('İncelenecek sohbet şikayeti yok.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reports.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final report = _reports[index];
                          final message = Map<String, dynamic>.from(
                            report['community_chat_messages'] as Map? ??
                                const {},
                          );
                          return ListTile(
                            title: Text(message['author_name']?.toString() ??
                                'Bilinmeyen kullanıcı'),
                            subtitle: Text(
                              '${message['body'] ?? 'Mesaj silinmiş'}\nŞikayet: ${report['reason']}${report['note'] == null ? '' : ' · ${report['note']}'}',
                            ),
                            isThreeLine: true,
                            trailing: PopupMenuButton<int>(
                              tooltip: 'Kısıtlama seç',
                              onSelected: (days) => _restrict(report, days),
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                    value: 7, child: Text('1 hafta kısıtla')),
                                PopupMenuItem(
                                    value: -1, child: Text('Süresiz kısıtla')),
                              ],
                            ),
                          );
                        },
                      ),
      );
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
  bool _showPhotoContributions = false;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _submissions = const [];
  Map<String, dynamic>? _selected;
  List<Map<String, dynamic>> _photoSubmissions = const [];
  Map<String, dynamic>? _selectedPhotoSubmission;

  /// Dashboard status counts — {status: count}
  Map<String, int> _statusCounts = const {};

  @override
  void initState() {
    super.initState();
    try {
      final aal =
          Supabase.instance.client.auth.mfa.getAuthenticatorAssuranceLevel();
      if (aal.nextLevel == AuthenticatorAssuranceLevels.aal2 &&
          aal.currentLevel != AuthenticatorAssuranceLevels.aal2) {
        _error = 'Oturum için AAL2 iki aşamalı doğrulama zorunludur.';
        _loading = false;
        return;
      }
    } catch (_) {
      _error =
          'MFA güvenlik kontrolü başarısız oldu. Panel verileri yüklenemez.';
      _loading = false;
      return;
    }
    _loadStats();
    _load();
  }

  Future<void> _loadStats() async {
    try {
      final counts = <String, int>{};
      for (final status in _statuses) {
        final table = _showPhotoContributions
            ? 'place_photo_submissions'
            : 'place_submissions';
        final result = await Supabase.instance.client
            .from(table)
            .select('id')
            .eq('status', status)
            .count(CountOption.exact);
        counts[status] = result.count;
      }
      if (mounted) setState(() => _statusCounts = counts);
    } catch (_) {
      // Stats are informational; don't block the dashboard.
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_showPhotoContributions) {
        final rows = await Supabase.instance.client
            .from('place_photo_submissions')
            .select()
            .eq('status', _status)
            .order('created_at', ascending: false)
            .limit(250);
        final loaded = rows
            .map((row) => Map<String, dynamic>.from(row))
            .toList(growable: false);
        if (mounted) {
          setState(() {
            _photoSubmissions = loaded;
            _selectedPhotoSubmission = loaded.isEmpty ? null : loaded.first;
          });
        }
        return;
      }
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

  Future<void> _reviewPhoto(String decision) async {
    final selected = _selectedPhotoSubmission;
    if (selected == null) return;
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(decision == 'approved'
            ? 'Fotoğrafı onayla'
            : decision == 'rejected'
                ? 'Fotoğrafı reddet'
                : 'Düzeltme iste'),
        content: TextField(
          controller: noteController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Yönetici notu'),
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
          'approve_community_photo_submission',
          params: {
            'p_submission_id': selected['id'],
            'p_note': note.isEmpty ? null : note,
          },
        );
      } else {
        await Supabase.instance.client.rpc(
          'review_community_photo_submission',
          params: {
            'p_submission_id': selected['id'],
            'p_decision': decision,
            'p_note': note.isEmpty ? null : note,
          },
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotoğraf katkısı güncellendi.')),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İşlem tamamlanamadı: $error')),
      );
    }
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

  Future<void> _openMfaSettings(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _AdminMfaSettingsDialog(),
    );
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
              tooltip: 'Sohbet şikayetleri',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminChatModerationScreen(),
                ),
              ),
              icon: const Icon(Icons.forum_outlined),
            ),
            IconButton(
              tooltip: 'İki Aşamalı Doğrulama (MFA)',
              onPressed: () => _openMfaSettings(context),
              icon: const Icon(Icons.shield_outlined),
            ),
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
                children: [
                  ChoiceChip(
                    label: const Text('Yer başvuruları'),
                    selected: !_showPhotoContributions,
                    onSelected: (_) {
                      if (!_showPhotoContributions) return;
                      setState(() => _showPhotoContributions = false);
                      _loadStats();
                      _load();
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Fotoğraf katkıları'),
                    selected: _showPhotoContributions,
                    onSelected: (_) {
                      if (_showPhotoContributions) return;
                      setState(() => _showPhotoContributions = true);
                      _loadStats();
                      _load();
                    },
                  ),
                  ..._statuses.map(
                    (status) {
                      final count = _statusCounts[status];
                      final label = count != null
                          ? '${_statusLabel(status)} ($count)'
                          : _statusLabel(status);
                      return ChoiceChip(
                        label: Text(label),
                        selected: _status == status,
                        onSelected: (_) {
                          if (_status == status) return;
                          setState(() => _status = status);
                          _load();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(child: _body()),
          ],
        ),
      );

  Widget _photoBody() {
    if (_loading && _photoSubmissions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _photoSubmissions.isEmpty) {
      return _AdminEmpty(
        icon: Icons.cloud_off_outlined,
        title: _error!,
        action: TextButton(onPressed: _load, child: const Text('Tekrar dene')),
      );
    }
    if (_photoSubmissions.isEmpty) {
      return _AdminEmpty(
        icon: Icons.photo_library_outlined,
        title: '${_statusLabel(_status)} fotoğraf katkısı bulunmuyor.',
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final list = _PhotoContributionList(
          submissions: _photoSubmissions,
          selectedId: _selectedPhotoSubmission?['id']?.toString(),
          onSelected: (submission) {
            if (wide) {
              setState(() => _selectedPhotoSubmission = submission);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('Fotoğraf katkısı')),
                    body: _PhotoContributionDetail(
                      submission: submission,
                      onReview: _reviewPhoto,
                    ),
                  ),
                ),
              );
              setState(() => _selectedPhotoSubmission = submission);
            }
          },
        );
        if (!wide) return list;
        return Row(
          children: [
            SizedBox(width: 390, child: list),
            const VerticalDivider(width: 1),
            Expanded(
              child: _selectedPhotoSubmission == null
                  ? const SizedBox.shrink()
                  : _PhotoContributionDetail(
                      submission: _selectedPhotoSubmission!,
                      onReview: _reviewPhoto,
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _body() {
    if (_showPhotoContributions) return _photoBody();
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
          final submitter = submission['submitter_name']?.toString().trim();
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
              [
                if (submitter?.isNotEmpty == true) submitter!,
                '${categoryName ?? 'Kategori yok'} · ${submission['city'] ?? ''}',
              ].join('\n'),
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
    final submitterName =
        submission['submitter_name']?.toString().trim().isNotEmpty == true
            ? submission['submitter_name'].toString().trim()
            : 'Eski kayıt · gönderen bilgisi yok';
    final submitterEmail = submission['submitter_email']?.toString().trim();
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
          title: 'Gönderen',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(submitterName,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              if (submitterEmail?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(submitterEmail!),
              ],
              const SizedBox(height: 4),
              Text('Gönderim: ${submission['created_at'] ?? '-'}'),
            ],
          ),
        ),
        const SizedBox(height: 14),
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
        const SizedBox(height: 14),
        _DuplicateCheck(submission: submission),
        const SizedBox(height: 14),
        _AuditLogSection(submissionId: submission['id']?.toString() ?? ''),
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

class _PhotoContributionList extends StatelessWidget {
  const _PhotoContributionList({
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
          final submitter = submission['submitter_name']?.toString().trim();
          return ListTile(
            selected: selectedId == submission['id']?.toString(),
            selectedTileColor: AppColors.primarySoft,
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            leading: const Icon(Icons.photo_outlined),
            title: Text(
              submission['place_name']?.toString() ?? 'Adsız mekân',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text([
              if (submitter?.isNotEmpty == true) submitter!,
              submission['place_location']?.toString() ?? '',
            ].where((text) => text.isNotEmpty).join('\n')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onSelected(submission),
          );
        },
      );
}

class _PhotoContributionDetail extends StatelessWidget {
  const _PhotoContributionDetail({
    required this.submission,
    required this.onReview,
  });

  final Map<String, dynamic> submission;
  final Future<void> Function(String decision) onReview;

  @override
  Widget build(BuildContext context) {
    final path = submission['photo_path']?.toString().trim() ?? '';
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
                  submission['place_name']?.toString() ?? 'Adsız mekân',
                  style: const TextStyle(
                    fontSize: AppFontSizes.display,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  submission['place_location']?.toString() ?? '',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            _StatusBadge(status: submission['status']?.toString() ?? ''),
          ],
        ),
        const SizedBox(height: 24),
        _AdminSection(
          title: 'Gönderen',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(submission['submitter_name']?.toString() ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              if ((submission['submitter_email']?.toString().trim() ?? '')
                  .isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(submission['submitter_email'].toString()),
              ],
              const SizedBox(height: 4),
              Text('Gönderim: ${submission['created_at'] ?? '-'}'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _AdminSection(
          title: 'Fotoğraf',
          child: path.isEmpty
              ? const Text('Fotoğraf yüklenemedi.')
              : _SubmissionPhotos(paths: [path], bucket: 'community-photos'),
        ),
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
  const _SubmissionPhotos(
      {required this.paths, this.bucket = 'place-submissions'});

  final List<String> paths;
  final String bucket;

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
    if (!listEquals(oldWidget.paths, widget.paths) ||
        oldWidget.bucket != widget.bucket) {
      _urls = _loadUrls();
    }
  }

  Future<List<String>> _loadUrls() async {
    final urls = await Future.wait<String?>(
      widget.paths.map((path) async {
        final normalizedPath = path.trim();
        if (normalizedPath.isEmpty) return null;
        if (normalizedPath.startsWith('https://')) return normalizedPath;
        try {
          return await Supabase.instance.client.storage
              .from(widget.bucket)
              .createSignedUrl(normalizedPath, 600);
        } catch (_) {
          // Bir eski/bozuk yol diğer başvuru fotoğraflarını gizlememeli.
          return null;
        }
      }),
    );
    return urls.whereType<String>().toList(growable: false);
  }

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

// ---------------------------------------------------------------------------
// Duplicate detection — shows existing places near the submission's coordinates
// or with a similar name, so the moderator can avoid duplicate approvals.
// ---------------------------------------------------------------------------
class _DuplicateCheck extends StatefulWidget {
  const _DuplicateCheck({required this.submission});

  final Map<String, dynamic> submission;

  @override
  State<_DuplicateCheck> createState() => _DuplicateCheckState();
}

class _DuplicateCheckState extends State<_DuplicateCheck> {
  List<Map<String, dynamic>>? _duplicates;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _check();
  }

  @override
  void didUpdateWidget(covariant _DuplicateCheck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.submission['id'] != widget.submission['id']) _check();
  }

  Future<void> _check() async {
    setState(() {
      _loading = true;
      _duplicates = null;
    });

    final lat = (widget.submission['latitude'] as num?)?.toDouble();
    final lng = (widget.submission['longitude'] as num?)?.toDouble();
    final name = widget.submission['name']?.toString().trim() ?? '';

    if (lat == null || lng == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      // ~1 km bounding box
      const delta = 0.009; // ~1 km in degrees
      final rows = await Supabase.instance.client
          .from('places')
          .select('id, name, latitude, longitude, city')
          .gte('latitude', lat - delta)
          .lte('latitude', lat + delta)
          .gte('longitude', lng - delta)
          .lte('longitude', lng + delta)
          .limit(20);

      var results = rows
          .map((row) => Map<String, dynamic>.from(row))
          .toList(growable: true);

      // Also search by name if non-empty
      if (name.length >= 3) {
        final nameRows = await Supabase.instance.client
            .from('places')
            .select('id, name, latitude, longitude, city')
            .ilike('name', '%$name%')
            .limit(10);
        final existingIds = results.map((r) => r['id']).toSet();
        for (final row in nameRows) {
          if (!existingIds.contains(row['id'])) {
            results.add(Map<String, dynamic>.from(row));
          }
        }
      }

      if (mounted) {
        setState(() {
          _duplicates = results;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _AdminSection(
        title: 'Duplicate kontrolü',
        child: const SizedBox(
          height: 32,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }
    final dupes = _duplicates ?? const [];
    if (dupes.isEmpty) {
      return _AdminSection(
        title: 'Duplicate kontrolü',
        child: Row(
          children: [
            Icon(Icons.check_circle_outline,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text('Yakınlarda veya benzer isimde mevcut yer bulunamadı.'),
          ],
        ),
      );
    }

    return _AdminSection(
      title: 'Duplicate kontrolü ⚠️',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${dupes.length} benzer/yakın yer bulundu:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.warningText,
            ),
          ),
          const SizedBox(height: 8),
          ...dupes.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.place_outlined, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${d['name'] ?? '-'} · ${d['city'] ?? ''}  '
                      '(${(d['latitude'] as num?)?.toStringAsFixed(4)}, '
                      '${(d['longitude'] as num?)?.toStringAsFixed(4)})',
                      style: const TextStyle(fontSize: AppFontSizes.label),
                    ),
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

// ---------------------------------------------------------------------------
// Audit log timeline — shows the immutable moderation history for a submission.
// ---------------------------------------------------------------------------
class _AuditLogSection extends StatefulWidget {
  const _AuditLogSection({required this.submissionId});

  final String submissionId;

  @override
  State<_AuditLogSection> createState() => _AuditLogSectionState();
}

class _AuditLogSectionState extends State<_AuditLogSection> {
  List<Map<String, dynamic>>? _logs;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _AuditLogSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.submissionId != widget.submissionId) _load();
  }

  Future<void> _load() async {
    if (widget.submissionId.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final rows = await Supabase.instance.client
          .from('moderation_audit_logs')
          .select()
          .eq('submission_id', widget.submissionId)
          .order('created_at', ascending: true);
      if (mounted) {
        setState(() {
          _logs = rows
              .map((r) => Map<String, dynamic>.from(r))
              .toList(growable: false);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _AdminSection(
        title: 'Moderasyon geçmişi',
        child: const SizedBox(
          height: 32,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }
    final logs = _logs ?? const [];
    if (logs.isEmpty) {
      return _AdminSection(
        title: 'Moderasyon geçmişi',
        child: const Text('Henüz moderasyon işlemi yapılmamış.'),
      );
    }

    return _AdminSection(
      title: 'Moderasyon geçmişi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: logs.map((log) {
          final action = log['action']?.toString() ?? '';
          final note = log['note']?.toString().trim() ?? '';
          final createdAt = log['created_at']?.toString() ?? '';
          final prevStatus = log['previous_status']?.toString();
          final newStatus = log['new_status']?.toString() ?? '';

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _actionIcon(action),
                  size: 18,
                  color: _actionColor(action),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _actionLabel(action),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _actionColor(action),
                        ),
                      ),
                      if (prevStatus != null)
                        Text(
                          '${_statusLabel(prevStatus)} → ${_statusLabel(newStatus)}',
                          style: const TextStyle(
                            fontSize: AppFontSizes.caption,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      if (note.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            note,
                            style: const TextStyle(
                              fontSize: AppFontSizes.label,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      Text(
                        _formatTimestamp(createdAt),
                        style: const TextStyle(
                          fontSize: AppFontSizes.caption,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  static IconData _actionIcon(String action) => switch (action) {
        'approve' => Icons.check_circle,
        'reject' => Icons.cancel,
        'request_changes' => Icons.edit_note,
        'resubmit' => Icons.replay,
        _ => Icons.info_outline,
      };

  static Color _actionColor(String action) => switch (action) {
        'approve' => AppColors.primary,
        'reject' => AppColors.error,
        'request_changes' => AppColors.warningText,
        _ => AppColors.textSecondary,
      };

  static String _actionLabel(String action) => switch (action) {
        'approve' => 'Onaylandı',
        'reject' => 'Reddedildi',
        'request_changes' => 'Düzeltme istendi',
        'resubmit' => 'Tekrar gönderildi',
        _ => action,
      };

  static String _formatTimestamp(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------
// MFA / TOTP verification screen (aal2 challenge on admin sign-in)
// ---------------------------------------------------------------------------
class _AdminMfaVerifyScreen extends StatefulWidget {
  const _AdminMfaVerifyScreen({
    required this.onVerified,
    required this.onCancel,
  });

  final Future<void> Function() onVerified;
  final Future<void> Function() onCancel;

  @override
  State<_AdminMfaVerifyScreen> createState() => _AdminMfaVerifyScreenState();
}

class _AdminMfaVerifyScreenState extends State<_AdminMfaVerifyScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _error = '6 haneli doğrulama kodunu girin.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final factors = await Supabase.instance.client.auth.mfa.listFactors();
      final totp = factors.totp.firstOrNull;
      if (totp == null) {
        throw Exception('MFA faktörü bulunamadı.');
      }
      await Supabase.instance.client.auth.mfa.challengeAndVerify(
        factorId: totp.id,
        code: code,
      );
      await widget.onVerified();
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Doğrulama başarısız: $e');
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Icon(
                          Icons.shield_outlined,
                          size: 56,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'İki Aşamalı Doğrulama',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppFontSizes.display,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Yönetici hesabınız için doğrulayıcı uygulamanızdaki 6 haneli kodu girin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: AppFontSizes.display,
                          letterSpacing: 8,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: const InputDecoration(
                          hintText: '000000',
                          counterText: '',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        onFieldSubmitted: (_) => _verify(),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _loading ? null : _verify,
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
                            : const Text('Doğrula ve Giriş Yap'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: widget.onCancel,
                        child: const Text('İptal Et / Çıkış Yap'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

// ---------------------------------------------------------------------------
// MFA / TOTP Settings dialog (Admin enrollment / unenrollment)
// ---------------------------------------------------------------------------
class _AdminMfaSettingsDialog extends StatefulWidget {
  const _AdminMfaSettingsDialog();

  @override
  State<_AdminMfaSettingsDialog> createState() =>
      _AdminMfaSettingsDialogState();
}

class _AdminMfaSettingsDialogState extends State<_AdminMfaSettingsDialog> {
  bool _loading = true;
  String? _error;
  List<Factor>? _factors;
  AuthMFAEnrollResponse? _enrollment;
  final _codeController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadFactors();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadFactors() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await Supabase.instance.client.auth.mfa.listFactors();
      if (mounted) {
        setState(() {
          _factors = res.all;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'MFA bilgisi yüklenemedi: $e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _startEnroll() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final res = await Supabase.instance.client.auth.mfa.enroll(
        factorType: FactorType.totp,
        issuer: 'Dogadayim',
      );
      if (mounted) {
        setState(() {
          _enrollment = res;
          _submitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Kurulum başlatılamadı: $e';
          _submitting = false;
        });
      }
    }
  }

  Future<void> _verifyEnrollment() async {
    final enrollment = _enrollment;
    if (enrollment == null) return;
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _error = '6 haneli kodu girin.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.mfa.challengeAndVerify(
        factorId: enrollment.id,
        code: code,
      );
      if (!mounted) return;
      setState(() {
        _enrollment = null;
        _codeController.clear();
      });
      await _loadFactors();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İki aşamalı doğrulama başarıyla etkinleştirildi.'),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Etkinleştirme başarısız: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _unenroll(String factorId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('2FA Devre Dışı Bırakılsın mı?'),
        content: const Text(
          'İki aşamalı doğrulamayı kaldırmak yönetici hesabınızın güvenliğini azaltır.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Kaldır'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.mfa.unenroll(factorId);
      await _loadFactors();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İki aşamalı doğrulama kaldırıldı.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Kaldırılamadı: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.shield_outlined, color: AppColors.primary),
          SizedBox(width: 8),
          Text('İki Aşamalı Doğrulama (2FA)'),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: _loading
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null) ...[
                      Text(
                        _error!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_enrollment != null) ...[
                      const Text(
                        'Doğrulayıcı Uygulamaya Ekleyin',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Google Authenticator, Apple Parolalar veya 1Password uygulamanıza bu anahtarı ekleyin:',
                        style: TextStyle(fontSize: AppFontSizes.label),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                _enrollment?.totp?.secret ?? '-',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Kopyala',
                              icon: const Icon(Icons.copy, size: 18),
                              onPressed: () {
                                final secret = _enrollment?.totp?.secret;
                                if (secret != null && secret.isNotEmpty) {
                                  Clipboard.setData(
                                    ClipboardData(text: secret),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Gizli anahtar kopyalandı.'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: AppFontSizes.heading,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Uygulamadaki 6 haneli kod',
                          hintText: '000000',
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _submitting ? null : _verifyEnrollment,
                        child: _submitting
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Doğrula ve Etkinleştir'),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _enrollment = null),
                        child: const Text('Vazgeç'),
                      ),
                    ] else if ((_factors ?? const [])
                        .any((f) => f.status == FactorStatus.verified)) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              color: AppColors.primary,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '2FA Etkin',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Hesabınız TOTP ile korunmaktadır.',
                                    style: TextStyle(
                                      fontSize: AppFontSizes.label,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._factors!
                          .where((f) => f.status == FactorStatus.verified)
                          .map(
                            (f) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: OutlinedButton.icon(
                                onPressed:
                                    _submitting ? null : () => _unenroll(f.id),
                                icon: const Icon(Icons.delete_outline,
                                    color: AppColors.error),
                                label: const Text(
                                  'İki aşamalı doğrulamayı kaldır',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ),
                            ),
                          ),
                    ] else ...[
                      const Text(
                        'Hesabınızda iki aşamalı doğrulama etkin değil. Yönetici paneline daha güvenli erişim için TOTP doğrulaması önerilir.',
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _submitting ? null : _startEnroll,
                        icon: const Icon(Icons.lock_open_rounded),
                        label: const Text('2FA\'yı Etkinleştir'),
                      ),
                    ],
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kapat'),
        ),
      ],
    );
  }
}
