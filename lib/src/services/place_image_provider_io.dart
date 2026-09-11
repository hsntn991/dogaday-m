import 'dart:io';

import 'package:flutter/widgets.dart';

ImageProvider<Object>? localPlaceImageProvider(String path) {
  if (path.trim().isEmpty) return null;
  final file = File(path);
  if (!file.existsSync()) return null;
  return FileImage(file);
}
