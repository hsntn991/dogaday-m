import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PlacePhotoStorage {
  PlacePhotoStorage._();

  static Future<String> persistPrimaryPhoto(
    XFile photo,
    String placeId, {
    String? directoryOverride,
  }) async {
    final root = directoryOverride == null
        ? await getApplicationDocumentsDirectory()
        : Directory(directoryOverride);
    final directory =
        Directory('${root.path}${Platform.pathSeparator}place_photos');
    await directory.create(recursive: true);

    final extension = _safeExtension(photo.path);
    final safeId = placeId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final destination = File(
      '${directory.path}${Platform.pathSeparator}$safeId$extension',
    );
    await photo.saveTo(destination.path);
    return destination.path;
  }

  static Future<Uint8List?> readPersistedPhoto(String value) async {
    try {
      final file = File(value);
      if (!await file.exists()) return null;
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  static String _safeExtension(String path) {
    final fileName = path.replaceAll('\\', '/').split('/').last;
    final dot = fileName.lastIndexOf('.');
    if (dot < 0) return '.jpg';
    final extension = fileName.substring(dot).toLowerCase();
    const allowed = {'.jpg', '.jpeg', '.png', '.webp', '.heic'};
    return allowed.contains(extension) ? extension : '.jpg';
  }

  static Future<void> clearLocalPhotos() async {
    try {
      final root = await getApplicationDocumentsDirectory();
      final directory =
          Directory('${root.path}${Platform.pathSeparator}place_photos');
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } catch (_) {}
  }
}
