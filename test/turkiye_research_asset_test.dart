import 'dart:convert';
import 'dart:io';
import 'package:dogada_gezi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Türkiye package covers 81 provinces and keeps facilities as utilities',
      () {
    final rows = jsonDecode(
            File('assets/data/turkiye_research_places.json').readAsStringSync())
        as List;
    final places = RegionalResearchPlaces.decodeRecords(rows);
    expect(places.length, rows.length);
    expect(rows.map((r) => r['province']).toSet().length, 81);
    for (var i = 0; i < rows.length; i++) {
      expect(places[i].hasCoordinates, isTrue);
      expect(
        places[i].isUtility,
        rows[i]['poi_type'] == 'utility' ||
            isUtilitySubtype(rows[i]['subtype'] as String?),
        reason:
            'Row $i: ${rows[i]['name']} (poi_type: ${rows[i]['poi_type']}, category: ${rows[i]['category']}, subtype: ${rows[i]['subtype']})',
      );
    }
    expect(places.any((p) => p.subtype == 'water_fountain'), isTrue);
    expect(places.any((p) => p.subtype == 'toilet'), isTrue);
  });

  test('keeps a safe Google photo-search link with its map point', () {
    final places = RegionalResearchPlaces.decodeRecords([
      {
        'id': 'photo-link-test',
        'name': 'Örnek Kanyon',
        'province': 'Antalya',
        'latitude': 36.9,
        'longitude': 30.7,
        'category': 'Kanyon',
        'google_photo_search_url':
            'https://www.google.com/maps/search/?api=1&query=%C3%96rnek+Kanyon',
      },
    ]);
    expect(places.single.googlePhotoSearchUrl,
        startsWith('https://www.google.com/'));
  });
}
