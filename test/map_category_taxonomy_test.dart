import 'dart:io';

import 'package:dogada_gezi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('discovery taxonomy contains only categories backed by live places', () {
    expect(
      placeTaxonomy.map((category) => category.key),
      equals(const [
        'camp',
        'caravan',
        'lake',
        'waterfall',
        'canyon_valley',
        'cave',
        'national_park',
      ]),
    );
  });

  test('legacy place values resolve to one of the seven discovery categories',
      () {
    expect(taxonomyFromLegacy('Kamp Alanı').mainCategory, 'camp');
    expect(taxonomyFromLegacy('Karavan').mainCategory, 'caravan');
    expect(taxonomyFromLegacy('Vadi').mainCategory, 'canyon_valley');
    expect(taxonomyFromLegacy('Tabiat Parkı').mainCategory, 'national_park');
  });

  test('water tanks and similar utility infrastructure are excluded', () {
    expect(isNonNatureCandidateName('Güney Su Deposu'), isTrue);
    expect(
      isNonNatureCandidateName('Köy Deposu', subtype: 'water_tank'),
      isTrue,
    );
    expect(isNonNatureCandidateName('Abant Gölü', subtype: 'lake'), isFalse);
    expect(
      isNonNatureCandidateName('Düden Şelalesi', subtype: 'waterfall'),
      isFalse,
    );

    final validation = AddPlaceQualityService.validate(
      name: 'Köy Su Deposu',
      category: 'Kamp',
      description: 'Yolun yanında bulunan altyapı tesisidir.',
      latitude: 39.9,
      longitude: 32.8,
    );
    expect(validation.errors['name'], contains('altyapı'));
  });

  test('map no longer contains the weather layer controls', () {
    final mapSource =
        File('lib/src/features/search_map.dart').readAsStringSync();

    expect(mapSource, isNot(contains('Canlı hava katmanı')));
    expect(mapSource, isNot(contains('_weatherLayerVisible')));
    expect(mapSource, isNot(contains('MapWeatherService')));
  });
}
