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
    final rawBytes = await photo.readAsBytes();
    final sanitizedBytes = stripExif(rawBytes);
    await destination.writeAsBytes(sanitizedBytes, flush: true);
    return destination.path;
  }

  /// Strips EXIF metadata (APP1/APP2 segments containing GPS/camera metadata)
  /// from JPEG images to protect user privacy.
  static Uint8List stripExif(Uint8List bytes) {
    if (bytes.length < 4 || bytes[0] != 0xFF || bytes[1] != 0xD8) {
      return bytes;
    }
    final buffer = BytesBuilder();
    buffer.add([0xFF, 0xD8]);
    var offset = 2;
    while (offset < bytes.length - 1) {
      if (bytes[offset] != 0xFF) {
        buffer.add(bytes.sublist(offset));
        break;
      }
      final marker = bytes[offset + 1];
      offset += 2;
      if (marker == 0xD8 ||
          marker == 0xD9 ||
          (marker >= 0xD0 && marker <= 0xD7)) {
        buffer.add([0xFF, marker]);
        if (marker == 0xD9) break;
        continue;
      }
      if (offset + 1 >= bytes.length) break;
      final length = (bytes[offset] << 8) | bytes[offset + 1];
      final segmentEnd = offset + length;
      if (segmentEnd > bytes.length) {
        buffer.add(bytes.sublist(offset - 2));
        break;
      }
      // 0xE1 = APP1 (EXIF / GPS / XMP), 0xE2 = APP2 (ICC profile / metadata)
      if (marker == 0xE1 || marker == 0xE2) {
        offset = segmentEnd;
        continue;
      }
      buffer.add([0xFF, marker]);
      buffer.add(bytes.sublist(offset, segmentEnd));
      if (marker == 0xDA) {
        // SOS: remaining bytes are compressed image data
        buffer.add(bytes.sublist(segmentEnd));
        break;
      }
      offset = segmentEnd;
    }
    return buffer.toBytes();
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
