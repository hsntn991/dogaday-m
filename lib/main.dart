import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data' show Uint8List;
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/foundation.dart' show compute, kIsWeb, listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/device_location.dart';
import 'services/place_image_provider.dart';
import 'services/place_photo_storage.dart';

part 'src/app/app.dart';
part 'src/app/admin_panel.dart';
part 'src/core/app_core.dart';
part 'src/core/place_taxonomy.dart';
part 'src/core/place_enrichment.dart';
part 'src/core/recommendation_service.dart';
part 'src/features/add_place.dart';
part 'src/features/detail.dart';
part 'src/features/favorites_profile.dart';
part 'src/features/home.dart';
part 'src/features/community_chat.dart';
part 'src/features/goodness_movement.dart';
part 'src/features/search_map.dart';
part 'src/widgets/shared_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lluypcdjiuyskelbwxys.supabase.co',
    publishableKey: 'sb_publishable__vxa5ShMV58IaqEqfWfgAQ_6xZXlrdE',
  );
  final isAdminRoute = kIsWeb &&
      (Uri.base.path.startsWith('/admin') ||
          Uri.base.fragment.startsWith('/admin') ||
          Uri.base.queryParameters['admin'] == 'true');
  if (isAdminRoute) {
    runApp(const DogaAdminApp());
    return;
  }

  await UserPlacesController.load();
  await AppThemeController.load();
  await OfflineMapTiles.initialize();
  runApp(const DogaApp());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(SupabasePlacesController.loadCachedAndRefresh());
    unawaited(PlaceSubmissionController.syncPending());
  });
}
