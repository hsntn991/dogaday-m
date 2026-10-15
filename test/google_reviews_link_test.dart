import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('place details offer an external Google Maps reviews action', () {
    final detail = File('lib/src/features/detail.dart').readAsStringSync();

    expect(detail, contains('Uri googleMapsSearchUriForPlace(Place place)'));
    expect(detail, contains("'/maps/search/'"));
    expect(detail, contains("'api': '1'"));
    expect(detail, contains("Google Maps'te yorumları gör"));
    expect(detail, contains('googleMapsSearchUriForPlace(widget.place)'));
    expect(detail, contains('LaunchMode.externalApplication'));
  });
}
