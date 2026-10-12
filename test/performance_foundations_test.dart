import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('startup applies a bounded image-cache policy before the first frame',
      () {
    final main = File('lib/main.dart').readAsStringSync();
    final core = File('lib/src/core/app_core.dart').readAsStringSync();

    expect(main, contains('AppImageCachePolicy.configure();'));
    expect(core, contains('abstract final class AppImageCachePolicy'));
    expect(core, contains('maximumSizeBytes'));
    expect(core, contains('maximumSize'));
  });

  test('map clustering avoids unbounded country-wide marker rendering', () {
    final map = File('lib/src/features/search_map.dart').readAsStringSync();

    expect(map, contains('targetClusterCount'));
    expect(map, contains('Timer(const Duration(milliseconds: 120)'));
    expect(map, contains('List<_MapCluster>? _clusterCache'));
    expect(map, contains('MapViewportPointsService.maxPoints'));
  });

  test('push registration is protected by a per-user device-token policy', () {
    final migration = File(
      'supabase/migrations/202610120001_device_push_tokens.sql',
    ).readAsStringSync();

    expect(migration,
        contains('create table if not exists public.device_push_tokens'));
    expect(migration, contains('auth.uid() = user_id'));
    expect(migration, contains('upsert_device_push_token'));
    expect(migration,
        contains('revoke all on public.device_push_tokens from anon'));
  });

  test('in-app notifications refresh live without exposing another user data',
      () {
    final core = File('lib/src/core/app_core.dart').readAsStringSync();
    final migration = File(
      'supabase/migrations/202610120001_device_push_tokens.sql',
    ).readAsStringSync();

    expect(core, contains('static RealtimeChannel? _channel'));
    expect(core, contains("table: 'user_notifications'"));
    expect(core, contains("column: 'user_id'"));
    expect(core, contains('callback: (_) => unawaited(load())'));
    expect(migration, contains("tablename = 'user_notifications'"));
  });

  test('app shell exposes a non-blocking offline indicator', () {
    final main = File('lib/main.dart').readAsStringSync();
    final app = File('lib/src/app/app.dart').readAsStringSync();
    final core = File('lib/src/core/app_core.dart').readAsStringSync();

    expect(main, contains('package:connectivity_plus/connectivity_plus.dart'));
    expect(main, contains('AppConnectivityController.initialize()'));
    expect(core, contains('class AppConnectivityController'));
    expect(app, contains('const AppOfflineBanner()'));
  });
}
