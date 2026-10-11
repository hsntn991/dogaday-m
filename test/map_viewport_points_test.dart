import 'dart:io';

import 'package:dogada_gezi/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('viewport RPC keeps primary places and nearby amenities separate', () {
    final migration = File(
      'supabase/migrations/202610040008_viewport_map_points.sql',
    ).readAsStringSync();

    expect(migration, contains('map_points_in_bbox'));
    expect(migration, contains('from public.places as place'));
    expect(migration, contains('from public.amenities as amenity'));
    expect(migration, contains('p_zoom_level >= 9'));
    expect(migration, contains('limit 200'));
    expect(migration, contains('limit 100'));
    expect(migration, contains('security definer'));
    expect(migration, contains('points.is_amenity'));
    expect(migration, isNot(contains('return query\n  select * from')));
  });

  test('map has a reversible viewport-data mode and a search-this-area action',
      () {
    final core = File('lib/src/core/app_core.dart').readAsStringSync();
    final map = File('lib/src/features/search_map.dart').readAsStringSync();

    expect(core, contains('class MapViewportPointsService'));
    expect(core, contains('static const enabled = true'));
    expect(
        core, contains('final zoomLevel = zoom.round().clamp(4, 18).toInt()'));
    expect(core, contains('static const auxiliaryMinZoom = 9.0'));
    expect(map, contains('Bu alanda ara'));
    expect(map, contains('_loadViewportPoints'));
    expect(map, contains('final markerColor = category == null'));
    expect(map, contains('isUtility: isUtilitySubtype(category)'));
    expect(map, contains("'water_amenities'"));
    expect(map, contains("'drinking_water', 'water_fountain'"));
    expect(map,
        contains('final markerSize = (isUtility ? 20.0 : 27.0) * sizeScale'));
    expect(map, contains('double _markerScaleForZoom'));
    expect(map, contains('taxonomy.subtype ?? taxonomy.mainCategory'));
    expect(map, contains(r':$layerKey'));
    expect(map, contains('final useClusterMarkers ='));
  });

  test('regional explorer starts with a clean map and keeps all-regions opt-in',
      () {
    final core = File('lib/src/core/app_core.dart').readAsStringSync();
    final map = File('lib/src/features/search_map.dart').readAsStringSync();

    expect(core, contains('static const regionalExplorerEnabled = true'));
    expect(map, contains('bool _isAllRegionsMode = false'));
    expect(map, contains('bool _hasOpenedRegion = false'));
    expect(map, contains('Bu bölgeyi aç'));
    expect(map, contains('Tüm bölgeleri aç'));
    expect(map, contains('Bölge görünümüne dön'));
    expect(map, contains('_toggleAllRegionsMode'));
  });

  test('a province selection can focus the map into a fresh regional search',
      () {
    final core = File('lib/src/core/app_core.dart').readAsStringSync();
    final map = File('lib/src/features/search_map.dart').readAsStringSync();

    expect(core, contains('class MapRegionFocusController'));
    expect(core, contains('class MapRegionFocus'));
    expect(map, contains('_onMapRegionFocusRequested'));
    expect(map, contains('MapRegionFocusController.focusedRegion'));
  });

  test('Gümüşhane always resolves to its own map centre', () {
    final region = MapRegionFocus.forProvince('Gümüşhane');

    expect(region.label, 'Gümüşhane');
    expect(region.center.latitude, closeTo(40.46, .001));
    expect(region.center.longitude, closeTo(39.48, .001));
    expect(region.zoom, greaterThanOrEqualTo(8.6));
  });

  test('a province request waits for the map surface before moving the camera',
      () {
    final map = File('lib/src/features/search_map.dart').readAsStringSync();

    expect(map, contains('MapRegionFocus? _pendingRegionFocus'));
    expect(map, contains('onMapReady: _applyPendingRegionFocus'));
    expect(map, contains('_applyRegionFocus(region)'));
  });

  test('regional map uses compact category pins instead of numeric clusters',
      () {
    final core = File('lib/src/core/app_core.dart').readAsStringSync();
    final map = File('lib/src/features/search_map.dart').readAsStringSync();

    expect(map, contains('renderAsIndividualPins'));
    expect(core, contains('static const compactPinsMinZoom = 10.5'));
    expect(map,
        contains('_mapZoom >= MapViewportPointsService.compactPinsMinZoom'));
    expect(map, contains('final useClusterMarkers = !renderAsIndividualPins'));
    expect(map,
        contains('final markerSize = (isUtility ? 20.0 : 27.0) * sizeScale'));
    expect(map, contains('double _markerScaleForZoom'));
  });

  test('map never reads a stale selected marker index after points refresh',
      () {
    final map = File('lib/src/features/search_map.dart').readAsStringSync();

    expect(map, contains('int? get validSelectedIndex'));
    expect(map, contains('Place? get selectedMapPlace'));
    expect(map, contains('final current = validSelectedIndex'));
    expect(map, contains('final currentSelection = validSelectedIndex'));
  });

  test('all-regions overview clusters the country instead of drawing every pin',
      () {
    final map = File('lib/src/features/search_map.dart').readAsStringSync();

    expect(map, contains('!_isAllRegionsMode'));
    expect(map, contains('showCount: false'));
    expect(map, contains('mapController.move(initialCenter, initialZoom)'));
  });

  test('province explorer has a city-scoped points endpoint and drilldown UI',
      () {
    final migration = File(
      'supabase/migrations/202610070001_province_explorer.sql',
    ).readAsStringSync();
    final core = File('lib/src/core/app_core.dart').readAsStringSync();
    final home = File('lib/src/features/home.dart').readAsStringSync();

    expect(migration, contains('province_explorer_points'));
    expect(migration, contains('province_explorer_summary'));
    expect(migration, contains('from public.amenities'));
    expect(migration, contains('false as is_amenity'));
    expect(core, contains('class ProvinceExplorerDataService'));
    expect(home, contains('class ProvinceExplorerScreen'));
    expect(home, contains('class ProvinceCategoryListScreen'));
    expect(
        home, contains('tileProvider: OfflineMapTiles.createTileProvider()'));
    expect(home, contains('height: isSelected ? 82 : 54'));
  });

  test('province explorer keeps water amenities distinct from primary places',
      () {
    final water = Place(
      'Çeşme',
      'Antalya',
      'Su',
      0,
      Icons.water_drop_rounded,
      AppColors.defaultGradient,
      null,
      latitude: 36.9,
      longitude: 30.7,
      subtype: 'drinking_water',
    );
    final camp = Place(
      'Kamp',
      'Antalya',
      'Kamp',
      0,
      Icons.cabin_rounded,
      AppColors.campGradient,
      null,
      latitude: 36.91,
      longitude: 30.71,
      mainCategory: 'camp',
      subtype: 'camp',
    );
    final snapshot = ProvinceExplorerSnapshot(
      city: 'Antalya',
      places: [water, camp],
      counts: const {'water_amenities': 50, 'camp': 10},
      districtCount: 2,
    );

    expect(provinceExplorerCategoryFor(water), 'water_amenities');
    expect(snapshot.countFor('camp'), 10);
    expect(snapshot.placesFor('water_amenities'), [water]);
    expect(snapshot.totalCount, 60);
  });

  test('province explorer rejects points returned from another province', () {
    final points = ProvinceExplorerDataService.decodePointsForCity(
      <Map<String, dynamic>>[
        <String, dynamic>{
          'source_kind': 'place',
          'id': 1,
          'name': 'Aydın Şelalesi',
          'latitude': 37.84,
          'longitude': 27.84,
          'city': 'Aydın',
          'district': 'Köşk',
          'main_category': 'waterfall',
          'subtype': 'waterfall',
        },
        <String, dynamic>{
          'source_kind': 'place',
          'id': 2,
          'name': 'Balıkesir Kampı',
          'latitude': 39.64,
          'longitude': 27.88,
          'city': 'Balıkesir',
          'district': 'Edremit',
          'main_category': 'camp',
          'subtype': 'camp',
        },
      ],
      'Aydın',
    );

    expect(points, hasLength(1));
    expect(points.single.name, 'Aydın Şelalesi');
    expect(points.single.location, contains('Aydın'));
  });

  test('regional map preserves cached points inside the selected viewport', () {
    final map = File('lib/src/features/search_map.dart').readAsStringSync();

    expect(map, contains('_cachedPlacesInsideViewport'));
    expect(map, contains('loaded.isEmpty'));
  });

  test('nearby places action focuses the map on the user location', () {
    final app = File('lib/src/app/app.dart').readAsStringSync();

    expect(app, contains('void _openNearbyPlacesOnMap()'));
    expect(app, contains('MapRegionFocusController.focus('));
    expect(app, contains('zoom: 11.5'));
    expect(app, contains('onExploreMap: _openNearbyPlacesOnMap'));
  });

  test('province explorer does not offer a route into the global map mode', () {
    final home = File('lib/src/features/home.dart').readAsStringSync();

    expect(home, isNot(contains('this.onOpenFullMap')));
    expect(home, isNot(contains("label: const Text('Tam harita')")));
  });
}
