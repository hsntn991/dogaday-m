import 'dart:convert';
import 'dart:io';
import 'package:dogada_gezi/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, dynamic> fixture;
  setUp(() {
    fixture = Map<String, dynamic>.from((jsonDecode(
            File('assets/data/research_photo_places.json')
                .readAsStringSync()) as List)
        .first);
  });
  test('remote approved photo records are used', () async {
    final rows = await ResearchPhotoPlaces.readRecords(
        remote: () async => [fixture], fallback: () async => []);
    expect(rows.single['id'], fixture['id']);
  });
  test('network failure preserves bundled photos', () async {
    final rows = await ResearchPhotoPlaces.readRecords(
        remote: () async => throw Exception('offline'),
        fallback: () async => [fixture]);
    expect(rows.single['name'], fixture['name']);
  });
  test('review photos cannot enter remote gallery', () async {
    final rejected = jsonDecode(jsonEncode(fixture)) as Map<String, dynamic>;
    (rejected['photos'] as List).first['confidence_level'] = 'C';
    final rows = await ResearchPhotoPlaces.readRecords(
        remote: () async => [rejected], fallback: () async => []);
    expect(rows, isEmpty);
  });
  test('empty remote dataset preserves bundled photos', () async {
    final rows = await ResearchPhotoPlaces.readRecords(
        remote: () async => [], fallback: () async => [fixture]);
    expect(rows, hasLength(1));
  });

  group('ResearchPhotoPlaces.mergePlaces duplicate behaviors', () {
    test('1. ayni sourceId -> duplicate (ikinci eklenmez)', () {
      final existing = [
        _createTestPlace(
            name: 'Yer A', latitude: 36.9, longitude: 30.7, sourceId: 'src-1'),
      ];
      final incoming = [
        _createTestPlace(
            name: 'Farkli Isim',
            latitude: 40.0,
            longitude: 40.0,
            sourceId: 'src-1'),
      ];
      final merged = ResearchPhotoPlaces.mergePlaces(
          existing: existing, incoming: incoming);
      expect(merged, hasLength(1));
      expect(merged.first.name, 'Yer A');
    });

    test('2. ayni normalize isim ve <= 750m -> duplicate', () {
      final existing = [
        _createTestPlace(
            name: 'Şelale Piknik Alanı',
            latitude: 36.900,
            longitude: 30.700,
            sourceId: 'osm-1'),
      ];
      final incoming = [
        _createTestPlace(
            name: 'selale piknik alani',
            latitude: 36.901,
            longitude: 30.701,
            sourceId: 'research-1'),
      ];
      final merged = ResearchPhotoPlaces.mergePlaces(
          existing: existing, incoming: incoming);
      expect(merged, hasLength(1));
      expect(merged.first.sourceId, 'osm-1');
    });

    test('3. ayni normalize isim ve > 750m -> iki ayri yer korunmali', () {
      final existing = [
        _createTestPlace(
            name: 'Şelale Piknik Alanı',
            latitude: 36.900,
            longitude: 30.700,
            sourceId: 'osm-1'),
      ];
      final incoming = [
        _createTestPlace(
            name: 'selale piknik alani',
            latitude: 41.000,
            longitude: 29.000,
            sourceId: 'research-2'),
      ];
      final merged = ResearchPhotoPlaces.mergePlaces(
          existing: existing, incoming: incoming);
      expect(merged, hasLength(2));
      expect(
          merged.map((p) => p.sourceId), containsAll(['osm-1', 'research-2']));
    });

    test('4. farkli isim ve ayni koordinat -> iki ayri yer korunmali', () {
      final existing = [
        _createTestPlace(
            name: 'Doğal Park',
            latitude: 36.900,
            longitude: 30.700,
            sourceId: 'osm-1'),
      ];
      final incoming = [
        _createTestPlace(
            name: 'Bambu Bahçesi',
            latitude: 36.900,
            longitude: 30.700,
            sourceId: 'research-3'),
      ];
      final merged = ResearchPhotoPlaces.mergePlaces(
          existing: existing, incoming: incoming);
      expect(merged, hasLength(2));
      expect(merged.map((p) => p.name),
          containsAll(['Doğal Park', 'Bambu Bahçesi']));
    });

    test(
        '5. arastirma listesindeki iki yeni kayit kendi aralarinda duplicate ise mevcut davranis korunmali',
        () {
      final existing = <Place>[];
      final incoming = [
        _createTestPlace(
            name: 'Gizli Koy',
            latitude: 36.500,
            longitude: 30.200,
            sourceId: 'r-1'),
        _createTestPlace(
            name: 'gizli koy',
            latitude: 36.501,
            longitude: 30.201,
            sourceId: 'r-2'),
      ];
      final merged = ResearchPhotoPlaces.mergePlaces(
          existing: existing, incoming: incoming);
      expect(merged, hasLength(1));
      expect(merged.single.sourceId, 'r-1');
    });
  });
}

Place _createTestPlace({
  required String name,
  required double latitude,
  required double longitude,
  String? sourceId,
}) {
  return Place(
    name,
    'Antalya',
    'Doğa Noktası',
    0,
    Icons.place_rounded,
    const [Color(0xFF315F45), Color(0xFF9BBF82)],
    null,
    latitude: latitude,
    longitude: longitude,
    sourceId: sourceId,
  );
}
