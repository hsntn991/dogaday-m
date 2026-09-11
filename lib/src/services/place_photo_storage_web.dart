import 'dart:convert';
import 'dart:typed_data';

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

  static Future<Uint8List?> readPersistedPhoto(String value) async {
    if (!value.startsWith('data:image/')) return null;
    final comma = value.indexOf(',');
    if (comma < 0) return null;
    try {
      return base64Decode(value.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }

  static String _mimeType(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }

  static Future<void> clearLocalPhotos() async {}
}
