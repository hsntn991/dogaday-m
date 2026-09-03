import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data' show Uint8List;
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/device_location.dart';
import 'services/place_image_provider.dart';
import 'services/place_photo_storage.dart';

part 'src/app/app.dart';
part 'src/core/app_core.dart';
part 'src/core/recommendation_service.dart';
part 'src/features/add_place.dart';
part 'src/features/detail.dart';
part 'src/features/favorites_profile.dart';
part 'src/features/home.dart';
part 'src/features/search_map.dart';
part 'src/widgets/shared_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lluypcdjiuyskelbwxys.supabase.co',
    anonKey: 'sb_publishable__vxa5ShMV58IaqEqfWfgAQ_6xZXlrdE',
  );
  final supabase = Supabase.instance.client;
  final testPlaces =
      await supabase.from('places').select('id').eq('city', 'Trabzon');
  debugPrint('SUPABASE TEST: ${testPlaces.length} Trabzon kaydı okundu');
  await SupabasePlacesController.load();
  await UserPlacesController.load();
  runApp(const DogaApp());
}
