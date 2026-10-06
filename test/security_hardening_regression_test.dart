import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('account deletion removes moderated community-photo files', () {
    final edgeFunction = File(
      'supabase/functions/delete-account/index.ts',
    ).readAsStringSync();

    expect(edgeFunction, contains('"community-photos"'));
  });

  test('notifications cannot be changed directly by a signed-in user', () {
    final migration = File(
      'supabase/migrations/202610030004_notification_and_account_privacy.sql',
    ).readAsStringSync();

    expect(migration, contains('revoke update on public.user_notifications'));
    expect(migration, contains('drop policy if exists'));
    expect(migration, isNot(contains('grant update (read_at)')));
  });

  test('help acceptance details cannot be unlocked by a direct table write',
      () {
    final migration = File(
      'supabase/migrations/202610020004_lock_down_help_acceptances.sql',
    ).readAsStringSync();

    expect(
      migration,
      contains('revoke insert, update on public.help_request_acceptances'),
    );
    expect(migration, contains('drop policy if exists'));
  });

  test('account deletion clears locally persisted community photo records', () {
    final core = File('lib/src/core/app_core.dart').readAsStringSync();
    final profile = File(
      'lib/src/features/favorites_profile.dart',
    ).readAsStringSync();

    expect(
      core,
      matches(
        RegExp(
          r'class CommunityPlacePhotosController[\s\S]*?static Future<void> clear\(\) async',
        ),
      ),
    );
    expect(profile, contains('CommunityPlacePhotosController.clear()'));
  });
}
