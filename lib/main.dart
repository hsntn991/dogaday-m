import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data' show Uint8List;
import 'dart:ui' show ImageFilter, PointerDeviceKind;

import 'package:flutter/foundation.dart' show compute, kIsWeb, listEquals;
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'src/services/device_location.dart';
import 'src/services/place_image_provider.dart';
import 'src/services/place_photo_storage.dart';

part 'src/app/app.dart';
part 'src/app/admin_panel.dart';
part 'src/core/app_core.dart';
part 'src/core/app_locale.dart';
part 'src/core/place_taxonomy.dart';
part 'src/core/place_enrichment.dart';
part 'src/core/recommendation_service.dart';
part 'src/features/add_place.dart';
part 'src/features/detail.dart';
part 'src/features/emergency_help.dart';
part 'src/features/favorites_profile.dart';
part 'src/features/privacy_policy.dart';
part 'src/features/home.dart';
part 'src/features/community_chat.dart';
part 'src/features/goodness_movement.dart';
part 'src/features/search_map.dart';
part 'src/features/mobile_service.dart';
part 'src/widgets/shared_widgets.dart';
part 'src/widgets/design_system_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppStartupTimer.mark('boot');

  // Supabase başlatma — ağ yoksa veya hata varsa hata ekranı göster.
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://lluypcdjiuyskelbwxys.supabase.co',
  );
  const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable__vxa5ShMV58IaqEqfWfgAQ_6xZXlrdE',
  );

  bool supabaseOk = false;
  try {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    );
    supabaseOk = true;
  } catch (e) {
    debugPrint('[Startup] Supabase başlatma hatası: $e');
    runApp(const _AppStartupErrorApp());
    return;
  }
  AppStartupTimer.mark('supabase_ok');

  final isAdminRoute = kIsWeb &&
      (Uri.base.path.startsWith('/admin') ||
          Uri.base.fragment.startsWith('/admin') ||
          Uri.base.queryParameters['admin'] == 'true');
  if (isAdminRoute) {
    runApp(const DogaAdminApp());
    return;
  }

  await UserPlacesController.load();
  await UserReviewsController.load();
  await UserFavoritesController.load();
  await UserProfileAvatarController.load();
  await CommunityFacilityUpdatesController.load();
  await CommunityPlacePhotosController.load();
  await UserSocialAccountsController.load();
  await AppThemeController.load();
  await AppLocaleController.load();
  await HomeWeatherLocationController.load();
  await OfflineMapTiles.initialize();
  AppStartupTimer.mark('controllers_ok');

  assert(supabaseOk);
  runApp(const DogaApp());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    AppStartupTimer.mark('first_frame');
    unawaited(SupabasePlacesController.loadCachedAndRefresh());
    unawaited(PlaceSubmissionController.syncPending());
    unawaited(EmergencyHelpController.load());
  });
}
