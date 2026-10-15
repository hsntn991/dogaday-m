import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('selected photos have one reusable, bounded preview component', () {
    final widgets =
        File('lib/src/widgets/design_system_widgets.dart').readAsStringSync();

    expect(widgets, contains('class AppSelectedPhotoPreview'));
    expect(widgets, contains('FutureBuilder<Uint8List>'));
    expect(widgets, contains("label: 'Seçilen fotoğraf önizlemesi'"));
  });

  test('place and service photo forms show the selected image before saving',
      () {
    final detail = File('lib/src/features/detail.dart').readAsStringSync();
    final service =
        File('lib/src/features/mobile_service.dart').readAsStringSync();

    expect(detail, contains('AppSelectedPhotoPreview(photo: selectedPhoto!)'));
    expect(
        service, contains('AppSelectedPhotoPreview(photo: _selectedPhoto!)'));
  });
}
