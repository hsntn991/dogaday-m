import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('province cards are the only home cards that start a province journey',
      () {
    final home = File('lib/src/features/home.dart').readAsStringSync();

    final provinceStart = home.indexOf('class _ProvinceExplorerEntry');
    final todayStart = home.indexOf('class _TodayRecommendationsSection');
    final nearbyStart = home.indexOf('class _NearbyPlacesSection');
    final communityStart = home.indexOf('class _CommunitySuggestionsSection');

    final province = home.substring(provinceStart, todayStart);
    final today = home.substring(todayStart, communityStart);
    final nearby = home.substring(nearbyStart, home.length);

    expect(province, contains('onSelect(MapRegionFocus.forProvince'));
    expect(today, contains('widget.onOpen(recommendations[0].place)'));
    expect(today, contains('widget.onOpen(recommendations[1].place)'));
    expect(nearby, contains('onTap: () => widget.onOpen(place)'));
    expect(today, isNot(contains('MapRegionFocus.forProvince')));
    expect(nearby, isNot(contains('MapRegionFocus.forProvince')));
  });

  test('today and nearby see-all actions open the current-location map', () {
    final home = File('lib/src/features/home.dart').readAsStringSync();
    final app = File('lib/src/app/app.dart').readAsStringSync();

    expect(home, contains('onAction: widget.onExploreMap'));
    expect(app, contains('void _openNearbyPlacesOnMap()'));
    expect(app, contains('zoom: 11.5'));
  });
}
