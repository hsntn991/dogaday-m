import 'dart:convert';

import 'package:image_picker/image_picker.dart';

class PlacePhotoStorage {
  PlacePhotoStorage._();

  static Future<String> persistPrimaryPhoto(
    XFile photo,
    String placeId, {
    String? directoryOverride,
  }) async {
    final bytes = await photo.readAsBytes();
    final mime = _mimeType(photo.name);
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  static String _mimeType(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }
}
