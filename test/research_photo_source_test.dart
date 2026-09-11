import 'dart:convert';
import 'dart:io';
import 'package:dogada_gezi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, dynamic> fixture;
  setUp(() {
    fixture = Map<String, dynamic>.from((jsonDecode(File('assets/data/research_photo_places.json').readAsStringSync()) as List).first);
  });
  test('remote approved photo records are used', () async {
    final rows = await ResearchPhotoPlaces.readRecords(
      remote: () async => [fixture], fallback: () async => []);
    expect(rows.single['id'], fixture['id']);
  });
  test('network failure preserves bundled photos', () async {
    final rows = await ResearchPhotoPlaces.readRecords(
      remote: () async => throw Exception('offline'), fallback: () async => [fixture]);
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
}
