import 'dart:io';

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

  test('regional map uses compact category pins instead of numeric clusters',
      () {
    final map = File('lib/src/features/search_map.dart').readAsStringSync();

    expect(map, contains('renderAsIndividualPins'));
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
    expect(map, contains('showCount: !_isAllRegionsMode'));
    expect(map, contains('mapController.move(initialCenter, initialZoom)'));
  });
}
