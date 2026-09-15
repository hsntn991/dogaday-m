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
        'main_category': 'water',
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
        'main_category': 'nature_area',
        'subtype': 'picnic_area',
      },
    ]);

    expect(places, isEmpty);
  });
}
