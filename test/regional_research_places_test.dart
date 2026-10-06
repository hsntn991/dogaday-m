import 'package:dogada_gezi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Akdeniz yayın kaydı haritada doğrulanmış yer olur', () {
    final places = RegionalResearchPlaces.decodeRecords([
      {
        'id': 'akdeniz-1',
        'name': 'Örnek Şelale',
        'province': 'Antalya',
        'latitude': 36.9,
        'longitude': 30.7,
        'main_category': 'waterfall',
        'subtype': 'waterfall',
        'description': 'Antalya sınırlarında yer alan bir şelale kaydı.',
      },
    ]);

    expect(places, hasLength(1));
    expect(places.single.name, 'Örnek Şelale');
    expect(places.single.verificationStatus, VerificationStatus.verified);
    expect(places.single.subtype, 'waterfall');
  });

  test('isimsiz genel kayıt haritaya eklenmez', () {
    final places = RegionalResearchPlaces.decodeRecords([
      {
        'id': 'generic-1',
        'name': 'Piknik Alanı',
        'province': 'Osmaniye',
        'latitude': 37.2,
        'longitude': 36.4,
        'main_category': 'national_park',
        'subtype': 'picnic_area',
      },
    ]);

    expect(places, isEmpty);
  });

  test('doğrulanmış yer, paket içi fotoğraf yolunu korur', () {
    final places = RegionalResearchPlaces.decodeRecords([
      {
        'id': 'ekotaban-1',
        'name': 'Örnek Tabiat Parkı',
        'province': 'Bolu',
        'latitude': 40.7,
        'longitude': 31.6,
        'main_category': 'national_park',
        'subtype': 'national_park',
        'image_asset': 'assets/photos/ekotaban/ornek.webp',
      },
    ]);

    expect(places.single.image, 'assets/photos/ekotaban/ornek.webp');
  });

  test('fotoğraf eşleme kaydı, yalnızca eşleşen araştırma yerine eklenir', () {
    final rows = RegionalResearchPlaces.attachBundledPhotoAssets([
      {
        'id': 'ekotaban-1',
        'name': 'Örnek Tabiat Parkı',
        'province': 'Bolu',
        'latitude': 40.7,
        'longitude': 31.6,
      },
      {
        'id': 'başka-yer',
        'name': 'Başka Yer',
        'province': 'Bolu',
        'latitude': 40.8,
        'longitude': 31.7,
      },
    ], {
      'ekotaban-1': 'assets/photos/ekotaban/ekotaban-1.jpg',
    });

    expect(rows[0]['image_asset'], 'assets/photos/ekotaban/ekotaban-1.jpg');
    expect(rows[1].containsKey('image_asset'), isFalse);
  });

  test('uzaktaki fotoğraf eşleme kaydı HTTPS görsel URLsi olarak eklenir', () {
    final rows = RegionalResearchPlaces.attachBundledPhotoAssets([
      {
        'id': 'ekotaban-1',
        'name': 'Örnek Tabiat Parkı',
        'province': 'Bolu',
        'latitude': 40.7,
        'longitude': 31.6,
      },
    ], {
      'ekotaban-1':
          'https://example.supabase.co/storage/v1/object/public/place-assets/ekotaban-1.jpg',
    });

    expect(
        rows.single['image_url'], startsWith('https://example.supabase.co/'));
    expect(rows.single.containsKey('image_asset'), isFalse);
  });

  test('sunucudaki onaylı fotoğraf URLsi yerin ana görseli olur', () {
    final places = RegionalResearchPlaces.decodeRecords([
      {
        'id': 'storage-1',
        'name': 'Sunucudaki Tabiat Parkı',
        'province': 'Bolu',
        'latitude': 40.7,
        'longitude': 31.6,
        'main_category': 'national_park',
        'subtype': 'national_park',
        'image_url':
            'https://example.supabase.co/storage/v1/object/public/place-assets/ekotaban/storage-1.jpg',
      },
    ]);

    expect(places.single.image, startsWith('https://example.supabase.co/'));
  });
}
