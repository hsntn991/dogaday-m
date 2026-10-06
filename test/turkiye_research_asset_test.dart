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
    expect(places.length, 17477);
    expect(rows.map((r) => r['province']).toSet().length, 81);
    for (final place in places) {
      expect(place.hasCoordinates, isTrue);
    }
    expect(places.any((p) => isNonNatureCandidateName(p.name)), isFalse);
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

  test('EKOTABAN photo URLs point only to known research places', () {
    final places = jsonDecode(
            File('assets/data/turkiye_research_places.json').readAsStringSync())
        as List;
    final placeIds = places.map((row) => row['id']).toSet();
    final assets = jsonDecode(
            File('assets/data/ekotaban_photo_assets.json').readAsStringSync())
        as List;

    expect(assets, isNotEmpty);
    expect(assets.map((row) => row['id']).toSet().length, assets.length);
    for (final asset in assets) {
      expect(placeIds, contains(asset['id']));
      expect(asset['image_url'],
          startsWith('https://lluypcdjiuyskelbwxys.supabase.co/'));
    }
  });
}
