part of '../../main.dart';

enum EmergencyHelpType { lost, vehicleStuck, vehicleNotWorking, injured }

enum EmergencyContactPreference { locationOnly, contactDetails }

enum EmergencyHelpStatus { active, resolved }

enum EmergencyHelpReportReason {
  spam,
  falseAlarm,
  inappropriate,
  resolvedAlready,
  other,
}

extension EmergencyHelpReportReasonDetails on EmergencyHelpReportReason {
  String get databaseValue => switch (this) {
        EmergencyHelpReportReason.spam => 'spam',
        EmergencyHelpReportReason.falseAlarm => 'false_alarm',
        EmergencyHelpReportReason.inappropriate => 'inappropriate',
        EmergencyHelpReportReason.resolvedAlready => 'resolved_already',
        EmergencyHelpReportReason.other => 'other',
      };

  String get label => switch (this) {
        EmergencyHelpReportReason.spam => 'Spam veya kötüye kullanım',
        EmergencyHelpReportReason.falseAlarm => 'Yanlış çağrı',
        EmergencyHelpReportReason.inappropriate => 'Uygunsuz içerik',
        EmergencyHelpReportReason.resolvedAlready =>
          'Yardım ulaştı / çağrı kapanmalı',
        EmergencyHelpReportReason.other => 'Diğer',
      };
}

extension EmergencyHelpTypeDetails on EmergencyHelpType {
  String get databaseValue => switch (this) {
        EmergencyHelpType.lost => 'lost',
        EmergencyHelpType.vehicleStuck => 'vehicle_stuck',
        EmergencyHelpType.vehicleNotWorking => 'vehicle_not_working',
        EmergencyHelpType.injured => 'injured',
      };

  String get label => switch (this) {
        EmergencyHelpType.lost => 'Kayboldum',
        EmergencyHelpType.vehicleStuck => 'Aracım çamura saplandı',
        EmergencyHelpType.vehicleNotWorking => 'Aracım çalışmıyor',
        EmergencyHelpType.injured => 'Yaralandım',
      };

  IconData get icon => switch (this) {
        EmergencyHelpType.lost => Icons.explore_off_rounded,
        EmergencyHelpType.vehicleStuck => Icons.car_crash_rounded,
        EmergencyHelpType.vehicleNotWorking =>
          Icons.directions_car_filled_rounded,
        EmergencyHelpType.injured => Icons.personal_injury_rounded,
      };

  static EmergencyHelpType fromDatabase(Object? value) => switch (value) {
        'vehicle_stuck' => EmergencyHelpType.vehicleStuck,
        'vehicle_not_working' => EmergencyHelpType.vehicleNotWorking,
        'injured' => EmergencyHelpType.injured,
        _ => EmergencyHelpType.lost,
      };
}

extension EmergencyContactPreferenceDetails on EmergencyContactPreference {
  String get databaseValue => switch (this) {
        EmergencyContactPreference.locationOnly => 'location_only',
        EmergencyContactPreference.contactDetails => 'contact_details',
      };

  String get label => switch (this) {
        EmergencyContactPreference.locationOnly => 'Yalnız konumum',
        EmergencyContactPreference.contactDetails => 'İletişim bilgilerim',
      };

  String get description => switch (this) {
        EmergencyContactPreference.locationOnly =>
          'Haritada yalnızca konumun görünür.',
        EmergencyContactPreference.contactDetails =>
          'Konumuna ek olarak yazdığın iletişim bilgisi görünür.',
      };

  static EmergencyContactPreference fromDatabase(Object? value) =>
      switch (value) {
        'contact_details' => EmergencyContactPreference.contactDetails,
        _ => EmergencyContactPreference.locationOnly,
      };
}

class EmergencyHelpDraft {
  const EmergencyHelpDraft({
    required this.type,
    required this.contactPreference,
    this.contactValue = '',
  });

  final EmergencyHelpType type;
  final EmergencyContactPreference contactPreference;
  final String contactValue;

  String? validationError({double? latitude, double? longitude}) {
    if (latitude == null || longitude == null) return 'Konumun alınamadı.';
    if (latitude.abs() > 90 || longitude.abs() > 180) {
      return 'Konum bilgisi geçerli değil.';
    }
    if (contactPreference == EmergencyContactPreference.contactDetails &&
        contactValue.trim().length < 3) {
      return 'İletişim bilgini gir veya yalnız konumumu seç.';
    }
    return null;
  }
}

class EmergencyHelpRequest {
  const EmergencyHelpRequest({
    required this.id,
    required this.requesterId,
    required this.type,
    required this.contactPreference,
    required this.contactValue,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.resolvedAt,
    this.isUnlocked = false,
  });

  final String id;
  final String requesterId;
  final EmergencyHelpType type;
  final EmergencyContactPreference contactPreference;
  final String? contactValue;
  final double latitude;
  final double longitude;
  final EmergencyHelpStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? resolvedAt;
  final bool isUnlocked;

  bool isVisibleAt(DateTime instant) =>
      status == EmergencyHelpStatus.active && expiresAt.isAfter(instant);

  bool isExpiredAt(DateTime instant) =>
      status == EmergencyHelpStatus.active && !expiresAt.isAfter(instant);

  bool get sharesContact =>
      contactPreference == EmergencyContactPreference.contactDetails &&
      (contactValue?.trim().isNotEmpty ?? false);

  LatLng get coordinate => LatLng(latitude, longitude);

  LatLng get approximateCoordinate {
    final hash = id.hashCode;
    final latOffset = ((hash % 100) - 50) * 0.00006;
    final lngOffset = (((hash ~/ 100) % 100) - 50) * 0.00006;
    return LatLng(latitude + latOffset, longitude + lngOffset);
  }

  static EmergencyHelpRequest fromJson(Map<String, dynamic> row) {
    final status = row['status']?.toString();
    final unlocked = row['is_accepted'] == true || row['is_unlocked'] == true;
    return EmergencyHelpRequest(
      id: row['id'].toString(),
      requesterId: row['requester_id'].toString(),
      type: EmergencyHelpTypeDetails.fromDatabase(row['request_type']),
      contactPreference: EmergencyContactPreferenceDetails.fromDatabase(
        row['contact_preference'],
      ),
      contactValue: row['contact_value']?.toString(),
      latitude: (row['latitude'] as num).toDouble(),
      longitude: (row['longitude'] as num).toDouble(),
      status: status == 'resolved'
          ? EmergencyHelpStatus.resolved
          : EmergencyHelpStatus.active,
      createdAt: DateTime.parse(row['created_at'].toString()).toLocal(),
      expiresAt: DateTime.parse(row['expires_at'].toString()).toLocal(),
      resolvedAt: row['resolved_at'] == null
          ? null
          : DateTime.parse(row['resolved_at'].toString()).toLocal(),
      isUnlocked: unlocked,
    );
  }
}

class EmergencyHelpController {
  EmergencyHelpController._();

  static final requests = ValueNotifier<List<EmergencyHelpRequest>>(
    const <EmergencyHelpRequest>[],
  );
  static final isLoading = ValueNotifier<bool>(false);
  static final isAvailable = ValueNotifier<bool>(true);
  static final acceptedRequestIds = ValueNotifier<Set<String>>(<String>{});

  static bool isAccepted(String id) =>
      acceptedRequestIds.value.contains(id) ||
      requests.value.any((r) => r.id == id && r.isUnlocked);

  /// Only a successful response from the server may unlock private details.
  static bool shouldUnlockFromAcceptanceResponse(Object? response) =>
      response is Map && response['success'] == true;

  static Future<bool> acceptRequest(String id) async {
    try {
      final client = Supabase.instance.client;
      final res = await client.rpc(
        'accept_help_request',
        params: {'p_request_id': id},
      );
      if (!shouldUnlockFromAcceptanceResponse(res)) return false;
      acceptedRequestIds.value = {...acceptedRequestIds.value, id};
      if (res is Map) {
        final lat = (res['latitude'] as num?)?.toDouble();
        final lon = (res['longitude'] as num?)?.toDouble();
        final contact = res['contact_value']?.toString();
        requests.value = requests.value.map((r) {
          if (r.id == id) {
            return EmergencyHelpRequest(
              id: r.id,
              requesterId: r.requesterId,
              type: r.type,
              contactPreference: r.contactPreference,
              contactValue: contact ?? r.contactValue,
              latitude: lat ?? r.latitude,
              longitude: lon ?? r.longitude,
              status: r.status,
              createdAt: r.createdAt,
              expiresAt: r.expiresAt,
              resolvedAt: r.resolvedAt,
              isUnlocked: true,
            );
          }
          return r;
        }).toList();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> reportRequest(
    String requestId,
    EmergencyHelpReportReason reason,
  ) async {
    final userId = currentUserId;
    if (userId == null) {
      throw StateError(
          'Şikâyet göndermek için önce hesabına giriş yapmalısın.');
    }
    await Supabase.instance.client.from('help_request_reports').insert({
      'request_id': requestId,
      'reporter_id': userId,
      'reason': reason.databaseValue,
    });
  }

  static Future<void> cancelAcceptance(String id) async {
    try {
      final client = Supabase.instance.client;
      await client.rpc(
        'cancel_help_request_acceptance',
        params: {'p_request_id': id},
      );
    } catch (_) {}
    acceptedRequestIds.value =
        acceptedRequestIds.value.where((x) => x != id).toSet();
    await load();
  }

  static void clearLocalData() {
    acceptedRequestIds.value = const <String>{};
  }

  static String? get currentUserId {
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  static String userFacingError(Object error) {
    final raw = error.toString();
    if (raw.contains('giriş yapmalısın')) {
      return 'Yardım çağrısı için önce hesabına giriş yapmalısın.';
    }
    if (raw.contains('row-level security') || raw.contains('42501')) {
      return 'Çağrı kaydedilemedi. Hesap oturumunu yenileyip tekrar dene.';
    }
    if (raw.contains('help_requests') && raw.contains('does not exist')) {
      return 'Yardım çağrısı altyapısı henüz hazır değil. Uygulamayı yenileyip tekrar dene.';
    }
    return raw
        .replaceFirst('Invalid argument(s): ', '')
        .replaceFirst('Bad state: ', '');
  }

  static EmergencyHelpRequest? get currentUserActiveRequest {
    final userId = currentUserId;
    if (userId == null) return null;
    final now = DateTime.now();
    for (final request in requests.value) {
      if (request.requesterId == userId && request.isVisibleAt(now)) {
        return request;
      }
    }
    return null;
  }

  static EmergencyHelpRequest? get currentUserExpiredRequest {
    final userId = currentUserId;
    if (userId == null) return null;
    final now = DateTime.now();
    for (final request in requests.value) {
      if (request.requesterId == userId && request.isExpiredAt(now)) {
        return request;
      }
    }
    return null;
  }

  static Future<void> load() async {
    // Test ortamında Supabase başlatılmamış olabilir; güvenli çık.
    late final SupabaseClient client;
    try {
      client = Supabase.instance.client;
    } catch (_) {
      return;
    }
    final userId = currentUserId;
    isLoading.value = true;
    try {
      if (userId != null) {
        try {
          final acceptances = await client
              .from('help_request_acceptances')
              .select('request_id')
              .eq('helper_id', userId)
              .eq('status', 'active');
          acceptedRequestIds.value = (acceptances as List)
              .map((r) => r['request_id']?.toString() ?? '')
              .where((id) => id.isNotEmpty)
              .toSet();
        } catch (_) {}
      }

      final now = DateTime.now().toUtc().toIso8601String();
      dynamic visible;
      try {
        visible = await client
            .from('help_requests_feed')
            .select()
            .order('created_at', ascending: false);
      } catch (_) {
        visible = await client
            .from('help_requests')
            .select()
            .eq('status', 'active')
            .gt('expires_at', now)
            .order('created_at', ascending: false);
      }

      final own = userId == null
          ? const <dynamic>[]
          : await client
              .from('help_requests')
              .select()
              .eq('requester_id', userId)
              .eq('status', 'active')
              .order('created_at', ascending: false);
      final unique = <String, EmergencyHelpRequest>{};
      for (final row in [...visible, ...own]) {
        final request = EmergencyHelpRequest.fromJson(
          Map<String, dynamic>.from(row),
        );
        unique[request.id] = request;
      }
      requests.value = unique.values.toList(growable: false);
      isAvailable.value = true;
    } catch (_) {
      // Migration henüz uygulanmadıysa mevcut uygulama işlevleri çalışmaya devam eder.
      isAvailable.value = false;
      requests.value = const <EmergencyHelpRequest>[];
    } finally {
      isLoading.value = false;
    }
  }

  static Future<EmergencyHelpRequest> create({
    required EmergencyHelpDraft draft,
    required DeviceCoordinates coordinate,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw StateError('Yardım çağrısı için giriş yapmalısın.');
    }
    final error = draft.validationError(
      latitude: coordinate.latitude,
      longitude: coordinate.longitude,
    );
    if (error != null) throw ArgumentError(error);

    // Sunucudaki RPC, süresi geçen eski çağrıyı kapatır ve yeni çağrıyı aynı
    // işlemde oluşturur. Böylece eski "aktif" satır, kullanıcıyı 48 saat
    // sonra yeni yardım isteği oluşturmaktan alıkoymaz.
    final row = await Supabase.instance.client.rpc(
      'create_help_request',
      params: <String, dynamic>{
        'p_request_type': draft.type.databaseValue,
        'p_contact_preference': draft.contactPreference.databaseValue,
        'p_contact_value':
            draft.contactPreference == EmergencyContactPreference.contactDetails
                ? draft.contactValue.trim()
                : null,
        'p_latitude': coordinate.latitude,
        'p_longitude': coordinate.longitude,
      },
    );
    final request =
        EmergencyHelpRequest.fromJson(Map<String, dynamic>.from(row));
    await load();
    return request;
  }

  static Future<void> resolve(EmergencyHelpRequest request) async {
    if (request.requesterId != currentUserId) {
      throw StateError(
          'Bu çağrıyı yalnızca yardım isteyen kişi sonlandırabilir.');
    }
    await Supabase.instance.client.from('help_requests').update({
      'status': 'resolved',
      'resolved_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', request.id);
    await load();
  }

  static Future<void> extend(EmergencyHelpRequest request) async {
    if (request.requesterId != currentUserId) {
      throw StateError('Bu çağrıyı yalnızca yardım isteyen kişi sürdürebilir.');
    }
    await Supabase.instance.client.from('help_requests').update({
      'expires_at': DateTime.now()
          .toUtc()
          .add(const Duration(hours: 48))
          .toIso8601String(),
    }).eq('id', request.id);
    await load();
  }
}

class EmergencyManualLocation {
  const EmergencyManualLocation._();

  static DeviceCoordinates? fromMapPoint(LatLng? point) {
    if (point == null ||
        point.latitude.abs() > 90 ||
        point.longitude.abs() > 180) {
      return null;
    }
    return DeviceCoordinates(
      latitude: point.latitude,
      longitude: point.longitude,
      label: 'Haritadan seçilen konum',
    );
  }
}

class EmergencyHelpRequestSheet extends StatefulWidget {
  const EmergencyHelpRequestSheet({super.key});

  static Future<EmergencyHelpRequest?> show(BuildContext context) async {
    final allowed = await AppAuthGuard.requireAuth(
      context,
      title: AppStrings.get('guest_auth_title'),
      message: AppStrings.get('guest_emergency_request_prompt'),
    );
    if (!allowed || !context.mounted) return null;

    return showModalBottomSheet<EmergencyHelpRequest>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const EmergencyHelpRequestSheet(),
    );
  }

  @override
  State<EmergencyHelpRequestSheet> createState() =>
      _EmergencyHelpRequestSheetState();
}

class _EmergencyHelpRequestSheetState extends State<EmergencyHelpRequestSheet> {
  EmergencyHelpType _type = EmergencyHelpType.lost;
  EmergencyContactPreference _contact = EmergencyContactPreference.locationOnly;
  final _contactController = TextEditingController();
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  EmergencyHelpDraft? _draftOrShowError() {
    final draft = EmergencyHelpDraft(
      type: _type,
      contactPreference: _contact,
      contactValue: _contactController.text,
    );
    if (_contact == EmergencyContactPreference.contactDetails &&
        _contactController.text.trim().length < 3) {
      setState(() {
        _errorText = 'Telefon numarası veya iletişim bilgisi gir.';
      });
      return null;
    }
    return draft;
  }

  void _showError(Object error) {
    if (!mounted) return;
    final message = EmergencyHelpController.userFacingError(error);
    setState(() => _errorText = message);
    debugPrint('Emergency help request failed: $error');
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _createRequest(
    EmergencyHelpDraft draft,
    DeviceCoordinates coordinate,
  ) async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      final request = await EmergencyHelpController.create(
        draft: draft,
        coordinate: coordinate,
      );
      if (mounted) Navigator.pop(context, request);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final draft = _draftOrShowError();
    if (draft == null) return;
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      final coordinate = await DeviceLocationService.requestCurrentPosition();
      if (!mounted) return;
      setState(() => _submitting = false);
      await _createRequest(draft, coordinate);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted && _submitting) setState(() => _submitting = false);
    }
  }

  Future<void> _chooseLocationOnMap() async {
    if (_submitting) return;
    final draft = _draftOrShowError();
    if (draft == null || !mounted) return;
    final coordinate = await Navigator.of(context).push<DeviceCoordinates>(
      MaterialPageRoute<DeviceCoordinates>(
        builder: (_) => const EmergencyLocationPickerScreen(),
      ),
    );
    if (!mounted || coordinate == null) return;
    await _createRequest(draft, coordinate);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              'Yardım iste',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: AppFontSizes.heading,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorSoftOf(context),
                borderRadius: BorderRadius.circular(AppRadii.medium),
                border: Border.all(color: AppColors.errorBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.error, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hayati tehlike veya acil sağlık durumunda uygulama içi çağrı bekleme; doğrudan 112’yi ara.',
                      style: TextStyle(
                          color: textPrimary,
                          fontSize: AppFontSizes.caption,
                          height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Neye ihtiyacın var?',
                style:
                    TextStyle(fontWeight: FontWeight.w700, color: textPrimary)),
            const SizedBox(height: 10),
            ...EmergencyHelpType.values.map((type) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _EmergencyOptionTile(
                    icon: type.icon,
                    title: type.label,
                    selected: _type == type,
                    onTap: () => setState(() => _type = type),
                  ),
                )),
            const SizedBox(height: 12),
            Text('Sana nasıl ulaşılsın?',
                style:
                    TextStyle(fontWeight: FontWeight.w700, color: textPrimary)),
            const SizedBox(height: 10),
            ...EmergencyContactPreference.values.map((preference) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _EmergencyOptionTile(
                    icon: preference == EmergencyContactPreference.locationOnly
                        ? Icons.location_on_outlined
                        : Icons.phone_outlined,
                    title: preference.label,
                    subtitle: preference.description,
                    selected: _contact == preference,
                    onTap: () => setState(() => _contact = preference),
                  ),
                )),
            if (_contact == EmergencyContactPreference.contactDetails) ...[
              const SizedBox(height: 4),
              TextField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Telefon numarası veya iletişim bilgisi',
                  hintText: 'Örn. 05XX XXX XX XX',
                  filled: true,
                  fillColor: surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                  ),
                ),
              ),
            ],
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorSoftOf(context),
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.error),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorText!,
                          style: TextStyle(
                              color: textPrimary, fontSize: AppFontSizes.label),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _submitting ? null : _chooseLocationOnMap,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Haritadan konum seç'),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Çağrın 48 saat görünür. Bu süre sonunda uygulama sana çağrıyı sürdürmek isteyip istemediğini sorar.',
              style: TextStyle(
                  color: textSecondary,
                  fontSize: AppFontSizes.caption,
                  height: 1.35),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.sos_rounded),
                label: const Text('Yardım çağrısını başlat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmergencyLocationPickerScreen extends StatefulWidget {
  const EmergencyLocationPickerScreen({super.key});

  @override
  State<EmergencyLocationPickerScreen> createState() =>
      _EmergencyLocationPickerScreenState();
}

class _EmergencyLocationPickerScreenState
    extends State<EmergencyLocationPickerScreen> {
  late final TileProvider _tileProvider = OfflineMapTiles.createTileProvider();
  LatLng? _selectedPoint;

  @override
  Widget build(BuildContext context) {
    final selected = _selectedPoint;
    return Scaffold(
      appBar: AppBar(title: const Text('Konumunu işaretle')),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(39.0, 35.2),
              initialZoom: 5.4,
              minZoom: 4,
              maxZoom: 18,
              cameraConstraint: CameraConstraint.containLatitude(),
              onTap: (_, point) => setState(() => _selectedPoint = point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.dogadagezi.dogada_gezi',
                maxNativeZoom: 19,
                tileProvider: _tileProvider,
              ),
              if (selected != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selected,
                      width: 56,
                      height: 64,
                      alignment: Alignment.bottomCenter,
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.error,
                        size: 52,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Semantics(
              liveRegion: true,
              child: Material(
                borderRadius: BorderRadius.circular(AppRadii.medium),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'Bulunduğun noktaya dokun. Bu konum yardım çağrında paylaşılır.',
                    style: TextStyle(
                      color: AppColors.textPrimaryOf(context),
                      fontSize: AppFontSizes.label,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: selected == null
                      ? null
                      : () {
                          final coordinate =
                              EmergencyManualLocation.fromMapPoint(selected);
                          if (coordinate != null) {
                            Navigator.pop(context, coordinate);
                          }
                        },
                  icon: const Icon(Icons.check_rounded),
                  label: Text(
                    selected == null
                        ? 'Haritadan bir nokta seç'
                        : 'Bu konumu kullan',
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

class _EmergencyOptionTile extends StatelessWidget {
  const _EmergencyOptionTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimaryOf(context);
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.medium),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.errorSoftOf(context)
                  : AppColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(AppRadii.medium),
              border: Border.all(
                color: selected ? AppColors.error : AppColors.borderOf(context),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: selected ? AppColors.error : textPrimary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: textPrimary)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!,
                            style: TextStyle(
                                color: AppColors.textSecondaryOf(context),
                                fontSize: AppFontSizes.caption)),
                      ],
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected
                      ? AppColors.error
                      : AppColors.textSecondaryOf(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmergencyHelpMapScreen extends StatefulWidget {
  const EmergencyHelpMapScreen({super.key, this.focusRequest});

  /// Newly created and owned calls open at their exact location instead of
  /// leaving the requester to find the marker on the Turkey-wide map.
  final EmergencyHelpRequest? focusRequest;

  @override
  State<EmergencyHelpMapScreen> createState() => _EmergencyHelpMapScreenState();
}

class _EmergencyHelpMapScreenState extends State<EmergencyHelpMapScreen> {
  final _mapController = MapController();
  late final TileProvider _tileProvider = OfflineMapTiles.createTileProvider();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    unawaited(EmergencyHelpController.load());
    final focusRequest = widget.focusRequest;
    if (focusRequest != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _mapController.move(focusRequest.coordinate, 14);
      });
    }
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(EmergencyHelpController.load()),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _confirmResolve(EmergencyHelpRequest request) async {
    final shouldResolve = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Yardım çağrısı sonlansın mı?'),
        content: const Text(
            'Çağrın haritadan kaldırılır. Yeniden yardım gerekirse yeni bir çağrı başlatabilirsin.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Vazgeç')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Çağrıyı sonlandır'),
          ),
        ],
      ),
    );
    if (shouldResolve != true || !mounted) return;
    try {
      await EmergencyHelpController.resolve(request);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }

  void _showRequest(EmergencyHelpRequest request) {
    final isMine = request.requesterId == EmergencyHelpController.currentUserId;
    final isAccepted = isMine || EmergencyHelpController.isAccepted(request.id);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(request.type.label,
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: AppFontSizes.heading,
                            fontWeight: FontWeight.w700))),
              ]),
              const SizedBox(height: 16),
              _EmergencyInfoRow(
                icon: Icons.location_on_outlined,
                text: isAccepted
                    ? '${request.latitude.toStringAsFixed(5)}, ${request.longitude.toStringAsFixed(5)}'
                    : 'Yaklaşık bölge (~300-500 m çevre)',
              ),
              const SizedBox(height: 10),
              _EmergencyInfoRow(
                icon: request.sharesContact
                    ? Icons.phone_outlined
                    : Icons.location_searching_rounded,
                text: isAccepted
                    ? (request.sharesContact
                        ? request.contactValue!.trim()
                        : 'Yalnız konum paylaşımı seçildi')
                    : (request.sharesContact
                        ? 'İletişim gizli (Yardım kabul edilince açılır)'
                        : 'Yalnız konum paylaşımı seçildi'),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emergency_rounded,
                        color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hayati tehlikede öncelikle 112 Acil Çağrı Merkezi aranmalıdır.',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: AppFontSizes.caption,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isMine
                    ? 'Çağrın aktif. Yardım ulaştığında aşağıdan sonlandır.'
                    : 'Bu çağrı uygulama içi bir yardım duyurusudur.',
                style: TextStyle(
                    color: AppColors.textSecondaryOf(sheetContext),
                    fontSize: AppFontSizes.caption,
                    height: 1.35),
              ),
              if (!isMine) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _showReportOptions(request),
                    icon: const Icon(Icons.flag_outlined, size: 17),
                    label: const Text('Şüpheli çağrıyı bildir'),
                  ),
                ),
              ],
              if (isMine) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _confirmResolve(request);
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Yardım ulaştı, çağrıyı sonlandır'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error)),
                  ),
                ),
              ] else if (!isAccepted) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final allowed = await AppAuthGuard.requireAuth(
                        sheetContext,
                        title: AppStrings.get('guest_auth_title'),
                        message:
                            AppStrings.get('guest_emergency_accept_prompt'),
                      );
                      if (!allowed) return;
                      final accepted =
                          await EmergencyHelpController.acceptRequest(
                              request.id);
                      if (!sheetContext.mounted) return;
                      if (!accepted) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Çağrı kabul edilemedi. Bağlantını kontrol edip tekrar dene.',
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(sheetContext);
                      final updated = EmergencyHelpController.requests.value
                          .firstWhere((r) => r.id == request.id,
                              orElse: () => request);
                      _showRequest(updated);
                    },
                    icon: const Icon(Icons.volunteer_activism_rounded),
                    label: const Text('Yardım Etmek İstiyorum (İletişimi Aç)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ] else if (isAccepted && request.sharesContact) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton.tonalIcon(
                    onPressed: () => _handleContactAction(
                      sheetContext,
                      request.contactValue!.trim(),
                    ),
                    icon: const Icon(Icons.phone_in_talk_rounded),
                    label: Text('İletişim: ${request.contactValue!.trim()}'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showReportOptions(EmergencyHelpRequest request) async {
    final reason = await showModalBottomSheet<EmergencyHelpReportReason>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Çağrıyı neden bildiriyorsun?',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w700,
                  fontSize: AppFontSizes.title,
                ),
              ),
              const SizedBox(height: 8),
              ...EmergencyHelpReportReason.values.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.label),
                  onTap: () => Navigator.pop(sheetContext, item),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (reason == null || !mounted) return;
    try {
      await EmergencyHelpController.reportRequest(request.id, reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bildirim alındı. İncelemeye alınacak.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bildirim gönderilemedi. Lütfen tekrar dene.')),
      );
    }
  }

  void _handleContactAction(BuildContext ctx, String raw) async {
    final cleaned = raw.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final isPhone = RegExp(r'^\+?[0-9]{7,15}$').hasMatch(cleaned);
    if (isPhone) {
      final uri = Uri(scheme: 'tel', path: cleaned);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
    }
    await Clipboard.setData(ClipboardData(text: raw));
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('İletişim bilgisi panoya kopyalandı.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            EmergencyHelpController.requests,
            EmergencyHelpController.isAvailable,
          ]),
          builder: (context, _) {
            final requests = EmergencyHelpController.requests.value;
            final visible = requests
                .where((request) => request.isVisibleAt(DateTime.now()))
                .toList();
            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(39.0, 35.2),
                    initialZoom: 5.4,
                    minZoom: 4,
                    maxZoom: 18,
                    cameraConstraint: CameraConstraint.containLatitude(),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.dogadagezi.dogada_gezi',
                      maxNativeZoom: 19,
                      tileProvider: _tileProvider,
                    ),
                    MarkerLayer(
                      markers: visible.map((request) {
                        final isOwner = request.requesterId ==
                            EmergencyHelpController.currentUserId;
                        return Marker(
                          point: isOwner
                              ? request.coordinate
                              : request.approximateCoordinate,
                          width: 64,
                          height: 72,
                          alignment: Alignment.bottomCenter,
                          child: _EmergencyMapMarker(
                              onTap: () => _showRequest(request)),
                        );
                      }).toList(growable: false),
                    ),
                  ],
                ),
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Material(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.large),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 10, 12, 10),
                      child: Row(children: [
                        IconButton(
                          tooltip: 'Geri',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Yardım çağrıları',
                                style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimaryOf(context))),
                            Text(
                                '${visible.length} aktif çağrı · Yalnız yardım çağrıları gösterilir',
                                style: TextStyle(
                                    fontSize: AppFontSizes.caption,
                                    color: AppColors.textSecondaryOf(context))),
                          ],
                        )),
                        IconButton(
                          tooltip: 'Yenile',
                          onPressed: () =>
                              unawaited(EmergencyHelpController.load()),
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ]),
                    ),
                  ),
                ),
                if (!EmergencyHelpController.isAvailable.value)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 20,
                    child: _EmergencyUnavailableNotice(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmergencyMapMarker extends StatefulWidget {
  const _EmergencyMapMarker({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_EmergencyMapMarker> createState() => _EmergencyMapMarkerState();
}

class _EmergencyMapMarkerState extends State<_EmergencyMapMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Aktif yardım çağrısı',
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Stack(
              alignment: Alignment.topCenter,
              children: [
                Opacity(
                  opacity: .30 + (_controller.value * .55),
                  child: const Icon(Icons.location_on_rounded,
                      color: AppColors.error, size: 64),
                ),
                const Icon(Icons.location_on_rounded,
                    color: AppColors.error, size: 58),
                const Positioned(
                  top: 13,
                  child: Icon(Icons.warning_amber_rounded,
                      color: Colors.white, size: 23),
                ),
              ],
            ),
          ),
        ),
      );
}

class _EmergencyInfoRow extends StatelessWidget {
  const _EmergencyInfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 20, color: AppColors.textSecondaryOf(context)),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: TextStyle(color: AppColors.textPrimaryOf(context)))),
      ]);
}

class _EmergencyUnavailableNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.errorSoftOf(context),
        borderRadius: BorderRadius.circular(AppRadii.medium),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
              'Yardım çağrıları listesi şu an yüklenemedi. Yeni çağrı oluşturmayı deneyebilirsin. Hayati acil durumdaysan 112’yi ara.',
              style: TextStyle(
                  color: AppColors.error, fontWeight: FontWeight.w600)),
        ),
      );
}
