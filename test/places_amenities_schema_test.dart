import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('amenities are isolated from map places and exposed only by proximity',
      () {
    final migration = File(
      'supabase/migrations/202610030005_places_and_amenities_staging.sql',
    ).readAsStringSync();

    expect(migration, contains('create table if not exists public.amenities'));
    expect(migration, contains('add column if not exists clean_type text'));
    expect(migration, contains('add column if not exists parent_id bigint'));
    expect(migration,
        contains('create or replace function public.nearby_amenities'));
    expect(migration, contains('extensions.st_dwithin'));
    expect(migration, contains('extensions.st_distance'));
    expect(migration, contains('p_radius_m integer default 2000'));
    expect(migration, contains("'drinking_water', 'water_fountain', 'toilet'"));
  });

  test('place details request amenities only after the user opens nearby list',
      () {
    final core = File('lib/src/core/app_core.dart').readAsStringSync();
    final detail = File('lib/src/features/detail.dart').readAsStringSync();

    expect(core, contains('class NearbyAmenitiesService'));
    expect(core, contains("'nearby_amenities'"));
    expect(detail, contains('Yakınımda ne var?'));
    expect(detail, contains('loadNearbyAmenities'));
    expect(detail, contains('nearbyAmenitiesError'));
  });

  test('live cleanup preserves a recoverable snapshot before hiding utility rows',
      () {
    final migration = File(
      'supabase/migrations/202610030006_activate_clean_places.sql',
    ).readAsStringSync();

    expect(migration, contains('places_pre_cleanup_backup_20261003'));
    expect(migration, contains('insert into public.amenities'));
    expect(migration, contains("'drinking_water', 'water_fountain', 'toilet'"));
    expect(migration, contains('set is_active = false'));
    expect(migration, contains('extensions.st_dwithin'));
  });

  test('places cache is versioned after the live dataset cleanup', () {
    final core = File('lib/src/core/app_core.dart').readAsStringSync();

    expect(core, contains("supabase_places_cache_v2"));
  });
}
